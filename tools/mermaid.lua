-- Renders ```mermaid fenced blocks to SVG with mmdc and substitutes the image,
-- so a diagram that GitHub renders natively is a diagram in the PDF and the
-- EPUB too rather than a page of flowchart source.
--
-- The SVG is content-addressed by the SHA-1 of the block, so an unchanged
-- diagram is never re-rendered (mmdc costs a headless Chromium launch), and a
-- stale one cannot be served. build-docs.sh passes the cache directory and the
-- mermaid config in the environment.
--
-- tools/mermaid.json turns htmlLabels off, which JSON gives no room to explain:
-- mermaid 11 puts node labels in <foreignObject> by default, and typst renders
-- those as blank boxes. With it off, labels are plain <text> and the diagram
-- survives the typst path.

local cache  = os.getenv("MERMAID_CACHE")  or error("MERMAID_CACHE unset")
local config = os.getenv("MERMAID_CONFIG") or error("MERMAID_CONFIG unset")

local function render(src, svg)
  local mmd = svg:gsub("%.svg$", ".mmd")
  local log = svg .. ".log"
  local f = assert(io.open(mmd, "w"))
  f:write(src, "\n")
  f:close()
  -- Failure must stop the build: without this the block would silently vanish.
  local cmd = ("mmdc --input %q --output %q --configFile %q --backgroundColor transparent > %q 2>&1")
    :format(mmd, svg, config, log)
  if not os.execute(cmd) then
    local l = io.open(log, "r")
    local why = l and l:read("a") or "(no mmdc output)"
    if l then l:close() end
    error("mmdc failed on a mermaid block:\n" .. why)
  end
end

function CodeBlock(el)
  if not el.classes:includes("mermaid") then return nil end

  local svg = cache .. "/" .. pandoc.utils.sha1(el.text) .. ".svg"
  local hit = io.open(svg, "r")
  if hit then hit:close() else render(el.text, svg) end

  -- The diagrams run to the measure; 100% keeps a wide one inside it. The alt
  -- text names the shape, which is all the source gives us.
  local kind = el.text:match("^%s*([%a]+)") or "mermaid"
  return pandoc.Para{
    pandoc.Image({ pandoc.Str(kind .. " diagram") }, svg, "", { width = "100%" })
  }
end
