# What the glossary does not say

`glossary.json` was corrected against the 2.0 source and republished on 2026-09-29. These are the points it
does not cover — host attributes of tags, which belong to the catalogue, and a few traps. Checked against
the 2.0 source the same day.

## `button` means an element with the button tag

In the glossary, the catalogue and this skill, **`button` is only an element with the `button` tag**:
`@element: DOM @tag: button`. Webflow's Button element publishes an `<a>` and is a `link`; the Form Button
is an `<input>` and is an `input`. Every Smootify action selector is `button[...]`, so a Webflow Button with
`data-action=plus` does nothing.

The loading label: `data-wait` only changes an `<input>` value. On a `<button>`, draw the labels as children
with `data-state=default` and `data-state=loading`.

## Swatches pick their option two ways

`data-option` (1-based, default 1) **or** `data-option-name` (a comma list of names). Both are inputs: the name
wins, and a name that matches nothing removes the widget. Smootify writes `data-value` on the buttons —
never annotate that.

In `variant-dropdown` and `variant-popover` (2.0) the value template takes the same `[option]` parts as a swatch
button (`title`, `color`, `bg-color`, `image`, `description`, `price-difference`) and keeps its children; a template
with no `[option]` part still gets the value's name as its text. The current value gets `w--current` and the
unavailable ones `disabled`; in `variant-swatches` the classes are `is-active` and `is-disabled`. `variant-selector`
is a native `<select>` whose options hold text only: the price difference goes in `data-format` on the `<select>`
(`{{value}}`, `{{difference}}`), never in an `[option="price-difference"]` element. Add-ons never show it: in
`addon-swatches` a `price-difference` element stays hidden and empty.

## Also legal, and not in the glossary

- **Cart**: `[data-trigger=open|close]` (clicked by Smootify when the cart opens or closes); `data-name` on any
  field of the add-to-cart form makes it a line property (checkboxes take `data-value`).
- **Account lists** (`customer-orders`, `customer-subscriptions`): pagination `button[data-action=prev|next|load]`.
- **Metafield modifiers** (`namespace`, `data-attr`, `separator`, `data-digits`, `data-path`, `property`) work on
  every metafield family — variant, customer, company and the `if-` / `unless-` forms too.
- **Cart upsells**: `button[data-is=direct-add-to-cart]`, only inside `smootify-product[data-id=cart-upsells]`.
- **Consent**: `button[data-is=preferences-button]` anywhere, to reopen the preferences.
- `[customer-condition=has-orders]` and `has-subscriptions` resolve only when `customer-orders` /
  `customer-subscriptions` is on the page.

## Runtime facts the kit keeps needing

Checked against the 2.0 source on 2026-10-05.

- **Status pills.** `subscription=status`, `order=fulfillmentStatus`, `order=cancelReason` and
  `fulfillment=latestShipmentStatus` write the status text **and add the status as a class** on the same element,
  in camelCase: `active`, `paused`, `cancelled`, `expired`, `failed`, `stale` for subscriptions; Shopify's status
  for orders and shipments (`fulfilled`, `partiallyFulfilled`, `inTransit`, `delivered`…). Style each with a combo
  class on the pill: `@state: <class> on <pill>`. The subscription row also gets `data-status`.
- **`wishlist-toggle`.** The host gets `is-in-wishlist` (and `is-inited`), a `button` inside gets `is-active`:
  draw the heart as an SVG and style the saved state with a combo class. A Webflow Rive element inside the toggle
  also works, with `data-animation-on` / `data-animation-off` naming its two animations; `data-rive-url` is
  Webflow's own attribute, never annotated.
- **New products.** `smootify-product[data-new-days=<n>]` changes the 30 days of `condition=is-new` /
  `not-new` and of the `is-new` class.
- **No card-level pickup condition.** `condition=in-stock` is the online stock of the variant, not a shop's;
  pickup availability exists only inside `store-availability`.
- **Opening the cart.** `button[data-action=open]` (or `open-cart`) must be **inside** `smootify-cart`: the
  navbar's cart icon is a real button there (`@element: DOM @tag: button`, with an accessible label). A popover
  cart keeps its `[popover]` panel inside `smootify-cart`.
- **Line properties.** A cart line's options and properties are a `cart-item=options` template, one copy per
  option, with `option=name` and `option=value` inside; properties starting with `_` never show.
- **Bundles in the cart.** A Magic Box line lists its products with a `box-item` template; a line bundled with
  add-ons, with a `bundle-item` template. Both go inside `cart-item`, with their own `[box-item=…]` /
  `[bundle-item=…]` values.
- **The default address** has no marker in the address list: the row's `delete-address` disappears on it, and
  `customer=defaultAddress` shows it anywhere. The address form's checkbox Name is `defaultAddress`, the phone
  `phoneNumber`.
- **Sticky add to cart.** A submit button outside the form works like one inside, loading label and disabled
  state included: `@element: DOM @tag: button @attr: type=submit @attr: form=<form id>`, and the Form gets that ID
  (unique on the page: on the product page, never inside a list of cards).
- **`product-slider`** turns each item of a Webflow Collection list into a slide: the list (Products, with the
  limit you want) sits in the slider's first slide, and each item holds a `smootify-product` whose `data-id` is
  the item's Shopify ID. Lists that do not come from the CMS (related, best sellers) need no `product-slider`:
  their `smootify-product` in the first slide clones the slide.
- **Search page cards** are `smootify-product[data-id=search]`; search & discovery cards `[data-id=filter]`.
- **Predictive search results** are product cards too: inside `search-with-query`, a `smootify-product[data-id=search]`
  is the result template, with the card's own price and buttons. Prefer it to the `search-result` template with
  `search=…` bindings.

## 1.x functions that are back in 2.0

- `hide-if-product-in-cart` on `smootify-product` hides the card while the cart holds its product. It counts when
  the attribute is **present**, whatever its value: `hide-if-product-in-cart=false` hides the card too. A prop cannot
  switch it through the value: use a variant of the component with the attribute and one without, or keep it fixed.
- `remove-parent` on a `variant=option1-value` … `option3-value` element removes its parent when the variant has no
  such option (a "Size: M" row); `option1-label` … `option3-label` are aliases of `optionN-name`.
- The subscription totals (`subtotalPrice`, `totalPrice`, `totalTax`…) show the order that started the subscription.
  `subscription=canceledAt` is not read in 2.0: never annotate it.

## Two names the kit list gets wrong

- "Load more" exists everywhere, but the value differs: on a collection grid, search & discovery and the search
  page it is `button[data-action=load]` (or `name=load`); in `smootify-metaobjects` it is
  `button[data-action=load-more]`. The kit writes `load-more` for the collection grid.
- `[subscription-group=<nome>]` is literally `[subscription-group=name]`.
