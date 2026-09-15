local collected_links = {}
local seen_links = {}

-- Add a link to our collection (avoiding duplicates)
local function add_link(link_elem)
  local link_key = pandoc.utils.stringify(link_elem.content) .. "|" .. link_elem.target
  
  if not seen_links[link_key] then
    seen_links[link_key] = true
    table.insert(collected_links, link_elem:clone())
  end
end

-- Collect links during the first pass
local function collect_links(el)
  if el.t == "Link" then
    add_link(el)
  end
  return nil  -- Don't modify the element, just collect
end

-- Add the Links section at the end
local function add_links_section(doc)
  if #collected_links == 0 then
    return doc  -- No links found, return unchanged
  end
  
  -- Check if the output format is revealjs
  local is_revealjs = quarto.doc.is_format("revealjs")
  -- Determine if scrolling is needed (more than ~6 links under revealjs)
  local needs_scroll = is_revealjs and #collected_links > 6
  
  -- Set header level and classes
  --
  -- LOCAL MODIFICATION for this book. Upstream uses H1 outside revealjs,
  -- which in a Quarto book is the chapter level - so "Links" rendered as a
  -- sibling of the chapter title and picked up a chapter number ("2 Links").
  -- H2 puts it inside the chapter, and `unnumbered` keeps it out of the
  -- section numbering. Re-apply this if the extension is ever updated.
  local header_level = 2
  local header_classes = needs_scroll and {"scrollable", "unnumbered"} or {"unnumbered"}
  local header_attr = pandoc.Attr("", header_classes, {})
  
  -- Convert collected links to list items
  local links_list = {}
  for _, link in ipairs(collected_links) do
    table.insert(links_list, pandoc.Plain({link}))
  end
  
  -- Add elements to document
  table.insert(doc.blocks, pandoc.Header(header_level, "Links", header_attr))

  -- If scrolling is needed, add a hint
  if needs_scroll then
    table.insert(doc.blocks, pandoc.Para({pandoc.Emph({pandoc.Str("Scroll to see more links")})}))
  end
  
  table.insert(doc.blocks, pandoc.BulletList(links_list))
  
  return doc
end

-- Return the filter functions
return {
  {
    Link = collect_links  -- First pass: collect all links
  },
  {
    Pandoc = add_links_section  -- Second pass: add links section
  }
}