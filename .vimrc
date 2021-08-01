" PREREQUIREMENTS ------------------------
"
" git (1.8+ recommended) for vim-plug and other plugins
" nodejs (>= 10.12) for CoC plugin
" nerd-comatable font (https://github.com/ryanoasis/nerd-fonts) for vim-devicons
"	On android (Termux) (re-)place selected font at ~/.termux/font.ttf:
"	cd ~/.termux/ && wget -O SourceCodePro.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SourceCodePro.zip && unzip -j SourceCodePro.zip 'Sauce Code Pro Nerd Font Complete Mono.ttf' && mv 'Sauce Code Pro Nerd Font Complete Mono.ttf' 'font.ttf' && rm SourceCodePro.zip
"
"-----------------------------------------


" Tips -----------------------------------
"
" Vim-Plug:
"
"	Updating plugins:
"		1. :PlugUpdate - Install or update plugins
"		2. :PlugUpgrade - Update vim-plug itself
"	If you want to disable some plugins:
"		1. Remove or comment out their Plugs in the Vim-Plug section of this .vimrc
"		2. Then reload vimrc (:source ~/.vimrc) or restart Vim.
"		3. (Optional) Run :PlugClean to seek and destroy all undeclared plugins from disk.
" CoC plugin:
"	List installed extensions:
"		:Coclist extensions
"			(+) - extension was loaded
"			(-) - extension was disabled
"			(*) - extension was activated
"			(?) - invalid extension
"	Updating extensions:
"		For manual updates use :CocUpdate
"		To enable autoupdate - in :CocConfig set 'coc.preferences.extensionUpdateCheck' to 'daily'
"	Uninstalling extensions:
"		:CocUninstall coc-css
"
" ----------------------------------------


" OS detector ----------------------------
"
" Record name of running OS to a variable
" It may be used later for OS-specific options
let s:platform = "unknown"

if has("unix")
	if has("mac")
		let s:platform = "macOS"
	else
		if substitute(system('uname -o'), "\n", "", "") == "Android"
			let s:platform = "Android"
		else
			let s:platform = "Linux"
		endif
	endif
elseif has("win32") || has("win64")
	let s:platform = "Windows"
endif
"
"-----------------------------------------


" General Settings -----------------------
"
" Syntax highlighting ('enable' and 'on' aren't the same)
syntax on
" Ward off unexpected things from distro. Helpful when sharing this config for a test-ride (vim -u test_vimrc)
set nocompatible
" Requirenment for vim-devicons and CoC
set encoding=utf-8
"
" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
if s:platform=="Android"
	set updatetime=1024
else
	set updatetime=512
endif
" Display line numbers on the left
set number
" Enable use of the mouse if it's present
" or if we're on a portable device (presumably with a touchscreen)
" Hold Shift when selecting with mouse to copy text.
if has('mouse') || s:platform=="Android"
	set mouse=a
endif
" Set working directory to the current file
set autochdir
" Show whitespace characters
set list
" Characters to represent whitespace characters
"set listchars=tab:░\ ,trail:-,extends:❯,precedes:❮,nbsp:⎵,space:·
if s:platform=="Android"
	set listchars=tab:░\ ,trail:-,extends:❯,precedes:❮,nbsp:⎵
else
	set listchars=tab:░\ ,trail:-,extends:❯,precedes:❮,nbsp:⎵,space:◦
endif
"
"-----------------------------------------


" Shortcuts ------------------------------
"
" :map <key> will list anyexisting mappingsfor <key>.
"
" Clipboard
	" if vim was compiled with clipboard support:
if has("clipboard")
	" remap Y and P to copy/past to system clipboard
	noremap <C-y> "+y<CR>
	noremap <C-p> "+p<CR>
endif
"
" Buffer switching
" (In analogy with switching tabs, using 'gt' and 'gT'):
"	Go to the next buffer in buffer list
noremap bt :bnext<CR>
"	Go to the previous buffer in buffer list
noremap bT :bprevious<CR>
"	Go to the specific buffer:
noremap b1 :b1<CR>
noremap b2 :b2<CR>
noremap b3 :b3<CR>
noremap b4 :b4<CR>
noremap b5 :b5<CR>
noremap b6 :b6<CR>
noremap b7 :b7<CR>
noremap b8 :b8<CR>
noremap b9 :b9<CR>
"
" ----------------------------------------


" Tabs and Indentation -------------------
"
" Explicitly disable converting tabs to spaces (default = noexpandtab)
set noexpandtab
" Width of the TAB character
set tabstop=4
" Affects what happens when you press >>, << or ==. Also affects automatic indentation.
set shiftwidth=4
" affects what happens when you press the <TAB> or <BS> keys.
set softtabstop=4
" (Good idea to keep tabstop, shiftwidth and softtabstop to the same value)
" <TAB> in front of a line inserts blanks according to 'shiftwidth'. 'tabstop' or 'softtabstop' is used in other places.
set smarttab
" Copy indent from current line when starting a new line
set autoindent
" Automatically inserts one extra level of indentation in some cases
set smartindent
"
"-----------------------------------------


" Wrapping -------------------------------
"
" Enable word wrapping
set wrap
" Prevent wrapping from breaking words (soft-wrap)
set linebreak
" Character to display start of wrapped line
let &showbreak='⤷ '
" Keep indentation while wrapping text
set breakindent
" Ident by an additional 2 characters on wrapped lines, when line >= 40 characters, put 'showbreak' at start of line
set breakindentopt=shift:0,min:40,sbr
"
" Map wrap toggling to the `Shift+w` in NORMAL mode
function WrapToggle()
	" Ampersand in fron of 'wrap' tells Vim that we're referring to an option, not a variable.
	if (&wrap == 1)
		" Disable wrap (set it to 'nowrap') if it was enabled
		set wrap!
	else
		set wrap
	endif
endfunction
nnoremap <S-w> :call WrapToggle()<CR>
"
"-----------------------------------------


" Highlight word under the cursor -------
"
" Highlight all instances of the word that is currently under the cursor
" https://stackoverflow.com/a/64782689/15153114
"
function! HighlightWordUnderCursor()
	let disabled_ft = ["qf", "fugitive", "nerdtree", "gundo", "diff", "fzf", "floaterm"]
	if &diff || &buftype == "terminal" || index(disabled_ft, &filetype) >= 0
		return
	endif
	if getline(".")[col(".")-1] !~# '[[:punct:][:blank:]]'
		hi MatchWord cterm=undercurl gui=undercurl guibg=#20253d
		exec 'match' 'MatchWord' '/\V\<'.expand('<cword>').'\>/'
	else
		match none
	endif
endfunction
augroup MatchWord
	" Clear the autocmds of the current group
	" to prevent them from piling up each time you reload your vimrc.
	autocmd!
	autocmd! CursorHold,CursorHoldI * call HighlightWordUnderCursor()
augroup END
"
"----------------------------------------


" Highlight trailing whitespaces ---------
"
"
" Color for highlighting
highlight default ExtraWhitespace ctermbg=172 guibg=#e39400
autocmd ColorScheme * highlight default ExtraWhitespace ctermbg=172 guibg=#e39400
" Show trailing whitespace and spaces before a tab:
"	(We are using `2match`, beacuse` match` was already taken
"	by the HighlightWordUnderCursor function)
2match ExtraWhitespace /\s\+$\| \+\ze\t/
autocmd BufWinEnter * 2match ExtraWhitespace /\s\+$\| \+\ze\t/
" Make highlighting to show up instantly after entering/leaving Insert mode
autocmd InsertEnter * 2match ExtraWhitespace /\s\+\%#\@<!$\| \+\ze\t/
autocmd InsertLeave * 2match ExtraWhitespace /\s\+$\| \+\ze\t/
autocmd BufWinLeave * call clearmatches()
"
"-----------------------------------------


" Vim-Polyglot ---------------------------
"
" Polyglot pack's settings should be declared BEFORE
" polyglot itself is loaded (i.e. before Vim-Plug part).
"
" autoindent doesn't let me use tabs somwtimes
" (specificly in the markdown files)
let g:polyglot_disabled = ['autoindent']
"
"-----------------------------------------


" Vim-Plug -------------------------------
"
" Install vim-plug if not found
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
	silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
"
" Run PlugInstall if there are missing plugins (NOTE: may increase the startup time of Vim.)
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif
"
" Plugins will be downloaded under the specified directory.
call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')
"
	" Theme
	Plug 'pineapplegiant/spaceduck', { 'branch': 'main' }
	" Access to :help plug
	Plug 'junegunn/vim-plug'
	" Status/tabline
	Plug 'vim-airline/vim-airline'
		" Official theme repository for vim-airline
		Plug 'vim-airline/vim-airline-themes'
		if s:platform != "Android"
			" File type icons (freak's out airline on Android)
			Plug 'ryanoasis/vim-devicons'
		endif
	if s:platform != "Android"
		" Markdown preview
		Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
	endif
	" Extension host (autocompletion)
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	" Shows git diff markers in the sign column
	Plug 'airblade/vim-gitgutter'
	" Better syntax support: a collection of language packs for Vim
	Plug 'sheerun/vim-polyglot'
"
call plug#end()
"
"-----------------------------------------


" Theme ----------------------------------
"
" Enable true color
if exists('+termguicolors')
	let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
	let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
	set termguicolors
endif
"
colorscheme spaceduck
" Overrides for the selected colorscheme
"	Pure black backgrounds on Android (AMOLED-friendly)
if s:platform == "Android"
	set background=dark
	highlight Normal guibg=black
	highlight LineNr guibg=black
	highlight EndOfBuffer guibg=black
	highlight VertSplit guibg=#0f111b guifg=#0f111b
endif
" Whitespace characters color:
highlight SpecialKey guifg=#20253d
" Line break symbol color:
highlight NonText guifg=#20253d
"
" Fix for unreadable text on inactive tabs:
"	https://github.com/pineapplegiant/spaceduck/issues/43
let s:inactive1 = [ "#30365F", "#16172d", 234, 234 ]
let s:inactive2 = [ "#30365F", "#16172d", 234, 234 ]
let s:inactive3 = [ "#30365F", "#16172d", 234, 234 ]
"
" ----------------------------------------


" Netrw file browser ---------------------
"
" map Netwr toggle to Ctrl+t comibnation
"	noremap means non-recursive mapping (stackoverflow.com/questions/3776117/)
"	<cr> stands for 'Carrige return', i.e. smae as hitting 'Enter'
noremap <C-t> :Lexplore<cr>
" hide that giant ugly help banner
let g:netrw_banner = 0
" I'd prefer 3rd style, but opening syslinks there is bugged with it (https://github.com/vim/vim/pull/3609)
let g:netrw_liststyle = 0
" Width of the file browser window
let g:netrw_winsize = 15
" Enable case-insensitive sorting
let g:netrw_sort_options = "i"
" Sort files with no regard to it's extension
let g:netrw_sort_sequence = '[\/]$,\<core\%(\.\d\+\)\=\>,\*,\~$'
"let g:netrw_sort_sequence = '[\/]$,\<core\%(\.\d\+\)\=\>,\.h$,\.c$,\.cpp$,\~\=\*$,*,\.o$,\.obj$,\.info$,\.swp$,\.bak$,\~$' " Default value
"
" ----------------------------------------


" Vim-airline ----------------------------
"
let g:airline_powerline_fonts = 1
"
let g:airline#extensions#tabline#enabled = 1
" 'Straight' separators
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_left_sep = ' '
let g:airline_right_sep = ' '
let g:airline_left_alt_sep = '|'
let g:airline_right_alt_sep = '|'
" Set colorscheme, 'silent!' should hide error on first launch
silent! let g:airline_theme = 'spaceduck'
"
" ----------------------------------------


" Markdown-Preview ----------------------
"
if s:platform != "Android"
	" Binds
	"	Toggle markdown preview in the browser with <Ctrl+p>
	nmap <C-p> <Plug>MarkdownPreviewToggle
	" Options
	let g:mkdp_auto_start = 0
	"	set to 1, nvim will open the preview window after entering the markdown buffer
	"	default: 0
	let g:mkdp_auto_close = 1
	"	set to 1, the nvim will auto close current preview window when change
	"	from markdown buffer to another buffer
	"	default: 1
	let g:mkdp_refresh_slow = 0
	"	set to 1, the vim will refresh markdown when save the buffer or
	"	leave from insert mode, default 0 is auto refresh markdown as you edit or
	"	move the cursor
	"	default: 0
	let g:mkdp_command_for_global = 0
	"	set to 1, the MarkdownPreview command can be use for all files,
	"	by default it can be use in markdown file
	"	default: 0
	let g:mkdp_open_to_the_world = 0
	"	set to 1, preview server available to others in your network
	"	by default, the server listens on localhost (127.0.0.1)
	"	default: 0
	let g:mkdp_open_ip = ''
	"	use custom IP to open preview page
	"	useful when you work in remote vim and preview on local browser
	"	more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9
	"	default empty
	let g:mkdp_browser = ''
	"	specify browser to open preview page
	"	default: ''
	let g:mkdp_echo_preview_url = 0
	"	set to 1, echo preview page url in command line when open preview page
	"	default is 0
	let g:mkdp_browserfunc = ''
	"	a custom vim function name to open preview page
	"	this function will receive url as param
	"	default is empty
	let g:mkdp_preview_options = {
		\ 'mkit': {},
		\ 'katex': {},
		\ 'uml': {},
		\ 'maid': {},
		\ 'disable_sync_scroll': 0,
		\ 'sync_scroll_type': 'middle',
		\ 'hide_yaml_meta': 1,
		\ 'sequence_diagrams': {},
		\ 'flowchart_diagrams': {},
		\ 'content_editable': v:false,
		\ 'disable_filename': 0
		\ }
	"	options for markdown render
	"	mkit: markdown-it options for render
	"	katex: katex options for math
	"	uml: markdown-it-plantuml options
	"	maid: mermaid options
	"	disable_sync_scroll: if disable sync scroll, default 0
	"	sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
	"		middle: mean the cursor position alway show at the middle of the preview page
	"		top: mean the vim top viewport alway show at the top of the preview page
	"		relative: mean the cursor position alway show at the relative positon of the preview page
	"	hide_yaml_meta: if hide yaml metadata, default is 1
	"	sequence_diagrams: js-sequence-diagrams options
	"	content_editable: if enable content editable for preview page, default: v:false
	"	disable_filename: if disable filename header for preview page, default: 0
	let g:mkdp_markdown_css = ''
	"	use a custom markdown style must be absolute path
	"	like '/Users/username/markdown.css' or expand('~/markdown.css')
	let g:mkdp_highlight_css = ''
	"	use a custom highlight style must absolute path
	"	like '/Users/username/highlight.css' or expand('~/highlight.css')
	let g:mkdp_port = ''
	"	use a custom port to start server or random for empty
	let g:mkdp_page_title = '「${name}」'
	"	preview page title
	"	${name} will be replace with the file name
	let g:mkdp_filetypes = ['markdown']
	"	recognized filetypes
	"	these filetypes will have MarkdownPreview... commands
endif
"
" ---------------------------------------


" CoC - Conquer of Completion ------------
"
let g:coc_global_extensions = [
	\'coc-highlight',
	\'coc-sh',
	\'coc-vimlsp',
	\'coc-clangd',
	\'coc-jedi',
	\]
" TextEdit might fail if hidden is not set.
set hidden
"
" Some servers have issues with backup files, see #649.
" Backup file wile editing it, delete backup upon writing file.
set nobackup
set nowritebackup
"
" Change to 2 if more space for displaying messages needed.
set cmdheight=1
"
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
"
" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
" (vim>=8.1.1564 can merge signcolumn and number column into one with value 'number')
set signcolumn=yes
"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
"
" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif
"
" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
"
" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
"
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
"
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
"
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
"
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
"
" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)
"
" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
"
augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
"
" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
"
" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)
"
" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
"
" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif
"
" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)
"
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
"
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
"
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
"
" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
"
" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
" ----------------------------------------
