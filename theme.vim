set background=dark
"colorscheme tokyonight-night
colorscheme github_dark_colorblind

"override colorscheme
"enable transparent background
"highlight Normal ctermbg=NONE guibg=NONE

"render whitespace softer than comments
highlight NonText guifg=#262a40
highlight Whitespace guifg=#262a40
highlight SpecialKey guifg=#262a40

"highlight only one character when line too long
highlight ColorColumn ctermbg=grey guibg=grey25
call matchadd('ColorColumn', '\%88v', 100)
