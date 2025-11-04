local hues = require('mini.hues')

local palette

if vim.o.background == 'dark' then
  palette = hues.make_palette({
    background = '#2E3440',
    foreground = '#ECEFF4',
  })
else
  palette = hues.make_palette({
    background = '#FFFFFF',
    foreground = '#37474F',
  })
end

hues.apply_palette(palette)

vim.g.colors_name = 'mini-nano'
