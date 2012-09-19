function [mdiff mcorr] = diffmean3d(imgs, ids)

ct = 0;

flatten = @(x) x(:);

brainvox = flatten(all(imgs ~= 0, 4));

for rowidx1 = 1 : size(ids, 1)
    img1 = mean(imgs(:, :, :, ids(rowidx1, :)), 4);
    fimg1 = flatten(img1);
    for rowidx2 = rowidx1 + 1 : size(ids, 1)
        ct = ct + 1;
        img2 = mean(imgs(:, :, :, ids(rowidx2, :)), 4);
        fimg2 = flatten(img2);
        mdiff{ct} = img1 - img2;
        mcorr{ct} = corr(fimg1(brainvox), fimg2(brainvox));
    end
end