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

## 1.x functions the 2.0 port is still missing

`hide-if-product-in-cart` (the kit's `Nascondi se nel carrello` prop), `remove-parent`, `option1-label` …
`option3-label` and the subscription totals (`totalPrice`, `subtotalPrice`, `totalTax`, `canceledAt`) are 1.x
functions being put back into 2.0. **Annotate them normally** where the design needs them.

## Two names the kit list gets wrong

- "Load more" exists everywhere, but the value differs: on a collection grid, search & discovery and the search
  page it is `button[data-action=load]` (or `name=load`); in `smootify-metaobjects` it is
  `button[data-action=load-more]`. The kit writes `load-more` for the collection grid.
- `[subscription-group=<nome>]` is literally `[subscription-group=name]`.
