defmodule Examples.Advisors.CreateAndCancelPendingOrder.Advisor do
  use Tai.Advisor

  def handle_inside_quote(venue_id, product_symbol, _inside_quote, _changes, _state) do
    if Tai.Trading.NewOrderStore.count() == 0 do
      Tai.Trading.Orders.create(%Tai.Trading.OrderSubmissions.BuyLimitGtc{
        venue_id: venue_id,
        account_id: :main,
        product_symbol: product_symbol,
        price: Decimal.new("100.1"),
        qty: Decimal.new("0.1"),
        post_only: false,
        order_updated_callback: &order_updated/2
      })
    end

    :ok
  end

  def order_updated(
        %Tai.Trading.Order{status: :enqueued},
        %Tai.Trading.Order{status: :open} = open_order
      ) do
    Tai.Trading.Orders.cancel(open_order)
  end

  def order_updated(_previous_order, _updated_order), do: nil
end
