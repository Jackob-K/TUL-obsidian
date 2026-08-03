function Inlines(inlines)
  local out = {}
  local i = 1

  while i <= #inlines do
    local el = inlines[i]

    -- začátek wikilinku [[
    if el.t == "Str" and el.text:sub(1, 2) == "[[" then
      local text = el.text
      local j = i + 1

      -- sbíráme jen Str a Space, nic jiného
      while j <= #inlines do
        local next_el = inlines[j]

        if next_el.t == "Str" then
          text = text .. next_el.text
        elseif next_el.t == "Space" then
          text = text .. " "
        else
          break
        end

        if text:find("%]%]") then
          break
        end

        j = j + 1
      end

      -- [[id|label]]
      local label = text:match("%[%[[^|%]]+|([^%]]+)%]%]")
      if label then
        table.insert(out, pandoc.Str(label))
        i = j + 1
        goto continue
      end

      -- [[label]]
      local simple = text:match("%[%[([^%]]+)%]%]")
      if simple then
        table.insert(out, pandoc.Str(simple))
        i = j + 1
        goto continue
      end
    end

    -- fallback: beze změny
    table.insert(out, el)
    i = i + 1

    ::continue::
  end

  return out
end
