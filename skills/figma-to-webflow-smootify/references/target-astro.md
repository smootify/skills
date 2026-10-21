# Target: Astro (`@smootify/astro`)

This is the Astro output of the build skill. **Read this whole file before building.** Everything here wins over
the generic wording in `SKILL.md`; where `SKILL.md` or `annotation-format.md` says "Webflow", read the Astro
construct of the tables below. The annotations, the Smootify attributes and the catalogue are the same on both
outputs: only the way the page is written changes. There is no Webflow MCP, no Designer and no CMS sync here: the
build is code in an Astro project, and nothing is left to the person except store, admin and hosting settings.

## Project

Smootify Studio's scaffold creates this project (Astro 7, **Cloudflare only**: Workers with `@astrojs/cloudflare`, static or on demand). **Package manager: the lockfile decides**: `pnpm-lock.yaml` → pnpm
(`pnpm add`, `pnpm exec astro …`), `package-lock.json` → npm (`npm install`, `npx astro …`). Never mix them, never
create the other lockfile. **If a piece is missing, create it
exactly like this.** Never put the Smootify runtime in the bundle: the `@smootify/astro` integration injects the CDN
loader before `</head>`, and the runtime only ever comes from the CDN (there is no runtime package on npm to install).

**Install, when the project has no `@smootify/astro`**: `npx astro add @smootify/astro` (with a pnpm lockfile
`pnpm exec astro add @smootify/astro`); it adds the dependency from npm and `smootify()` to `astro.config.mjs`, then
write `siteId` (and `userOptions`) as below. The adapter, if missing: `npx astro add cloudflare`. Never a `vendor/`
folder, a tarball or a `file:` path for the package. A project made before the npm release that still points it at
`file:./vendor/…tgz`: ask before moving it to the npm version (`^0.1.0`), then reinstall with the project's manager.

```
astro/
├── astro.config.mjs          site, trailingSlash: "always", adapter cloudflare(),
│                             integrations: [smootify({ siteId, userOptions: { productsBase, collectionsBase, vendorsBase }, locales? })]
│                             (siteId and routes read from smootify.config.mjs)
├── smootify.config.mjs       the ONE source of siteId, country, language, metafields, routes (read by config, content.config, Base)
├── package.json              astro, @astrojs/cloudflare, @smootify/astro (from npm); wrangler (dev); scripts dev / build / preview / check
├── tsconfig.json             extends "astro/tsconfigs/strict"
├── public/                   favicon; nothing else (design images live in src/assets; robots.txt and the sitemap come from the integration)
└── src/
    ├── content.config.ts     products / collections (withProducts: true) / vendors with the three loaders
    ├── layouts/
    │   └── Base.astro        <html lang data-smootify-item-slug?>, head (slot "head": the page's <Seo>, no title of its own), Options, Lightbox, global.css,
    │                         Navbar and Footer around the slot (a page that differs places its own, see Rules)
    ├── pages/
    │   ├── index.astro
    │   ├── products/[slug].astro       getStaticPaths over "products"; <Seo type="product"> (folder = routes.products)
    │   ├── collections/[slug].astro    getStaticPaths over "collections"; <Seo type="collection"> (folder = routes.collections)
    │   ├── vendors/[slug].astro        getStaticPaths over "vendors"; <Seo type="vendor"> (folder = routes.vendors)
    │   ├── 404.astro                   <Seo type="other" noindex>
    │   └── <slug>.astro                every other page of the Figma file (cart, search, account…), slug from the annotation;
    │                                   each has its <Seo> (type "page" / "article" / "blog" with an entry, else "other")
    │   (locales on: the same files under src/pages/[...locale]/, see Languages and markets)
    ├── components/
    │   ├── <group>/<Name>.astro        one component per `@component`: group = its `@group` in kebab-case (not the
    │   │                               Figma page: the Product card on the page "Components · Collection" with
    │   │                               `@group: Product` is product/), name = the Figma name in PascalCase
    │   │                               ("Cart line" → cart/CartLine.astro)
    │   └── smootify/                   the pieces the generic build leaves to code, the same in every project:
    │       ├── Options.astro           page-specific window.SmootifyUserOptions only (is:inline, in the head); site-wide options go in userOptions
    │       ├── Lightbox.astro          <dialog> viewer for a[lightbox-item], re-armed on smootify:render
    │       └── Slider.astro            static content slider (not Smootify): scroll-snap + arrows, same parts
    │                                   slider-track / slider-prev / slider-next / slider-dots (arrows inside it only)
    ├── styles/
    │   ├── tokens.css        Figma variables → custom properties; Desktop / Tablet / Mobile modes → media queries max-width 991 / 767
    │   └── global.css        reset, Figma text styles as classes, the generic build's bases
    │                         (:where([popover]) reset, [slider-track] scroll-snap, native label/input),
    │                         the library classes shared by many components (see Styles)
    ├── i18n/                 only with locales: <lang>.json (flat key → text) + index.ts with createTranslator
    ├── assets/               design images exported from Figma (astro:assets <Image>)
    └── icons/                SVGs as Astro components (currentColor)
```

Rules that go with the structure:

- **Trailing slash**: `astro.config.mjs` has `trailingSlash: "always"`, and **every internal link ends with `/`**
  (`/` for home, `/${routes.products}/${entry.id}/`, `/${routes.collections}/${c.id}/`, `/cart/`). Why: Cloudflare serves
  `/x/` with 200 and redirects `/x` to it, so the canonical, the internal links, the sitemap and the hreflang must all be
  the URL that answers 200, the one with the slash; a link without it costs a redirect and splits the signals between two
  addresses. Applies to absolute URLs built for `<Seo>` (`productUrl`, `breadcrumbs`) too. Not to files with an
  extension (`/favicon.svg`), anchors (`#…`), query-only links or external links.

- **Routes**: the runtime defaults to the plural (`/products/`, `/collections/`, `/vendors/`) and they are
  customizable. `routes = { products: "products", collections: "collections", vendors: "vendors" }` in
  `smootify.config.mjs` is the only source; the folders of `src/pages` have the same names; every internal link and
  the `<Seo>` of a collection or vendor page (`productUrl`) read `routes`. `astro.config.mjs` always passes them to the
  integration as `userOptions: { productsBase: routes.products, collectionsBase: routes.collections, vendorsBase:
  routes.vendors }`: the integration writes them into every page before the loader **and** the build uses them (the
  prerender draws links with them, the sitemap finds on-demand routes by them). With the default plural it changes
  nothing; a project that customizes `routes` and forgets them has runtime and prerendered links to the wrong paths.
  A Studio project whose `Base.astro` passes the bases only to `Options.astro` reaches the browser runtime but not the
  build: add the `userOptions` (leave `Options.astro` as it is). Keep the existing indexed URLs of a migrated
  site by setting `routes` to them. The parameter is `[slug]`, its value `entry.id` (= slug).
- **Dynamic pages**: every `@page: template C` is the `[slug].astro` page of that collection. The product page passes
  `itemSlug={p.handle}` to `Base` (→ `data-smootify-item-slug`), and puts its `<Seo type="product">` in the head slot. The seed is automatic (see *Seed and SEO*): nothing to write at the end of the body.
- **A template page is built from the entry, not from the drawn sample.** The Figma frame draws one product; the page
  serves every entry. Pickers come from the product's real options: **one picker per option of `p.options`**
  (`name`, `values`; Shopify allows 3, `position` 1–3), skipping the single option **`Title` / `Default Title`** of
  a product with no options. The drawn pickers (a colour swatch, a pill row, a popover) give the **design**, not the
  count: choose the picker per option by its name and number of values (colour-like name → swatches, many values →
  popover, else pills), and say the rule in the report. The same goes for galleries (`p.images`), accordions and
  any list the drawing repeats.
- **Components**: `@prop`s are the `Props` (camelCase, default = the annotation's value); a variant is a `variant`
  prop that adds the class `is-<variant>`; a slot is `<slot />` (named when there is more than one). Styles in the
  component's scoped `<style>`; `:global()` only for HTML that does not go through Astro (see *Styles*). Classes stay
  the Figma ones (`sm-…`), as on Webflow.
- **Lists**: every item of a product list has the class `sm-dyn-item` (the card boundary of the generic build) and
  inside it `smootify-product data-id={p.shopifyId}`: that id is what the automatic seed reads, so it must be right.
- **Head**: the integration's middleware inserts, right before `</head>`, the runtime stylesheet, the
  `window.SmootifyUserOptions` script of `userOptions` (plus `trailingSlash: true`, which it adds by itself with
  Astro's `trailingSlash: "always"`) and the loader. Every option the page's drawn state depends on goes in
  `userOptions` (route bases, `useBrowserFormatter`, `newCustomerAccountsPublicKey`): the build prerender and the
  loaders' money format see only those. `Options.astro` is for a page-specific override, merged in the browser only;
  it has to come **before the loader**, which holds anywhere in the head (after the page's `head` slot: fine).
- **`astro check` and the Smootify attributes**: Astro's HTML types do not know `product="title"`, `condition`, `cart`,
  `search`, `variant`, `option`, `metaobject`, `discount`, `wishlist`… and `astro check` rejects them on plain elements
  (custom tags such as `smootify-product` pass) unless they are declared. **`@smootify/astro` declares them**: its
  integration injects its `attributes.d.ts`, generated from the contract (`rules.json`, the generic-only attributes from
  its `builds.generic.attributes`; option `types`, default `true`). Never write a
  local `.d.ts` of attributes, a cast or `// @ts-ignore`: when `check` rejects an attribute the catalogue lists, the
  package's typings lack it: report it (it is fixed in the generator), and do not change the markup.
- **Navbar and Footer go in the layout**: `Base.astro` imports `Navbar` and `Footer` and puts them around `<slot />`
  (the cart drawer, the consent banner and the search live inside them), when every page of the file uses them: one
  place, no page forgets them. Only a page that differs (e.g. a checkout-like page without chrome) opts out: give
  `Base` a prop (`chrome={false}`) or place its own pieces; say which pages and why in the report.

## Reading the Figma file

What the Figma tools return, and where the build needs more (all true for this output; the first two also on Webflow):

- **Annotations of component masters are not in `get_design_context`**: it returns those of the frame's own nodes and
  instances, with `data-smootify-annotations`, but not the ones on the master of an instance. Read the masters with
  `use_figma` (`node.annotations`, category `Smootify`) over every main component the frame uses, before Phase 0 (the
  plan, the extensions and the `@ask`s sit there too).
  The pass is long (masters live on other pages: one page switch per `use_figma` call): walk the frame's instances,
  collect `getMainComponentAsync()` (and its component set), dump `annotations` per master, group by page.
- **`get_design_context` truncates on a whole page** (about 25k tokens): call it **per section** (header, hero, each
  list, footer), not on the page frame.
- **`get_variable_defs` returns letter spacing as a percent**: `-3.5` is `-0.035em` (`get_design_context` prints px).
- **`download_assets` returns the pictures in arbitrary order**, not the layers' order. Match each file to its layer
  by `imageHash`, read with `use_figma` (`fills[].imageHash` of the rectangle), as `SKILL.md` says (SHA-1 of the file).
  Never by eye or by position.
- **The Tablet frame is 768 wide, the breakpoint is 991**: the Tablet mode of the variables applies at
  `max-width: 991px`, Mobile at `767px`. What lies between 768 and 991 is extrapolated from the two frames: say so.

## Phase 0 for Astro

One checklist before the first file, in one message. No Webflow MCP, no Designer open, no CMS sync.

- the site id (`@setup: site=` is the Smootify site id; ask if `none`): read `https://cdn.smootify.io/keys/<siteId>.json`,
  `f` is `1`; the project's `smootify.config.mjs` holds the same id;
- the store is ready: products, collections, and a **metafield definition exposed to the Storefront API for every
  metafield the annotations read** (without it the loader gets no value); the licence is active, with the plan and the
  extensions the design uses (read them from the annotation and the catalogue's *Extension* column);
- the domains: without a plan Smootify runs (with its badge) only on `localhost` and `*.workers.dev`; the production
  domain needs the licence, and it must be the domain registered in the Smootify dashboard, exactly (only `www.` is
  normalised: `shop.example.com` and `www.shop.example.com` are the same, a subdomain is not). The debugger loads only on
  `*.workers.dev` and the Vite dev server. Put the registration in the report when the domain is not there yet;
- the Customer Account API client id, when the design has account parts (sign in, account pages, orders, addresses,
  profile, store credit): in Shopify, `http://localhost:4321` and the preview and production domains go in its
  JavaScript origins and callback URIs; the client id goes in the integration's `userOptions` as
  `newCustomerAccountsPublicKey`. Without it Smootify turns off login and every account element;
- the hosting is Cloudflare (Workers, `@astrojs/cloudflare`), and the domain and the account are the person's.
  Automatic updates from a store change are **optional** and are not part of this build: Smootify Studio's Deploy
  section (or the Smootify dashboard) turns them on. You never add `webhook` to the config, write `src/worker.ts` or
  edit `wrangler.jsonc` for them unless the person asks; a new project starts with them off;
- the Search & Discovery filters the design uses (labels are case-sensitive, a filter whose label the app does not know
  is removed by Smootify; colour filters need native swatches): no tool reads them (`probe_storefront` checks the
  token and published products only), so list them as **unverified** for the person to check;
- the languages and markets: if the annotation or the plan does not say, and the store has more than one language or
  market, ask whether the site is built in them; **default: one language, `locales` off** (see *Languages and markets*);
- the redirects, policies and other admin settings the design depends on, for the report.

**Ask only what the person decides**, as in `SKILL.md`: a question the catalogue, the contract or the annotation
answers is applied and written in the report.

## How each directive is built in Astro

| Directive | Build |
|---|---|
| `@setup` | Read it first. `site=` is the Smootify site id (ask if `none`). `image=url` means product pictures are plain `<img>` with `src` / `alt` from the entry (`p.image`, `p.imageAlt`); the other answers are already in the annotations |
| `@ask` | **Do not build** the node's Smootify part. List it first in the report: the annotation is not finished |
| `@skip` | Do not build the node |
| `@repeat` | Render the node **once**, as the template Smootify repeats. Its `@skip` siblings are drawn copies. A list that Astro renders itself (`@list`) maps over entries instead |
| `@wrap: <tag or element> over <a>..<b>` | A wrapper element in the markup around the siblings from `a` to `b`: a plain `div` (or the tag named) with no class unless the annotation gives one. Then `@attr: wrap …` and `@cms: wrap attr:…` on the same node go on the wrapper as attributes (`@wrap: div … @attr: wrap not-tagged=bookable` → `<div not-tagged="bookable">…</div>`; `not-tagged` and its kin need a product in scope, so the wrapper sits inside `smootify-product`) |
| `@target: <layer>` | Apply the node's directives to that descendant |
| `@component` `@group` `@desc` | `src/components/<group-kebab>/<Name>.astro`, with the `@desc` as a comment at the top of the file |
| `@prop` + `@tip` | A field of `interface Props` (camelCase, default from the annotation), the `@tip` as its JSDoc comment |
| `@bind: text\|image\|alt\|link\|domId = P` | A `{prop}` expression in the element: text content, `src`, `alt`, `href`, `id` |
| `@bind: attr:<name> = P` | `attr={value}` on the element |
| `@bind: visibility = P` | `{show && …}` around the element |
| `@slot` | `<slot />` (`<slot name="…" />` when the component has more than one). The `Options` area of Add to cart (pickers, add-on) is its default `<slot />`; the caller fills it. A required prop left empty (an add-on product id) renders nothing |
| `@axis: X = variant` + `@variant: N` | A `variant` prop that adds the class `is-<variant-kebab>` on the component's root; what the variant changes is `.root.is-<variant>` in the component's `<style>` |
| `@axis: X = state` + `@state: <class> on <layer>` | The state class combo, styled in the component's `<style>` (`.base.<class>`). Smootify toggles the class at runtime; nothing to pass |
| `@axis: X = interaction` | `:hover`, `:focus-visible`, `:active` on the class |
| `@axis: X = breakpoint` | Media queries (`max-width: 991px` Tablet, `767px` Mobile) on the same element, in the same component. Never a second element |
| `@axis: X = split` | Each variant carrying `@component` is a separate component |
| `@axis: X = prop` / `sample` | Already covered by the prop it names (a `boolean` for `{show && …}`, a `string` for `attr={…}`) / nothing |
| `@attr: name=<Name>` on a form field | The field's `name` attribute; keep the case |
| `@set: P = v` (and `@set: Variant = N`) | The props passed on the instance (`<Card variant="compact" title="…" />`); `@set: P = prop:Q` passes the prop of the component being built |
| `@cms: P = Collection.Field` · `@cms: attr:<name>\|text\|image\|link = Collection.Field` | The entry's field (table below) as the prop value on the instance, or as the expression in the plain element (`attr:data-id` → `data-id={p.shopifyId}`) |
| `@inline: Master` | Copy the master's annotated markup in place of the instance (not an import); its `@bind`s become the props of the component it lands in, matched by name |
| `@element: FormSuccess` / `FormError` | An element with the `[form-done]` / `[form-fail]` attribute and `hidden`, next to the `<form>` inside the form's host |
| `@use: Component` | Import the component and place it, instead of building the frame. On a main component: build no component for it, and place the target (with its `@set` values) wherever its instances are. When the frame **draws** something the component's default does not (a secondary button where the component is primary, a compact card), the instance passes the props / variant that match the drawing: the component is the markup, the frame decides its values |
| `@page: template C` | `src/pages/<route>/[slug].astro`, where `<route>` comes from `routes` (default `products`, `collections`, `vendors`), with `getStaticPaths` over that collection (`products`, `collections`, `vendors`; params `{ slug: entry.id }`) |
| `@list: C limit=… sort=…` | In the frontmatter: `getCollection` / `getEntries`, sorted and sliced; each item is wrapped with the class `sm-dyn-item` and contains `smootify-product data-id={p.shopifyId}`. **Without `limit`, slice to the number of items the Desktop frame draws**, never the whole collection (two tiles drawn, five collections in the store: the page would grow by a row). Say in the report that the annotation had no `limit` |
| `@manual` | Done in code. There is no Designer: only store, admin and hosting settings stay with the person |
| *(no directive)* a tag whose catalogue row must contain `form` | A plain `<form>` around the tag's content, then the fields inside. It is never a manual step |
| `@note` | Ignore |

Where the Webflow MCP could not do something and `@manual` said so, here you write the code. The ban on
`data_whtml_builder` and the whole MCP vocabulary of `target-webflow.md` do not apply.

## `@cms` → content collection

`@cms` names a Webflow CMS field; Astro reads the same data from the content collection of the loader. In a page or
component that has the entry, `p = entry.data` (`const p = entry.data;`). Links use `routes`: `import { routes } from "../../smootify.config.mjs"` (path relative to the file).

**Products** (`getCollection("products")`)

| Webflow CMS field | Astro |
|---|---|
| Name | `p.name` |
| Slug | `entry.id` (or `p.slug`) |
| Shopify ID | `p.shopifyId` |
| Description | `<Fragment set:html={p.description} />` |
| Image / Image URL | `p.image` (`null` when none) |
| Image Alt | `p.imageAlt` |
| Is Gift Card | `p.isGiftCard` |
| Price | `p.price` |
| Price Formatted | `p.priceFormatted` |
| Compare At Price | `p.compareAtPrice` (`0` when none) |
| Compare At Price Formatted | `p.compareAtPriceFormatted` (`""` when none) |
| Vendor | `const vendor = p.vendor ? await getEntry(p.vendor) : undefined`, then `vendor.data.name`, link `/${routes.vendors}/${vendor.id}` |
| Collections | `(await getEntries(p.collections)).filter(Boolean)`, each `c.data.name`, link `/${routes.collections}/${c.id}` |
| SEO Title / SEO Description | `p.seoTitle` / `p.seoDescription` |
| Product Type | `p.productType` |
| a metafield field | `p.metafields.<key>`, **and add the key to `metafields` in `smootify.config.mjs`** (the loader loads only those) |
| the current item's page link | `` `/${routes.products}/${entry.id}` `` |

**Collections** (`getCollection("collections")`, loaded with `withProducts: true`): Name `c.name`; Slug `entry.id`; Shopify
ID `c.shopifyId`; Description `<Fragment set:html={c.description} />`; Image / Image URL `c.image`; Image Alt
`c.imageAlt`; SEO Title / SEO Description `c.seoTitle` / `c.seoDescription`; a metafield `c.metafields.<key>` (and the
key in `metafields`); its products `(await getEntries(c.products)).filter(Boolean)`; the current item's page link
`` `/${routes.collections}/${entry.id}` ``.

**Vendors** (`getCollection("vendors")`): Name `v.name`; Slug `entry.id`; its products `await getEntries(v.products)`
(filtered); the current item's page link `` `/${routes.vendors}/${entry.id}` ``.

**Filter out undefined references.** A reference to something not in the store (a product not published to the
Storefront API channel) resolves to `undefined`: always `.filter(Boolean)` after `getEntries`, and check the vendor.

**The Astro-only superset** is there for what the Webflow CMS could not bind: `p.images` (all pictures, with `url`,
`altText`, `width`, `height`: the gallery's first image server-rendered), `p.imageWidth` / `p.imageHeight`
(`<img width height>`), `p.options`, `p.variants`, `p.priceRange`, `p.compareAtPriceRange`, `p.tags`,
`p.availableForSale`, `p.vendorName`, `p.currencyCode`, `p.media`, `p.seo`, `p.descriptionText`, `p.rating`
(`{ value, bestRating, worstRating, count? }` from `reviews.rating` / `reviews.rating_count`, absent without them). Use them to server-render
what the design shows before Smootify loads (the first picture, a "from €…" range, a price) and leave the
interactive part (variant pickers, the cart) to the Smootify elements.

## Element mapping

Replaces the Webflow Element Type Mapping. The `@element` vocabulary of the annotations is the same; the output is
plain HTML.

| `@element` / Figma | Astro |
|---|---|
| `DivBlock` / `Container` / `Section` | `div` / `section`; semantic tags (`nav`, `header`, `footer`, `main`, `aside`, `article`, `address`, `figure`) are just tags |
| `Heading` | `h1`–`h6` |
| `Paragraph` | `p` |
| `TextBlock` | `div` |
| `TextLink` / `LinkBlock` / `Button` drawn as a link | `a` |
| `DOM @tag: button`, a Smootify `button[...]` | a real `<button type="button">` |
| `Image` | `<img>` for Shopify pictures (`width` / `height` from the entry, `loading="lazy"` except the first visible one); `astro:assets` `<Image>` for design pictures in `src/assets` |
| `BY_CUSTOM_TAG` | the tag itself (`<smootify-product …>`) |
| `Form` / `FormBlock` | `<form>` |
| `FormTextInput` / `FormTextarea` / `FormSelect` / `FormCheckboxInput` / `FormRadioInput` | native `input` / `textarea` / `select` with the real `type`, `placeholder`, `required`, `checked`, `disabled`: none of Webflow's reserved-attribute limits apply |
| `FormButton` | `<button type="submit">` (with its `[data-state="default"]` / `[data-state="loading"]` children when it is a Smootify submit) |
| `FormBlockLabel` | `<label for>` tied to its field |
| Checkbox / radio that Smootify clones | `<label><input type="checkbox\|radio"><span form-label>…</span></label>`: the look comes from `:checked` / `:has(:checked)` in CSS |
| `Dropdown` | only `[popover]` + `popovertarget` (or `<dialog>`), never a `.w-dropdown` |
| Language / country switcher (`country-switcher`, `[locales]`, a "language" or "country" picker) on a site with `locales` on | **the `[locales]` element with real links** from `localeSwitcherLinks` (see *Languages and markets*): each option goes to the same page in the other language or market. **Never `country-switcher` there**: it changes the country without changing page, so the page (its language, prices, seed) would disagree with the visitor. Without `locales`, `country-switcher` stays as the catalogue says. Say in the report when an annotated `country-switcher` was swapped |
| `sort-dropdown`, `filter-dropdown`, `variant-dropdown`, `addon-dropdown`, `configurator-dropdown` (the tag the annotation or the Figma note names) | **the `*-popover` tag**: `sort-popover`, `filter-popover`, `variant-popover`, `addon-popover`, `configurator-popover`. Writing the `*-popover` tag is the preferred 2.0 form, but in the generic build every `*-dropdown` tag also reads the `[popover]` it holds like its `*-popover` twin (it removes itself only if the markup has no `[popover]` with an option link or button), so a `*-dropdown` tag needs no `.w-dropdown`. The catalogue's `*-dropdown` rows describe the Webflow markup; the popover twin has the same attributes. Say in the report when the annotation's tag was swapped |
| Popover | `[popover]` with its trigger `button popovertarget`; open and close transitions in CSS (`@starting-style`, `transition-behavior: allow-discrete`). Never a popover inside a template Smootify repeats: use `details` / `summary` there |
| `Tabs` Smootify fills (`subscription-swatches`, Magic Box categories) | WAI-ARIA tabs keyed by `data-tab` (`[role="tablist"]` > `[role="tab"]`, `[role="tabpanel"]` with `hidden`); Smootify runs them. Static tabs: the same markup plus a tiny script in the component |
| `Slider` inside `[gallery="slider"]` or Magic Box | `[slider-track]` (the slides are its children), `[slider-prev]`, `[slider-next]`, `[slider-dots]` (first child = the dot template) |
| A static content slider (not Smootify) | `components/smootify/Slider.astro` |
| `Lightbox` | `a[lightbox-item]` + `components/smootify/Lightbox.astro` (already in `Base.astro`) |
| Code Embed | markup, `<style>` or `<script>` in the component |
| `CMSCollection` / `CollectionList` | the frontmatter map (see `@list`) |
| Navbar / mobile menu | `[popover]` or `<dialog>` with `data-overflow-body` |
| Accordions | `<details>` / `<summary>`; `open` is fine as a bare attribute here |
| `RichText` | `<div set:html={…}>` for data, a styled `div` for static copy; style its `h2`, `p`, `ul` with `:global()` |

**Marker tags are elements, not attributes.** The catalogue's *Tag marker* section is written `@tag: search-with-query`
and the output is `<search-with-query>…</search-with-query>`: the tag itself. Only a selector the catalogue writes with
brackets (`[consent-panel="banner"]`, `[box-category]`, `[slider-track]`) is an attribute. Read the catalogue entry
(or `get_element`) for the exact form before writing the markup; `[search-with-query]` is not the marker.

## Lists, carousels and sliders

- **`@list` is rendered by Astro** (table above): entries mapped in the frontmatter; the automatic seed covers the cards (see Seed and SEO).
- **A Smootify source instead of `@list`** (`Source = best-seller`, `custom-query`, `related`, `last-viewed`,
  `wishlist`…): decide per source and write the decision in the report.
  - What the loader can answer at build time (a collection, a query on tags, newest by `createdAt`, products tagged
    `featured` first for "best sellers", since the loader has no sales data) is **rendered from the entries and
    covered by the automatic seed**: the same cards as a `@list`, each `sm-dyn-item > smootify-product[data-id=gid]`.
  - What depends on the visitor or on Shopify's analytics (`last-viewed`, `wishlist`, `related` / complementary, real
    best-selling) stays **one template card** with the Smootify `data-id` (`data-id="last-viewed"`): Smootify clones it.
    It has no server data, so it needs the pre-load rules of *Styles* below.
  Do not invent build-time data for a source that has none, and never leave a source that could be rendered as a bare
  template when the design is meant to show products before Smootify runs.
- **`sm-dyn-item` is the card component's own root** (the slide of a carousel, the item of a list): the component
  renders `div.sm-dyn-item > smootify-product[data-id]`, so no caller forgets it. In a carousel the track's children are
  those items (`.track > .sm-dyn-item`).
- **Cards per view come from the frames**: count the cards drawn in the Desktop, Tablet and Mobile frames of the
  slider (they can differ per slider variant: 4 / 2 / 2 here, 4 / 3 / 2 there) and write the width of the track's
  children per breakpoint in CSS (`flex: 0 0 calc((100% - gap * (n - 1)) / n)`, `max-width: 991px` / `767px`).
  The variant-size rule of `SKILL.md` covers aspect ratio, not the count.
- **`Slider.astro` is for static content** with its own arrows and dots in fixed markup. A slider that needs its parts
  elsewhere (arrows in a header row, dots and arrows in a footer row, a product carousel) writes the same `[slider-track]`,
  `[slider-prev]`, `[slider-next]`, `[slider-dots]` in its own component, styled by the component, plus a small
  `<script>` in the component that wires them (scroll by one page, active dot); the starter's `ProductCarousel.astro` does
  this. Do not bend `Slider.astro` for one design; if several components need the same wiring, extend it with named
  slots for the arrows and say so in the report.

## Search & discovery on Astro

For `smootify-search-discovery` (collection page, search results, any filtered list). Facts from the runtime's code;
the Smootify MCP has no generic example of it yet (`get_example` serves Webflow markup only), so this is the model.

**The list**
- **Render the real cards on the server**: `sm-dyn-item > smootify-product[data-id=gid]` as in *Lists*, real title,
  price and link. Smootify clones the **first** `.sm-dyn-item` as the card template (it is not taken out of the page).
  The server cards stay as they are until the first results: when those are the same products in the same order (the
  default first page, from the seed) the drawn cards are kept as the list's own; otherwise the list is replaced in one
  step. No `data-id="filter"` and no placeholder or loader card are needed (the runtime writes `data-id="filter"` on
  the server cards itself, which only keeps them inert).
- **Render only `limit` cards**, however many the collection has (`limit`: default 50, min 1, max 250). The first page
  is served from the seed only when the markup matches the seed's key, so: `limit` equal on the host and in the code
  that picks the cards; the cards in the collection's default order (no sort of your own: the list would reshuffle at
  boot); `unavailable-products` (default `LAST`) the same as the host's.
- **`data-collection`** takes the collection's **numeric id or its gid** (`c.shopifyId`), never the handle.
- **Seed**: automatic, from the rendered cards' `data-id` (see *Seed and SEO*); write nothing. The collection seed
  (`data-smootify-collection`) is **not for S&D**: only a `smootify-product data-id="specific-collection"` reads it. The first page is **not** seeded (a network search runs)
  with `data-wait`, a `selected-value` on any widget (a preselection makes a second search: leave it out unless the
  design preselects), or `?q=`, filters or `?page=` in the URL.
- No shift at boot when the seed serves the first page: the cards are not taken out at mount. A state that is not
  seeded (above) replaces the list once, when its results arrive.

**Parts** (each widget needs a `<form>`; the runtime strips the form's attributes except `id` and `class` and blocks
its submit)
- **The visible filter label is the site's**: write it as a `<span>` / `<p>` / `<legend>` outside the value list.
  `label` is the Shopify filter key (case-sensitive, e.g. `Color`), `custom-label` the name shown in the active chips.
- **Popover widgets** (`filter-popover`, `sort-popover`): the trigger is a `button type="button" popovertarget="<id>"`
  and the `[popover]` has that `id`. The **option template is the first `a` or `button:not([popovertarget])`** in the
  popover (write `type="button"`); its siblings are removed. The trigger shows its first text (a `filter-popover`
  always; with `show-count` the count is in it); a `sort-popover` shows the first text or the `[data-selected]` element
  and keeps the designer's text until the visitor sorts.
- **One template row** for `filter-list`, `filter-checkbox`, `sort-radio`: a single `<label><input><span form-label>…</span></label>`
  (the runtime repeats only the first label and does not remove extra sample ones). Without `[form-label]` it wraps
  the label's last text itself. The count is `<span class="filter-count-label">` inside the row (`show-count`;
  `hide-parenthesis` drops the brackets); `filter-popover`, `filter-swatches` and the other pickers drop extra samples.
- **Selected state the runtime writes** (style these, do not write them): `aria-current="true"` on a popover option;
  `active` and `is-active` plus `aria-pressed` on a swatch button; `checked` on a radio / checkbox (style with `:checked`
  / `:has(:checked)`); `empty-count` on a value with no products; `preselected-filter` on a chip the page set;
  `disabled` / `is-disabled` on `[filter="active-count"]` and `[type="reset"]` at 0. The trigger gets `aria-expanded`.
- Never `hidden` on a `filter-*` / `sort-*` widget: the runtime writes `style.display` on it.

**Before boot** (`smootify-search-discovery:not(.inited)`)
- **The stylesheet already hides**: `[filter="empty-state"]` unless the host is `.empty`; `[search="with-query"]` /
  `[search="no-query"]` by `.has-query`; `[count-condition="one"|"other"]` by `.is-single-result`; `[skeleton="…"]`
  until the first render.
- **The site hides, with CSS on the host state class, never with `hidden`**: the active chips (show them with
  `.is-filtered`), **Load more / previous / next** (visible until boot: `…:not(.inited) button[data-action]`, and
  after boot only with `.has-pagination`), numbered pages (`.has-page-numbers`), and the sample text rows of the filters
  (`visibility: hidden` until `.inited`, so the layout does not jump). **Never `hidden` on the empty state, Load more or a
  widget**: the generic `[hidden]` rule wins with `!important` and the runtime never removes it (it toggles classes and
  `style.display`).
- **Host classes**: `empty` (S&D) / `is-empty` (the search page), `is-single-result` (both: use it for
  "product / products"), `is-filtered`, `has-pagination`, `has-page-numbers`, `inited` (after the first render),
  `has-query`; `loaded` on a widget. `data-count` on the host and `[filter="count"]` carry the total.
- The closest verified markup is the runtime's test fixtures (`plp.html`: `smootify-search-discovery` with
  `data-collection`, `limit`, one `filter-list`, one `sm-dyn-item`); no S&D page has been run live from Astro yet, so
  say in the report what was only checked from the build output.

## Generic build contract instead of `w-*` classes

The generic build (the runtime `@smootify/astro` loads) reads HTML, not Webflow classes. **Never write a `w-*` class
or a `data-w-*` attribute.** The catalogue's section *Build generica (Astro)* (attributes only the generic build reads,
the attributes of both builds, Webflow structure → generic build) and the values marked *(solo build generica)* are the
generated form of this table (contract §2.15, §2.16, §4 last column); the attributes of the generic build are not in
the glossary, which describes Webflow values. If the catalogue copy has no such section (a copy generated before the
Astro release), this table is the source. Webflow structure → generic build:

| Webflow structure | Astro / generic build |
|---|---|
| `.w-dyn-item`, `.w-dyn-list` | `.sm-dyn-item` on the card (card boundary); no list wrapper class |
| `.w-dyn-bind-empty`, `.w-condition-invisible` | the `hidden` attribute (Smootify marks its own with `data-smootify-hidden`: never write that one) |
| `.w-dropdown*`, `.w--open` | `[popover]` + `popovertarget`; the current option gets `aria-current="true"`, the trigger `aria-expanded` |
| `.w-slider`, `.w-slide`, `.w-slider-dot`, `.w-slider-arrow-*` | `[slider-track]`, `[slider-prev]`, `[slider-next]`, `[slider-dots]` |
| `.w-tabs`, `.w-tab-link`, `.w-tab-pane`, `data-w-tab` | WAI-ARIA tabs keyed by `data-tab` |
| `.w-lightbox` | `a[lightbox-item]` + the project's `Lightbox.astro` |
| `.w-form-done` / `.w-form-fail` | `[form-done]` / `[form-fail]` next to the `<form>`, with `hidden` |
| `.w-form-label`, `.w-checkbox`, `.w-radio` | `<label><input …><span form-label>…</span></label>` |
| `.w-locales-item` | `a[hreflang]` inside `[locales]` |
| `.w-nav`, `.w-nav-overlay` | `[popover]` or `<dialog>` with `data-overflow-body` |
| `.w-file-upload-input` | `input[type="file"][data-name]` |
| `data-wf-site`, `data-wf-item-slug`, `Last Published:` | `data-smootify-site`, `data-smootify-item-slug`, `data-smootify-build` on `<html>`: written by the integration and by `Base` (`itemSlug`), not by hand |

The attributes of the generic build: `slider-track`, `slider-prev`, `slider-next`, `slider-dots`, `lightbox-item`,
`form-done`, `form-fail`, `form-label`, `locales`, `data-tab`. `data-smootify-site`, `data-smootify-build` and
`data-smootify-item-slug` are written by the integration and the layout; `data-smootify-hidden` is written only by
Smootify.

- `hidden` replaces `w-condition-invisible`. The generic stylesheet hides `[hidden]` with `display: none !important`
  (except `hidden="until-found"`): a class with a `display` does not show a hidden element.
- `.sm-dyn-item` is the card boundary: a product not found, or `hide-if-product-in-cart`, sets `hidden` on it.
- **Server-side conditions are Astro expressions** (`{p.compareAtPrice > p.price && …}`); **runtime conditions**
  (`condition="out-of-stock"`, `customer-condition`, `if-metafield`…) stay attributes, exactly as in the catalogue.
- The DOM event `smootify:render` on `document` (debounced 400 ms; `detail.nodes` is always an empty array) replaces the Webflow
  restart: a site script that wires something itself (a lightbox, its own animations) listens to it and reads the
  page again. Sliders, tabs and popovers need no restart. See *Animations*.
- `--smootify-closed-display` and `--smootify-backdrop-color` still work on popovers, with the same meaning as on
  Webflow. `data-overflow-body` on a popover or `dialog` stops the page scrolling under it (cart drawer, menu).

## Seed and SEO

**Why**: with the seed, the runtime makes **zero Storefront queries for products on first load**.

- **What the integration does by itself, never by hand:** `sitemap.xml` (from every page's `<Seo>` canonical and
  hreflang, `noindex` and 404 left out; never add `@astrojs/sitemap`), a `robots.txt` with the `Sitemap:` line when the
  project has none (if the project has its own, add the line to it), `aggregateRating` in the product JSON-LD from the
  store's `reviews.rating` / `reviews.rating_count`, `data-smootify-404` on the built 404 page (store redirects and
  Collabs creator links), and products hidden with `seo.hidden` / `sync.hidden` left out of the loaders, as in the
  Webflow CMS sync. A page needs `site` set in `astro.config.mjs` for the sitemap.

- **The seed is automatic.** After `astro build`, the `@smootify/astro` integration writes the seed scripts into every
  page, from the runtime's `buildSeed`; `<SmootifyProducts>` / `<SmootifyCollection>` render nothing while the automatic
  seed is on (the default). **Never write them by hand** and never add `ids`. What the skill owns is the input: every
  card's `smootify-product data-id={p.shopifyId}` must be the right gid, because the seed is built from the ids found in the
  page.
- **Seed country**: leave `country` empty in `smootify.config.mjs` = the store's primary market, so a new visitor
  uses the seed. A licence is never inlined: it is always fetched from the CDN.
- **Verify the seed in `dist`** (see *Verify*): `data-smootify-products` and `data-smootify-seed`, with `data-country` /
  `data-primary-market`, on every page that renders products. `data-smootify-collection` appears only where a
  `specific-collection` list reads it (not for S&D: see *Search & discovery on Astro*).
- **Every page has a `<Seo type=… />`** in the head slot (`import Seo from "@smootify/astro/components/Seo.astro"`), and
  nothing else writes `<title>`, description, canonical, `og:*`, `twitter:*` or JSON-LD by hand. It builds them from the
  entry (`seoTitle` else `name`, `seoDescription` else an excerpt, first image, canonical on the page path) and adds the
  JSON-LD of the type:
  - product: `<Seo type="product" entry={entry} url? siteName breadcrumbs={…} />` (`breadcrumbs`: `[{ name, url }]`,
    absolute, home → collection → product). `<ProductSeo product={entry} …>` is the documented shortcut for exactly
    this; use it only if you prefer, never both. The page passes `itemSlug={p.handle}` to `Base`;
  - collection: `<Seo type="collection" entry={c} products={listed.map((e) => e.data)} productUrl={(p) => abs(`/${routes.products}/${p.slug}/`)} />`
    (the default `productUrl` is `/products/`; passing it keeps the links right when `routes` is customized);
  - vendor: `<Seo type="vendor" entry={v} products={…} productUrl={…} />`; article, blog, page: `type` with the `entry`;
  - home: `<Seo type="home" title description siteName logo? />` (title and description from the design or annotation);
  - other (404, cart, search, account…): `<Seo type="other" title description? />`, `noindex` for 404 and pages that must
    not be indexed (account, cart, checkout-like).
  `title` / `description` are passed only where the entry has none or the design says otherwise. `siteName` is the
  store's name, the same on every page.
- **Absolute URLs use `Astro.site ?? Astro.url` as base** (`const abs = (p: string) => new URL(p, Astro.site ?? Astro.url).toString()`):
  a project without a domain yet has no `site` (Studio writes `site: "http://localhost:4321"` until it has one;
  `<Seo>`'s canonical and `og:url` need it). Pass `url` only if the canonical is not the page path.
- **Every page has exactly one canonical, one `<title>`, one description and its og tags**, all from `<Seo>`; `Base`
  has no `<title>` of its own.
- The seed serves the **default first page** of a `smootify-search-discovery` list; a filtered, sorted or searched
  state, and a logged-in customer, still query.

## Languages and markets

Only when the store has more than one language or market **and** the person wants them (Phase 0; default: one language,
nothing in this section applies and no file moves). Then:

- `astro.config.mjs`: `smootify({ siteId, locales: true })`, or `locales: { languages: ["EN", "IT"], markets: ["CH", "europe"], paths: { "en-ch": "ch" } }`
  to narrow it or rename a prefix. Discovery reads the Storefront API only.
- **URL scheme**: the primary market's default language at the root (`/`), its other languages at `/<lang>/` (`/it/`),
  every other market at `/<lang>-<suffix>/` (`/en-ch/`; suffix = country code of a one-country market, else the market
  handle). Each locale page has its own `<html lang>` (`en`, `it`, `en-CH`): that is how the runtime knows the page's
  country and language, and the automatic seed is built per page in that market (own currency and prices).
- **Route files** move under `src/pages/[...locale]/` (home, products, collections, vendors, every other page), same
  names as before. Pages with no other parameter: `export function getStaticPaths() { return localeStaticPaths(); }`;
  `[slug]` pages: `return localizedStaticPaths(await getCollection("products"));` (props `{ locale, entry }`, so the page
  shows the entry of its locale). `Base` takes `locale` and writes `<html lang={locale.htmlLang}>`.
  `import { localeStaticPaths, localizedStaticPaths, localizedPaths, alternatesFor, localeUrl, localeSwitcherLinks, createTranslator } from "@smootify/astro/locales"`.
  On demand mode: `prerender = false`, `getLiveEntry(…, { id, locale: locale.key })` (see *Rendering mode*).
- **Links**: every internal link is `localeUrl(locale, `/${routes.products}/${p.slug}`)` (also `/` for the logo), never a
  bare path. The `routes` stay the only source of the folders.
- **Translated slugs**: a product can have a different handle per locale. On a `[slug]` page, compute
  `const paths = localizedPaths(await getCollection("products"), entry, (e) => `/${routes.products}/${e.data.slug}`);`
  and pass `alternates={alternatesFor(paths, Astro.site!)}` to `<Seo>` and `paths` to the switcher. Pages whose path is
  the same in every locale (home, 404, cart…) pass the string path, and `<Seo>` writes the hreflang by itself.
- **Design texts**: `src/i18n/<lang>.json` (flat `{ "key": "text" }`, `{name}` placeholders; a file per language, or
  per locale key such as `it-ch.json` when a market differs) and `src/i18n/index.ts`:
  ```ts
  import { createTranslator } from "@smootify/astro/locales";
  const files = import.meta.glob("./*.json", { eager: true, import: "default" }) as Record<string, Record<string, string>>;
  export const t = createTranslator(Object.fromEntries(Object.entries(files).map(([f, d]) => [f.replace(/^\.\/|\.json$/g, ""), d])));
  ```
  **Every fixed text of the design goes through `t(locale, "<key>", vars?)`** (nav, buttons, labels, headings, empty
  states, footer, form copy, `aria-label`s), with the same key in every file; components take `locale` as a prop. The
  file of the **source language is written from Figma**; the other languages are **left for the person or a translation
  step, with the same keys** (until then `t` falls back to the language of the root locale): say so in the report, with
  the list of languages missing a file. Texts that come from the store (names, descriptions) are not in the files.
- **Switcher**: the design's language / market switcher is the runtime's `[locales]` markup: a component that renders
  `localeSwitcherLinks(paths, locale)` as `<a href={l.href} hreflang={l.hreflang} aria-current={l.current ? "true" : undefined}>{l.label}</a>`
  inside the `[locales]` element (`l.region` for the market name). Do not use `country-switcher` on a localized site: it
  changes country without navigating and the page would disagree with the visitor.
- **SEO**: `<Seo>` adds the hreflang alternates (every locale plus `x-default`) by itself; pass `alternates` only for
  translated slugs, as above. Canonical and hreflang hrefs end with a slash, as `Astro.url` does.
- **Cost**: pages = routes x locales (20 products and 7 collections in 8 locales are 216 pages), and each locale pages
  through the Storefront API. Many markets: use on demand mode (`prerender = false`, live loaders), and narrow
  `languages` / `markets`; say the page count in the report. A language with a region (`PT_BR`) belongs only to its market.

## Animations

The generic runtime fires `smootify:render` on `document` (debounced 400 ms; `detail.nodes` is always an empty array) after
it renders or clones; it replaces Webflow's IX restart. Animations are **code in the component's `<script>`**, never an
interaction tool or a CDN tag:

- **CSS first**: transitions, `@starting-style`, scroll-driven animations (`animation-timeline`). It needs no script and
  survives clones.
- **GSAP when the design needs timelines or ScrollTrigger**: `pnpm add gsap` (the project's package manager), import it
  in the component script, never a CDN `<script>`.
- **Static design parts** (a hero, a section the server renders) bind once on load.
- **Anything that animates nodes Smootify clones or rewrites** (product cards in lists, S&D results, cart lines) binds
  on `smootify:render` by querying the document for the nodes not bound yet and marking them (the event names no
  nodes): `document.addEventListener("smootify:render", () => bind(document.querySelectorAll(".sm-dyn-item:not([data-bound])")))`.
  The binding is **idempotent** (a data attribute or a `WeakSet`), because the event fires again at every render. For
  S&D results without the debounce, `smootify:search_discovery:rendered` also works (it names no nodes either). Call `ScrollTrigger.refresh()` after binding, the layout has changed.
- Respect `prefers-reduced-motion: reduce`: no movement, only the final state (CSS `@media`, or `gsap.matchMedia()`).

## Forms Smootify does not handle

A form whose data Shopify and Smootify do not take (a contact form, a quote request, a newsletter outside Shopify).
`webflow-form` is not one: in the generic build it only shows `[form-done]` and follows `data-redirect`, **it sends
nothing** (contract §1, `webflow-form`). Never build a form that must deliver its data on it:

1. **If the data belongs in Shopify, first choice: Smootify's metaobject creator** (no backend). Check the catalogue /
   `get_element` for the element before building anything else.
2. **Otherwise an Astro API route on the Worker**: `src/pages/api/<name>.ts` with `export const prerender = false`, a
   `POST` handler, input validated server-side, a honeypot field and/or Cloudflare Turnstile against spam, and the email sent with
   **Cloudflare Email Service**: a `send_email` binding declared in the wrangler config (`"send_email": [{ "name": "EMAIL" }]`),
   read through `import { env } from "cloudflare:workers"` (`env.EMAIL.send({ to, from, subject, text })`; `from` an address
   on a verified, onboarded domain: otherwise `send` fails with `E_SENDER_NOT_VERIFIED` / `E_SENDER_DOMAIN_NOT_AVAILABLE`).
   It needs the **Workers Paid plan** (about $5/month; the docs state paid is required to send to arbitrary recipients; 3,000 emails/month
   included). Put both in the Manual list of the report.
3. **A site that needs a lot of backend** (many endpoints, auth, a database): recommend **Hono** (on the same Worker, or
   a separate Worker) instead of piling up API routes.
4. **The form's UI**: the success and error elements are `[form-done]` / `[form-fail]` with `hidden`, next to the `<form>`;
   the component's `<script>` submits with `fetch` and toggles them from the response (`ok` → show done, else fail), and
   disables the submit while pending.

## Rendering mode: static or on demand

Studio's scaffold has two modes (Cloudflare, Pietro 2026-10-20). Read the mode from `astro.config.mjs` before writing
a page, and write every page for that mode:

- **Static (SSG)**: no `cache` in the config. The `[slug]` pages use `getStaticPaths` (above). With automatic updates on (Studio's
  Deploy section), a store change triggers a rebuild; without them the site changes at the next build.
- **On demand (ISR)**: the config has `cache: { provider: cacheCloudflare() }` (no `webhook` option until the person turns
  automatic updates on in Studio's Deploy section). Every page that renders store data is rendered on request and
  cached with tags, which the automatic updates purge when they are on. It reads **live collections**, never
  `getEntry`: build-time collections hold the last build's data, so a re-render after an invalidation would still show
  stale data.
  - `src/live.config.ts` declares them (Studio generates it) with `defineLiveCollection`, from `@smootify/astro/live`:
    `smootifyLiveProducts`, `smootifyLiveCollections({ …, withProducts: true })`, `smootifyLiveVendors` and
    `smootifySchemas`, with the same `siteId`, `country`, `language` and `metafields` as `content.config.ts` (both read
    `smootify.config.mjs`);
  - `export const prerender = false`; no `getStaticPaths`;
  - `const { entry, error, cacheHint } = await getLiveEntry("<collection>", { id: Astro.params.slug! })`;
    `if (error || !entry) return new Response(null, { status: 404 });` (errors are returned, never thrown);
  - the `@cms` fields are the same: `entry.data` has the shape of the build entry, so `entry.data.<field>` and the
    components that take an entry (`Seo`, `SmootifyCollection`) work unchanged. A collection's `data.products`
    is a list of `{ collection, id }` references that `getEntries` does not resolve against a live collection: read the
    collection's products, all of them and in its order, with
    `getLiveCollection("products", { collection: entry.data.handle })` (optional `sortKey`); no 250 limit, no matching
    by slug;
  - the cache: `Astro.cache.set(cacheHint)` applies the entry's tags (the package's, the same ones `productCacheTags`
    and the other helpers return, never written by hand) and `Astro.cache.set({ maxAge: 3600, swr: 600 })` the
    duration. A list's `cacheHint` (`getLiveCollection`) works the same, and a page that lists products carries it
    (it has `smootify:product-lists`), so the home with a product list, a landing and the vendor page refresh on every
    product event. Use `productListCacheTags()` only on a page that lists product data without reading a live list;
  - a vendor page reads `getLiveEntry("vendors", { id: Astro.params.slug! })` (`smootifyLiveVendors`: same id, slug,
    `data.name` and `productCount` as the build loader). The Storefront API has no vendor list, so each read pages
    through the catalogue: keep the page behind the route cache (`Astro.cache.set(cacheHint)` plus a `maxAge`);
  - pages with no store data (404, about, policy written in the design) stay prerendered.
  The update webhook, `src/worker.ts` and the wrangler entries belong to Studio's Deploy section; the skill never
  writes them unless asked.

**Automatic updates, only when the person asks** (otherwise Studio's Deploy section turns them on). Shopify calls the
site at `/_smootify/webhook/<token>/`; the Smootify server only registers the webhooks. Static: the route calls the
Cloudflare deploy hook; on demand: it purges the cache tags. What it takes, from `@smootify/astro`:
- `smootify({ …, webhook: true })` (or `{ debounce: <seconds> }`, default 60);
- `src/worker.ts`: `import { handle } from "@astrojs/cloudflare/handler"; import { withSmootifyWebhook } from
  "@smootify/astro/cloudflare"; export { SmootifyWebhookDebouncer } from "@smootify/astro/cloudflare"; export default
  { fetch: withSmootifyWebhook(handle) };` (the wrapper makes the route answer with and without the trailing slash);
- `wrangler.jsonc`: `"main": "./src/worker.ts"`, the Durable Object binding `SMOOTIFY_WEBHOOK_DEBOUNCER` → class
  `SmootifyWebhookDebouncer`, and the migration `{ "tag": "smootify-v1", "new_sqlite_classes": ["SmootifyWebhookDebouncer"] }`;
- the Worker secrets `SMOOTIFY_WEBHOOK_TOKEN` (from the Smootify server) and, static only, `SMOOTIFY_DEPLOY_HOOK`:
  set by Studio or by the person, never written in the code or committed. The registration itself is Studio's or the
  dashboard's: put it in the report as manual.
  The reference pages are Studio's `ON_DEMAND_PAGES` (desktop-importer `src/lib/astro/templates.ts`); the markup,
  seed and SEO are the same as in static mode. Each live read is a Storefront call when the cache misses, so keep the
  reads to what the page shows.

## Styles

- **Figma variables → `src/styles/tokens.css`** as custom properties: Desktop is the default; the Tablet and Mobile
  modes go in media queries (`max-width: 991px`, `767px`).
- **Text styles → classes** in `global.css`.
- **Component styles** in the component's scoped `<style>`. **Templates Smootify clones stay scoped**: the runtime
  clones the template node, and the clone keeps its `data-astro-cid-…` attribute (a product card in a carousel, a
  filter value row, a chip), so the scoped rules (state classes included: `.empty-count`, `.preselected-filter`,
  `[aria-current]`) still match. `:global()` is for HTML Smootify **writes from data**, which has no scope
  attribute: rich text, policies, `set:html`, and what the runtime builds with `innerHTML` (the
  `<span class="filter-count-label">` of a filter value), and for classes on the host or on a parent that Smootify
  sets (`.is-filtered`, `.inited`: `:global(.host.inited) .part`). A `<style is:global>` on a component is not wrong
  (the starter's filters use it), it is only not needed for clones.
- **Classes named from Figma** (`sm-…`), as on Webflow: the *Style Auto-Generation* rules of `SKILL.md` hold, including
  "one class, one design" and names from the component and the role.
- **Smootify custom tags are inline by default**: give them `display` where they carry layout.
- **Library classes are global, component classes are scoped.** A class that markup in *other* components also writes
  (`sm-button`, `sm-icon-button`, `sm-badge`, the text styles `heading-*` / `body-*` / `label-*`, `sm-input`, the
  container) lives in `global.css` or in a `<style is:global>` of the library component that owns it (`Button.astro`).
  A scoped rule would not reach it from a caller. Classes only that component's markup uses stay in its scoped `<style>`.
- **CSS-only Smootify states need the site's CSS.** Where the catalogue says a marker is shown or hidden by CSS, or by a
  host class (`is-open`, `is-required`, `is-empty`…), the runtime's stylesheet only hides what it must (contract §2.10;
  for `[consent-panel]` it hides the panels while the host is not `is-required` / `is-open`, and
  `[consent-condition="sale-of-data"]` outside `is-sale-of-data-region`; for `smootify-metaobjects` the `empty-state`
  **element** while not `is-empty`). What a shown state looks like, and the layout of the panels, is the site's: write the
  rules in the component from the host classes the catalogue lists (`get_element` when it does not), e.g. the starter's
  cookie banner: `.host.is-required:not(.is-open) .is-banner, .host.is-open .is-preferences { display: flex }`, and
  `.host.is-empty .empty { … }` plus hiding the list and pager while `is-empty`. Do not rely on the attribute form of a
  marker the stylesheet only knows as an element (`[empty-state]` is not hidden by it): write both the hiding and the
  showing yourself. Verify against the host classes of the catalogue, never guess a class name.
- **Server-render what the entry knows, leave the rest to the prerender.** At build time the entry knows the title,
  description and first image: render them in the markup (they are also SEO). The markup must still carry the Smootify
  attributes **exactly**: after `astro build`, `@smootify/astro` runs the runtime's seed builder with prerender, and for
  every product in the seed and its default variant in the build market the runtime draws into the static HTML the state
  classes and binds, prices and compare-at in the shop's money format, pickers (swatches, select, popover, price
  difference, lead time, selected value), gallery, quantity, add-to-cart form, dynamic properties and metaobject lists.
  At boot the runtime adopts what is drawn (no re-render). **Do not hand-render** what it draws (prices, variant-dependent
  stock messages, selected option labels, price differences): a hand-written value is a second source that drifts.
  What depends on the **visitor** (customer, cart, wishlist, B2B, another market) stays runtime-only.
- **Templates flash before Smootify runs: only for what the prerender cannot draw.** Do **not** hide variant-dependent
  parts with `:not(.loaded)` CSS any more (stock messages, discount badge, volume pricing, backorder notes): the
  prerender already sets them. Keep the pre-load hiding only for what depends on the visitor and for S&D runtime-only
  parts, in the component's CSS, from the host's own state class:
  - **visitor-dependent**: the wishlist button `.wishlist:not(.is-inited) { visibility: hidden }` (`is-inited` on
    `wishlist-toggle`), and customer, cart and account parts until their host is ready;
  - **S&D runtime-only parts**: `smootify-search-discovery:not(.inited) …` (see *Search & discovery on Astro*).
  The classes per host are in the catalogue's *Classi di stato*. Use `visibility` / `opacity` where the layout must not
  jump. **Never write `hidden` yourself on something Smootify should show**: it removes only the `hidden` it set
  (`data-smootify-hidden`). `[hidden]` is for what the server decides and for `[form-done]` / `[form-fail]`, whose
  `hidden` the contract says Smootify takes off when it shows them.
- **Fonts: self-host and match the fallback.** Self-host the design's fonts (in `src/assets`, or with Astro's font
  support if the project uses it) with `font-display: swap` and a metric-matched fallback: a `@font-face` on a
  `local()` system font with `size-adjust`, `ascent-override` and `descent-override`, listed right after the web font in
  `font-family`, so the swap does not move the layout. Preload only the 1-2 fonts used above the fold. Why: after the
  prerender, web-font swaps were the remaining layout shift on home and collection pages.
- **A template `img` with no data** (`img[cart-item="image"]`, `[search="image"]`, `[metaobject="image"]`, a hover
  image) has **no `src`**: omit the attribute, never `src=""` (the Verify grep fails on it). Hide it where the browser
  would show a broken icon: `img:not([src]) { visibility: hidden }` in the component (or `display: none` when it takes no space).
- **Images exported from Figma at 2x** into `src/assets` (picture alone, at 2x: the same rule as on Webflow, never
  the whole card). Product and collection pictures stay in Shopify.
- An empty `@style:` derives no class; the element takes no class.

## Which Smootify rules of SKILL.md change on Astro

- No Webflow element names to honour: "A name that is a Webflow element" does not apply (Dropdown → popover, Slider →
  slider parts, Tabs → ARIA tabs, Lightbox → `a[lightbox-item]`).
- `/search` is not reserved: the search page can use that slug.
- Required fields can use the native `required`; `data-required` still works.
- CSS that Webflow could not write goes in the component's `<style>` (`:has()`, parent-state rules, a panel's position).
- The cookie Necessary box is a plain `<input type="checkbox" checked disabled>`, without a `name`.
- Links to the current item are real hrefs (`/${routes.products}/${entry.id}/`, with the trailing slash), never `#`.
- Page titles, descriptions and `og:image` come from the entry in code (`<Seo>`).
- Labels are `<label for>`; the form defaults of Webflow (`.w-input` margins…) do not exist.
- A custom attribute can be set on a component instance's root through a prop; no wrapper Div is needed.
- **Submit labels for sold out / unavailable**: `data-state` only has `default` and `loading`. Any other label is a
  sibling span inside `[data-state="default"]`, shown by the state class Smootify writes on `smootify-product`
  (`is-currently-out-of-stock`, `not-existing-variant`; read the exact classes in the catalogue's *Classi di stato*):
  `<span class="label-add">Add to cart</span><span class="label-sold-out">Sold out</span>`, the extra ones
  `display: none` by default and swapped with `:global(smootify-product.is-currently-out-of-stock) …`. Never a
  second submit.
- **Layer names are not annotations.** A layer named like a selector (`[gallery=thumbnails]`, `[product=images]`) gives
  nothing: only `@attr` and the other directives do. The attribute goes where the annotation puts it.
- **An annotation that contradicts a `SKILL.md` rule wins**, unless it breaks the runtime or the contract; either way
  say so in the report (e.g. a filter-count the annotation says is not built).
- **A nested `smootify-product`** (related / complementary cards inside the page's own wrapper) is what the annotation
  asks for; the catalogue notes a nested product ignores `?variant=`: no action, one line in the report.
- **Popover as a drawer / column**: `--smootify-closed-display: none` is the default (write it only to restate); a panel
  that is a static column at desktop and a drawer below needs, at desktop, `--smootify-closed-display: flex;
  position: static; inset: auto; margin: 0; width`, and in the drawer `transition: …, display …, overlay …`
  with `allow-discrete` plus `@starting-style` for the top-layer transition.

## Build (Phases 2–5 for Astro)

1. Check the project against the structure above and create the missing pieces.
2. Components, **inner first**: for each distinct `@component` one `.astro` file: `Props` from the `@prop`s (types
   `string`, `boolean`, `number`; an image prop is a URL string or an `ImageMetadata`), the markup from the tree with the
   element mapping, `@bind`s as expressions (validate them against the `Props` first: Bind Validation), `<slot />`s,
   scoped styles (base class, state combos, interactions, media queries).
3. Pages: one `.astro` file per page of the Figma file, composed of components (Navbar and Footer come from `Base`); the dynamic ones with
   `getStaticPaths`; tokens and text styles in `src/styles`.
4. **A component two pages need** (a breadcrumb, a card, an empty state) is built **once**, in its group folder. When
   two builds run in parallel, one owns it (the page whose frame the component belongs to, else the first to need it)
   and the other **reads the tree again before writing a file** and reuses it, never a second copy under another name;
   the reuser says in its report which build owns it.
5. Fixed text and attributes as written in the annotation; classes from `@style` (base first), else `sm-` + the
   kebab-case layer name. Nothing is generated by hand twice: a repeated structure is a component with props.

## Verify (Phase 6 for Astro)

1. `astro check` and `astro build` green (a rejected Smootify attribute is a gap in `@smootify/astro`'s typings: report it, never a cast) (through the project's package manager: `pnpm exec astro …` or `npx astro …`).
2. Run the Smootify MCP `check_markup` on the **built HTML of every page** (`dist/**/index.html`; at least one product,
   one collection and the home page). **The MCP's rules are Webflow-only for now**; fix every error **except these known
   false positives of the generic build**, which you list in the report as **checker gaps** (never change correct
   generic markup to please the checker):
   - `gallery="slider"` on the generic slider parts: "not a Webflow Slider" (error);
   - `data-state` on a submit tied to its form with `form=` while sitting outside it (a sticky bar): "works only inside
     smootify-add-to-cart [type=submit]";
   - a `*-dropdown` tag "requires `.w-dropdown`": write the `*-popover` tag instead (element mapping), which the
     checker accepts; if it errors on that too, it is a gap.
   List also what `check_markup` marks as not checkable.
3. `astro preview` (same package manager; Astro 7 runs `astro dev` in the background when it detects an agent, so stop
   it with `astro dev stop` when done — `astro dev status | logs` to inspect), and the platform-neutral shopper checks of `SKILL.md` Phase 6 in the browser at desktop,
   tablet and mobile width.
4. `grep` the `dist` folder for `class="w-`, `data-w-`, `href="#"`, `src=""` and leftover sample text (the design's
   placeholder copy that a binding or an entry should have replaced).
5. `grep` the `dist` folder for links that use the **other** form than the configured `routes` (e.g. with the default
   plural, `href="/product/`, `/collection/`, `/vendor/`; with customized routes, `href="/products/` and the other
   defaults): none should be left (Shopify CDN image paths such as `.../collections/900.jpg` are not links).
6. `grep` the `dist` folder for **internal hrefs without the trailing slash**: every `href="/…"` must end with `/`,
   excluding hrefs to files with an extension (`/favicon.svg`, `/robots.txt`, `.css`, `.js`, images), anchors (`#…`),
   external links (`https://…`, `mailto:`, `tel:`) and query-only links; for example
   `grep -rhoE 'href="/[^"#?]*[^/"]"' dist | grep -vE '\.[a-z0-9]+"$' | sort -u` should print nothing. Also the
   canonical, the sitemap entries and the hreflang hrefs end with `/`. A match is a link that costs a redirect: fix it
   at the source.
   Check that the automatic seed is in `dist` on the product, collection and home pages and on every page with product cards:
   `data-smootify-products` and `data-smootify-seed`, with `data-country` / `data-primary-market`
   (and `data-smootify-collection` only where a `specific-collection` list reads it, not for S&D).
   Check the SEO of **every built page**: exactly one `<link rel="canonical">`, one `<title>`, one meta description,
   the `og:title`, `og:description`, `og:url`, `og:type`, `og:image` (where the page has an image) and `twitter:*` tags,
   and the JSON-LD of its type (product, collection, home...); none written outside `<Seo>`.
   With `locales` on: every combination of route x locale builds (count the pages against the expected number); each
   page's `<html lang>` is its locale's `htmlLang`; every link of the switcher resolves to a built page; every page's
   hreflang lists **every** locale plus `x-default`, and each href equals that locale page's canonical; internal links
   carry the locale prefix; no text of the design is left outside the files of `src/i18n`.

7. Check that nothing visible changes at boot on the product and collection pages: the built product page has the prices
   (and compare-at) in the shop's money format, the same string the runtime shows once loaded; then measure layout shift
   (Chrome DevTools Performance → Layout shifts, or the CLS number) on PDP and PLP and **report the CLS**. A shift that
   remains is usually a font swap or a hand-hidden part, not Smootify.

What fails goes in the report before anything else: a page that builds but cannot be used is not done.

## Report

The same template as `SKILL.md`. "Manual" only for what is outside the code: store settings, Cloudflare hosting and
domain, automatic updates when the person wants them (optional: Smootify Studio's Deploy section or the Smootify dashboard
turns them on; this build leaves them off), the Workers paid plan and the verified sender domain when a form sends email,
Customer Account API origins, admin redirects and policies. Say what you could only check from the build output and
what `check_markup` could not check.
