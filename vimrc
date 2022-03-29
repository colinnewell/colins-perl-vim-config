let g:go_fmt_command = 'goimports'
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'
let g:go_rename_command='gopls'

let g:go_metalinter_command='golangci-lint'
"let g:go_metalinter_autosave = 1

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1


augroup filetypedetect
    au BufRead,BufNewFile *.cgi setfiletype perl
" associate *.foo with php filetype
augroup END

filetype off
filetype plugin indent off
set runtimepath+=/usr/lib/go/misc/vim
filetype plugin indent on
syntax on

colorscheme industry
"colorscheme peachpuff

set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp

" scripts from the blog of Marcel Grünauer
" http://blogs.perl.org/mt/mt-search.fcgi?blog_id=353&tag=vim&limit=20

map <Leader>pa :<C-u>call PerlReplacePackageName()<CR>

function! PerlPackageNameFromFile()
    let s:filename = expand("%:p")
    let s:package = substitute(s:filename, "^.*/lib/", "", "")
    let s:package = substitute(s:package, "\.pm$", "", "")
    let s:package = substitute(s:package, "/", "::", "g")
    return s:package
endfunction

function! PerlReplacePackageName()
    let s:package = PerlPackageNameFromFile()
    let pos = getpos('.')
    1,/^package /s/^package\s\+\zs[A-Za-z_0-9:]\+\ze\(\s\+{\|;\)/\=s:package/
    call setpos('.', pos)
endfunction

" perl: add 'use' statement
"
" not quite as original blog post.

function! PerlAddUseStatement()
    let line = getline('.')
    let p = matchstr(line, '[A-Za-z_0-9:]\+', col('.') - 1)
    let s:package = input('Package? ', p)
    "let s:package = input('Package? ', expand('<cword>'))
    " skip if that use statement already exists
    if (search('^use\s\+'.s:package.'[^A-Za-z_0-9:]', 'bnw') == 0)
        " below the last use statement, except for some special cases
        let s:line = search('^use\s\+\(constant\|strict\|warnings\|parent\|base\|5\)\@!','bnw')
        " otherwise, below the ABSTRACT (see Dist::git@github.com:colinnewell/pcap2mysql-log.gitZilla)
        if (s:line == 0)
            let s:line = search('^# ABSTRACT','bnw')
        endif
        " otherwise, below the package statement
        if (s:line == 0)
            let s:line = search('^package\s\+','bnw')
        endif
        " if there isn't a package statement either, put it below
        " the last use statement, no matter what it is
        if (s:line == 0)
            let s:line = search('^use\s\+','bnw')
        endif
        " if there are no package or use statements, it might be a
        " script; put it below the shebang line
        if (s:line == 0)
            let s:line = search('^#!','bnw')
        endif
        " if s:line still is 0, it just goes at the top
        call append(s:line, 'use ' . s:package . ';')
    endif
endfunction

map <Leader>us :<C-u>call PerlAddUseStatement()<CR>
set iskeyword=@,48-57,_,192-255

if exists('g:perltidy')
    finish
en

function! s:TrimEndLines()
    let save_cursor = getpos(".")
    :silent! %s#\($\n\s*\)\+\%$##
    call setpos('.', save_cursor)
endfunction


function!s:PerlTidy()
    let old_shell = &shell
    let &shell = old_shell
    let b:firstline = a:firstline
    let b:lastline = a:lastline
    if b:firstline == b:lastline
      let b:firstline = 1
      let b:lastline = line('$')
    endif
    let lines = join(getline(b:firstline, b:lastline), "\n")
    let b:perltidy_output = system('perltidy -q ', lines)
    let &shell = old_shell
    let prevcur = getpos(".")
    let prevx = getpos("'x")
    let prevy = getpos("'y")
    call setpos("'x", [0, b:firstline, 0, 0])
    call setpos("'y", [0, b:lastline, 0, 0])
    exec "'x,'yd"
    set paste
    call setpos(".", [0, b:firstline, 0, 0])
    exec ":normal i" . b:perltidy_output
    call s:TrimEndLines()
    call setpos(".", prevcur)
    call setpos("'x", prevx)
    call setpos("'y", prevy)
    set ruler		" show the cursor position all the time
    set autoindent
    set tabstop=4
    set shiftwidth=4
    set softtabstop=4
    set expandtab
endfunction

command! -nargs=* -range -bang PerlTidy <line1>,<line2>call s:PerlTidy()

vnoremap :call PerlTidy() t
" au BufWritePre *.p[lm],*.t,*.cgi call s:PerlTidy()

let g:perltidy = 1

set ruler		" show the cursor position all the time
set autoindent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set grepprg=rg\ --vimgrep
syntax on
let loaded_matchparen = 1
" don't expand tabs for make files
" use spaces for python files because they
" are funny like that
autocmd FileType make set noexpandtab shiftwidth=8
autocmd FileType go set noexpandtab shiftwidth=4 tabstop=4
autocmd FileType python set expandtab
autocmd FileType cpp set expandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType javascript set expandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType markdown set expandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType YAML set expandtab shiftwidth=4 tabstop=4

au BufNewFile,BufRead *.cgi set filetype=perl
au BufNewFile,BufRead *.tt set filetype=tt2html
au BufNewFile,BufRead *.tmpl set filetype=tt2html
