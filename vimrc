set autoindent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
syntax on
set ruler		" show the cursor position all the time
" don't expand tabs for make files
" use spaces for python files because they 
" are funny like that
autocmd FileType make set noexpandtab shiftwidth=8
autocmd FileType python set expandtab 
autocmd FileType javascript set expandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType yaml set expandtab shiftwidth=2 tabstop=2

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
        " otherwise, below the ABSTRACT (see Dist::Zilla)
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
