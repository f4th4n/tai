defmodule Tai.Venues.Product do
  @type status ::
          :unknown
          | :pre_trading
          | :trading
          | :restricted
          | :post_trading
          | :end_of_day
          | :halt
          | :auction_match
          | :break
          | :settled
          | :delisted

  @typedoc """
  The product to buy/sell or the underlying product used to buy/sell. For the product BTCUSD

  - BTC = base asset
  - USD = quote asset
  """
  @type asset :: Tai.Markets.Asset.symbol()
  @type venue_asset :: String.t()

  @typedoc """
  The underlying value of the product. Spot products will always have a value = 1. Derivative products
  can have values > 1.

  e.g. OkEx quarterly futures product has a value of 100 where 1 contract represents $100 USD.
  """
  @type value :: Decimal.t()

  @typedoc """
  The side that the value represents
  """
  @type value_side :: :base | :quote

  @typedoc """
  Whether or not the product can be used as collateral for a portfolios balance
  """
  @type collateral :: true | false

  @typedoc """
  The ratio of balance of the quote asset that is used as collateral in the portfolio balance
  """
  @type collateral_weight :: Decimal.t() | nil

  @typedoc """
  A derivative contract where PnL settlement is a different asset to the base or quote assets.
  """
  @type quanto :: true | false

  @typedoc """
  A derivative contract where the PnL settlement is in the base asset, e.g. XBTUSD settles PnL in XBT
  """
  @type inverse :: true | false

  @typedoc """
  The expiration date
  """
  @type expiry :: DateTime.t() | nil

  @type symbol :: atom
  @type venue_symbol :: String.t()
  @type type :: :spot | :future | :swap | :option | :leveraged_token | :bvol | :ibvol | :move
  @type t :: %Tai.Venues.Product{
          venue_id: Tai.Venue.id(),
          symbol: symbol,
          venue_symbol: venue_symbol,
          alias: String.t() | nil,
          base: asset,
          quote: asset,
          venue_base: venue_asset,
          venue_quote: venue_asset,
          status: status,
          type: type,
          listing: DateTime.t() | nil,
          expiry: expiry,
          collateral: collateral,
          collateral_weight: collateral_weight,
          price_increment: Decimal.t(),
          size_increment: Decimal.t(),
          min_price: Decimal.t(),
          min_size: Decimal.t(),
          min_notional: Decimal.t() | nil,
          max_price: Decimal.t() | nil,
          max_size: Decimal.t() | nil,
          value: value,
          value_side: value_side,
          is_quanto: quanto,
          is_inverse: inverse,
          maker_fee: Decimal.t() | nil,
          taker_fee: Decimal.t() | nil,
          strike: Decimal.t() | nil,
          option_type: :call | :put | nil
        }

  @enforce_keys ~w[
    venue_id
    symbol
    venue_symbol
    base
    quote
    venue_base
    venue_quote
    status
    type
    collateral
    price_increment
    size_increment
    min_price
    min_size
    value
    value_side
    is_quanto
    is_inverse
  ]a
  defstruct ~w[
    venue_id
    symbol
    venue_symbol
    alias
    base
    quote
    venue_base
    venue_quote
    status
    type
    listing
    expiry
    collateral
    collateral_weight
    price_increment
    size_increment
    min_notional
    min_price
    min_size
    max_size
    max_price
    value
    value_side
    is_quanto
    is_inverse
    maker_fee
    taker_fee
    strike
    option_type
  ]a
end
