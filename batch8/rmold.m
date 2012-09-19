function rmold(data, prep)

global CCN;

if isfield(CCN, 'rmold') && ...
        CCN.rmold == true
    for runidx = 1 : length(data)
        [path name] = fileparts(data{runidx});
        dfiles = dir(sprintf('%s/%s%s*', ...
            path, prep, name));
        dfiles = {dfiles.name};
        for fileidx = 1 : length(dfiles)
            dfile = sprintf('%s/%s', ...
                path, dfiles{fileidx});
            disp(dfile);
            delete(dfile);
        end
    end
end