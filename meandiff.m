function d = meandiff(x)

d = zeros(1, size(x, 2));
ct = 0;

for rowidx1 = 1 : size(x, 1)
    for rowidx2 = rowidx1 + 1 : size(x, 1)
        d = d + abs(x(rowidx1, :) - x(rowidx2, :));
        ct = ct + 1;
    end
end

d = d ./ ct;