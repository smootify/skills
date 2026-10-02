---
name: smootify-custom-script
description: Writes and changes custom scripts for Webflow sites on Smootify Storefront 2.0, in the Vite and TypeScript starter. Covers how a script starts (Smootify.push), the events, the filters, the API, and how a script is built, measured and put on the site. Use it in a script folder (one with smootify.json and src/smootify.d.ts), or for any code on a Smootify site that calls window.Smootify, listens to smootify:* events, or changes what the cart, products, checkout or markets do.
---

# Smootify custom scripts

You're working on one script for one Webflow site that runs **Smootify Storefront 2.0**, the script that turns a
Webflow site into a Shopify storefront. The script is a Vite project: TypeScript modules in `src/`, built into one
minified ES module, `dist/script.js`, which the site loads with `<script type="module">`.

Smootify's public interface is `src/smootify.d.ts`: `window.Smootify` (the API), the events with their payloads, and
the filters. Nothing else is public: not the components' internals, not the markup they render, not module imports.
Build only on what that file describes, and don't edit it: it's Smootify's, replaced with each release, so the
script's own types go in a file of their own.

## Before writing

1. Read `CLAUDE.md`: the site, its domains and languages, the CMS collections and how it keeps images. Don't ask for
   what's written there.
2. Read `src/smootify.d.ts` for every method, event and filter you use: its comments are the documentation.
3. Read `README.md` and `src/main.ts`: what the script does so far and the markup it needs.
4. If what the script should do is unclear, ask one question. Otherwise write it, then explain what the site needs.

## How a script starts

Everything goes inside one function pushed to Smootify, in `src/main.ts`:

```ts
window.Smootify = window.Smootify || [];
window.Smootify.push((Smootify) => {
  Smootify.on("cart_updated", (cart) => render(cart), { replay: true });
  Smootify.addFilter("checkout_url", (_url, { cart }) => {
    if (cart.totalQuantity < 2) throw new Error("Add one more item to check out.");
  });
});
```

- Smootify runs the function once it knows the visitor and the market, before it loads products and cart. Listeners
  added there get every event from the first `product_loaded` and `cart_updated` on, and filters apply from the first
  request. The session, the market and the money format are already known.
- It works wherever the script loads, before or after Smootify: a function pushed later runs right away. A function
  that throws is logged and doesn't stop the others.
- For state that may have gone out before the function ran (the cart, the session, the consent), listen with
  `{ replay: true }`: the handler also gets the last payload. Never replay actions (`added_to_cart`,
  `initiate_checkout`), or an old one is handled again.
- For data, use the async methods (`getCart()`, `getCustomer()`, `getLocalization()`) rather than keeping payloads
  yourself.
- Don't start a script from `document.addEventListener("smootify:loaded", …)`: the event fires once per page, so a
  late script never sees it. Don't load it with `type="smootify-load"`: that runs after products and cart have loaded,
  so filters miss the first requests. `smootify-load` is for third-party snippets that don't use the API but must wait
  for Smootify, such as one that calls `/cart.js`: paste it as it is and change only the type.

## Events

- `Smootify.on(name, handler, { replay })` and `Smootify.once(name, handler)` return the function that stops
  listening. Use the short name: `"cart_updated"`, `"wishlist:changed_product"`.
- A handler's answer is ignored. Each event goes out once per thing that happened, so never count events to work out
  a state.
- The ones scripts use most (payloads in `smootify.d.ts`):
  - `cart_updated`: the cart at every change, the first load included;
  - `added_to_cart`: `{ lines, cart, goToCheckout }`, after the cart came back;
  - `removed_from_cart`: the ids of the removed lines;
  - `initiate_checkout`: `{ cart }`, when the visitor really leaves for checkout;
  - `errors`: Shopify's errors of a cart operation, or the error a filter threw;
  - `product_loaded`: `{ product, id }`, for every product on the page (cards too), `product` null when it isn't
    sold in the market;
  - `variant_changed`: `{ element, product, variant }`, after a product's first render;
  - `changed_option`: when the visitor picks an option;
  - `user_auth_change`: the customer, null for a guest;
  - `changed_country`: `{ country, oldCountry }`;
  - `cart_opened` and `cart_closed`: `{ element }`;
  - `consent_changed`: the visitor's consent, once known and at every change;
  - `filter_changed`, `sort_changed`, `filter_initial_change`: Search & Discovery.
- Every event is also a DOM event on `document` (`smootify:` and the name, the payload in `event.detail`), typed through
  `DocumentEventMap`. Prefer `Smootify.on`.

## Filters

`Smootify.addFilter(name, filter)` changes a value before Smootify uses it, and returns the filter's removal.
Filters run in the order they were added, each getting what the one before answered.

- Answer the changed value, `undefined` to keep it, or `false` to stop. A filter can be async.
- Throwing also stops, and the form or the cart shows the error's message, which also goes out with
  `smootify:errors`. To tell the visitor why, `throw new Error("…")` with a sentence meant for them.
- `add_to_cart_lines(lines, { goToCheckout, element })`: every addition, whether from a form (the main line and its
  add-ons at once), a box, a direct add, buy again, `addToCart`, `addBoxToCart` or `/cart/add.js`.
- `checkout_url(url, { cart, draftOrder })`: where the visitor goes to check out, from the cart's button, a buy now or
  `Smootify.checkout()`. Answer another url (parameters added), or stop, for terms or a minimum order.
- `draft_order_data(data, { reason })`: the draft order about to be created (Draft Orders, server plan), for a quote,
  a checkout or a buy now with a custom price.
- `metafield_definitions(definitions, { scope, attribute, selector })`: the metafields products, variants or cart
  lines ask Shopify for (`scope` says which); add the ones the script reads. It's synchronous and can't stop.
- Add filters inside the pushed function, so they apply from the first request.

## The API

The pushed function's argument is `window.Smootify`, typed as `SmootifyApi`. What trips people up:

- `addToCart`, `applyCouponCode` and `applyGiftCard` resolve with the cart **or** with Shopify's errors: check
  `Array.isArray(result)`. `updateCartLines`, `removeCouponCode`, `removeGiftCard` and `checkout` reject with them.
- Amounts are decimal strings in the cart's currency (`"12.50"`); `formatMoney` takes cents:
  `Smootify.formatMoney(Math.round(Number(amount) * 100))`.
- `query<T>(query, variables)` asks the Storefront API in the visitor's market: it resolves with `data` and rejects
  with the GraphQL errors. Ask for the fields you use and nothing else.
- `getProductsById`, `getProductByHandle`, `selectVariant(productElement, variantId)`, `openCart()`, `closeCart()`,
  `isLoggedIn()`, `getCustomer()`, `queryCustomer<T>(fields)`, `getLocalization()`, `getConsent()`, `setConsent()`:
  their comments in `smootify.d.ts` say what they answer.

## Writing the code

- **TypeScript, strict.** The starter's `tsconfig.json` must pass as it is: `npm run build` type-checks first. No
  `any`, no `@ts-ignore`, no non-null assertions to quiet an error. Import shapes with
  `import type { Cart } from "./smootify"`.
- **Modules.** Split the code into modules under `src/` when it grows, with static imports only: a dynamic `import()`
  makes Vite add its preload helper, about 1.3 kB, to the file.
- **The DOM, directly.** Use `querySelectorAll`, `closest`, `dataset`, `classList`, and `addEventListener` delegated on
  `document` for elements Smootify renders later. No jQuery and no libraries unless the task can't be done without one:
  every byte goes to every visitor.
- **Webflow's own markup.** Elements are found by custom attributes named after the script (`checkout-terms`,
  `data-message`), and every matching element on the page is handled, not only the first. Text a visitor reads comes
  from an attribute with an English default, so each language sets its own.
- **Styles stay in Webflow.** A state goes on a class (`is-below`, `is-active`) or a CSS custom property
  (`--progress`), for the designer to style. If the script needs CSS of its own, import it with `?inline` and adopt it
  with `document.adoptedStyleSheets`.
- **Markets.** Amounts and thresholds are in the cart's currency; take one per currency when the store sells in
  several (`data-amount-usd`).
- **Nothing Smootify doesn't promise.** Don't poll with timers for its state: an event or a method answers it. Don't
  read or write its storage or cookies, or the inside of its components, beyond the attributes the site designs.
- **Nothing global.** A module keeps its names. If something must be global (a callback for a third party), say so in
  the README.
- **Debug output** goes behind `import.meta.env.DEV`, so the build drops it.

## Build, size and where it goes

- `npm run build` type-checks, writes `dist/script.js`, and says how long it is and where it goes.
- **Up to 10,000 characters: inline.** `<script type="module">` with the contents of `dist/script.js`, in the site's
  custom code or in an Embed on the pages that need it. Webflow's cap is 50,000 per field, but the site's other code
  shares it.
- **Longer: hosted.** Put the file on a bucket of the owner's (Cloudflare R2 on a custom domain works well) and load it
  with `<script type="module" src="…">`. A module is fetched with CORS, so the bucket needs a policy that allows the
  addresses in `smootify.json`.
- Measure after each change. Near 10,000, remove code before you move the script to a bucket.

## Trying it

- `npm run dev` serves `src/` over HTTPS at `https://localhost:<port>`, the port in `smootify.json` (each script has
  its own), to the site's own addresses only. The browser accepts its certificate once, at that address.
- The README has the loader to add on staging and the line that turns it on in the browser. Its key is `cs:` and the
  script's name in snake_case (`cs:checkout_rules`), so each script turns on alone; `CLAUDE.md` gives this one's.
- Check the browser console for errors, both on a fresh load and after Smootify has loaded. On the staging domain
  (`*.webflow.io`) Smootify logs at debug level.

## When done

1. `npm run build` passes. Say how many characters the script has and where it goes.
2. The header comment of `src/main.ts` and `README.md` list what the site needs: the attributes, the classes Webflow
   can style, where the elements go, and anything to set in Shopify.
3. Say what to paste where. Don't publish the site or change Webflow unless you're asked to.
