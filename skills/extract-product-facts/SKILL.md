---
name: extract-product-facts
description: Extract a DealerMarkets product's search facts from its stored documents and save them with the admin connector. Use when an App Admin asks to extract, re-extract, refresh or backfill a product's facts, after publishing a product, or after its documents or plans change (catalog_get_documents shows its facts as never extracted or out of date).
---

# Extracting product facts

Dealers search DealerMarkets products by **facts**: short, specific terms taken from each product's documents (cancellation fees, waiting periods, excluded vehicles, lender rules, where coverage applies). You read the product's documents through the admin connector, write the facts, and save them. Saving replaces all of the product's facts, so always extract from **every** document, never only the changed one.

The server decides which facts are public: a fact citing a Consumer Facing document is shown to everyone, one citing a Dealer Only document only to verified dealers. You never set this yourself, but it's why rule 6 below matters.

## Steps

1. **Find the product.** If you don't have its ID, use `catalog_find_products`.
2. **List its documents:** `catalog_get_documents` with the `productId`. It returns each document (id, type, `publiclyVisible`, `pricingGuide`, `kind`), the product's `plans` (names) and its `facts` status. Tell the user if the facts are out of date and why.
3. **Read every document** except pricing guides (`pricingGuide: true`) and web links (`kind: "link"`): `catalog_get_documents` with `documentId` and `text: true`. Read the Consumer Facing ones (`publiclyVisible: true`) first. For documents over about 30 pages, read in ranges (`pages: "1-30"`, then `"31-60"`). Contracts are long but hold most of the facts: read them fully.
   - A document that comes back unreadable (a scanned PDF, not a PDF): if the user attached the same file in this chat, read it from there and cite the stored document's id and page. Otherwise list it as unreadable in your summary and go on.
4. **Write the facts** following the rules below. A product typically has 15–60 facts; long contracts more. Keep a running file of facts as you go (in your code sandbox if you have one) rather than holding them all in your head until the end.
5. **Check them** (rule 11).
6. **Save them all at once**, in whichever way this host allows:
   - **You can run `curl` with internet access** (Claude with a code sandbox, Claude Code, Codex): write `facts.json`, call `catalog_facts_upload_link`, then `curl -sS -X PUT --data-binary @facts.json -H "Content-Type: application/json" "<link>"`. The link stays valid after a refusal.
   - **ChatGPT:** write `facts.json` in your Python tool and call `catalog_set_product_facts` with it as `file`. Its sandbox has no internet, so never use curl there.
   - **Otherwise:** call `catalog_set_product_facts` with the list as `facts`.
7. **If the save is refused**, nothing was saved. The reply lists every problem: fix them all (re-read the cited page for quote problems) and send the whole set again.
8. **Report** to the user: how many public and dealer-only facts were saved, documents no fact cites (`notCited`: check you read them), unreadable documents, and any contradictions between documents you noticed.

## File format

```json
{
  "facts": [
    {
      "topics": ["cancellation", "lender", "state"],
      "text": "Cancellation refund is pro rata less a $50 fee. No fee for Ford Motor Credit (FMCC) contracts or in CO, IN, LA, ME, NM, SC, VT, WI. Refund is paid to the lienholder.",
      "quote": "less a $50 cancellation fee. The Lienholder will be the payee on any refund",
      "plans": "all",
      "source": { "documentId": "<id from catalog_get_documents>", "page": 3 }
    }
  ]
}
```

No ids, visibility or document types: the server adds them.

## Topics (a fact usually has 1–3)

| key | covers |
| --- | --- |
| coverage | what is covered, benefits, limits, max amounts, roadside/rental/trip benefits, plan tiers |
| eligibility | vehicle age / mileage / value / LTV limits, eligible vehicle types and conditions, new/used, eligible buyers |
| exclusions | what is not covered, excluded vehicles (commercial, rideshare, salvage, grey market, modified, makes), excluded losses |
| waiting_period | waiting periods, days/miles before coverage starts, when claims can first be made, "not eligible for N days" clauses |
| cancellation | cancellation rights, free-look period, refund method (pro rata, short rate), fees, who gets the refund |
| claims | how to file, deadlines, documentation, who pays the repair facility, claim limits per period |
| transfer | transferability to new owner or vehicle, fees |
| lender | lender / lienholder / finance company rules, captive-lender (FMCC, GM Financial, etc.) specifics, LTV, payoff |
| state | state-specific variations, availability, regulator notes, states where the product or a term differs |
| territory | where coverage applies, where repairs or claims can be made, where the vehicle must be registered or the loss must happen. Not vehicle specification ("non-US spec", grey market): that's eligibility/exclusions |
| options | optional add-ons, surcharges (commercial use, lift kit, etc.), upgrade options |
| other | anything useful that fits nowhere else (administrator/obligor, insurer backing, provider details) |

Tag every topic that applies. Write each territory rule as its own fact, not inside a long exclusions list, and keep different territories apart.

## Rules

1. **Specific and self-contained.** Each `text` makes sense alone: numbers, units, conditions, named lenders and states. Plan names go in `plans`, not the text. Not "Fee applies"; instead "Cancellation after 60 days: pro rata refund less a $75 fee."
2. **One idea per fact, but don't shred.** Keep a rule and its exceptions together. Don't pad.
3. **No pricing.** Never premiums, rates, dealer cost, remit, retail prices, markups or surcharge amounts. Say a surcharge exists and what it's for, not its amount. Benefit limits, claim limits, cancellation fees and deductibles are fine.
4. **No marketing fluff** ("peace of mind", "industry leading"): only facts a dealer could act on.
5. **quote:** a verbatim excerpt (up to ~25 words) from the cited page, copied exactly from the text `catalog_get_documents` returned. The server checks it is on that page.
6. **source:** the document id and page the fact came from. Signed-out dealers only see facts from Consumer Facing documents:
   - When several documents say the same thing (for example one brochure per plan with the same terms), record it **once**: one fact listing every plan it applies to, citing one of the documents. Write separate facts only where the terms differ.
   - When a Consumer Facing and a Dealer Only document say the same thing, record it once, citing the **Consumer Facing** one.
   - When the Consumer Facing document says only part of it, write two facts: one with just what the Consumer Facing document says (citing it), and one with the dealer document's fuller version (citing that).
   - A fact contains only what its cited document says. Never merge terms from a deck, FAQ, contract or dealer summary into a fact citing a Consumer Facing document, and never mention a dealer document in its text.
7. When documents contradict each other (benefit amounts, state availability), keep both, each with its own source.
8. **plans:** which of the product's plans the fact applies to, using the names from `catalog_get_documents`' `plans`, never the document's wording.
   - The document names the plans or tiers it applies to: list every matching plan. A tier can match several plans ("Gold" → "Multi-Guard Gold 36 mo", "Multi-Guard Gold 60 mo").
   - The document says it applies to every plan, or the product has one plan: `"all"`.
   - The document is one contract form or brochure used for every plan alike, and the fact names no plan, tier, term or option that differs: `"all"`.
   - The document doesn't say: leave `plans` out. Don't guess, and don't use `"all"` just because no plan is named.
   - A plan or tier that matches no plan on the product: keep its name in the text and leave `plans` out.
   - When a term differs by plan ("$50 on Gold, $100 on Platinum"), write one fact per plan.
   - Options and add-ons are not plans: name them in the text.
9. Never cite a pricing guide.
10. Write facts as the product's terms ("Not available for rideshare vehicles"), not as "the brochure says…".
11. **Check before saving.** A fact citing a Consumer Facing document must not mention a deck, FAQ, contract, dealer summary or program guide; no fact gives a surcharge amount; every quote is copied from its cited page; every plan name is one of `plans`.
