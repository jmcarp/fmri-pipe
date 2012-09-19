function [incvox nhood] = getsphere(radius, voxdims)

cubedims = ceil(radius ./ voxdims);
incvox = [];
nhood = zeros(cubedims(1) * 2 + 1, ...
    cubedims(2) * 2 + 1, ...
    cubedims(3) * 2 + 1);

for x = -cubedims(1) : cubedims(1)
    for y = -cubedims(2) : cubedims(2)
        for z = -cubedims(3) : cubedims(3)
            rdist = sqrt(sum(([x y z] .* voxdims) .^ 2));
            if rdist <= radius
                incvox = [incvox ; x y z];
                nhood(x + cubedims(1) + 1, ...
                    y + cubedims(2) + 1, ...
                    z + cubedims(3) + 1) = 1;
            end
        end
    end
end