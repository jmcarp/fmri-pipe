function outname = chext(inname, newext)

[path name ext] = fileparts(inname);
outname = sprintf('%s/%s%s', path, name, newext);