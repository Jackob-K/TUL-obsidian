function Para(el)
  if #el.content == 1 then
    local c = el.content[1]
    if c.t == "Str" and c.text == "***" then
      return {
        pandoc.Para({}),
        pandoc.HorizontalRule(),
        pandoc.Para({})
      }
    end
  end
end
