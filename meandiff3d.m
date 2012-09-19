function [d c] = meandiff3d(imgs, ids)

dim = size(imgs);
d = zeros(dim(1 : 3));
c = 0;
ct = 0;

flatten = @(x) x(:);

brainvox = flatten(all(imgs ~= 0, 4));

for rowidx1 = 1 : size(ids, 1)
    for rowidx2 = rowidx1 + 1 : size(ids, 1)
        for colidx = 1 : size(ids, 2)
            d = d + abs( ...
                max(imgs(:, :, :, ids(rowidx1, colidx)), [], 4) - ...
                min(imgs(:, :, :, ids(rowidx2, colidx)), [], 4) ...
                );
            imgf1 = flatten(imgs(:, :, :, ids(rowidx1, colidx)));
            imgf2 = flatten(imgs(:, :, :, ids(rowidx2, colidx)));
            c = c + corr(imgf1(brainvox), imgf2(brainvox));
            ct = ct + 1;
        end
    end
end

d = d ./ ct;
d(d == 0) = nan;

c = c / ct;