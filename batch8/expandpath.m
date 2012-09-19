function dirs = expandpath(path, varargin)

% Optional args
if length(varargin) >= 1
    cutpath = varargin{1};
else
    cutpath = false;
end

if length(varargin) >= 2
    ndirs = varargin{2};
else
    ndirs = inf;
end

if length(varargin) >= 3
    depstr = sprintf('-maxdepth %d ', ...
        varargin{3});
else
    depstr = '';
end

global CCN;

% Build search string
fields = regexp(path, '\[(.*?)\]', 'tokens');
for fieldidx = 1 : length(fields)
    txt = CCN.(char(fields{fieldidx}));
    path = regexprep(path, '(?<!@)\[.*?\]', txt, 'once');
end

path = regexprep(path, '@', '');

% Find separators
sepidx = strfind(path, '/');
% Find regex characters
wldidx = regexp(path, '[\|\*\$\\]');

if isempty(wldidx)  % Don't search
    
    dirs = {path};
    
else                % Search
    
    % Split search string
    findidx = max(sepidx(sepidx < min(wldidx)));
    
    
    findcmd = sprintf('find %s %s | grep -P "%s"', ...
        path(1 : findidx), depstr, path(findidx + 1 : end));

    % Run search
    [~, result] = system(findcmd);
    dirs = regexp(result(1 : end - 1), '\s+', 'split');
    dirs = sort(dirs);
    
end

if cutpath
    for diridx = 1 : length(dirs)
        [path name ext] = fileparts(dirs{diridx});
        dirs{diridx} = [name ext];
    end
end

% Crash if empty
if isequal(dirs, {''})
    error('No files matched pattern:\n%s', path);
end

% Crash if wrong number dirs
if ~isinf(ndirs) && length(dirs) ~= ndirs
    error('Wrong number of files matched pattern:\n%s', path);
end
if ndirs == 1
    dirs = dirs{1};
end