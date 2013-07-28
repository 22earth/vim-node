if exists("g:loaded_node") || &cp || v:version < 700 | finish | endif
let g:loaded_node = 1

function! s:detect(path)
	if exists("b:node_root") | return | en
	let path = a:path

	while 1
		let is_node = 0
		let is_node = is_node || filereadable(path . "/package.json")
		let is_node = is_node || isdirectory(path . "/node_modules")
		if is_node | return s:init(path) | endif

		let parent = fnamemodify(path, ":h")
		if parent == path | return | endif
		let path = parent
	endwhile
endfunction

function! s:init(root)
	let b:node_root = a:root

	if &filetype == "javascript"
		setl suffixesadd+=.js
		exe "setl includeexpr=" . s:snr() . "find(v:fname)"
	endif
endfunction

function! s:snr()
	return matchstr(expand("<sfile>"), '<SNR>\d\+_')
endfunction

function! s:find(name)
	" Skip relative or absolute paths.
	if a:name =~# '^\(/\|\./\|\.\./\)' | return a:name | endif

	let path = b:node_root . "/node_modules/" . a:name
	if isdirectory(path) | let path .= "/index" | endif

	let path_with_suffix = s:findWithSuffix(path)
	if !empty(path_with_suffix) | return path_with_suffix | endif

	return a:name
endfunction

function! s:findWithSuffix(path)
	for suffix in ([""] + split(&suffixesadd, ","))
		let path = a:path . suffix
		if filereadable(path) | return path | endif
	endfor

	return ""
endfunction

augroup Node
	au!
	au BufRead,BufNewFile * call s:detect(expand("<amatch>:p"))
augroup END
