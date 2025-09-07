" dracula-pro.vim - Kitty'deki Dracula Pro paletine uygun Neovim teması

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "dracula-pro"

" Renk tanımları (Kitty config’inden alındı)
let s:bg       = '#22212c'
let s:fg       = '#f8f8f2'
let s:cursor   = '#f8f8f2'
let s:sel_bg   = '#454158'

let s:black    = '#22212c'
let s:black_b  = '#6272a4'

let s:red      = '#ff9580'
let s:red_b    = '#ffaa99'

let s:green    = '#8aff80'
let s:green_b  = '#a2ff99'

let s:yellow   = '#ffff80'
let s:yellow_b = '#ffff99'

let s:blue     = '#9580ff'
let s:blue_b   = '#aa99ff'

let s:magenta  = '#ff80bf'
let s:magenta_b= '#ff99cc'

let s:cyan     = '#80ffea'
let s:cyan_b   = '#99ffee'

let s:white    = '#f8f8f2'
let s:white_b  = '#ffffff'

" Temel vurgular
exe 'hi Normal          guifg=' . s:fg . ' guibg=' . s:bg
exe 'hi Cursor          guifg=' . s:bg . ' guibg=' . s:cursor
exe 'hi CursorLine      guibg=' . s:sel_bg
exe 'hi Visual          guibg=' . s:sel_bg . ' guifg=' . s:fg

" Syntax renkleri
exe 'hi Comment         guifg=' . s:black_b
exe 'hi Constant        guifg=' . s:cyan
exe 'hi String          guifg=' . s:green
exe 'hi Number          guifg=' . s:yellow
exe 'hi Boolean         guifg=' . s:yellow
exe 'hi Function        guifg=' . s:blue
exe 'hi Identifier      guifg=' . s:red
exe 'hi Statement       guifg=' . s:red
exe 'hi PreProc         guifg=' . s:magenta
exe 'hi Type            guifg=' . s:yellow
exe 'hi Special         guifg=' . s:cyan
exe 'hi Error           guifg=' . s:red . ' guibg=' . s:black
exe 'hi Todo            guifg=' . s:white . ' guibg=' . s:yellow

" UI Bileşenleri
exe 'hi LineNr          guifg=' . s:black_b . ' guibg=' . s:bg
exe 'hi CursorLineNr    guifg=' . s:yellow . ' guibg=' . s:sel_bg
exe 'hi StatusLine      guifg=' . s:fg . ' guibg=' . s:sel_bg . ' gui=bold'
exe 'hi StatusLineNC    guifg=' . s:black_b . ' guibg=' . s:bg
exe 'hi VertSplit       guifg=' . s:sel_bg . ' guibg=' . s:sel_bg
exe 'hi TabLine         guifg=' . s:fg . ' guibg=' . s:bg
exe 'hi TabLineSel      guifg=' . s:fg . ' guibg=' . s:sel_bg
exe 'hi Pmenu           guifg=' . s:fg . ' guibg=' . s:sel_bg
exe 'hi PmenuSel        guifg=' . s:fg . ' guibg=' . s:blue
exe 'hi MatchParen      guifg=' . s:red . ' guibg=' . s:sel_bg

" Diff
exe 'hi DiffAdd         guifg=' . s:green . ' guibg=' . s:bg
exe 'hi DiffChange      guifg=' . s:yellow . ' guibg=' . s:bg
exe 'hi DiffDelete      guifg=' . s:red . ' guibg=' . s:bg
exe 'hi DiffText        guifg=' . s:blue . ' guibg=' . s:bg
