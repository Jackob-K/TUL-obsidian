-- Remove Obsidian-style %%...%% editorial comments from Pandoc inline content.
-- Comments must open and close within the same paragraph. Fail closed if one
-- is left open so editorial text cannot silently leak into the PDF.

local function strip_comments(inlines)
  local result = {}
  local inside_comment = false

  local function append_text(text)
    if text ~= "" then
      table.insert(result, pandoc.Str(text))
    end
  end

  for _, inline in ipairs(inlines) do
    if inline.t == "Str" then
      local text = inline.text
      local cursor = 1

      while cursor <= #text do
        local marker_start = text:find("%%", cursor, true)
        if not marker_start then
          if not inside_comment then
            append_text(text:sub(cursor))
          end
          break
        end

        if not inside_comment then
          append_text(text:sub(cursor, marker_start - 1))
        end

        inside_comment = not inside_comment
        cursor = marker_start + 2
      end
    elseif not inside_comment then
      table.insert(result, inline)
    end
  end

  if inside_comment then
    error("Neuzavreny komentar %%...%%: oteviraci a uzaviraci znacka musi byt ve stejnem odstavci.")
  end

  return result
end

function Inlines(inlines)
  return strip_comments(inlines)
end
