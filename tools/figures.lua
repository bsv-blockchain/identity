-- Drops the auto-generated figure caption. pandoc promotes an image's alt text
-- to a numbered caption ("Figure 1: Figure 1 - Layered architecture"), which in
-- these papers collides twice over: every diagram carries its own title inside
-- the SVG, and the markdown supplies a real caption paragraph beneath it. The
-- alt text stays on the image for accessibility.

function Figure(el)
  return pandoc.Div(el.content)
end
