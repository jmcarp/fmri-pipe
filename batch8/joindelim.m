function s = joindelim(list, delim)

s = tostr(list(1));

for listidx = 2 : length(list)
    s = sprintf('%s%s%s', s, delim, tostr(list(listidx)));
end

function out = tostr(in)

if iscell(in)
    in = in{1};
end

if isstr(in)
    out = in;
else
    try
        out = num2str(in);
    catch
        out = char(in);
    end
end