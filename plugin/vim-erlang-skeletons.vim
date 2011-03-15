if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

let s:plugin_dir = expand('<sfile>:p:h')
if !exists("g:erl_tpl_dir")
    let g:erl_tpl_dir=s:plugin_dir . "/templates"
endif

if !exists("g:erl_author")
    let g:erl_author=$USER
endif

if !exists("g:erl_company")
    let g:erl_company=g:erl_author
endif

if !exists("g:erl_replace_buffer")
    let g:erl_replace_buffer=0
endif

function! LoadTemplate(tpl_file)

python << EOF

import vim
import os
import getpass
from string import Template
from datetime import datetime

fulldate = datetime.now()
year = fulldate.year
author = vim.eval("g:erl_author") or getpass.getuser()
company = vim.eval("g:erl_company")

name = vim.current.buffer.name or "untitled"
basename = os.path.split(os.path.splitext(name)[0])[1]

tpl_dir = vim.eval("g:erl_tpl_dir")
tpl_file = vim.eval("a:tpl_file")
tpl = os.path.join(tpl_dir, tpl_file)
template = open(tpl, "r").read()
s = Template(template)
output = s.substitute(author=author, fulldate=fulldate, \
    basename=basename, year=year, company=company)

if vim.eval("g:erl_replace_buffer")==1:
    del vim.current.buffer[:]

vim.current.buffer.append(output.split("\n"), 0)
vim.command("set filetype=erlang")

EOF

endfunction

command! -nargs=0 ErlServer      call LoadTemplate("gen_server")
command! -nargs=0 ErlFsm         call LoadTemplate("gen_fsm")
command! -nargs=0 ErlSupervisor  call LoadTemplate("supervisor")
command! -nargs=0 ErlEvent       call LoadTemplate("gen_event")
command! -nargs=0 ErlApplication call LoadTemplate("application")
command! -nargs=1 ErlTemplate    call LoadTemplate(<args>)

