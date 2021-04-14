" PREREQUIREMENTS -----------------------
"
" git (1.8+ recommended) for vim-plug and other plugins
" nodejs (>= 10.12) for CoC plugin
" nerd-comatable font (https://github.com/ryanoasis/nerd-fonts) for vim-devicons
" 	On android (Termux) (re-)place selected font at ~/.termux/font.ttf:
" 	cd ~/.termux/ && wget -O SourceCodePro.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SourceCodePro.zip && unzip -j SourceCodePro.zip 'Sauce Code Pro Nerd Font Complete Mono.ttf' && mv 'Sauce Code Pro Nerd Font Complete Mono.ttf' 'font.ttf' && rm SourceCodePro.zip
"
"----------------------------------------

" Tips ----------------------------------
"
" Vim-Plug:
" 	Updating plugins:
" 		1. :PlugUpdate - Install or update plugins
" 		2. :PlugUpgrade - Update vim-plug itself
" 	If you want to disable some plugins:
" 		1. Remove or comment out their Plugs in the Vim-Plug section of this .vimrc
" 		2. Then reload vimrc (:source ~/.vimrc) or restart Vim.
" 		3. (Optional) Run :PlugClean to seek and destroy all undeclared plugins from disk.
" CoC plugin:
" 	List installed extensions:
" 		:Coclist extensions
" 			(+) - extension was loaded
" 			(-) - extension was disabled
" 			(*) - extension was activated
" 			(?) - invalid extension
" 	Updating extensions:
" 		For manual updates use :CocUpdate
" 		To enable autoupdate - in :CocConfig set 'coc.preferences.extensionUpdateCheck' to 'daily'
" 	Uninstalling extensions:
" 		:CocUninstall coc-css
"
"
" ---------------------------------------


" OS detector ---------------------------
"
" Record name of running OS to a variable
" It may be used later for OS-specific options
let platform = "unknown"
if has("unix")
	if has("mac")
		let platform = "macOS"
	else
		if substitute(system('uname -o'), "\n", "", "") == "Android"
			let platform = "Android"
		else
			let platform = "Linux"
		endif
	endif
elseif has("win32") || has("win64")
	let platform = "Windows"
endif
"
"----------------------------------------



"----------------------------------------
"
" Ward off unexpected things from distro. Helpful when sharing this config for a test-ride (vim -u test_vimrc)
set nocompatible
" Enable syntax highlighting
syntax enable
" Requirenment for vim-devicons and CoC
set encoding=utf-8
" Display line numbers on the left
set number
" Enable use of the mouse if it's present
" or if we're on a portable device (presumably with a touchscreen)
" Hold Shift when selecting with mouse to copy text.
if has('mouse') || platform=="Android"
	set mouse=a
endif
" Copies the indentation from the previous line, when starting a new line
set autoindent
" Automatically inserts one extra level of indentation in some cases
set smartindent
" Set working directory to the current file
set autochdir
" Show whitespace characters
if platform!="Android"
	set list
endif
" Characters to represent whitespace characters
set listchars=tab:⇥\ ,trail:-,extends:>,precedes:<,nbsp:+,space:·
" Enable soft-wrapping
set wrap
set linebreak
" Character to display start of wrapped line
let &showbreak='⤷ '
" Keep indentation while wrapping text
set breakindent
" Ident by an additional 2 characters on wrapped lines, when line >= 40 characters, put 'showbreak' at start of line
set breakindentopt=shift:0,min:40,sbr

"----------------------------------------


" Vim-Plug ------------------------------
"
" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif
"
" Run PlugInstall if there are missing plugins (NOTE: may increase the startup time of Vim.)
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif
"
call plug#begin('~/.vim/plugged') 					" Specify a directory for plugins
"
	" Theme
	Plug 'pineapplegiant/spaceduck', { 'branch': 'main' }
	" Access to :help plug
	Plug 'junegunn/vim-plug'
	" Status/tabline
	Plug 'vim-airline/vim-airline'
		" Official theme repository for vim-airline
		Plug 'vim-airline/vim-airline-themes'
		if platform != "Android"
			" File type icons (freak's out airline on Android)
			Plug 'ryanoasis/vim-devicons'
		endif
	" Extension host (autocompletion)
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	" Shows git diff markers in the sign column
	Plug 'airblade/vim-gitgutter'
	" Better syntax support: a collection of language packs for Vim
	Plug 'sheerun/vim-polyglot'
	" Insert or delete brackets, parens, and quotes in pair.
	"Plug 'LunarWatcher/auto-pairs', { 'tag': '*' }
"
call plug#end()
"
"----------------------------------------


" Theme ---------------------------------
"
" Enable true color
if exists('+termguicolors')
	let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
	let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
	set termguicolors
endif
"
colorscheme spaceduck
"" Overrides for the selected colorscheme
" Pure black backgrounds on Android (AMOLED-friendly)
if platform == "Android"
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
" ---------------------------------------


" Netrw file browser --------------------
"
" map Netwr toggle to Ctrl+t comibnation
" 	noremap means non-recursive mapping (stackoverflow.com/questions/3776117/)
" 	<cr> stands for 'Carrige return', i.e. smae as hitting 'Enter'
noremap <C-t> :Lexplore<cr>
" hide that giant ugly help banner
let g:netrw_banner = 0
" I'd prefer 3rd style, but opening syslinks there is bugged with it (https://github.com/vim/vim/pull/3609)
let g:netrw_liststyle = 0
" Width of the file browser window
let g:netrw_winsize = 15
"
" ---------------------------------------


" Vim-airline ---------------------------
"
let g:airline#extensions#ale#enabled = 1
let g:airline_powerline_fonts = 1
"TODO: check if installed for the first launch
let g:airline_theme = 'spaceduck'
"
" ---------------------------------------


" CoC - Conquer of Completion -----------
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
" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300
"
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
"
" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
" (vim>=8.1.1564 can merge signcolumn and number column into one with value 'number')
set signcolumn=yes
"
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
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
" ---------------------------------------
