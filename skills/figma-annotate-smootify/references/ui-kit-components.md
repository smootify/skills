<!-- The Smootify 2.0 UI kit, component by component. Names and props here are in Italian; in Webflow they go in English. The markup is checked against glossary.json and glossary-errata.md, which win. -->

# UI Kit Smootify 2.0: i componenti da creare in Figma

Per chi disegna in Figma (e il Claude che lavora con lui). Qui c'è ogni componente del kit: dove compare, le varianti e
gli stati da disegnare, cosa contiene. Le righe **Prop Webflow** e **Markup** servono a chi porta i
componenti in Webflow e nella Designer App: non si disegnano, ma possono andare nelle annotazioni Dev Mode dei layer
(`@prop`, `@attr`). Scritta sulla 2.0 del 25/09/2026: dove un nome qui è diverso dal catalogo della skill Figma, vale
questa lista.

## Regole

- **Nomi Figma**: `Area / Componente` (per esempio `Prodotto / Card`).
- **Stati e stili sono variant properties** (`Stato = Default | Caricamento | …`, `Stile = …`). Le parti che possono
  mancare sono boolean properties (`Prezzo barrato`, `Badge`), i testi text properties, le icone instance swap.
- **Stati dei form**: successo, errore e bottone in caricamento si disegnano dentro ogni form (aggiungi al carrello,
  carrello, account, newsletter), non come componenti a sé.
- **Dialog e popover**: dove c'è "dialog o popover", il popover è la forma nuova (l'elemento Popover di Webflow, o gli
  attributi `popover` / `popovertarget` finché la beta è privata); il dialog resta per i siti senza.
- **Non si disegnano**: gli skeleton (sono un attributo, `skeleton="text|button|block|image"`, e l'effetto lo dà il CSS
  di Smootify), i banner che Smootify inserisce da solo, header, footer, breadcrumb e pagine CMS (Webflow puro), il
  selettore di lingua (quello nativo di Webflow Localization).
- **Ordine**: prima lo starter, che serve a ogni negozio, pagina per pagina; poi i moduli, che si aggiungono solo
  quando servono.

---

# Starter

## 1. Collezione (PLP)

### Prodotto / Card
- Dove: collezione, ricerca, home, correlati, wishlist, ultimi visti.
- Varianti Figma: Formato = Griglia | Orizzontale | Mini; Aggiunta = Nessuna | Form (varianti + quantità + bottone) |
  Quick view (bottone che apre un popover col form completo).
- Stati: Default, Caricamento, Esaurito, In offerta, Nuovo.
- Contenuto: immagine, seconda immagine al passaggio, titolo, vendor, prezzo (e barrato), badge, pallini colore,
  stelle.
- Prop Webflow: nessuna obbligatoria (l'id del prodotto viene dal CMS); `Nascondi se nel carrello` (boolean).
- Markup: `smootify-product[data-id]` con `[variant=image]`, `[product=specific-image][index=1]`,
  `[product=title|vendor|url]`, `smootify-price`, badge `[condition=…]`; `hide-if-product-in-cart`.
- Note: il bottone di aggiunta diretta **non** va sulle card normali: esiste solo per gli upsell del carrello (vedi
  Carrello / Upsell).

### Prodotto / Prezzo
- Varianti Figma: Formato = Singolo | Da (range) | Con barrato; Dimensione = Card | PDP.
- Stati: Default, In offerta, Gratis.
- Contenuto: prezzo, prezzo barrato, "da", prezzo unitario (€/kg), risparmio.
- Markup: `smootify-price` con `[data-prop="price|compareAtPrice|total"]`; `[product=min-price|max-price]`,
  `[variant=unit-price]` (`data-format` con `{{price}}` e `{{unit}}`), `[variant=discounted-amount]`.

### Prodotto / Badge
- Varianti Figma: Tipo = Sconto % | Nuovo | Esaurito | Ultimi pezzi | Scorte basse | Preordine | Abbonamento |
  Disponibile in negozio.
- Markup: un elemento con `[condition=on-sale|is-new|out-of-stock|last-in-stock|low-stock|in-backorder|subscription|
  available-at-location]`; lo sconto % è `[variant=discount-percentage]`.
- Prop Webflow: Tipo → l'attributo `condition`; `Giorni "nuovo"` → `data-new-days` (default 30).

### Prodotto / Stelle
- Varianti Figma: Fonte = Judge.me | Metafield; Dimensione = S | M.
- Contenuto: stelle piene in proporzione, voto, numero di recensioni.
- Markup: `judge-me-stars`, oppure `[metafield=<chiave>]` di tipo rating: le stelle riempite con
  `width: var(--metafield-rating)`.

### Collezione / Griglia prodotti
- Stati: Caricamento, Risultati, Vuoto.
- Contenuto: la card ripetuta, conteggio risultati, stato vuoto.
- Prop Webflow: `Collezione` → `data-collection` (di solito dal CMS); `Per pagina` → `limit`; `Filtri nell'url` →
  `sync-query-params`; `Nascondi filtri vuoti` → `hide-empty`; `Chiudi il pannello dopo la scelta` →
  `auto-close-details="true"`.
- Markup: `smootify-search-discovery` con dentro `smootify-product[data-id=filter]`; `[filter=count]`,
  `[filter=empty-state]`.

### Filtri / Pannello
- Varianti Figma: Formato = Sidebar | Drawer | Popover.
- Contenuto: i gruppi di filtri, reset, contatore dei filtri attivi.
- Markup: `button[type=reset]`, `[filter=active-count]`; un pannello fuori dalla griglia (drawer) si collega con
  `data-expand` sul contenitore della collezione.

### Filtri / Gruppo
- Varianti Figma: Tipo = Checkbox | Radio | Select | Dropdown | Popover | Swatch (colore o immagine) | Ricerca testo |
  Prezzo (slider); Aperto = Sì | No.
- Stati del valore: Default, Selezionato, Conteggio zero.
- Contenuto: etichetta del gruppo, valori con conteggio; per il prezzo barra, da, a.
- Prop Webflow: `Etichetta` → `label` (il nome del filtro in Shopify); `Mostra conteggio` → `show-count`;
  `Senza parentesi` → `hide-parenthesis`; `Etichetta visibile` → `custom-label`.
- Markup: `filter-checkbox | filter-list | filter-select | filter-dropdown | filter-popover | filter-swatches |
  filter-search | filter-price` (per il prezzo `[filter-price=progress|from-label|to-label]`).

### Filtri / Attivi
- Contenuto: chip con il nome del filtro e la x, "Azzera tutto".
- Markup: `[filter=active]` (template), `[filter=active-label]`, `button[type=reset]`.

### Collezione / Ordinamento
- Varianti Figma: Tipo = Select | Radio | Dropdown | Popover.
- Prop Webflow: `Valore iniziale` → `selected-value`.
- Markup: `sort-select | sort-radio | sort-dropdown | sort-popover`.

### Collezione / Paginazione
- Varianti Figma: Tipo = Precedente-Successiva | Carica altri | Scroll infinito.
- Stati: Default, Caricamento, Nascosto (non ci sono altre pagine).
- Markup: `button[data-action=prev|next|load-more|load-in-view]`.

## 2. Pagina prodotto (PDP)

### Prodotto / Gallery
- Varianti Figma: Miniature = Sotto | A lato | Nessuna; Zoom = Sì | No; Formato = Slider | Griglia di lightbox.
- Stati: miniatura attiva; media Immagine | Video | Video esterno | 3D (miniatura con icona play o 3D).
- Contenuto: slider, miniature, link zoom (icona), griglia di immagini che aprono la lightbox.
- Prop Webflow: `Includi video e 3D` → `include-media`; `Solo immagini della variante` → `only-variant-images`;
  `Immagini per alt` → `variant-images="alt"`.
- Markup: `[product=gallery]` con `[gallery=slider]` (Slider di Webflow), `[gallery=thumbnails]`,
  `[gallery=lightbox]` (un link che apre tutto), `[gallery=lightboxes]` (un link per immagine); slide e miniature
  ricevono `data-media-type=image|video|external-video|model`.

### Prodotto / Info
- Contenuto: titolo, vendor (link), tipo, SKU, barcode, disponibilità ("3 disponibili"), tag, collezioni (link),
  descrizione, data, elenco dei valori delle opzioni.
- Markup: `[product=title|vendor|type|description|tags|collections|created-at|option-values|stock]`,
  `[variant=sku|barcode|stock]`.

### Varianti / Swatch
- Varianti Figma: Stile = Colore | Immagine | Pillola di testo; Prezzo = Nessuno | Differenza (+ €5);
  Contenitore = In linea | Popover.
- Stati del valore: Default, Selezionato, Non disponibile (resta cliccabile), Focus.
- Contenuto: etichetta dell'opzione con il valore scelto ("Colore: Rosso"), i valori.
- Prop Webflow: `Opzione` → `data-option-name`.
- Markup: `variant-swatches[data-option-name]` > `button` con `[option=title|color|bg-color|image|price-difference]`,
  `[selected-option=title]`.

### Varianti / Tendina
- Varianti Figma: Tipo = Dropdown | Popover | Select nativa.
- Stati: Chiuso, Aperto, voce corrente, voce non disponibile.
- Prop Webflow: `Opzione` → `data-option-name`.
- Markup: `variant-dropdown` (Dropdown di Webflow), `variant-popover` (trigger + popover: il primo link è il
  modello), `variant-selector` (select).

### Prodotto / Quantità
- Stati: Default, Al minimo, Al massimo.
- Markup: `quantity-input` > `button[data-action=minus]`, `input`, `button[data-action=plus]`.

### Prodotto / Aggiungi al carrello
- Varianti Figma: Formato = Blocco | Barra fissa (mobile); Compra ora = Sì | No.
- Stati del bottone: Default, Caricamento, Esaurito, Non disponibile; messaggio di errore.
- Contenuto: le varianti, la quantità, il bottone, "compra ora", l'errore.
- Markup: `smootify-add-to-cart` > `form`, `button[type=submit]` con `[data-state=default|loading]`,
  `button[name=buy-now]`, `.w-form-fail`.

### Prodotto / Shop Pay
- Markup: `smootify-shop-pay` (il bottone lo disegna Shopify: va previsto solo lo spazio).

### Prodotto / Regole di quantità
- Contenuto: minimo, massimo, multipli ("Si ordina a multipli di 6").
- Markup: `[variant=quantity-min|quantity-max|quantity-increment]`.

### Prodotto / Disponibilità in negozio
- Varianti Figma: Contenitore = Dialog | Popover.
- Stati: Disponibile, Non disponibile, Nessun ritiro.
- Contenuto: riga di stato col negozio, elenco negozi (nome, indirizzo, disponibilità, tempi di ritiro).
- Markup: `store-availability`, `store-location` (modello della riga) con `[location=…]`,
  `[condition=available-at-location|not-available-at-location]`.

### Prodotto / Avvisami quando torna
- Varianti Figma: Contenitore = Dialog | Popover.
- Stati: Form, Inviato, Errore.
- Prop Webflow: `ID Klaviyo` → `data-company-id`.
- Markup: `klaviyo-back-in-stock[data-company-id]`, input con `data-name`.

### Prodotto / Wishlist
- Varianti Figma: Stato = Vuoto | Pieno; Animazione = Nessuna | Rive.
- Prop Webflow: `Per variante` → `data-use-variants`.
- Markup: `wishlist-toggle`.

### Prodotto / Recensioni
- Markup: `judge-me-reviews` (il widget è di Judge.me: va previsto lo spazio).

### Prodotto / Blocchi metafield
- Varianti Figma: Tipo = Tabella specifiche | Elenco caratteristiche | Download | Pallini colore | Link correlati |
  Card contenuto | Testo ricco | Guida taglie.
- Contenuto: per la tabella una riga ripetuta (etichetta, valore); per i link correlati titolo, immagine, url.
- Prop Webflow: `Chiave` → `metafield`; `Namespace` → `namespace`; per il JSON `Percorso` → `data-path`;
  `Separatore` → `separator`.
- Markup: `[metafield=<chiave>]`; dentro un JSON più `[data-path]`, una lista di oggetti ripete la riga; dentro un
  riferimento `[reference=title|url|image|description|body]`; dentro un metaobject `[metaobject=<campo>]`.

### Prodotto / Componenti del bundle
- Contenuto: riga ripetuta con immagine, nome, quantità.
- Markup: `[variant=components]` con `[component=…]`.

### Prodotto / Carosello
- Varianti Figma: Fonte = Correlati | Complementari | Più venduti | Nuovi | Collezione | Query | Da metafield |
  Ultimi visti.
- Contenuto: titolo della sezione, frecce, la card ripetuta.
- Prop Webflow: `Fonte` → `data-id` (`related`, `complementary`, `best-seller`, `created-at`, `specific-collection`,
  `custom-query`, `metafields.<ns>.<chiave>`, `last-viewed`; dentro `smootify-metaobject` anche `metaobject.<chiave>`, i
  prodotti di un campo della voce); `Quanti` → `limit`; `Collezione` →
  `data-collection-handle`; `Query` → `data-query`; `Ordine` → `data-sort`.
- Markup: `product-slider` (Slider di Webflow) o `dynamic-swiper`, con dentro `smootify-product[data-id][data-parent-id]`.

### Carrello / Barra spedizione gratuita
- Dove: PDP e carrello.
- Stati: Mancano X, Raggiunta.
- Contenuto: testo con quanto manca, barra di avanzamento.
- Prop Webflow: `Soglia` → `data-amount` (importo) o `data-quantity` (pezzi).
- Markup: `free-shipping-bar` con `[data-prop=left|progress-width]`.

## 3. Carrello

Si disegna una volta e si monta in quattro modi: pagina, drawer, dropdown, popover. I componenti interni sono gli
stessi.

### Carrello / Contenitore
- Varianti Figma: Formato = Pagina | Drawer (dialog) | Dropdown | Popover.
- Stati: Caricamento, Vuoto, Pieno, Errore.
- Prop Webflow: `Apri dopo l'aggiunta` → `data-open`.
- Markup: `smootify-cart`, `button[data-action=open|close]`; il carrello vuoto è il blocco `.w-form-done`.

### Carrello / Riga
- Varianti Figma: Tipo = Prodotto | Bundle (con righe figlie) | Box (con righe figlie) | Abbonamento.
- Stati: Default, Aggiornamento, Rimozione.
- Contenuto: immagine, titolo (link), variante ("Rosso / M") o opzioni una per riga, quantità, rimuovi, prezzo
  unitario, barrato, totale riga, risparmio e % di sconto, SKU, prezzo al kg, sconti della riga, proprietà
  (incisione, file).
- Markup: `cart-item` con `[cart-item=image|title|url|variant-title|options|quantity|price|compare-at-price|total|
  savings|discount-percentage|sku|unit-price|discount]`, `button[data-action=remove]`; righe figlie `bundle-item`,
  `box-item`.

### Carrello / Riepilogo
- Contenuto: subtotale, sconti (codici e automatici, i codici con la x), risparmio, totale barrato, totale, nota su
  tasse e spedizione, bottone checkout.
- Stati: checkout Default e Caricamento.
- Markup: `[cart=subtotal|discount|savings|compare-at-total|total|taxes]`, `button[type=submit]` con i figli `[data-state=default|loading]` (`data-wait` cambia solo il `value` di un `input[type=submit]`).

### Carrello / Codice sconto e gift card
- Stati: Vuoto, Applicato, Errore.
- Markup: input `coupon` + `button[data-action=coupon]`; input `gift-card` + `button[data-action=gift-card]`;
  `[cart=gift-card]`.

### Carrello / Nota e campi
- Contenuto: nota per il venditore, campi personalizzati (per esempio data di consegna, messaggio regalo).
- Markup: `textarea[name=note]`; ogni campo con `data-name` diventa un attributo del carrello.

### Carrello / Upsell
- Contenuto: card mini (immagine, titolo, prezzo) con il bottone di aggiunta diretta.
- Stati del bottone: Default, Caricamento, Non disponibile.
- Prop Webflow: `Fonte` → `data-id` (`cart-upsells`, `cart-complementary`, `cart-related`); `Quanti` → `limit`.
- Markup: `smootify-product[data-id=cart-upsells]` con `button[data-is=direct-add-to-cart]` (è l'unico posto dove
  va: un form non può stare dentro il form del carrello).

### Carrello / Countdown
- Contenuto: "Il carrello è riservato per 04:59".
- Prop Webflow: `Minuti` → `data-time`; `Alla fine` → `data-on-end` (`clear` o `redirect`).
- Markup: `urgent-cart-countdown` con `[data-prop=minutes|seconds]`.

### Carrello / Preventivo
- Stati: Richiesta, Inviato.
- Contenuto: bottone "Richiedi preventivo", messaggio di richiesta inviata, bottone di stampa.
- Markup: `smootify-cart[data-draft]`, `button[name=draft-order]`, `[cart-condition=items-in-quote|no-items-in-quote]`;
  stampa con `printable-element` e `print-button[data-target]` (si stampa prima di inviare: dopo il carrello si
  svuota).

## 4. Navbar e footer

### Navbar / Icona carrello
- Contenuto: icona e contatore; è un link alla pagina del carrello.
- Stati: Vuoto, Con articoli.
- Markup: `a` verso la pagina carrello con `[cart=count]`, dentro uno `smootify-cart` (anche senza pannello: il
  contatore si aggiorna solo dentro un carrello). Se il sito ha il mini cart, il bottone che lo apre sta nel
  Contenitore del carrello.

### Navbar / Ricerca predittiva
- Varianti Figma: Pannello = Dropdown | Popover.
- Stati: Vuoto (suggerimenti), Con risultati, Nessun risultato.
- Contenuto: campo; risultato (immagine, titolo, prezzo, barrato, vendor, collezione); suggerimenti; "vedi tutti".
- Prop Webflow: `Quanti` → `limit`.
- Markup: `smootify-search` con `search-result` (`[search=title|url|image|price|compare-at-price|vendor|collection]`),
  `search-suggestions` (`[search=suggested-query]`), `search-with-query`, `search-no-query`, `search-empty`.

### Navbar / Accesso
- Varianti Figma: Stato = Non loggato (bottone "Accedi") | Loggato (link all'account col nome).
- Markup: `passwordless-login`; `[customer-condition=logged-in|not-logged-in]`, `[customer=first-name]`.
- Note: non c'è una pagina di login: il login lo ospita Shopify.

## 5. Account: riepilogo e ordini

### Account / Intestazione
- Contenuto: nome, email, esci.
- Markup: `[customer=display-name|email]`, `logout-form`.

### Account / Ordini
- Stati: Caricamento, Lista, Vuoto.
- Contenuto: riga ordine (numero, data, stato pagamento, stato spedizione, totale, anteprima prodotti, link al
  dettaglio, "Compra di nuovo"), paginazione.
- Prop Webflow: `Per pagina` → `limit`.
- Markup: `customer-orders[limit]` > `customer-order` con `[order=name|processed-at|financial-status|
  fulfillment-status|total|url]`, `line-item`, `button[data-action=buy-again]`, `button[data-action=prev|next|load]`;
  `[customer-condition=has-orders|no-orders]`.

## 6. Account: dettaglio ordine

### Account / Ordine
- Contenuto: intestazione (numero, data, stati), righe (immagine, nome, opzioni, quantità, prezzo), totali (subtotale,
  spedizione, tasse, rimborsi, totale), indirizzi, spedizioni con corriere e tracking, "Compra di nuovo", stampa.
- Markup: `order-page` con `[order=…]`, `line-item` (`[line-item=…]`, opzioni `[option=name|value]`),
  `order-fulfillment` (`[fulfillment=status|tracking-company|tracking-number|tracking-url|estimated-delivery-at]`),
  `[order-condition=has-fulfillments]`, `button[data-action=buy-again]`, `print-button`.

## 7. Account: indirizzi e profilo

### Account / Indirizzi
- Stati: Lista, Vuoto; card Predefinito | Altro.
- Contenuto: card indirizzo (badge predefinito, modifica, elimina), form di creazione, form di modifica (in popover o
  pannello), conferma di eliminazione.
- Markup: `customer-addresses` (card con `[address=…]`), `create-address`, `edit-address`, `delete-address`;
  `[customer-condition=has-addresses|no-addresses]`.

### Account / Profilo
- Contenuto: nome, cognome, telefono; iscrizione alla newsletter.
- Stati: Default, Salvato, Errore.
- Markup: `customer-user-update`, `customer-subscribe-email`, `customer-unsubscribe-email`;
  `[customer-condition=email-subscribed|email-not-subscribed]`.

## 8. Ricerca

### Ricerca / Pagina
- Stati: Risultati, Vuoto.
- Contenuto: "Risultati per …", conteggio, griglia di card, paginazione.
- Markup: `smootify-search-page` con `[search=query|count|empty-state]`.

## 9. Home

Nessun componente nuovo: caroselli (Prodotto / Carosello con le varie fonti) e blocchi editoriali di Webflow.

## 10. 404 e policy

### Pagina / Policy
- Varianti Figma: Tipo = Privacy | Rimborsi | Termini | Spedizioni | Abbonamenti.
- Markup: rich text con `policy=privacy|refund|terms|shipping|subscription`.

---

# Moduli

## Add-on e bundle

### Add-on / Scelta
- Varianti Figma: Tipo = Checkbox | Select | Dropdown | Popover | Swatch (con immagine e prezzo).
- Stati: Non scelto, Scelto, Non disponibile.
- Prop Webflow: `Mostra prezzo` → `show-price`; `Deselezionabile` → `allow-unselect`; per le swatch `Tipo` →
  `addon-type`.
- Markup: `addon-checkbox | addon-select | addon-dropdown | addon-popover | addon-swatches`.

### Add-on / Riepilogo bundle
- Contenuto: totale del bundle, immagini degli add-on impilate, limiti ("Ne mancano 2", "Hai superato il limite").
- Markup: `[bundle=total|images]`, `[bundle-limit=current-total|above-units|missing-units]`,
  `[condition=below-bundle-limits|above-bundle-limits]`.

## Proprietà personalizzate

### Prodotto / Proprietà
- Varianti Figma: Tipo = Testo | Url | Email | Numero | Select | Swatch | Dropdown | Radio | Checkbox.
- Stati: Default, Errore (obbligatoria).
- Prop Webflow: `Etichetta` → `label` (il nome della proprietà in Smootify); `Togli se manca` → `delete-parent`.
- Markup: `dynamic-property[label]` dentro `smootify-add-to-cart`.

## Abbonamenti

### Prodotto / Abbonamento
- Varianti Figma: Scelta = Tab (acquisto singolo, abbonamento) | Solo abbonamento.
- Contenuto: le frequenze, il prezzo scontato.
- Prop Webflow: `Piano iniziale` → `auto-select-plan`; `Gruppo iniziale` → `data-selected-group`.
- Markup: `subscription-swatches` (Tabs di Webflow e radio), `[subscription-group=<nome>]`.

### Account / Abbonamenti
- Contenuto: lista contratti (prodotto, frequenza, prossimo addebito, stato), dettaglio (righe, consegna,
  pagamento), azioni pausa, riattiva, annulla.
- Stati: Attivo, In pausa, Annullato; lista vuota.
- Markup: `customer-subscriptions` > `customer-subscription` con `[subscription=…]`, `subscription-page`,
  `subscription-pause | subscription-activate | subscription-cancel`.

## Multi-mercato

### Mercati / Paese e valuta
- Varianti Figma: Formato = Dropdown | Popover.
- Contenuto: bandiera, nome del paese, valuta.
- Markup: `country-switcher`, `currency-code`.

### Mercati / Suggerimento
- Contenuto: "Stai visitando da Italia: prezzi in EUR", bandiera, lingua, bottone per continuare.
- Prop Webflow: `Ritardo` → `delay` (secondi); `Animazione` → `animation-name`; `Senza sfocatura` → `disable-blur`.
- Markup: `[popover][data-is=market-dialog]` (solo popover) con `[market-dialog=country|flag|language|currency|
  currency-symbol|currency-name]`, `button[data-action=continue]`.

### Mercati / Location di ritiro preferita
- Varianti Figma: Formato = Dropdown | Popover.
- Contenuto: nome e indirizzo della location scelta, elenco location.
- Markup: `location-switcher` con `[location=name|address]`.

## B2B

### Account / Azienda
- Contenuto: nome azienda, dati dell'azienda (metafield), credito store (saldo, movimenti).
- Markup: `[company=name]`, `[company-metafield=…]`, `store-credit` con `[store-credit=…]` e
  `[store-credit-transaction=…]`.

### Account / Dati personalizzati
- Contenuto: campi del cliente da mostrare e form per modificarli.
- Markup: `[customer-metafield=…]`, `customer-metafields-editor`.

## Wishlist e ultimi visti

### Wishlist / Pagina
- Stati: Lista, Vuota.
- Contenuto: griglia di card, contatore in navbar.
- Markup: `smootify-product[data-id=wishlist]`, `[wishlist=count]`,
  `[condition=has-items-in-wishlist|no-items-in-wishlist]`.

### Ultimi visti
- Markup: Prodotto / Carosello con `data-id=last-viewed`; `[condition=has-items-in-last-viewed|no-items-in-last-viewed]`.

## Store locator

### Store locator / Pagina
- Contenuto: mappa, ricerca per città o CAP, lista negozi (nome, indirizzo, orari, distanza), popup sulla mappa.
- Stati: negozio attivo nella lista.
- Prop Webflow: `Chiave Mapbox` → `data-api-key`; `Stile` → `data-style`; `Zoom iniziale` → `data-initial-zoom`.
- Markup: `store-locator` con `store-location` (`[location=…]`) e `form input[name=query]`.

## Contenuti (metaobject)

### Contenuti / Lista
- Stati: Lista, Vuota, Caricamento di altri.
- Contenuto: card ripetuta con i campi del metaobject, "carica altri".
- Prop Webflow: `Tipo` → `data-type`; `Quanti` → `data-limit`.
- Markup: `smootify-metaobjects[data-type][data-limit]` > `smootify-metaobject` con `[metaobject=<campo>]`,
  `empty-state`, `button[data-action=next|prev|load-more]`.

## Consenso cookie

### Consenso / Banner
- Varianti Figma: Pannello = Banner | Preferenze.
- Contenuto: testo, accetta, rifiuta, preferenze; nelle preferenze quattro caselle (marketing, statistiche,
  preferenze, vendita dei dati) e salva; link "Preferenze cookie" nel footer.
- Markup: `smootify-consent` con `[data-action=accept|decline|save|preferences|close]`, checkbox
  `marketing|analytics|preferences|sale_of_data`, `[consent-panel=banner|preferences]`,
  `[consent-condition=sale-of-data]`; `button[data-is=preferences-button]`.

## Magic box

### Magic box / Builder
- Contenuto: categorie, prodotti con più e meno, avanzamento, sconto raggiunto, riepilogo del box, bottone.
- Stati: prodotto Non scelto | Nel box; box Completabile | Non completabile.
- Markup: `smootify-magic-box`, `smootify-box-category`, `box-item`, `smootify-magic-box-cart` (`items-list`,
  `empty-state`, `data-buy-now`), `[box-condition=can-purchase|cannot-purchase]`.

## Piano server

### Server / Newsletter
- Stati: Default, Iscritto, Errore.
- Prop Webflow: `Tag` → `tags`.
- Markup: `newsletter-subscribe[tags]`.

### Server / Caricamento file
- Stati: Vuoto, Trascinamento, Caricamento, Caricato, Errore, Pieno.
- Contenuto: area di trascinamento, riga file (anteprima, nome, dimensione, avanzamento, errore, rimuovi), errori.
- Prop Webflow: `Nome del campo` → `name`; `Multipli` → `data-multiple`; `Solo immagini` → `data-only-images`;
  `Dimensione massima` → `max-file-size`; `Obbligatorio` → `data-required`.
- Markup: `file-uploader` con `[upload=dropzone|list|item|preview|name|size|progress|error|remove|errors]`.

### Server / Configuratore
- Varianti Figma: Campo = Testo | Checkbox | Radio | Select | Dropdown | Popover | Dimensioni (L × A × P) | File.
- Contenuto: il campo e il prezzo configurato che si aggiorna.
- Markup: `configurator-field[data-formula]` con `configurator-input | -checkbox | -radio | -select | -dropdown |
  -popover | -dimension | -file-input`.

### Server / Scegli tu il prezzo
- Stati: Default, Prezzo troppo basso.
- Markup: `name-your-price[data-invalid-price]`.

### Server / Crea contenuto
- Contenuto: form con i campi del metaobject e caricamento file.
- Markup: `metaobject-creator[data-type][data-draft]` con `file-input`.
