function outname = fileprep(inname, prep)

[path name ext] = fileparts(inname);
outname = sprintf('%s/%s%s%s', path, prep, name, ext);