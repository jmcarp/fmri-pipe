   
for voxidx = 1 : size(xyzmm, 2)
    if isequal(round(xyzmm(:, voxidx)), round([41 ; 19 ; 0]))
        break
    end
end

voxidx