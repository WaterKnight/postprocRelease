local f = io.open([[postproc\version.txt]], 'w+')

f:write(os.date('%y-%m-%d %X'))

f:close()