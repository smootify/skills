# Smootify documentation map

Use this map to find the right doc page for each topic.

**A 2.0 site: cite the 2.0 docs, `https://www.smootify.io/docs/…`.** Every page is fetchable as markdown by adding
`.md` to its path (`https://www.smootify.io/docs/build/cart.md`), and `https://www.smootify.io/llms.txt` lists them
all. Elements and attribute values have a page each: the `reference` URLs in `rules.json`.

**A 1.x site: cite `docs.smootify.io`**, the tables after the 2.0 one. When citing one of those pages, use
`https://docs.smootify.io{path}`; its raw markdown is `https://docs.smootify.io/llms.mdx{path}/content.md`, and the
whole set is `https://docs.smootify.io/llms-full.txt`.

---

## Smootify 2.0 (www.smootify.io/docs)

| Issue area or topic | Page |
|---|---|
| Install, the loader, the options script | `/docs/start/install`, `/docs/reference/options` |
| What 2.0 removed, renamed or changed; URL defaults | `/docs/start/changes` |
| Moving a 1.x site (accounts, loader, options, markup, scripts) | `/docs/start/migrate` |
| What is new in 2.0 | `https://www.smootify.io/changelog/2-0` |
| 1.x bugs 2.0 fixes (numbers that differ after the move) | `/docs/start/whats-fixed` |
| The debugger | `/docs/start/debugger` |
| Something does not work: where to start | `/docs/start/troubleshooting` |
| CMS collections, sync, 404 on product / collection links | `/docs/start/cms`, `/docs/start/migrate` ("Set the options") |
| Images, page weight, loading placeholders | `/docs/start/performance` |
| Publish, domains, hand-off | `/docs/start/publish`, `/docs/start/domains`, `/docs/start/hand-off` |
| Product page, add to cart, variant selectors | `/docs/build/product-page`, `/docs/build/swatches`, `/docs/build/variants-list` |
| Product gallery (`[product="gallery"]`) | `/docs/build/product-gallery` |
| Product cards and lists, related products | `/docs/build/product-cards`, `/docs/build/product-lists` |
| Collection page, search & discovery, filters | `/docs/build/collection-page`, `/docs/build/filters` |
| Search page, predictive search | `/docs/build/search-page`, `/docs/build/predictive-search` |
| Cart, cart extras, upsells, gift cards | `/docs/build/cart`, `/docs/build/cart-extras`, `/docs/build/cart-upsells`, `/docs/build/gift-cards` |
| Popovers (mini cart, panels) | `/docs/build/popovers` |
| Navbar, markets switcher | `/docs/build/navbar`, `/docs/features/markets` |
| Account, addresses, orders and buy again, subscriptions | `/docs/build/account`, `/docs/build/addresses`, `/docs/build/orders`, `/docs/build/account-subscriptions` |
| Metafields, customer data | `/docs/build/metafields`, `/docs/build/customer-data` |
| Cookie banner (`smootify-consent`) | `/docs/features/cookie-consent` |
| Market suggestion | `/docs/features/market-suggestion` |
| Analytics pixels | `/docs/features/analytics` |
| Add-ons, Magic Box, configurator, file uploads, booking, metaobject creator | `/docs/features/add-ons`, `/docs/features/magic-box`, `/docs/features/product-configurator`, `/docs/features/file-uploads`, `/docs/features/booking`, `/docs/features/metaobject-creator` |
| Wishlist, back in stock, store availability, quotes | `/docs/features/wishlist`, `/docs/features/back-in-stock`, `/docs/features/store-availability`, `/docs/features/quotes` |
| JavaScript API, events, filters, custom scripts | `/docs/developers/javascript-api`, `/docs/developers/events`, `/docs/developers/filters`, `/docs/developers/scripts` |
| CSS, state classes | `/docs/developers/css`, `/docs/reference/state-classes` |
| Every element, attribute value and condition | `/docs/reference/elements`, `/docs/reference/attributes`, `/docs/reference/conditions` |

---

# Smootify 1.x (docs.smootify.io)

The pages below describe 1.x. Rows note where a page no longer matches 2.0.

## Getting started

| Topic | Path |
|---|---|
| Overview | `/docs/getting-started` |
| Why Smootify / Quick start | `/docs/getting-started/quick-start` |
| Create Shopify store | `/docs/getting-started/quick-start/shopify-store` |
| Create Webflow project | `/docs/getting-started/quick-start/webflow-project` |
| Connect Webflow project | `/docs/getting-started/quick-start/connect-webflow-project` |
| Create CMS Collections | `/docs/getting-started/quick-start/create-cms-collections` |
| Import and Sync | `/docs/getting-started/quick-start/import-and-sync` |
| Publish - Domains | `/docs/getting-started/publish/domains` |
| Publish - Headless App | `/docs/getting-started/publish/headless-app` |
| Publish - Shopify Redirect Theme | `/docs/getting-started/publish/shopify-theme` |
| Publish - Checklist | `/docs/getting-started/publish/checklist` |
| Project hand off | `/docs/getting-started/publish/project-hand-off` |
| FAQs | `/docs/getting-started/faqs` |
| Templates - Smootify Starter Project | `/docs/getting-started/templates/smootify-starter-project` |
| Templates - Relume Starter | `/docs/getting-started/templates/relume-starter-project` |
| Templates - Bovist | `/docs/getting-started/templates/bovist` |
| Templates - Craftify | `/docs/getting-started/templates/craftify` |
| Templates - Evo | `/docs/getting-started/templates/evo` |
| Templates - Naturelle | `/docs/getting-started/templates/naturelle` |
| Templates - Noise | `/docs/getting-started/templates/noise` |
| Templates - Reciklo | `/docs/getting-started/templates/reciklo` |
| Templates - Volt | `/docs/getting-started/templates/volt` |
| Libraries - Relume | `/docs/getting-started/libraries/relume` |

## Products & Collections

| Topic | Path |
|---|---|
| Overview | `/docs/ecommerce` |
| FAQs | `/docs/ecommerce/faqs` |

### Products

| Topic | Path |
|---|---|
| Products overview | `/docs/ecommerce/products` |
| Product CMS structure | `/docs/ecommerce/products/cms` |
| Product Custom Element | `/docs/ecommerce/products/custom-element` |
| Product Listing | `/docs/ecommerce/products/listing` |
| Product Template Page | `/docs/ecommerce/products/template` |
| Elements and Attributes (its Images and Media sections — `product=images`, `product=media` — are **deprecated in 2.0**: they still work, the replacement is the product gallery, `[product="gallery"]`, which has no page yet) | `/docs/ecommerce/products/elements` |
| Add to Cart | `/docs/ecommerce/products/add-to-cart` |
| Conditional Visibility | `/docs/ecommerce/products/conditional-visibility` |
| Metafields | `/docs/ecommerce/products/metafields` |
| Gift Cards | `/docs/ecommerce/products/gift-cards` |
| Bundles | `/docs/ecommerce/products/bundles` |

### Collections

| Topic | Path |
|---|---|
| Collections overview | `/docs/ecommerce/collections` |
| Collection CMS structure | `/docs/ecommerce/collections/cms` |
| Collection Template Page | `/docs/ecommerce/collections/template` |

### Variants

| Topic | Path |
|---|---|
| Variants overview | `/docs/ecommerce/variants` |
| Variant Custom Element | `/docs/ecommerce/variants/custom-element` |
| Variant Listing | `/docs/ecommerce/variants/listing` |
| Variant Elements and Attributes | `/docs/ecommerce/variants/elements` |
| Variant Metafields | `/docs/ecommerce/variants/metafields` |

### Vendors

| Topic | Path |
|---|---|
| Vendors overview | `/docs/ecommerce/vendors` |
| Vendor CMS structure | `/docs/ecommerce/vendors/cms` |
| Vendor Template Page | `/docs/ecommerce/vendors/template` |

### Add-ons (server plan or activatable)

| Topic | Path |
|---|---|
| Add-ons overview / Wishlist | `/docs/ecommerce/add-ons` |
| Last Viewed | `/docs/ecommerce/add-ons/last-viewed` |
| Magic Box | `/docs/ecommerce/add-ons/magic-box` |
| Magic Add-Ons | `/docs/ecommerce/add-ons/magic-add-ons` |
| Dynamic Properties | `/docs/ecommerce/add-ons/dynamic-properties` |
| Name your Price | `/docs/ecommerce/add-ons/name-your-price` |
| Product Configurator | `/docs/ecommerce/add-ons/product-configurator` |
| Product File Upload (describes 1.x: on 2.0 the uploader uses the designer's `[upload=…]` markup and `max-file-size` changes the 20 MB limit) | `/docs/ecommerce/add-ons/product-file-upload` |

## Cart

| Topic | Path |
|---|---|
| Cart overview | `/docs/cart` |
| Cart Page | `/docs/cart/cart-page` |
| Mini Cart | `/docs/cart/mini-cart` |
| Additional Data (Cart Attributes) | `/docs/cart/additional-data` |
| Cart Upsells | `/docs/cart/cart-upsells` |
| Free Shipping Progress | `/docs/cart/free-shipping-progress` |
| Urgent Cart Countdown | `/docs/cart/urgent-cart-countdown` |
| Draft Orders | `/docs/cart/draft-orders` |
| FAQs | `/docs/cart/faqs` |

## Search & Filters

| Topic | Path |
|---|---|
| Predictive Search / Overview | `/docs/search-filters` |
| Search and Discovery | `/docs/search-filters/search-and-discovery` |
| Search Page | `/docs/search-filters/search-page` |
| FAQs | `/docs/search-filters/faqs` |

## Customer Accounts

| Topic | Path |
|---|---|
| Accounts overview | `/docs/accounts` |
| How to enable | `/docs/accounts/how-to-enable` |
| Components & Attributes | `/docs/accounts/components-attributes` |
| Conditional Visibility | `/docs/accounts/conditional-visibility` |
| Metafields | `/docs/accounts/metafields` |
| Customer Metafields Editor | `/docs/accounts/customer-editor` |
| Newsletter Subscription | `/docs/accounts/newsletter-subscription` |
| Order Listing | `/docs/accounts/order-listing` |
| Order Page | `/docs/accounts/order-page` |
| Subscription Listing | `/docs/accounts/subscription-listing` |
| Subscription Page | `/docs/accounts/subscription-page` |
| Legacy (classic accounts, **1.x only**) - Components & Attributes | `/docs/accounts/legacy-components-attributes` |
| Legacy (classic accounts, **1.x only**) - Conditional Visibility | `/docs/accounts/legacy-conditional-visibility` |
| Legacy (classic accounts, **1.x only**) - Order Listing | `/docs/accounts/legacy-order-listing` |
| Legacy (classic accounts, **1.x only**) - Order Page | `/docs/accounts/legacy-order-page` |
| FAQs | `/docs/accounts/faqs` |

## Metaobjects

| Topic | Path |
|---|---|
| Metaobjects overview | `/docs/metaobjects` |
| Metaobject Listing | `/docs/metaobjects/listing` |
| Single Metaobject | `/docs/metaobjects/single-item` |
| Metaobject Creator | `/docs/metaobjects/creator` |
| FAQs | `/docs/metaobjects/faqs` |

## Internationalization

| Topic | Path |
|---|---|
| Overview | `/docs/internationalization` |
| Webflow Localization | `/docs/internationalization/webflow` |
| Shopify Localization | `/docs/internationalization/shopify` |
| Shopify Markets | `/docs/internationalization/markets` |
| Markets Switcher | `/docs/internationalization/markets-switcher` |
| Store Availability | `/docs/internationalization/store-availability` |
| Store Locator | `/docs/internationalization/store-locator` |
| Preferred Store / Store Switcher | `/docs/internationalization/store-switcher` |

## Integrations (3rd party apps)

| Topic | Path |
|---|---|
| Apps overview | `/docs/apps` |
| App Embeds | `/docs/apps/blocks` |
| Judge.me Reviews | `/docs/apps/judge-me-reviews` |
| Klaviyo - Back in Stock | `/docs/apps/klaviyo-back-in-stock` |
| Klaviyo - Reviews | `/docs/apps/klaviyo-reviews` |
| Loox Reviews | `/docs/apps/loox-reviews` |
| FAQs | `/docs/apps/faqs` |

## Analytics

| Topic | Path |
|---|---|
| Analytics overview | `/docs/analytics` |
| Cookie Consent (describes 1.x, Shopify's banner restyled; on 2.0 the banner is a `smootify-consent` block built in Webflow, see `rules.json`) | `/docs/analytics/cookie-consent` |
| Analytics Integrations (GA, Meta, Klaviyo) | `/docs/analytics/integrations` |

## Custom Code

| Topic | Path |
|---|---|
| Custom Code overview | `/docs/custom-code` |
| JS - Settings / Options Customizer | `/docs/custom-code/js` |
| JS - APIs | `/docs/custom-code/js/api` |
| JS - Events | `/docs/custom-code/js/events` |
| CSS - Skeleton & Variables (its automatic skeleton is 1.x only: on 2.0 only elements with `[skeleton]` shimmer) | `/docs/custom-code/css` |
| CSS - Snippets | `/docs/custom-code/css/snippets` |

---

## Topic-to-page quick lookup (for diagnostic checklist)

When the user has an issue in one of these areas, look in this section first:

| Issue area | Primary doc page |
|---|---|
| Products not showing on a page | `/docs/ecommerce/products/listing` |
| Single product page empty | `/docs/ecommerce/products/template` and `/docs/ecommerce/products/custom-element` |
| Variant selectors not working | `/docs/ecommerce/products/add-to-cart` and `/docs/ecommerce/variants` |
| Price not updating with variant | `/docs/ecommerce/products/elements` (Price section) |
| Add to Cart not working | `/docs/ecommerce/products/add-to-cart` |
| Cart page issues | `/docs/cart/cart-page` |
| Mini Cart issues | `/docs/cart/mini-cart` |
| Images not loading | `/docs/ecommerce/products/elements` (Specific Image; Images and Media are 1.x, deprecated in 2.0 → the product gallery) |
| Slow images / CDN | `/docs/ecommerce/products/elements` (Dynamic CDN Compression) |
| 404 on product/collection links | `/docs/custom-code/js` (Options Customizer) |
| Search returns nothing | `/docs/search-filters/search-and-discovery` or `/docs/search-filters/search-page` |
| Filters not applying | `/docs/search-filters/search-and-discovery` |
| Customer login/account broken | `/docs/accounts/how-to-enable` |
| Account pages not protected | `/docs/accounts` |
| Multi-currency / multi-language | `/docs/internationalization` |
| Markets switcher not working | `/docs/internationalization/markets-switcher` |
| Metafields not showing | `/docs/ecommerce/products/metafields` |
| Site won't publish at all | `/docs/getting-started/publish/checklist` and `/docs/getting-started/publish/domains` |
| Checkout redirects to wrong domain | `/docs/getting-started/publish/domains` |
| Order confirmation emails missing | `/docs/getting-started/publish/headless-app` |
| Wishlist not saving | `/docs/ecommerce/add-ons` |
| Bundles / Magic Box issues | `/docs/ecommerce/add-ons/magic-box` |
| Dynamic pricing / configurator | `/docs/ecommerce/add-ons/product-configurator` |
| Cookie consent / GDPR | `/docs/analytics/cookie-consent` (2.0: `smootify-consent`, see the 2.0 table) |
| Analytics tracking (GA, Meta) | `/docs/analytics/integrations` |
| Custom JS / events | `/docs/custom-code/js/events` and `/docs/custom-code/js/api` |
| Sync issues (products not appearing in Webflow) | `/docs/ecommerce/faqs` (Sync Issues section) |
