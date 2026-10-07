# Smootify catalogue

GENERATO da `tools/contract-to-rules.ts`. Non modificare a mano.
Fonte: `v2/docs/markup-contract.md` §1 nel repo storefront (scritta dai sorgenti 2.0) · rigenerato il 2026-10-07.

Serve ad annotare i layer Figma: dice quale tag mettere in `@tag`, dentro cosa deve stare, cosa deve
contenere e quali attributi sono leciti in `@attr`.

## Come si annota un elemento Smootify

```
@tag: smootify-product @prop: string Product ID @bind: attr:data-id = Product ID
```

Ogni tag qui sotto è un custom tag: `@tag` basta, `@element` non si scrive (il suo valore,
`BY_CUSTOM_TAG`, contiene un underscore e arriverebbe come `BY\_CUSTOM\_TAG`). Il formato completo è in
`annotation-format.md`. Mai `data_whtml_builder`: cancella i tag custom e gli attributi non `data-*`.
Le righe con un selettore (`smootify-product[data-id="wishlist"]`, `[policy]`) sono un tag o un elemento
qualsiasi con quell'attributo.

**Per i valori degli attributi vale il glossario** (`glossary.json` + `glossary-errata.md`): dice su che
tipo di elemento va ogni valore e quali valori ripetono l'elemento. La sezione "Valori leciti" qui sotto
è solo l'elenco dei nomi.

## Elementi (88)

"Dentro" è vincolante: uno di quei contenitori deve essere un antenato. "Fuori contesto" dice cosa succede
se non c'è: si rimuove dalla pagina, resta inerte o dà errore.

| Tag | Cosa fa | Dentro | Deve contenere | Fuori contesto | Richiede | Attributi host |
|---|---|---|---|---|---|---|
| `[policy]` | Writes a shop policy body, in the page language, into the element. | ovunque | — | si rimuove | — | `policy` |
| `[popover][data-is="market-dialog"]` | Suggests the visitor's market once per browser, opening after a delay and after the cookie banner closes. | ovunque | — | resta inerte | — | `disable-blur`, `animation-name`, `animation-duration`, `delay` |
| `[wishlist="count"]` | Shows how many items the wishlist holds (products and variants); on a wishlist page opened from a shared link, how many the shared list holds. | ovunque | — | resta inerte | "Wishlist" | `wishlist` |
| `addon-checkbox` | Checkbox that adds the nested product as an add-on. The fields of every add-on widget can carry any Name (Webflow needs one). From mount they are named ##ignore-addon, which stays out of the cart line. Once the nested product loads, the checkbox becomes #addon|variantId|type|title|price, the quantity #quantity|variantId and the select #addon|SELECT|… (2.0). | `smootify-add-to-cart smootify-product`; non in `.w-condition-invisible` | `input[type="checkbox"]` | si rimuove | — | `addon-type`, `id` |
| `addon-dropdown` | Webflow dropdown listing the nested product's variants as add-ons. | `smootify-add-to-cart smootify-product`; non in `.w-condition-invisible` | `.w-dropdown`, `.w-dropdown-link` | si rimuove | — | `addon-type`, `show-price`, `allow-unselect`, `id` |
| `addon-popover` | Popover listing the nested product's variants as add-ons. | `smootify-add-to-cart smootify-product`; non in `.w-condition-invisible` | uno fra `[popover] a`, `[popover] button:not([popovertarget])` | si rimuove | — | `addon-type`, `show-price`, `allow-unselect`, `id` |
| `addon-select` | Select whose options are the nested product's variants as add-ons. | `smootify-add-to-cart smootify-product`; non in `.w-condition-invisible` | `select` | si rimuove | — | `addon-type`, `id` |
| `addon-swatches` | One button per value or variant of the nested product as add-ons. | `smootify-add-to-cart smootify-product`; non in `.w-condition-invisible` | `button:not([popovertarget])` | si rimuove | — | `addon-type`, `allow-unselect`, `id` |
| `box-item` | One line of the box, cloned from the first box-item for each picked item. | `smootify-magic-box-cart` o `cart-item` | — | resta inerte | "Magic Box" | `data-hash` |
| `button[data-is="direct-add-to-cart"]` | Button that adds the product's current variant to the cart without a form. | `smootify-product` | — | si rimuove | — | `data-is` |
| `button[data-is="preferences-button"]` | Opens the preferences panel of the page's cookie banner. | ovunque | — | si rimuove | — | `data-is` |
| `country-switcher` | Lists the market's countries in a Webflow dropdown or a popover and changes country on a pick; when Shopify has a language with the country's ISO code (IT → Italian) it changes language too. With Webflow Localization (a Webflow locale switcher, or the page's hreflang alternate links) the language goes through Webflow: the page moves to that language's locale (it-IT before it when the site has both), and without a locale for that language only the country changes. | ovunque | uno fra `.w-dropdown .w-dropdown-link`, `[popover] :is(a, button:not([popovertarget]))` | si rimuove | — | — |
| `create-address` | Form that creates an address, with country and zone selects filled from the shop. | ovunque | `form`, `select[name="countryCode"]`, `select[name="zoneCode"]` | si rimuove | Customer Accounts | — |
| `customer-addresses` | Lists the customer's addresses, one row per address, with edit and delete forms armed. | ovunque | `customer-address` | si rimuove | Customer Accounts | — |
| `customer-metafields-editor` | Form that prefills and saves the customer's custom metafields. | ovunque | `form` | si rimuove | Customer Accounts | — |
| `customer-orders` | Paged list of the customer's orders, one row per order. | ovunque | `customer-order` | si rimuove | Customer Accounts | `limit` |
| `customer-subscribe-email` | Form that subscribes the customer to email marketing. | ovunque | `form` | si rimuove | Customer Accounts | — |
| `customer-subscriptions` | Paged list of the customer's subscription contracts, one row per contract. | ovunque | `customer-subscription` | si rimuove | Customer Accounts | `limit` |
| `customer-unsubscribe-email` | Form that unsubscribes the customer from email marketing. | ovunque | `form` | si rimuove | Customer Accounts | — |
| `customer-user-update` | Form that prefills and saves the customer's first and last name. | ovunque | `form`, `input[name="firstName"]`, `input[name="lastName"]` | si rimuove | Customer Accounts | — |
| `delete-address` | Form that deletes the address of its row and removes the row. | `customer-address` | `form` | si rimuove | Customer Accounts | — |
| `dynamic-property` | Form control configured by the product's property metaobject with the same label. | `smootify-product` | uno fra `input`, `select`, `button`, `.w-dropdown`, `[popover]` | si rimuove | — | `label`, `delete-parent` |
| `dynamic-swiper` | CMS items become Swiper slides, then Swiper starts with the params of an inner JSON script. | ovunque | `swiper-container` | si rimuove | — | — |
| `edit-address` | Form that edits the address of its row, prefilled by the address list. | `customer-address` | `form`, `select[name="countryCode"]`, `select[name="zoneCode"]` | si rimuove | Customer Accounts | — |
| `filter-checkbox` | Multi-choice facet: one checkbox label per facet value. | `smootify-search-discovery` | `form`, `label` | si rimuove | "Search & discovery" | `label`, `custom-label`, `selected-value`, `allow-reset`, `show-count`, `hide-parenthesis` |
| `filter-dropdown` | Single-choice facet in a Webflow Dropdown; the toggle text shows the current value. | `smootify-search-discovery` | `form`, `.w-dropdown .w-dropdown-link` | si rimuove | "Search & discovery" | `label`, `custom-label`, `selected-value`, `allow-reset`, `show-count`, `hide-parenthesis` |
| `filter-list` | Single-choice facet: one radio label per facet value. | `smootify-search-discovery` | `form`, `label` | si rimuove | "Search & discovery" | `label`, `custom-label`, `selected-value`, `allow-reset`, `show-count`, `hide-parenthesis` |
| `filter-popover` | Single-choice facet in a popover; the trigger shows the current value, a pick closes it. | `smootify-search-discovery` | `form`, `[popover] :is(a, button:not([popovertarget]))` | si rimuove | "Search & discovery" | `label`, `custom-label`, `selected-value`, `allow-reset`, `show-count`, `hide-parenthesis` |
| `filter-price` | Price range facet with two number inputs, two range handles and a progress bar. | `smootify-search-discovery` | `form`, `form input[type="number"]`, `form input[type="range"]`, `[filter-price="progress"]` | si rimuove | "Search & discovery" | `custom-label`, `selected-value`, `allow-reset`, `show-count`, `hide-parenthesis` |
| `filter-search` | Free-text query of the block; typing or submitting sets the search query, also in a collection (data-collection). | `smootify-search-discovery` | `form` | si rimuove | "Search & discovery" | — |
| `filter-select` | Single-choice facet in a native select; the first option is the placeholder. | `smootify-search-discovery` | `form`, `select` | si rimuove | "Search & discovery" | `label`, `custom-label`, `selected-value`, `allow-reset`, `show-count`, `hide-parenthesis` |
| `filter-swatches` | Facet as swatch buttons painted from the value's native swatch; a click toggles the value. | `smootify-search-discovery` | `form`, `button` | si rimuove | "Search & discovery" | `label`, `custom-label`, `selected-value`, `allow-reset`, `show-count`, `hide-parenthesis`, `multiple` |
| `free-shipping-bar` | Shows the progress towards free shipping from the cart. | ovunque | — | resta inerte | — | `data-amount`, `data-quantity` |
| `judge-me-reviews` | Judge.me reviews widget for the product. | `smootify-product` | — | si rimuove | — | — |
| `judge-me-stars` | Judge.me stars badge for the product. | `smootify-product` | — | si rimuove | — | — |
| `klaviyo-back-in-stock` | Klaviyo back-in-stock form, in a dialog or popover, for the current variant. | `smootify-product` | `form`, `button[type="button"]`, uno fra `dialog`, `[popover]` | si rimuove | — | `data-company-id` |
| `location-switcher` | Lists the shop's pickup locations in a Webflow dropdown or a popover and changes location on a pick. | ovunque | uno fra `.w-dropdown .w-dropdown-link`, `[popover] :is(a, button:not([popovertarget]))` | si rimuove | — | — |
| `logout-form` | Clears the customer session and follows Shopify's logout url when there is one. | ovunque | `form` | si rimuove | — | — |
| `modal-backdrop` | Backdrop and animated panel of a <details> modal. | `details` | — | resta inerte | — | — |
| `order-page` | Renders the single order named in the page url. | ovunque | — | resta inerte | Customer Accounts | — |
| `passwordless-login` | Starts the Customer Accounts login when its form is submitted. | ovunque | `form` | si rimuove | Customer Accounts | — |
| `print-button` | Prints the printable-element its target names. | ovunque | — | si rimuove | — | `data-target` |
| `printable-element` | A region that a print-button prints alone. | ovunque | — | resta inerte | — | `id` |
| `product-slider` | At boot, each CMS item with a product card becomes a slide of a Webflow slider or Swiper. | ovunque | `.w-dyn-item smootify-product`, uno fra `.w-slider-mask .w-slide`, `swiper-container swiper-slide` | resta inerte | — | — |
| `quantity-input` | Number input with plus and minus buttons for a quantity. | `smootify-product` o `cart-item` | `input` | si rimuove | — | `data-disable-max` |
| `smootify-account-component` | Embeds Shopify's account web component (login menu) while the visitor is logged out. | ovunque | — | si rimuove | Customer Accounts | — |
| `smootify-add-to-cart` | Product form that turns the selection into cart lines. | `smootify-product` | `form` | si rimuove | — | `use-magic-box`, `box-title`, `box-image`, `single-addon-swatch`, `allow-unavailable`, `avoid-option-update` |
| `smootify-cart` | Renders the cart and opens or closes it as a mini cart. | ovunque | — | resta inerte | — | `data-open`, `data-draft` |
| `smootify-consent` | Cookie banner and preferences panel built in Webflow over Shopify's Customer Privacy API. | ovunque | — | resta inerte | — | — |
| `smootify-magic-box` | Build-a-box: the add-to-cart forms inside it add to the box instead of the cart. | ovunque | `smootify-magic-box-cart` | si rimuove | "Magic Box" | `data-handle`, `data-title`, `data-image`, `data-min`, `data-max`, `data-step`, `data-unique`, `data-unique-per-category`, `data-all-categories`, `data-auto-remove-category`, `data-only-one`, `data-only-one-per-category`, `data-full-error`, `data-too-many-error` |
| `smootify-magic-box-cart` | Box panel: picked items, counters, totals and the form that adds the whole box to the cart. | `smootify-magic-box` | `form`, `box-item` | si rimuove | "Magic Box" | `data-buy-now` |
| `smootify-metaobject` | One metaobject, written into its [metaobject] descendants. With data-handle-param the handle comes from that parameter of the page url (data-handle-param="l" on /list?l=giulia-birthday: a link to one entry, such as one a metaobject-creator form created), before data-id and data-handle, which stay the fallback; the handle only goes to the query, never into the page. Without the parameter (and no fallback) or with an unknown handle the element is removed like any not found: a message next to it can show with :has() (.list:not(:has(smootify-metaobject)) .not-found). | ovunque | — | si rimuove | — | `data-id`, `data-handle`, `data-handle-param`, `data-type` |
| `smootify-metaobjects` | Paged list of the metaobjects of a type, or of a product metafield. | ovunque | `smootify-metaobject` | si rimuove | — | `data-type`, `data-limit`, `data-product-id` |
| `smootify-price` | Writes the price, compare-at price and total of its scope into its children. | `smootify-product` o `smootify-variant` o `smootify-magic-box-cart` o `box-item` | — | resta inerte | — | `no-quantity`, `data-ignore`, `data-remove`, `data-replace`, `skeleton` |
| `smootify-product` | Loads a Shopify product into a scope and binds its descendants. | ovunque | — | si rimuove | — | `data-id`, `data-parent-id`, `limit`, `data-query`, `data-sort`, `data-collection-handle`, `data-repeat`, `hide-if-product-in-cart`, `data-new-days`, `skeleton` |
| `smootify-product[data-id="cart-complementary"]` | Card template repeated with the complementary products of the latest cart line. | ovunque | — | resta inerte | "Cart Upsell" | `data-id`, `limit` |
| `smootify-product[data-id="cart-related"]` | Card template repeated with the related products of the latest cart line. | ovunque | — | resta inerte | "Cart Upsell" | `data-id`, `limit` |
| `smootify-product[data-id="cart-upsell"]` | Alias of the cart-upsells card template (complementary and related). | ovunque | — | resta inerte | "Cart Upsell" | `data-id`, `limit` |
| `smootify-product[data-id="cart-upsells"]` | Card template repeated with the complementary and related products of the latest cart line. | ovunque | — | resta inerte | "Cart Upsell" | `data-id`, `limit` |
| `smootify-product[data-id="last-viewed"]` | Card template repeated once per recently viewed product (the first one in the page). | ovunque | — | resta inerte | "Last Viewed" | `data-id`, `limit` |
| `smootify-product[data-id="loader"]` | Design placeholder card (CMS lists for SEO and no layout shift): a product source in the same slider fills the n-th one, which then loads that product; search & discovery and the search page replace the list's cards with their first results. | `.w-slider` o `dynamic-swiper` o `smootify-search-discovery` o `smootify-search-page` | — | resta inerte | — | `data-id` |
| `smootify-product[data-id="wishlist"]` | Card template repeated once per saved product (the first one in the page); without a smootify-variant[data-product-id="wishlist"] also once per saved variant, as its product's card on that variant. A page opened from a wishlist-share link (?w=) shows that list instead of the visitor's, with body.is-shared-wishlist. | ovunque | — | resta inerte | "Wishlist" | `data-id` |
| `smootify-search` | Predictive search: products and query suggestions as the customer types, in a Webflow Dropdown or a popover. | ovunque | `input[name="query"]` | resta inerte | "Predictive Search" | `limit` |
| `smootify-search-discovery` | Faceted product list: runs the search, renders the cards, active chips, count and pagination, and hosts the filter and sort widgets. | ovunque | `smootify-product` | si rimuove | "Search & discovery" | `data-wait`, `limit`, `auto-close-details`, `disable-scroll`, `disable-scroll-on-load-more`, `avoid-webflow-restart`, `hide-empty`, `hide-if-single`, `sync-query-params`, `page-range`, `animation`, `easing`, `duration`, `stagger`, `data-expand`, `data-collection`, `data-vendor`, `data-tag`, `unavailable-products`, `body`, `menu` |
| `smootify-search-page` | Full search results page driven by the query in the url or its text inputs, with count and pagination. | ovunque | `smootify-product` | si rimuove | "Search" | `data-wait`, `limit`, `disable-scroll`, `disable-scroll-on-load-more`, `auto-close-details`, `avoid-webflow-restart`, `page-range`, `animation`, `easing`, `duration`, `stagger`, `unavailable-products` |
| `smootify-shop-pay` | Shows Shopify's Shop Pay button for the current variant or the cart lines. | `smootify-product` o `smootify-cart` | — | resta inerte | — | — |
| `smootify-variant` | Repeats its block once per variant of a product. | ovunque | — | resta inerte | — | `data-product-id`, `unique-by` |
| `smootify-variant[data-product-id="wishlist"]` | Variant card template (its .w-dyn-item, else itself) repeated once per saved variant (the first one in the page), with the smootify-variant markup; without a smootify-product[data-id="wishlist"] also once per saved product, as the card of its first available variant. | ovunque | — | resta inerte | "Wishlist" | `data-product-id` |
| `sort-dropdown` | Sort options in a Webflow Dropdown; toggle text and data-selected show the current sort. | `smootify-search-discovery` | `form`, `.w-dropdown .w-dropdown-link` | si rimuove | "Search & discovery" | `selected-value` |
| `sort-popover` | Sort options in a popover; the trigger shows the current sort, a pick closes it. | `smootify-search-discovery` | `form`, `[popover] :is(a, button:not([popovertarget]))` | si rimuove | "Search & discovery" | `selected-value` |
| `sort-radio` | Sort options as one radio label each. | `smootify-search-discovery` | `form`, `label` | si rimuove | "Search & discovery" | `selected-value` |
| `sort-select` | Sort options in a native select; the first option is the placeholder. | `smootify-search-discovery` | `form`, `select` | si rimuove | "Search & discovery" | `selected-value` |
| `store-availability` | Shows pickup availability of the current variant, with an optional list of locations. | `smootify-product` | — | si rimuove | — | `disable-blur`, `animation-name`, `animation-duration` |
| `store-credit` | Shows the customer's store credit balance and transactions. | ovunque | — | si rimuove | Customer Accounts | — |
| `store-locator` | Shopify pickup locations on a Mapbox map, with a list filtered by a query field. | ovunque | `map` | si rimuove | "Store Locator" | `data-api-key`, `data-style`, `data-zoom`, `data-initial-zoom`, `data-fit-bounds`, `data-padding` |
| `subscription-activate` | Form that resumes the paused contract of its wrapper and reloads the page. | `customer-subscription` o `subscription-page` | `form` | si rimuove | Customer Accounts | — |
| `subscription-cancel` | Form that cancels the contract of its wrapper and reloads the page. | `customer-subscription` o `subscription-page` | `form` | si rimuove | Customer Accounts | — |
| `subscription-page` | Renders the single subscription contract named in the page url. | ovunque | — | resta inerte | Customer Accounts | — |
| `subscription-pause` | Form that pauses the active contract of its wrapper and reloads the page. | `customer-subscription` o `subscription-page` | `form` | si rimuove | Customer Accounts | — |
| `subscription-swatches` | Webflow tabs and radios that choose a selling plan. | `smootify-product` | `.w-tabs`, `.w-tab-link`, `.w-tab-pane` | si rimuove | — | `auto-select-plan`, `auto-select-index`, `data-selected-group`, `data-selected-option-index` |
| `urgent-cart-countdown` | Counts down a cart reservation and empties the cart when it ends. | ovunque | — | resta inerte | — | `data-time`, `data-on-end`, `data-redirect-to` |
| `variant-dropdown` | Webflow dropdown whose links are the values of a product option. | `smootify-product`; non in `.w-condition-invisible` | `.w-dropdown`, `.w-dropdown-link` | si rimuove | — | `data-option`, `data-option-name`, `avoid-option-update` |
| `variant-popover` | Popover whose links or buttons are the values of a product option. | `smootify-product`; non in `.w-condition-invisible` | uno fra `[popover] a`, `[popover] button:not([popovertarget])` | si rimuove | — | `data-option`, `data-option-name`, `avoid-option-update` |
| `variant-selector` | Native select whose options are the values of a product option. | `smootify-product`; non in `.w-condition-invisible` | `select` | si rimuove | — | `data-option`, `data-option-name` |
| `variant-swatches` | One button per value of a product option. | `smootify-product`; non in `.w-condition-invisible` | `button:not([popovertarget])` | si rimuove | — | `data-option`, `data-option-name` |
| `webflow-form` | Generic Webflow form wrapper with success state and redirect, no request behind it. | ovunque | `form` | si rimuove | — | — |
| `wishlist-share` | Shares a link to the wishlist page (data-page, else this page) that shows the visitor's saved products and variants to whoever opens it, no account needed (?w=: numbers for products, v + number for variants, at most 100, only ids read): the device's share sheet where there is one, else the link is copied (data-copy: always copied). On the shared page the toggles keep working on the visitor's own list. | ovunque | — | resta inerte | "Wishlist" | `data-page`, `data-copy`, `data-title` |
| `wishlist-toggle` | Adds or removes the product, or its current variant (data-use-variants), from the wishlist; inside a card of the wishlist page it works on the entry the card shows, product or variant. | `smootify-product` o `smootify-variant[data-product-id="wishlist"]` | — | si rimuove | "Wishlist" | `data-use-variants`, `data-animation-on`, `data-animation-off` |

## Elementi del piano `server` (17)

Presenti solo con il piano `server` (e l'estensione accesa); senza, vengono rimossi dalla pagina.

| Tag | Cosa fa | Dentro | Deve contenere | Fuori contesto | Richiede | Attributi host |
|---|---|---|---|---|---|---|
| `booking-calendar` | Shows the slots of a bookable product (its Booking schedule, set in the Shopify admin) for days days, the places left of each, the day in the site's language and the time in the place's time zone; picking a free slot books it as its container says. In a booking-form: the form books it. In a product's add to cart: adding the product holds the slot for the quantity and writes it on the product's lines (a paid appointment); no slot or a full one stops the addition with the message. In the cart: the slot is held when picked and written on the cart (a pickup or delivery window); a slot taken by someone else meanwhile is refused at checkout, and with data-required the checkout stops until a slot is picked. The places are counted by Smootify: two visitors cannot book the last one. The availability is kept a minute, so pages opened again ask nothing. | `booking-form` o `smootify-add-to-cart` o `smootify-product` o `smootify-cart` | `[booking="day"] [booking="slot"]` | si rimuove | piano server + "Booking" | `data-product-id`, `days`, `property`, `data-required`, `data-error-required` |
| `booking-form` | Books the slot picked in its booking-calendar without a cart (an appointment): the booking, with the form's name, email, phone and note fields and the logged-in customer, is saved in the store's Bookings (Shopify admin → Content → Metaobjects) and shown on the product's Smootify booking block. Webflow's success and error states show the answer; a slot that filled up meanwhile is the form error and the calendar shows its places again. | ovunque | `booking-calendar`, `form` | si rimuove | piano server + "Booking" | — |
| `configurator-checkbox` | Checkbox whose formula step is on while checked. | `smootify-add-to-cart` | `input[type="checkbox"]` | si rimuove | piano server + "Product configurator" | `data-formula` |
| `configurator-dimension` | Number inputs named after formula variables; the step is on when all hold valid numbers. | `smootify-add-to-cart` | `input[type="number"]` | si rimuove | piano server + "Product configurator" | `data-formula` |
| `configurator-dropdown` | Webflow dropdown over a hidden select whose chosen option carries the formula step. | `smootify-add-to-cart` | `select`, `.w-dropdown .w-dropdown-link` | si rimuove | piano server + "Product configurator" | `data-formula` |
| `configurator-field` | Groups configurator fields; has no effect of its own. Every configurator field counts the value it already has when it mounts (typed before the configurator loaded, restored by the browser on Back, a default value / checked / selected), as the add to cart sends it (v2/src/components/server-extensions/configurator/configurator-field.ts:35). | `smootify-add-to-cart` | — | si rimuove | piano server + "Product configurator" | `data-formula` |
| `configurator-file-input` | File uploader that is also a formula step, with the number of files as variable. | `smootify-add-to-cart` | — | si rimuove | piano server + "Product configurator" | `data-formula`, `name`, `data-multiple`, `data-required`, `data-preview`, `data-only-images`, `min-file-size`, `max-file-size`, `min-resolution`, `data-error-<code>` |
| `configurator-input` | Text input whose formula step is on while its value is valid, with its length as variable. | `smootify-add-to-cart` | uno fra `input`, `textarea` | si rimuove | piano server + "Product configurator" | `data-formula` |
| `configurator-popover` | The configurator dropdown with its options in a popover. | `smootify-add-to-cart` | `select`, `[popover] :is(a, button:not([popovertarget]))` | si rimuove | piano server + "Product configurator" | `data-formula` |
| `configurator-radio` | Radios whose checked option carries the formula step. | `smootify-add-to-cart` | `input[type="radio"]` | si rimuove | piano server + "Product configurator" | `data-formula` |
| `configurator-select` | Select whose chosen option carries the formula step. | `smootify-add-to-cart` | `select` | si rimuove | piano server + "Product configurator" | `data-formula` |
| `configurator-share` | Shares a link to this page with the visitor's configuration: one url parameter per configurator field, named as its control (name: ?Engraving=abc&Finish=gloss&width=120), plus ?variant= when the product has more than one. A page opened from such a link starts every configurator field from its parameter, applied as a visitor would (the same input / change, so a value the field refuses stays off: below min, an option the select does not have; text cut at maxlength), and the price follows; names the page does not have are ignored, and a file stays out of the link (uploaded again). The device's share sheet where there is one, else the link is copied (data-copy: always copied). | `smootify-add-to-cart` | — | si rimuove | piano server + "Product configurator" | `data-copy`, `data-title` |
| `file-input` | Uploads files to Shopify and submits their gids as one form field. | `metaobject-creator` o `customer-metafields-editor` o `smootify-cart` | — | resta inerte | piano server | `name`, `value`, `data-multiple`, `data-required`, `data-preview`, `data-only-images`, `min-file-size`, `max-file-size`, `min-resolution`, `data-error-<code>` |
| `file-uploader` | Uploads files to Shopify and adds their names, gids and admin links to the cart line. | `smootify-add-to-cart` o `dynamic-property` | — | resta inerte | piano server + "Product File Upload" | `name`, `data-multiple`, `data-required`, `data-preview`, `data-only-images`, `min-file-size`, `max-file-size`, `min-resolution`, `data-error-<code>` |
| `metaobject-creator` | Creates a metaobject from a Webflow form: every filled field whose name does not start with _; a name the form repeats (a checkbox group with each checkbox's value, a multiple select) sends all its values; a lone checkbox sends true / false. The backend converts each value to its field type: rating from a number (the field's scale), list.* from repeated values, a comma separated text or a JSON array, boolean, number_decimal with a comma, url without https://, references from a numeric id, rich_text_field from lines (one paragraph each), money in the shop currency, date_time from datetime-local, dimension / volume / weight from "2.5 cm" (a select data-unit-for="<name>" gives the unit of that field, its own name is not sent); a value already in Shopify's format passes as it is. A definition without the publishable capability gets no status (data-draft is ignored there). The backend refuses Shopify's standard types (shopify--…), the app-reserved ones ($app:…) and Smootify's own (magic_box, combinations, dynamic_property, option), with the form error "This form cannot create entries of this metaobject type". customer-field="<key>": the entry belongs to the logged-in customer, written by the backend into that field (a customer reference) from the Customer Account token, never from the form; logged out the element is hidden and its form inert (is-customer while logged in), and a request without a valid token is refused ("Log in to send this form"). | ovunque | `form` | si rimuove | piano server + "Metaobject creator" | `data-type`, `data-draft`, `customer-field` |
| `name-your-price` | Lets the customer type the unit price the product is added at. | `smootify-add-to-cart` | `input[type="number"]` | si rimuove | piano server + "Name your price" | `data-invalid-price` |
| `newsletter-subscribe` | Subscribes the email of a Webflow form to the newsletter. | ovunque | `form input[type="email"]` | si rimuove | piano server + "Newsletter Subscription" | `tags` |

## Tag marker (46)

Non sono custom element registrati: sono **template** che l'elemento che li legge clona o riempie. Si
annotano come gli altri, con il solo `@tag`.

- `[box-category]` — Attribute form of smootify-box-category. (dentro `smootify-magic-box`; letto da `smootify-magic-box`)
- `[consent-condition="sale-of-data"]` — Shown only in sale-of-data regions (CSS only). (dentro `smootify-consent`; letto da `smootify-consent`)
- `[consent-panel="banner"]` — Hidden while the preferences panel is open (CSS only). (dentro `smootify-consent`; letto da `smootify-consent`)
- `[consent-panel="preferences"]` — Shown only while the preferences panel is open (CSS only). (dentro `smootify-consent`; letto da `smootify-consent`)
- `[popover][data-is="market-dialog"] button[data-action="continue"]` — Closes the market suggestion and remembers it was seen. (dentro `[popover][data-is="market-dialog"]`; letto da `[popover][data-is="market-dialog"]`)
- `[upload="dropzone"]` — Drop and click area; defaults to the element itself. (dentro `file-uploader` o `file-input` o `configurator-file-input`; letto da `file-uploader`, `file-input`, `configurator-file-input`)
- `[upload="error"]` — The item's error message, hidden without one. (dentro `[upload="item"]`; letto da `file-uploader`, `file-input`, `configurator-file-input`)
- `[upload="errors"]` — Messages of the rejected files, hidden without any. (dentro `file-uploader` o `file-input` o `configurator-file-input`; letto da `file-uploader`, `file-input`, `configurator-file-input`)
- `[upload="item"]` — Item template cloned per file; a minimal one is generated when missing. (dentro `file-uploader` o `file-input` o `configurator-file-input`; letto da `file-uploader`, `file-input`, `configurator-file-input`)
- `[upload="list"]` — Holds one item per file; created when missing. (dentro `file-uploader` o `file-input` o `configurator-file-input`; letto da `file-uploader`, `file-input`, `configurator-file-input`)
- `[upload="name"]` — File name. (dentro `[upload="item"]`; letto da `file-uploader`, `file-input`, `configurator-file-input`)
- `[upload="preview"]` — Image preview of the file (img source or background image). (dentro `[upload="item"]`; letto da `file-uploader`, `file-input`, `configurator-file-input`)
- `[upload="progress"]` — Upload progress (a progress element, or percentage text). (dentro `[upload="item"]`; letto da `file-uploader`, `file-input`, `configurator-file-input`)
- `[upload="remove"]` — Removes the file. (dentro `[upload="item"]`; letto da `file-uploader`, `file-input`, `configurator-file-input`)
- `[upload="size"]` — File size, hidden when unknown. (dentro `[upload="item"]`; letto da `file-uploader`, `file-input`, `configurator-file-input`)
- `bundle-item` — Template of one item of a bundle line, cloned per item. (dentro `cart-item`; letto da `smootify-cart`)
- `cart-item` — Template of one cart line: the first is cloned per line, the others are removed. (dentro `smootify-cart`; letto da `smootify-cart`, `quantity-input`)
- `currency-code` — Text set to the current currency ISO code, anywhere in the document. (dentro ovunque; letto da `country-switcher`)
- `customer-address` — Address row template, cloned once per address. (dentro `customer-addresses`; letto da `customer-addresses`, `delete-address`)
- `customer-order` — Order row template, cloned once per order and painted like an order page. (dentro `customer-orders`; letto da `customer-orders`)
- `customer-subscription` — Subscription row template, cloned once per contract. (dentro `customer-subscriptions`; letto da `customer-subscriptions`, `subscription-activate`, `subscription-cancel`, `subscription-pause`)
- `empty-state` — Shown while the box, or the metaobject list, is empty (CSS). (dentro `smootify-magic-box-cart` o `smootify-metaobjects`; letto da `smootify-magic-box-cart`, `smootify-metaobjects`)
- `error-message` — Error text shown only while the field is invalid (CSS only). (dentro `configurator-input` o `configurator-dimension`; letto da `configurator-input`, `configurator-dimension`)
- `input[type="file"]` — The file picker; created hidden when missing. (dentro `file-uploader` o `file-input` o `configurator-file-input`; letto da `file-uploader`, `file-input`, `configurator-file-input`)
- `items-list` — Shown while the box holds items (CSS on the box cart's is-empty). (dentro `smootify-magic-box-cart`; letto da `smootify-magic-box-cart`)
- `line-item` — Order line row template, cloned once per line of the order. (dentro `customer-order` o `order-page`; letto da `order-page`, `customer-orders`)
- `map` — Container the Mapbox map is drawn into. (dentro `store-locator`; letto da `store-locator`)
- `map-marker` — Marker template, one per location with coordinates. (dentro `store-locator`; letto da `store-locator`)
- `model-viewer` — 3D viewer Smootify creates for each 3D model of a product. (dentro `smootify-product`; letto da `smootify-product`)
- `order-fulfillment` — Fulfillment row template, cloned once per fulfillment of the order. (dentro `customer-order` o `order-page`; letto da `order-page`, `customer-orders`)
- `quantity-input script[type="application/json"]` — Quantity-break table applied to the configured price: each break's price applies from its min quantity (included) up to the next break. (dentro `smootify-add-to-cart`; letto da `configurator-input`, `configurator-checkbox`, `configurator-radio`, `configurator-select`, `configurator-dropdown`, `configurator-popover`, `configurator-dimension`, `configurator-file-input`)
- `search-empty` — Shown only when a query returned no products. (dentro `smootify-search`; letto da `smootify-search`)
- `search-no-query` — Region shown only without a query; its suggested-query links set the query on click. (dentro `smootify-search`; letto da `smootify-search`)
- `search-result` — Result template, cloned per product and filled through its search bindings. (dentro `smootify-search`; letto da `smootify-search`)
- `search-suggestions` — Holds the suggested-query template, cloned per Shopify query suggestion; hidden when there are none. (dentro `smootify-search`; letto da `smootify-search`)
- `search-with-query` — Region shown only while there is a query; its first product card can be the result template. (dentro `smootify-search`; letto da `smootify-search`)
- `smootify-box-category` — A box category: its add-to-cart forms fill that category, the box moves to the next one. (dentro `smootify-magic-box`; letto da `smootify-magic-box`)
- `smootify-consent [data-action]` — Consent buttons (accept all, decline all, save choices, open preferences, close). (dentro `smootify-consent`; letto da `smootify-consent`)
- `smootify-consent [popover]` — Opened and closed with the banner; closed from outside it hides the banner for the page. (dentro `smootify-consent`; letto da `smootify-consent`)
- `smootify-consent input[type="checkbox"][name]` — Consent category checkboxes, mirrored from and saved to the current consent. (dentro `smootify-consent`; letto da `smootify-consent`)
- `store-credit-transaction` — Store credit transaction row template, cloned once per transaction. (dentro `store-credit`; letto da `store-credit`)
- `store-location` — Template of one pickup location row, cloned per location. (dentro `store-availability` o `store-locator`; letto da `store-availability`, `store-locator`)
- `store-popup` — Popup template bound to a location, opened on a marker click. (dentro `store-locator`; letto da `store-locator`)
- `subscription-line-item` — Contract line row template, cloned once per line of the contract. (dentro `customer-subscription` o `subscription-page`; letto da `subscription-page`, `customer-subscriptions`)
- `swiper-container` — Swiper Element container that receives the slides. (dentro `dynamic-swiper` o `product-slider`; letto da `dynamic-swiper`, `product-slider`, `smootify-product`)
- `swiper-slide` — Slide template, cloned once per CMS item or per extra product of a card. (dentro `swiper-container`; letto da `dynamic-swiper`, `product-slider`, `smootify-product`)

## Rimossi nella 2.0 (11)

Non annotarli mai: nella 2.0 non esistono più.

- `activate-form` → `passwordless-login`
- `add-to-wishlist` → `wishlist-toggle`
- `configurator-calculator` → nessun sostituto
- `copy-authorization` → nessun sostituto
- `dialog[is="market-dialog"]` → `[popover][data-is="market-dialog"]`
- `login-form` → `passwordless-login`
- `recover-form` → `passwordless-login`
- `register-form` → `passwordless-login`
- `reset-form` → `passwordless-login`
- `sm-debugger` → `smootify-debugger`
- `smootify-prop` → nessun sostituto

## Valori leciti per `@attr`

Dal glossario (`https://cdn.smootify.io/components-v2/glossary.json`), lo stesso che leggono la Designer App e le skill Figma. Qui solo i
nomi, attributo per attributo; dove va ogni valore (`inside`), su che elemento (`on`: `button` è solo un
elemento col tag button) e se ripete l'elemento lo dice il glossario, o `attributes` in `rules.json`.

### `address=…` (13)

`address1` · `address2` · `city` · `company` · `countryCode` · `firstName` · `formatted` · `id` · `lastName` · `name` · `phoneNumber` · `zip` · `zoneCode`

### `address-condition=…` (1)

`zone`

### `booking=…` (12)

`capacity` · `date` · `day` · `day-number` · `error` · `left` · `month` · `range` · `selection` · `slot` · `time` · `weekday`

### `box-condition=…` (2)

`can-purchase` · `cannot-purchase`

### `box-item=…` (6)

`category` · `image` · `price` · `quantity` · `title` · `total`

### `bundle=…` (2)

`images` · `total`

### `bundle-item=…` (7)

`image` · `price` · `quantity` · `subtotal` · `title` · `total` · `url`

### `bundle-limit=…` (3)

`above-units` · `current-total` · `missing-units`

### `cart=…` (9)

`compare-at-total` · `count` · `discount` · `duties` · `gift-card` · `savings` · `subtotal` · `taxes` · `total`

### `cart-condition=…` (2)

`items-in-quote` · `no-items-in-quote`

### `cart-item=…` (19)

`compare-at-price` · `compare-at-total` · `discount` · `discount-percentage` · `image` · `options` · `price` · `product-image` · `quantity` · `savings` · `sku` · `subtotal` · `title` · `total` · `unit-price` · `url` · `variant-title` · `variant-url` · `vendor`

### `company=…` (1)

`name`

### `component=…` (5)

`image` · `quantity` · `title` · `url` · `variant`

### `condition=…` (38)

`above-bundle-limits` · `available-at-location` · `below-bundle-limits` · `disabled` · `fixed-price` · `has-cart-upsells` · `has-complementary` · `has-items-in-last-viewed` · `has-items-in-wishlist` · `has-related` · `in-backorder` · `in-stock` · `is-free` · `is-new` · `is-not-variable` · `is-paid` · `is-variable` · `last-in-stock` · `low-not-last-stock` · `low-stock` · `many-in-stock` · `no-items-in-last-viewed` · `no-items-in-wishlist` · `no-stores` · `no-subscription` · `not-available-as-local-pickup` · `not-available-at-location` · `not-in-backorder` · `not-new` · `not-on-sale` · `on-sale` · `out-of-stock` · `own-wishlist` · `product-available` · `product-unavailable` · `shared-wishlist` · `subscription` · `variable-price`

### `consent-condition=…` (1)

`sale-of-data`

### `consent-panel=…` (2)

`banner` · `preferences`

### `customer=…` (7)

`defaultAddress` · `display-name` · `email` · `first-name` · `last-name` · `phone` · `tags`

### `customer-condition=…` (12)

`email-not-subscribed` · `email-subscribed` · `has-addresses` · `has-names` · `has-orders` · `has-subscriptions` · `logged-in` · `no-addresses` · `no-names` · `no-orders` · `no-subscriptions` · `not-logged-in`

### `data-action=…` (22)

`accept` · `buy-again` · `close` · `close-cart` · `continue` · `coupon` · `decline` · `gift-card` · `load` · `load-in-view` · `load-more` · `minus` · `next` · `open` · `open-cart` · `page` · `plus` · `preferences` · `prev` · `previous` · `remove` · `save`

### `data-prop=…` (22)

`compareAtPrice` · `currency-iso-code` · `currency-name` · `currency-symbol` · `currentQuantity` · `discount-amount` · `discount-percentage` · `flag` · `iso-code` · `left` · `leftQuantity` · `leftQuantityPercentage` · `leftQuantityWidth` · `maxQuantity` · `minQuantity` · `minutes` · `missingCategories` · `name` · `price` · `progress-width` · `seconds` · `total`

### `data-state=…` (2)

`default` · `loading`

### `discount=…` (2)

`amount` · `title`

### `filter=…` (9)

`active` · `active-count` · `active-label` · `count` · `empty-state` · `page-current` · `page-ellipsis` · `page-number` · `page-total`

### `filter-price=…` (3)

`from-label` · `progress` · `to-label`

### `free-shipping-condition=…` (2)

`free-shipping` · `needs-more`

### `fulfillment=…` (8)

`cancelledAt` · `estimatedDeliveryAt` · `latestShipmentStatus` · `status` · `trackingCompany` · `trackingNumber` · `trackingUrl` · `updatedAt`

### `gallery=…` (4)

`lightbox` · `lightboxes` · `slider` · `thumbnails`

### `gift-card=…` (2)

`amount` · `code`

### `group-condition=…` (2)

`more-options` · `one-option`

### `if-credit=…` (1)

`expires`

### `if-credit-transaction=…` (1)

`expires`

### `line-item=…` (12)

`image` · `name` · `option` · `price` · `quantity` · `sku` · `title` · `totalDiscount` · `totalPrice` · `unitPrice` · `variantTitle` · `vendor`

### `location=…` (8)

`address` · `country` · `directions-link` · `name` · `phone` · `pick-up-time` · `quantity` · `zip`

### `market-dialog=…` (6)

`country` · `currency` · `currency-name` · `currency-symbol` · `flag` · `language`

### `option=…` (11)

`bg-color` · `color` · `description` · `image` · `name` · `option1` · `option2` · `option3` · `price-difference` · `title` · `value`

### `option-variant=…` (1)

`image`

### `order=…` (24)

`billingAddress` · `cancelReason` · `canceledAt` · `createdAt` · `customerUrl` · `email` · `financialStatus` · `fulfillmentStatus` · `locationName` · `name` · `note` · `orderNumber` · `phone` · `poNumber` · `processedAt` · `shippingAddress` · `status` · `statusUrl` · `subtotalPrice` · `totalPrice` · `totalRefunded` · `totalShipping` · `totalTax` · `url`

### `order-condition=…` (1)

`has-fulfillments`

### `policy=…` (5)

`privacy` · `refund` · `shipping` · `subscription` · `terms`

### `product=…` (26)

`category` · `collections` · `created-at` · `description` · `external-video` · `external-videos` · `first-collection` · `gallery` · `link` · `max-compare-at-price` · `max-price` · `min-available-price` · `min-compare-at-price` · `min-price` · `model` · `option-values` · `published-at` · `specific-image` · `stock` · `tags` · `title` · `type` · `url` · `vendor` · `video` · `videos`

### `reference=…` (6)

`body` · `description` · `handle` · `image` · `title` · `url`

### `search=…` (13)

`collection` · `compare-at-price` · `count` · `empty-state` · `image` · `price` · `query` · `search-page` · `suggested-query` · `title` · `type` · `url` · `vendor`

### `selected-option=…` (4)

`bg-color` · `color` · `image` · `title`

### `skeleton=…` (5)

`block` · `button` · `hide` · `image` · `text`

### `store-credit=…` (2)

`balance` · `expirableBalance`

### `store-credit-transaction=…` (5)

`amount` · `balanceAfterTransaction` · `createdAt` · `event` · `expiresAt`

### `subscription=…` (17)

`billingAddress` · `billingInterval` · `cancelReason` · `createdAt` · `customerUrl` · `name` · `nextBillingDate` · `note` · `shippingAddress` · `shippingPrice` · `status` · `statusUrl` · `subtotalPrice` · `totalPrice` · `totalRefunded` · `totalTax` · `url`

### `subscription-group=…` (1)

`name`

### `swatch=…` (6)

`bg-color` · `color` · `description` · `image` · `name` · `title`

### `upload=…` (10)

`dropzone` · `error` · `errors` · `item` · `list` · `name` · `preview` · `progress` · `remove` · `size`

### `variant=…` (24)

`barcode` · `components` · `discount-percentage` · `discounted-amount` · `image` · `number` · `option1-name` · `option1-value` · `option2-name` · `option2-value` · `option3-name` · `option3-value` · `quantity-increment` · `quantity-max` · `quantity-min` · `sku` · `stock` · `swatch1` · `swatch2` · `swatch3` · `title` · `unit-price` · `url` · `weight`

### `wishlist=…` (1)

`count`

### Valori deprecati: non annotarli (3)

Venivano dalla 1.x o dalle prime 2.0: qualcuno funziona ancora, qualcuno non più. In un progetto si scrive sempre il sostituto.

- `product=images` → `[product="gallery"]`
- `product=media` → `[product="gallery"]`
- `address=territoryCode` → `[address="countryCode"]`

## Classi di stato

Scritte da Smootify a runtime sull'host. Non vanno messe in `@style`: servono per disegnare gli stati.

- `smootify-product` → `loaded`, `w-dyn-bind-empty`, `price-varies`, `is-variable`, `has-subscription`, `is-on-sale`, `is-free`, `is-available`, `is-not-available`, `not-existing-variant`, `is-currently-out-of-stock`, `many-in-stock`, `last-in-stock`, `low-stock`, `low-not-last-stock`, `is-new`
- `smootify-variant` → `loaded`, `is-on-sale`, `is-available`, `is-not-available`, `last-in-stock`, `low-stock`, `not-existing-variant`
- `smootify-cart` → `loaded`, `is-rendered`, `is-empty-cart`, `has-taxes`, `has-empty-quote`
- `smootify-search-discovery` → `inited`, `empty`, `is-filtered`, `has-pagination`, `has-page-numbers`
- `smootify-search-page` → `inited`, `is-empty`, `is-filtered`, `has-pagination`, `has-page-numbers`

## Campi dei form (40)

Il **Name** di ogni campo (impostazione del campo in Webflow, non un attributo custom) dice a Smootify cosa
contiene. Si annota con `@attr: name=<Name>` sul campo, scritto esattamente come qui: maiuscole comprese.
"—" vuol dire che l'elemento non legge campi; "any other name" dice cosa succede ai nomi non elencati.

### `booking-form`

- `name`, `email`, `phone`, `note` (any case: Webflow's `Name`, `Email` work) — text, email, tel, textarea — written on the Booking entry the submit creates in the store, trimmed; an empty value is not sent
- any other name — not sent: only these four reach the store

### `configurator-checkbox`

- the `data-name`, else the `name`, of the first named element — any — the step name the formulas use

### `configurator-dimension`

- each `input[type="number"]` (its `name`) — number — **obbligatorio** (removed without one) — the formula variable of that value; the other inputs are removed

### `configurator-dropdown`

- the `data-name`, else the `name`, of the first named element — any — the step name the formulas use

### `configurator-file-input`

- the element's `name`, else its `input[type="file"]`'s — file — the field the uploaded files are sent under; the file input itself loses its name

### `configurator-input`

- the `data-name`, else the `name`, of the first named element — any — the step name the formulas use

### `configurator-popover`

- the `data-name`, else the `name`, of the first named element — any — the step name the formulas use

### `configurator-radio`

- the `data-name`, else the `name`, of the first named element — any — the step name the formulas use

### `configurator-select`

- the `data-name`, else the `name`, of the first named element — any — the step name the formulas use

### `create-address`

- `countryCode` — select — **obbligatorio** (removed without it) — the country, made required (1.x and the first 2.0 builds: `territoryCode`, which Shopify deprecated; the debugger flags it); Smootify fills the options with the countries the shop ships to, keeping an option without a value as the placeholder
- `zoneCode` — select — **obbligatorio** (removed without it) — the province or state; Smootify replaces every option with the zones of the chosen country, the select is required only when the country has zones, and the host has `no-zone` until it does
- `firstName`, `lastName`, `company`, `address1`, `address2`, `city`, `zip` — text — the address lines; in `edit-address` every field named like a key of the address is prefilled
- `phoneNumber` — text — the phone, sent without spaces
- `defaultAddress` — checkbox — checked: the address becomes the default; unchecked: the default stays
- any other name — sent to Shopify, which refuses the address: leave it out

### `customer-metafields-editor`

- any name: the metafield key — text, textarea, select, radio, checkbox, `file-input` — saves the customer metafield `custom.<key>`, the key being the snake_case of `data-name` (the `name` as written without it), and is prefilled from it, select and textarea included; a lone checkbox saves `true` checked and `false` unchecked; names starting with `_` and empty values are not saved, and a repeated name keeps its last value

### `customer-subscribe-email`

Non legge campi: the submit subscribes or unsubscribes the logged-in customer.

### `customer-unsubscribe-email`

Non legge campi: the submit subscribes or unsubscribes the logged-in customer.

### `customer-user-update`

- `firstName`, `lastName` — text input — **obbligatorio** (removed without either) — the customer's first and last name, prefilled when the customer has one and the field is not focused
- any other name — not sent: only the first and last name go to Shopify

### `delete-address`

- `id` — hidden — the address deleted; the form of the default address is removed

### `edit-address`

- `countryCode` — select — **obbligatorio** (removed without it) — the country, made required (1.x and the first 2.0 builds: `territoryCode`, which Shopify deprecated; the debugger flags it); Smootify fills the options with the countries the shop ships to, keeping an option without a value as the placeholder
- `zoneCode` — select — **obbligatorio** (removed without it) — the province or state; Smootify replaces every option with the zones of the chosen country, the select is required only when the country has zones, and the host has `no-zone` until it does
- `firstName`, `lastName`, `company`, `address1`, `address2`, `city`, `zip` — text — the address lines; in `edit-address` every field named like a key of the address is prefilled
- `phoneNumber` — text — the phone, sent without spaces
- `defaultAddress` — checkbox — checked: the address becomes the default; unchecked: the default stays
- any other name — sent to Shopify, which refuses the address: leave it out
- `id` — hidden — the address updated

### `file-input`

- the element's `name`, else its `input[type="file"]`'s — file — the field the uploaded files are sent under; the file input itself loses its name

### `file-uploader`

- the element's `name`, else its `input[type="file"]`'s — file — the field the uploaded files are sent under; the file input itself loses its name

### `filter-price`

Non legge campi: reads no name: the inputs by type and order.

### `filter-search`

- every input but the submit (any name) — text — renamed `query`; the first one sets the search & discovery query

### `klaviyo-back-in-stock`

- `email` (any case), else the first `input[type="email"]` — text or email — **obbligatorio** ("Invalid Email" without it) — the address Klaviyo alerts (Webflow's default Email field works: `data-name="Email"`); every other field is ignored

### `logout-form`

Non legge campi: the submit logs out and follows Shopify's logout url.

### `metaobject-creator`

- any name: the field key — any — the metaobject field whose key is the snake_case of `data-name` ("Serial number" → `serial_number`, as `customer-metafields-editor`), else the `name`; names starting with `_` and empty values are not sent; a repeated name sends a list, a lone checkbox `true` / `false`, a `[data-unit-for]` field adds its unit to that field and is not sent itself, a `file-input[data-multiple]` a list of file gids

### `name-your-price`

- the first `input[type="number"]` (any name) — number — **obbligatorio** (removed without it) — the unit price, bounded by its `min` / `max`; never a line property

### `newsletter-subscribe`

- the first `input[type="email"]` (any name) — email — **obbligatorio** (removed without it) — renamed `email`: the address subscribed; every other field is ignored

### `passwordless-login`

Non legge campi: the submit starts the Customer Accounts login.

### `smootify-add-to-cart`

- `quantity` — number (`quantity-input`) — the quantity of the line
- `sellingPlanId` — radio or select (written by `subscription-swatches`) — the selling plan of the line
- `option1`, `option2`, `option3` — select — a bare `select[name="optionN"]` picks that option; never a line property
- `Recipient email` — email — gift card: Shopify sends the card to this address
- `Send on` — date — gift card: the day the card is sent (Smootify sets today as the minimum)
- `buy-now` (submit button) — button — the line goes straight to checkout
- any Name on a field of an add-on widget (`addon-checkbox`, `addon-select`, `addon-dropdown`, `addon-popover`, `addon-swatches`, the add-on's `quantity-input`) — any — never a property of the main line, whatever the Name (Webflow needs one). From mount the widget names its fields `##ignore-addon`, left out of the line; once the add-on's product loads they get the names of the add-on line (2.0)
- any other name, or `properties[Name]` — any — a line item property named as the field's `data-name`; a checkbox with `data-name` sends its `data-value`, else `✓`; a file is sent as JSON; empty values are not sent; a name starting with `_` is hidden at checkout and in the cart

### `smootify-cart`

- `note` — textarea or input — the order note, saved before checkout and prefilled; a field whose name is `Note` becomes `note` (1.x read only a textarea)
- `coupon` — text — a discount code, applied by `button[data-action="coupon"]` or Enter, cleared after; a field whose name is `Coupon` becomes `coupon`
- `gift-card` (or `Gift Card`) — text — a gift card code, applied by `button[data-action="gift-card"]` (Enter only with `gift-card`)
- `email` — email — with a quote (`draft-order`): the email of the draft order (the logged-in customer otherwise); without a quote a cart attribute
- `quantity` — number — inside a cart line: that line's quantity
- `draft-order` (submit button) — button — sends the cart as a quote (draft order) instead of the checkout
- any other name — any — a cart attribute named as the field's `data-name`, saved before checkout; refilled for text, textarea, select, radio and checkbox; a multiple select is joined with `,`

### `smootify-consent`

- `analytics`, `marketing`, `preferences`, `sale_of_data` (or `saleOfData`) — checkbox (`name` exactly) — checked: that kind of tracking is allowed, saved by `[data-action="save"]`; the boxes follow the stored consent, Webflow's custom checkbox included

### `smootify-magic-box-cart`

- `buy-now` (submit button) — button — the box goes straight to checkout (also `data-buy-now`)
- any name — any — a property of the box's first line, named as the field's `data-name`; empty values are not sent

### `smootify-search`

- `query` — text input — the search text

### `smootify-search-page`

- every `input[type="text"]` (any name) — text — renamed `q`, prefilled from `?q=`; the first filled one is the query

### `sort-dropdown`

Non legge campi: reads no name of yours: Smootify names the field `sort`.

### `sort-radio`

Non legge campi: reads no name of yours: Smootify names the field `sort`.

### `sort-select`

Non legge campi: reads no name of yours: Smootify names the field `sort`.

### `store-locator`

- `query` — text — the place to search for

### `subscription-activate`

Non legge campi: the contract comes from the wrapper's `data-contract-id`.

### `subscription-cancel`

Non legge campi: the contract comes from the wrapper's `data-contract-id`.

### `subscription-pause`

Non legge campi: the contract comes from the wrapper's `data-contract-id`.

### `webflow-form`

Non legge campi: the submit shows the success state and follows `data-redirect`.
