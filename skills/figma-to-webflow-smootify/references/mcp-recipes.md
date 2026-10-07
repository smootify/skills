# MCP recipes for the steps that used to be `@manual`

Every recipe here was run on the starter build (beta.10, October 2026), where 60 `@manual` lines were done by hand
through the Webflow MCP. They are no longer manual: build them like any other directive. "scope" means passing
`scope_component_id` when the element is inside a component.

## Elements

| What | Calls |
|---|---|
| A block next to another (the block of a state: unavailable, no pickup, free shipping reached, above the bundle limit, discounted) | `data_element_builder` with position `after` the sibling (scope), then the attributes with `set_attributes` and the text (see *Text* below) |
| A template inside a template (`box-item`, `bundle-item` inside `cart-item`) | `data_element_builder` DOM with the custom tag, its children (img, TextBlock) inside, `set_attributes` on each. `bundle-item` and `box-item` are tags, not DivBlocks |
| A hidden `select` with options (configurator dropdown and popover) | DOM `select` (`data-name` = the step name) with DOM `option` children; `set_attributes` gives each option its `value` (`oak\|price`, `walnut\|price + 20`), `set_text` on the option gives the visible text. A FormSelect cannot take options through the MCP |
| A Webflow Dropdown (sort dropdown, mobile nav dropdown) | builder type `Dropdown`, remove the extra links, keep **one** link as the template, `set_attributes` on the value text (`data-selected=""`) |
| Webflow Tabs (subscription picker, magic box categories) | builder type `Tabs`, remove the extra tab and pane. A radio outside a form is a DOM `label` > `input[type=radio]`: Webflow rejects a FormRadioInput outside a Form |
| A popover panel and its trigger (only on a site without Webflow's Popover element; with it, place the Popover through Claude in Chrome) | panel: DivBlock with `popover="auto"` and its id through `set_dom_id` (with a prop binding if the id is a prop); trigger: DOM `button` with `popovertarget`; a close button: `popovertarget` + `popovertargetaction="hide"`. Never `display` on the panel class (see the build skill) |
| A popover inside a repeated template (address card, cart line) | DOM `details` > `summary` instead: a popover would repeat its id in every copy |
| A slot | builder type `ComponentSlot` inside a DivBlock; the slot's name is its display name (`set_display_name`). Not inside a Form |
| A Form Block inside a custom tag (`customer-unsubscribe-email`, the consent preferences panel) | builder with a `{type: "Form"}` child inside the tag; delete the sample fields Webflow adds; `set_settings` for the form `name`, `domId` and `buttonText` |
| Form fields in a component (Cart line with its quantity, Discount code field, Cart note) | build them inside a temporary Form Block on a page, then `transform_element_to_component`: Webflow refuses form fields outside a form, also inside a custom tag such as `configurator-field` |
| Showing or hiding an instance from a prop (Wishlist button, Rating stars in a card) | wrap the instance in a DivBlock and bind the wrapper's visibility: an instance has no visibility setting. The wrapper also carries the instance's position (the heart at the top right of the image) |
| A Collection List (products of a magic box category) | builder `CMSCollection`, `set_settings` on the `DynamoWrapper` for `source`, `limit`, `filters` (by collection: `fieldSlug: "collections"`); bind the instance props inside to the CMS with `set_component_instance_prop_values` |

## Pages

| What | Calls |
|---|---|
| An instance on a page | `insert_component_instance` with the `pageId` (works headless). **`after` an instance is rejected**: insert `before` the next sibling, or `prepend` / `append` in the parent |
| An instance inside a component | `insert_component_instance` with `scope_component_id` |
| A prop value or a CMS binding on a page instance | `set_component_instance_prop_values` |
| The site's custom code | `get_site_freeform_code`, then `set_site_freeform_code` with the **whole** block: it replaces what was there |

## Text and ids

- `set_text` in the builder's schema works only on Heading and Button. A TextBlock keeps "This is some text inside
  of a div block.": set the text afterwards on its String node, whose id is the TextBlock's id + 1.
- Ids inside a component are sequential (root + DFS index) when the component is built in one call; elements added
  later get random ids. Read them back with `get_all_elements` (scope, `depth: -1`).
- `id` is always `set_dom_id`, never an attribute.

## Before you retry

- The builder can leave the parent it created even when it answers with an error: look, and remove it.
- A `data_style_tool` call with several actions can answer "server error" and still apply them: read the styles
  back before retrying.
- Webflow answers 429 for minutes when several agents read or write the same site at once: build with one agent at
  a time on a site, and keep the checks for after.
