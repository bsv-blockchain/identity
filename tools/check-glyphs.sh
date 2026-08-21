#!/usr/bin/env bash
# Guard the PDF fonts against new characters.
#
#   tools/check-glyphs.sh            fail if a document uses a character that
#                                   has not been visually verified
#   tools/check-glyphs.sh --sheet    render a coverage sheet for eyeballing
#   tools/check-glyphs.sh --accept   record the current inventory as verified
#
# Why this exists: typst silently falls back across every installed font, so a
# missing glyph produces no warning and no error, only a wrong-looking or
# tofu character in the PDF, and only on machines lacking whatever font it
# borrowed. The two fonts this design targets (Libertinus Serif for text,
# DejaVu Sans Mono for code, both bundled with typst) were confirmed by eye to
# cover every character in tools/glyphs.verified. Anything new needs the same
# check before it can be trusted to render on someone else's machine.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
TOOLS=$PWD/tools
VERIFIED=$TOOLS/glyphs.verified
DOCS=(whitepaper.md technical-whitepaper.md summary.md zk-proofs-and-poc.md)

inventory() {
  python3 - "${DOCS[@]}" <<'PY'
import sys
chars=set()
for f in sys.argv[1:]:
    chars|={c for c in open(f, encoding='utf-8').read() if ord(c) > 127}
print(''.join(sorted(chars)))
PY
}

sheet() {
  local out=${1:-glyph-coverage.png}
  python3 - "$(inventory)" > /tmp/identity-glyphs.typ <<'PY'
import sys, unicodedata
g = sys.argv[1]
rows = "".join(
    f'[{c}], [U+{ord(c):04X}], [{unicodedata.name(c, "?")[:36]}], [#raw("{c}")],\n'
    for c in g
)
print(f'''#set page(width: 210mm, height: auto, margin: 12mm, fill: white)
#set text(font: "Libertinus Serif", size: 11pt)
#show raw: set text(font: "DejaVu Sans Mono", size: 10pt)
= Glyph coverage
Body font: Libertinus Serif. Code font: DejaVu Sans Mono. A blank or boxed cell
means the font lacks that character and typst fell back silently.
#v(6pt)
#table(columns: 4, stroke: 0.4pt + gray, align: (center, left, left, center),
  table.header([body], [code], [name], [mono]),
{rows})''')
PY
  typst compile --format png --ppi 130 /tmp/identity-glyphs.typ "$out"
  echo "wrote $out ($(inventory | wc -m | tr -d ' ') characters)"
}

case ${1:-check} in
  --sheet)  sheet "${2:-glyph-coverage.png}" ;;
  --accept) inventory > "$VERIFIED"; echo "recorded $(wc -m < "$VERIFIED" | tr -d ' ') characters as verified" ;;
  check|--check)
    [[ -f $VERIFIED ]] || { echo "error: $VERIFIED missing; run --accept after verifying a sheet" >&2; exit 2; }
    added=$(python3 -c "
import sys
cur=set(sys.argv[1]); ok=set(open(sys.argv[2],encoding='utf-8').read().strip())
print(''.join(sorted(cur-ok)))" "$(inventory)" "$VERIFIED")
    if [[ -n $added ]]; then
      echo "error: unverified character(s) in use: $added" >&2
      echo "run tools/check-glyphs.sh --sheet, confirm they render in both fonts," >&2
      echo "then tools/check-glyphs.sh --accept" >&2
      exit 1
    fi
    echo "glyphs ok ($(wc -m < "$VERIFIED" | tr -d ' ') verified characters, none new)"
    ;;
  -h|--help) sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^#\{1,\} \{0,1\}//' ;;
  *) echo "unknown argument: $1" >&2; exit 2 ;;
esac
