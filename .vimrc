" Execução do gerenciador de plugins
execute pathogen#infect()
" Colorir o editor
syntax on
" Identifica o tipo de arquivo e indenta
filetype plugin indent on

" Esse comando server para numerar as linhas
set nu
" destaque (highlight) nos resultados
set hlsearch
" Busca incremental - feedback visual enquanto busco
set incsearch

" Tamanho da identação
set tabstop=4
" Deixar coerente indentação com o tamanho de TAB
set shiftwidth=4
" Usar espaços no lugar de tab
set expandtab
" Backspace respeitar indentação - Utilizar mesmo valor de tabstop e
" shiftwidth para manter coerência
set softtabstop=4

" Highlight the current line
set cursorline

" noremap <Up> <NOP>
" noremap <Down> <NOP>
" noremap <Left> <NOP>
" noremap <Right> <NOP>

map <C-n> :NERDTreeToggle<CR>

" [START] Maping Ctrl-^ to toggle 'Caps Lock'

" Execute 'lnoremap x X' and 'lnoremap X x' for each letter a-z.
for c in range(char2nr('A'), char2nr('Z'))
  execute 'lnoremap ' . nr2char(c+32) . ' ' . nr2char(c)
  execute 'lnoremap ' . nr2char(c) . ' ' . nr2char(c+32)
endfor


" Kill the capslock when leaving insert mode.
autocmd InsertLeave * set iminsert=0

" [END] Maping Ctrl-^ to toggle 'Caps Lock'

