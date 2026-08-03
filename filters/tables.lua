function Table(tbl)
  local aligns = {}
  for i = 1, #tbl.colspecs do
    aligns[i] = {pandoc.AlignDefault, nil}
  end
  tbl.colspecs = aligns
  return tbl
end
