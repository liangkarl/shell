" Plugin: lightline-bufferline
let g:lightline#bufferline#show_number  = 1
let g:lightline#bufferline#shorten_path = 0
let g:lightline#bufferline#unnamed      = '[No Name]'

let g:lightline                  = {}
let g:lightline.tabline          = {'left': [['buffers']], 'right': [['close']]}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}

" Plugin: Vista.vim
function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction
set statusline+=%{NearestMethodOrFunction()}

" By default vista.vim never run if you don't call it explicitly.
"
" If you want to show the nearest function in your statusline automatically,
" you can add the following line to your vimrc
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()

" Ensure you have installed some decent font to show these pretty symbols, then you can enable icon for the kind.
let g:vista#renderer#enable_icon = 1

" The default icons can't be suitable for all the filetypes, you can extend it as you wish.
let g:vista#renderer#icons = {
\   "function": "\uf794",
\   "variable": "\uf71b",
\  }

" To enable fzf's preview window set g:vista_fzf_preview.
" The elements of g:vista_fzf_preview will be passed as arguments to fzf#vim#with_preview()
" For example:
let g:vista_fzf_preview = ['right:50%']

" Set executives
let g:vista#executives = ['coc']

" set up files
let g:vista_executive_for = {
\	'typescript': 'coc',
\	'javascript': 'coc',
\	'vim': 'coc',
\	'cpp': 'coc',
\	'c': 'coc',
\	'html': 'coc',
\	'css': 'coc',
\	'python': 'coc'
\  }

" let g:vista_icon_indent = ['╰─🞂 ', '├─🞂 ']
let g:vista_sidebar_width = 40

" Plugin: Startify
" Show startify when there is no opened buffers
autocmd BufDelete * if empty(filter(tabpagebuflist(), '!buflisted(v:val)')) && bufname() == "" | Startify | endif
" Auto-open startify when closing all buffers
autocmd BufEnter * if bufname() == "" && len(tabpagebuflist()) == 1 | Startify | endif

" Plugin: vim-clang-format

" Plugin: editorconfig
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
au FileType gitcommit let b:EditorConfig_disable = 1

" Plugin: vim_current_word
" The word under cursor:
let g:vim_current_word#highlight_current_word = 1
" Enable/disable highlighting only in focused window:
let g:vim_current_word#highlight_only_in_focused_window = 1
" Enable/disable plugin:
let g:vim_current_word#enabled = 1

" Plugin: auto-pairs
" Avoid conflict with edit motion"
let g:AutoPairsShortcutBackInsert = '<M-B>'

" Plugin: vim-commentary
au FileType c,cpp,cc,h setlocal commentstring=//\ %s

" Plugin: vim-better-whitespace
" To strip white lines at the end of the file when stripping whitespace
let g:strip_whitelines_at_eof=1
" To highlight space characters that appear before or in-between tabs
" let g:show_spaces_that_precede_tabs=1

" Plugin: vim-lsp-cxx-highlight
" c++ syntax highlighting
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1

" Plugin: fzf - fuzzy finder
" e.g. let g:fzf_command_prefix = 'Fzf' and you have FzfFiles, etc.
let g:fzf_command_prefix = 'Fzf'

" Plugin: coc

" Plugin: coc-explorer
let g:coc_explorer_global_presets = {
\   'open.nvim': {
\     'root-uri': '~/.config/nvim',
\     'position': 'floating',
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'tabview': {
\     'position': 'tab',
\     'quit-on-open': v:true,
\   },
\   'center': {
\     'position': 'floating',
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'top': {
\     'position': 'floating',
\     'floating-position': 'center-top',
\     'open-action-strategy': 'sourceWindow',
\   },
\   'left': {
\     'position': 'floating',
\     'floating-position': 'left-center',
\     'floating-width': 40,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'right': {
\     'position': 'floating',
\     'floating-position': 'right-center',
\     'floating-width': 40,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'fixLeft': {
\     'width': 30,
\     'file-child-template': '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'
\   }
\ }

""" Optimization start
" Disable showing trailing white space in coc-explorer
autocmd User CocExplorerOpenPre DisableWhitespace
autocmd TermEnter :let b:vim_current_word_disabled_in_this_buffer = 1
autocmd TermOpen :let b:vim_current_word_disabled_in_this_buffer = 1

""" Optimization end
