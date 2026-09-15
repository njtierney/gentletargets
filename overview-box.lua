-- Put the chapter overview in a box in the PDF as well as the HTML.
--
-- In HTML, `::: {.overview}` is styled by chapter-overview.scss and there is
-- nothing to do here. LaTeX has no equivalent: pandoc drops a div it does not
-- recognise, so the overview came out as a bare heading and two paragraphs,
-- indistinguishable from the chapter body around it.
--
-- So in LaTeX only, swap the div for the `rbpoverview` environment defined in
-- tufte.tex. The heading inside is lifted out and becomes the box title,
-- because a \section* set inside a tcolorbox looks wrong and lands in the
-- table of contents at the wrong level.

local function is_latex()
  return FORMAT:match("latex") ~= nil
end

function Div(el)
  if not el.classes:includes("overview") then
    return nil
  end

  if not is_latex() then
    return nil
  end

  -- Default title, in case a chapter's box has no heading in it.
  local title = "Overview"
  local body = pandoc.List({})

  for _, blk in ipairs(el.content) do
    if blk.t == "Header" then
      title = pandoc.utils.stringify(blk)
    else
      body:insert(blk)
    end
  end

  local out = pandoc.List({})
  out:insert(pandoc.RawBlock("latex", "\\begin{rbpoverview}{" .. title .. "}"))
  out:extend(body)
  out:insert(pandoc.RawBlock("latex", "\\end{rbpoverview}"))
  return out
end
