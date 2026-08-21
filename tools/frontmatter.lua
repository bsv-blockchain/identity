-- Strips the markdown front matter (H1 title, the optional H3 subtitle
-- directly beneath it, the bold status/editors block, and the closing
-- horizontal rule) from the body, because build-docs.sh has already lifted
-- those into the PDF title block and the EPUB metadata.
--
-- The whole front matter is positional, not pattern-matched anywhere in the
-- document: whitepaper.md carries no subtitle, so a "first H3" rule would eat
-- its "### 1. Executive summary" heading, and every paper uses bold lead-ins
-- ("**Changes since v0.2:**") in the body that must survive.

function Pandoc(doc)
  local blocks = doc.blocks

  if blocks[1] and blocks[1].t == "Header" and blocks[1].level == 1 then
    table.remove(blocks, 1)
  end
  if blocks[1] and blocks[1].t == "Header" and blocks[1].level == 3 then
    table.remove(blocks, 1)
  end

  -- The status/editors paragraph, and only it: search stops at the rule that
  -- closes the front matter.
  for i, b in ipairs(blocks) do
    if b.t == "HorizontalRule" then break end
    if b.t == "Para" and b.content[1] and b.content[1].t == "Strong" then
      table.remove(blocks, i)
      break
    end
  end

  for i, b in ipairs(blocks) do
    if b.t == "HorizontalRule" then table.remove(blocks, i); break end
  end

  return doc
end
