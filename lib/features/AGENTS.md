# lib/features — rules (UI slices)

- A feature imports `lib/domain` and `lib/core` only; never another feature, never `lib/data` (wired in `lib/core` DI).
- Text: ARB keys only. Counts use an ICU plural with all six Arabic categories (zero, one, two, few, many, other); English needs one and other.
- Numbers and dates: only through the `lib/core` formatter (Latin digits, Arabic month names يناير … ديسمبر; BR-30, BR-32). Amount fields pass input through the `lib/core` digit normalizer (BR-31).
- Direction: `EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`, `start`/`end`. Never `left`/`right` for layout. Mirror only icons that show direction (back, next).
- An amount or currency code inside Arabic text is isolated (Unicode FSI…PDI or its own `Text` with `TextDirection.ltr`).
- Colors and spacing from `lib/core/theme` tokens; no literal colors.
- A UI change is reviewed with one Arabic and one English screenshot.
