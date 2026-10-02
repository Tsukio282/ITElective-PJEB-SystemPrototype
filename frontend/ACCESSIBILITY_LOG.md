# Task 2: Manual Corrections Log (for Member 1's SUBMISSION.md)

Contrast ratios below were computed with the WCAG relative-luminance formula. AA needs 4.5:1 for normal text and 3:1 for UI components and focus indicators.

## Corrections made to the reference design before reuse

| # | Issue found | WCAG criterion | Fix applied |
|---|-------------|----------------|-------------|
| 1 | Muted text colour `#8a7f81` is 3.86:1 on white (3.53:1 on `#f7f4f4`) | 1.4.3 Contrast (Minimum) | Dark theme: muted text is `#b99aab` (7.19:1 on the card surface `#1c121a`, 7.64:1 on the page `#130b10`) |
| 2 | Input borders `#eadfdf` are 1.3:1 against white, so fields are hard to see | 1.4.11 Non-text Contrast | Field borders are `#9a7a8b` (5.11:1 on `#130b10`, 4.81:1 on `#1c121a`) |
| 3 | Focus ring was gold `#c49a3c`, only 2.61:1 on white | 2.4.7 Focus Visible, 1.4.11 | Focus ring is 3px pink `#ff5c9d` (6.71:1 on `#130b10`, 6.32:1 on `#1c121a`) |
| 4 | Reference relies on placeholder text inside inputs | 3.3.2 Labels or Instructions | Every field has a visible `<label for>` linked to its input `id`; placeholders removed |
| 5 | Small controls (icon buttons, checkbox) | 2.5.8 Target Size | Buttons, filters and fields are at least 44px tall; checkbox is 24px |

## Colour scheme (black and pink)

- Neutrals are near-black tinted toward pink (`#130b10`, `#1c121a`, `#281a23`) so the base and accent belong to one hue family. Rough split: 60% base, 30% surfaces, 10% pink.
- Pink `#ff5c9d` is the only action colour (buttons, active filter, links, focus). Text on pink is near-black `#1a0710` (6.72:1); white on this pink would fail.
- Body text `#fbeff4` is 16.3:1 on cards. Secondary text `#dcc3d0` is 11.09:1.
- Status colours sit away from pink on the colour wheel so they are not confused with the brand: green `#8cf0b5` on `#12301f` (10.38:1), amber `#ffc56b` on `#3a2a0c` (8.87:1), coral errors `#ff8f6b` on the card surface (8.16:1). Errors also use an "Error:" text prefix and a thicker border, so colour is never the only cue.
- `color-scheme: dark` makes native controls (select menu, checkbox, scrollbars) match.

## Added for this page

- Event cards are `<article>` elements inside a parent `<section>`. The page uses `<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<footer>`, with a skip link.
- Each input has a linked `<label for>` plus an `aria-label` that repeats the visible label text, so the accessible name matches what is shown (2.5.3 Label in Name).
- Errors appear in text with an "Error:" prefix (not colour alone), are tied to fields with `aria-describedby`, and focus moves to the first invalid field. The success message and result count use `role="status"`.
- Each card's Register button has an `aria-label` naming the event, so repeated "Register" buttons are distinguishable.
- All four `<img>` tags have `alt` text. They are placeholder shapes, so the alt text says so. Banner art is dark plum with a pink shape. Replace the art and rewrite the alt text when real event photos are available.

## Add your own entries from the AI tool run

Record anything your AI tool got wrong in its first output and what you changed. Example format:

| # | What the AI generated | Problem | Manual fix |
|---|-----------------------|---------|------------|
| A | | | |
