function Image(img)
  local unsupported = img.src:match("%.svg$")
    or img.src:match("%.webp$")
    or img.src:match("%.tif$")
    or img.src:match("%.tiff$")

  if not unsupported then
    return img
  end

  local png = img.src:gsub("%.[^.]+$", ".png")
  local subject_path = os.getenv("SUBJECT_PATH")
  if not subject_path then
    io.stderr:write("Upozornění: obrázek přeskočen, formát není vhodný pro LaTeX PDF: " .. img.src .. "\n")
    return {}
  end

  local file = io.open(subject_path .. "/" .. png, "r")
  if file then
    file:close()
    img.src = png
    return img
  end

  io.stderr:write("Upozornění: obrázek přeskočen, PNG varianta neexistuje: " .. img.src .. "\n")
  return {}
end
