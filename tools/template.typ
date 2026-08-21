// BSV Unified Identity document set: PDF layout.
//
// Fonts are the two typst bundles with complete coverage of the 30 non-ASCII
// characters these papers use (subscripts, modifier letters, set and logic
// operators, U+2225): Libertinus Serif for text, DejaVu Sans Mono for code.
// Do not swap either without re-running tools/check-glyphs.sh.

#let ink        = rgb("#14181F")
#let ink-soft   = rgb("#5A6472")
#let rule-col   = rgb("#D3D9E2")
#let code-bg    = rgb("#F6F7F9")
#let link-col   = rgb("#17457E")

// Code blocks cannot rely on typst's line breaking: raw text has no break
// opportunities, and the longest formula here is 129 characters, which would
// need 5.5pt to fit the measure. So each source line becomes its own paragraph
// that wraps at single spaces, with a hanging indent marking continuations.
// Runs of two or more spaces become non-breaking so aligned columns survive.
#let wrapped-code(txt) = {
  set text(font: "DejaVu Sans Mono", size: 8.7pt, fill: ink)
  set par(justify: false, leading: 0.52em, spacing: 0.52em, hanging-indent: 2em)
  let lines = txt.split("\n")
  // Trailing blank line is an artifact of fenced-block parsing.
  if lines.len() > 0 and lines.last().trim() == "" { lines = lines.slice(0, -1) }
  for line in lines {
    if line.trim() == "" {
      block(height: 0.52em)
    } else {
      let body = line.trim(at: start, "\u{20}")
      let indent = line.len() - body.len()
      // Protect column alignment, keep single spaces as break opportunities.
      let kept = body.replace(regex("[ ]{2,}"), m => "\u{00A0}" * m.text.len())
      par(h(indent * 0.6em) + kept)
    }
  }
}

// pandoc's typst writer emits #horizontalrule for a markdown thematic break
// and leaves it to the caller to define.
#let horizontalrule = align(center, block(above: 1.4em, below: 1.4em,
  line(length: 32%, stroke: 0.5pt + rule-col)))

#let paper(title: "", subtitle: "", status: "", editors: "", body) = {
  set document(title: title, description: subtitle)
  set page(
    paper: "a4",
    fill: white,
    margin: (top: 26mm, bottom: 26mm, inside: 30mm, outside: 24mm),
    header-ascent: 10mm,
    footer-descent: 8mm,
    header: context {
      if counter(page).get().first() <= 1 { return }
      // A heading that opens the current page must win: before(here()) does
      // not see it, which would label the page with the previous section.
      let page-no = counter(page).get().first()
      let sections = query(heading.where(level: 2))
      let opening = sections.filter(h => h.location().page() == page-no)
      let earlier = sections.filter(h => h.location().page() < page-no)
      let current = if opening.len() > 0 {
        opening.first().body
      } else if earlier.len() > 0 {
        earlier.last().body
      } else { [] }
      set text(size: 8.5pt, fill: ink-soft, font: "Libertinus Serif")
      grid(
        columns: (1fr, auto),
        align(left, emph(title)),
        align(right, emph(current)),
      )
      v(-2mm)
      line(length: 100%, stroke: 0.4pt + rule-col)
    },
    footer: context {
      set text(size: 8.5pt, fill: ink-soft, font: "Libertinus Serif")
      align(center, counter(page).display("1"))
    },
  )

  set text(font: "Libertinus Serif", size: 10.5pt, fill: ink, lang: "en", region: "gb",
    hyphenate: true)
  set par(justify: true, leading: 0.62em, spacing: 0.9em, linebreaks: "optimized")
  show link: set text(fill: link-col)
  // highlight() rather than box(): a box cannot break across lines, and some
  // inline literals here run to 90-odd characters, which would strand them on
  // their own line and stretch the justified line above into whitespace.
  show raw.where(block: false): it => highlight(
    fill: code-bg, extent: 1pt, radius: 1.5pt,
    text(font: "DejaVu Sans Mono", size: 8.9pt, it.text),
  )
  show raw.where(block: true): it => block(
    width: 100%, fill: code-bg, stroke: 0.5pt + rule-col, radius: 2.5pt,
    inset: (x: 9pt, y: 8pt), breakable: true, above: 1.1em, below: 1.1em,
    wrapped-code(it.text),
  )

  // The papers carry their own section numbers in the heading text.
  set heading(numbering: none)
  show heading: set text(font: "Libertinus Serif", weight: "bold")
  show heading.where(level: 2): it => block(above: 1.9em, below: 0.85em)[
    #set text(size: 14pt)
    #it.body
    #v(-0.55em)
    #line(length: 100%, stroke: 0.5pt + rule-col)
  ]
  show heading.where(level: 3): set text(size: 11.5pt)
  show heading.where(level: 4): it => block(above: 1.2em, below: 0.5em)[
    #set text(size: 10.5pt, style: "italic", weight: "regular", fill: ink-soft)
    #it.body
  ]
  show heading.where(level: 3): set block(above: 1.45em, below: 0.6em)

  set list(indent: 0.6em, spacing: 0.62em, marker: text(fill: ink-soft, [•]))
  set enum(indent: 0.6em, spacing: 0.62em)
  show table: set text(size: 9.5pt)
  set table(stroke: (x, y) => (top: if y <= 1 { 0.5pt + rule-col }, bottom: 0.5pt + rule-col))

  // Title block, then a rule. No separate title page: these documents run from
  // three pages to forty and a cover sheet suits only the long end.
  block(above: 0pt, below: 1.6em)[
    #set par(justify: false)
    #text(size: 20pt, weight: "bold")[#title]
    #if subtitle != "" [
      #v(0.35em)
      #text(size: 12pt, style: "italic", fill: ink-soft)[#subtitle]
    ]
    #v(0.7em)
    #line(length: 100%, stroke: 0.8pt + ink)
    #v(0.25em)
    #text(size: 9pt, fill: ink-soft)[#status #h(1fr) #editors]
  ]

  show outline.entry.where(level: 1): it => strong(it)
  block(below: 1.8em)[
    #set text(size: 9.5pt)
    #outline(title: text(size: 11pt, weight: "bold")[Contents], depth: 3, indent: 1.2em)
  ]

  body
}
