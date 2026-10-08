function Image(img)
  if img.src:match("%.svg$") then
    local vector_pdf = img.src:gsub("%.[^.]+$", ".pdf")
    local svg_pdf_path = os.getenv("SVG_PDF_PATH")
    if svg_pdf_path then
      local file = io.open(svg_pdf_path .. "/" .. vector_pdf, "r")
      if file then
        file:close()
        img.src = svg_pdf_path .. "/" .. vector_pdf
        return img
      end
    end

    -- Retain support for an explicitly prepared PNG fallback.
    local png = img.src:gsub("%.[^.]+$", ".png")
    local subject_path = os.getenv("SUBJECT_PATH")
    if subject_path then
      local file = io.open(subject_path .. "/" .. png, "r")
      if file then
        file:close()
        img.src = png
        return img
      end
    end
    io.stderr:write("Upozornění: SVG nebylo převedeno na PDF a PNG varianta neexistuje: " .. img.src .. "\n")
    return {}
  end

  local extension = img.src:lower():match("%.([^.]+)$")
  if extension ~= "webp" and extension ~= "tif" and extension ~= "tiff"
      and extension ~= "heic" and extension ~= "heif" then
    return img
  end

  local png = img.src:gsub("%.[^.]+$", ".png")
  local asset_path = os.getenv("CONVERTED_ASSET_PATH")
  if asset_path then
    local file = io.open(asset_path .. "/" .. png, "r")
    if file then
      file:close()
      img.src = asset_path .. "/" .. png
      return img
    end
  end

  io.stderr:write("Upozornění: obrázek přeskočen, PNG varianta neexistuje: " .. img.src .. "\n")
  return {}
end
