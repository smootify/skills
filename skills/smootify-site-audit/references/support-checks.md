# Smootify diagnostic checklist

This checklist is based on the most common configuration errors seen in Smootify support. Run through these checks in order when auditing a Webflow project that uses Smootify and isn't working as expected.

For each check, link the relevant doc page from `doc-map.md` when explaining the fix.

---

## 1. CMS collections structure

**What to check:**
Verify that the Webflow project has the three required CMS collections that Smootify expects:
- `Products` (or custom slug, configured in Smootify script options)
- `Collections` (or custom slug)
- `Vendors` (or custom slug)

For each CMS collection, verify the required Smootify-specific fields are present (Shopify ID field of type Plain text is the most critical).

**Why it breaks:**
Smootify reads from these CMS collections to fetch product/collection data. Missing collections or missing required fields prevents sync from Shopify and stops product rendering.

**If unclear which collections are needed:**
Ask the user: "Which Shopify entities are you trying to display on the site? (products, collections, vendors)"

**Doc references:**
- `/docs/getting-started/quick-start/create-cms-collections`
- `/docs/ecommerce/products/cms`
- `/docs/ecommerce/collections/cms`

- Customers can have other fields not needed by smootify, but they must be set as not required in webflow, otherwise it will break the sync.

---

## 2. Smootify script presence and order

**What to check:**
Open Project Settings > Custom Code > Head Code. Verify:
- The Smootify global script is present, and which version it loads: `https://cdn.smootify.io/assets/v2/loader.js` (or any `assets/v2/…` path) is 2.0; `https://cdn.smootify.io/assets/latest/js/index.js` with `assets/latest/css/index.css` is 1.x. The version decides the slug defaults below
- If the user used different cms slugs then the default ones of Smootify, a user script must be present to configure the smootify options, this script must be placed before the Smootify global script. The defaults are `products`, `collections` and `vendors` in 2.0, `product`, `collection` and `vendor` in 1.x: a 2.0 site whose CMS collections are still `product` / `collection` / `vendor` must set `productsBase: "product"`, `collectionsBase: "collection"` and `vendorsBase: "vendor"` in `SmootifyUserOptions` (2.0 migration guide, `v2/MIGRATION.md` step 1)

**Why it breaks:**
Without the script, no Smootify functionality will execute. With wrong CMS slug configuration, links will 404 and dynamic data won't render. A 1.x site switched to 2.0 without those three options links to `/products/…`, `/collections/…` and `/vendors/…` while its CMS pages still live at `/product/…`, `/collection/…` and `/vendor/…`

**Doc references:**
- `/docs/custom-code/js` (the options customizer; its slug defaults are the 1.x ones)
- 2.0: `v2/MIGRATION.md` step 1, `v2/BREAKING-CHANGES.md` (defaults table)

---

## 3. Check for attributes for CDN compression on images loaded from Shopify

**What to check:**
If the project uses attributes like:
- `[product="gallery"]` (the images of its `[gallery=…]` parts; slides take their size from the `[gallery="slider"]`)
- variant=image
- product=specific-image

Check that on any element they used with those attributes that also dynamic cdn compression elements are present (`max-width`, `max-height`, `crop`, `pad-color`). In this way the performances will be better

If the project still uses `product=images` or `product=media`: they are deprecated in 2.0 and still work; suggest `[product="gallery"]`, which does slider, thumbnails and lightboxes in one block (2.0 CHANGELOG, "`[product="gallery"]`")

**Why it breaks:**
Shopify url by default are raw, by using dynamic cdn compression attributes you can define better dimensions for images and avoid loading images that are bigger than required

**Doc references:**
- `/docs/ecommerce/products/elements#dynamic-cdn-compression` (the CDN attributes did not change; the Images and Media sections describe the 1.x pieces the gallery replaces)
- 2.0: the glossary entries `product=gallery` and `gallery=*`

---

## 4. Product Custom Element (smootify-product) presence

**What to check:**
On any page where dynamic product elements appear (price, add-to-cart, variants, gallery, etc.), verify there is a parent **Product Custom Element** (HTML tag: `smootify-product`) wrapping them.

The Product Custom Element must:
- Be connected to the Shopify ID field of the Webflow CMS (when on a CMS template page)
- Wrap ALL dynamic Smootify elements (price, gallery, add-to-cart, etc.)

**Dynamic elements that REQUIRE smootify-product as ancestor:**
- Add to Cart button and variant selectors
- Price element (smootify-price)
- Variant images, SKU, barcode, weight, unit-price, stock
- Discount percentage and discounted amount
- Variant URL, option names/values
- Any element using attributes `variant=...`

**Why it breaks:**
Without the Product Custom Element parent, Smootify has no context for which product to render. Dynamic elements stay empty or use defaults from the CMS without variant logic.

**Doc references:**
- `/docs/ecommerce/products/custom-element`
- `/docs/ecommerce/products/elements`

---

## 5. Attributes on dynamic elements

**What to check:**
Verify that all dynamic Smootify elements have the correct attributes. The complete list is the glossary (`https://cdn.smootify.io/components-v2/glossary.json`), as generated into `rules.json` (`bindings`, `attributes`).

Common errors:
- Missing `product` attribute on text elements meant to render product data (title, description, vendor, etc.)
- Missing `variant` attribute on elements meant to update with variant selection
- Wrong attribute value (e.g., `variant=gallery` instead of `product=gallery`, or `variation=` instead of `variant=`)
- Missing `data-prop` attributes inside the smootify-price element (must have `price` and `compareAtPrice` text elements with the correct data-prop)

**Why it breaks:**
Smootify renders dynamic data only on elements that explicitly declare what to show via attributes. Missing or wrong attributes leave elements empty or static.

**Doc references:**
- `/docs/ecommerce/products/elements`
- `/docs/ecommerce/variants`

---

## 6. Add to Cart structure (variant selectors)

**What to check:**
For products with variants, the Add to Cart section must contain:
- The Add to Cart button (smootify-add-to-cart)
- Variant selectors for each option set (Shopify allows up to 3 option sets)
- Each variant selector must be correctly tagged so Smootify can match it to a Shopify option

**Why it breaks:**
Wrong selector structure makes the variant selection non-functional. The user can click but the price/image/SKU won't update, and the Add to Cart will add the default variant instead of the selected one.

**Doc references:**
- `/docs/ecommerce/products/add-to-cart`
- `/docs/ecommerce/variants`

---

## 7. Cart implementation

**What to check:**
- If the project has a mini-cart, verify the cart custom element structure matches the Smootify requirements
- Verify the cart page (if separate) is correctly set up

**Why it breaks:**
Wrong cart structure means items added don't appear, or appear without correct quantities/prices, or the cart total doesn't update.

**Doc references:**
- `/docs/cart`

---

## 8. Product page template

**What to check:**
If diagnosing a Product Detail Page issue:
- The page should be a CMS template page bound to the Products CMS collection
- It should have a top-level Product Custom Element wrapping all product content
- Related products / recommendations sections need their own Product Custom Element setup

**Why it breaks:**
Wrong template structure prevents the page from being generated for each product, or generates pages with empty data.

**Doc references:**
- `/docs/ecommerce/products/template`

---

## 9. Collection page template, when the user didn't used Search and Discovery

**What to check:**
If diagnosing a Collection Detail Page issue, where the user didn't used Search and Discovery:
- CMS template page bound to Collections CMS collection
- Collection list inside, bound to Products with a filter "where Collection equals current collection"
- Each Product item in the list wrapped in a Product Custom Element

**Why it breaks:**
Without correct binding the collection page won't list its products.

**Doc references:**
- `/docs/ecommerce/collections/template`
- `/docs/ecommerce/products/listing`

---

## 10. Search and filter setup

**What to check:**
If the project has Search and Discovery component:
- Check that no CMS has been used inside the Search and Discovery wrapper element to render products: a Collection List whose single item holds the `smootify-product` card is fine (2.0 takes the `.w-dyn-item` as the card template), several CMS items or CMS-bound content in the card are not
- Check that if the user applied a limit attribute on the Search and Discovery element, suggest it to be below 24 for best performances
- If the page with search and discovery is the collection detail page, check that the `smootify-search-discovery` element has `data-collection` bound to the collection's Shopify ID CMS field: that alone locks the list to that collection (the Collection facet is locked and kept out of the URL), no Collection filter is needed. On a vendor template the same goes for `data-vendor`, bound to the vendor name. In the published HTML an empty `data-collection` is a CMS item with no Shopify ID. (1.x prescribed a filter with `label=Collection` and `selected-value`; on 2.0 `data-collection` is enough, so a missing Collection filter is not a finding)
- If user used load more or load more in view pagination buttons, suggest to avoid it if their collections have more than 200 products, in that case is better use next/previous pagination buttons instead to avoid performances issues on devices with low ram available.

**Why it breaks:**
Search and discovery is rendered through js, so no CMS item must be used inside the Search and Discovery wrapper element. If the user did use it, the Search and Discovery component will render incorrectly

**Doc references:**
- `/docs/search-filters/search-and-discovery` (describes 1.x)
- 2.0: `data-collection` / `data-vendor` on `smootify-search-discovery` in `rules.json`

---

## 11. If user talks about bad performances on Apple devices

- Ask the user to disable the webflow bot protection. Apple devices are not fully compatible with Cloudflare turnstile bot protection. If the user disables it, the website performances will be better.

---

## How to use this checklist

Run through it sequentially. For each check:
1. Verify the configuration on what you have: the project over the Webflow MCP, the published HTML, or — with neither — the user's answers
2. If you find an issue, note it for the final report (severity: blocker / important / minor, reported as `error` / `warning` / `info`)
3. If you cannot determine it from what you have, ask the user a targeted question
4. Always cite the source when explaining the fix: the doc page for setup that did not change in 2.0, the glossary / `rules.json` / 2.0 CHANGELOG, BREAKING-CHANGES or MIGRATION for 2.0 behaviour (docs.smootify.io describes 1.x until the 2.0 docs are published)
