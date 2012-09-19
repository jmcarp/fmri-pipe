function [coord lab] = peakinfo(peak)

for hem = 1 : 2
    
    hempeak = squeeze(peak.mmpeak(:, hem, :));
    
    for ax = 1 : 3
        
        cmin = min(hempeak(:, ax));
        cminidx = find(hempeak(:, ax) == cmin, 1);
        cmincoord = hempeak(cminidx, :);
        cminlab = getlab(cmincoord);
        cminlab = cminlab{1};
        
        cmax = max(hempeak(:, ax));
        cmaxidx = find(hempeak(:, ax) == cmax, 1);
        cmaxcoord = hempeak(cmaxidx, :);
        cmaxlab = getlab(cmaxcoord);
        cmaxlab = cmaxlab{1};
        
        coord(hem, ax, 1, :) = cmincoord;
        coord(hem, ax, 2, :) = cmaxcoord;
        
        lab{hem, ax, 1} = cminlab;
        lab{hem, ax, 2} = cmaxlab;
        
    end
    
end

'hi'