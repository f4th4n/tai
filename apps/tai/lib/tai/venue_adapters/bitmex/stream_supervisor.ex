defmodule Tai.VenueAdapters.Bitmex.StreamSupervisor do
  use Supervisor

  alias Tai.VenueAdapters.Bitmex.Stream.{
    Connection,
    ProcessAuth,
    ProcessOptionalChannels,
    ProcessOrderBook,
    RouteOrderBooks
  }

  alias Tai.Markets.OrderBook

  @type stream :: Tai.Venues.Stream.t()
  @type venue_id :: Tai.Venue.id()

  @spec start_link(stream) :: Supervisor.on_start()
  def start_link(stream) do
    name = to_name(stream.venue.id)
    Supervisor.start_link(__MODULE__, stream, name: name)
  end

  @spec to_name(venue_id) :: atom
  def to_name(venue), do: :"#{__MODULE__}_#{venue}"

  # TODO: Make this configurable. Could this come from opts?
  @endpoint "wss://#{ExBitmex.Rest.HTTPClient.domain()}/realtime"

  def init(stream) do
    venue = stream.venue
    credential = venue.credentials |> Map.to_list() |> List.first()

    children =
      []
      |> Enum.concat(
        build_order_book_children(stream.markets, venue.quote_depth, venue.broadcast_change_set)
      )
      |> Enum.concat(build_process_order_book_children(stream.markets))
      |> Enum.concat([{RouteOrderBooks, [venue_id: venue.id, order_books: stream.markets]}])

    children =
      if credential != nil do
        children ++ [{ProcessAuth, [venue: venue.id, credential: credential]}]
      else
        children
      end

    children =
      children
      |> Enum.concat([
        {ProcessOptionalChannels, [venue_id: venue.id]},
        {Connection, [endpoint: @endpoint, stream: stream, credential: credential]}
      ])

    children
    |> Supervisor.init(strategy: :one_for_one)
  end

  defp build_order_book_children(markets, quote_depth, broadcast_change_set) do
    markets
    |> Enum.map(&OrderBook.child_spec(&1, quote_depth, broadcast_change_set))
  end

  defp build_process_order_book_children(markets) do
    markets
    |> Enum.map(fn p ->
      %{
        id: ProcessOrderBook.to_name(p.venue_id, p.venue_symbol),
        start: {ProcessOrderBook, :start_link, [p]}
      }
    end)
  end
end
