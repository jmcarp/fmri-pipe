function [ulist uct] = texthist(list)

ulist = unique(list);

uct = nan(size(ulist));
for uidx = 1 : length(ulist)
    uitem = ulist{uidx};
    uct(uidx) = sum(ismember(list, uitem));
end

[uct sortidx] = sort(uct, 1, 'descend');
ulist = ulist(sortidx);