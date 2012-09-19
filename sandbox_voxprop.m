
clear sumvoxprop

contrnames = fieldnames(CCN.contr.contrs);
thrnames = { 'as_pe2' 'as_pe3' 'as_pe4' 'fdr' 'fwe' };
nthresh = length(thrnames);

for contridx = 1 : length(contrnames)
    
    % 
    for thridx = 1 : nthresh
        
        thrname = thrnames{thridx};
        
        sigidx = ismember(thrtypes, thrname);
        
        % Update voxel summary
        sumvoxprop(contridx, thridx) = median(voxprop(contridx, sigidx));
        
    end
    
end