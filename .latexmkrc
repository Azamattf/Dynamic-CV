$pdf_mode = 1;  # Ensure PDF output
$latex = 'lualatex';  # Use LuaLaTeX
$lualatex = 'lualatex -synctex=1 -interaction=nonstopmode -file-line-error -recorder %O %S';  # Correct LuaLaTeX command
