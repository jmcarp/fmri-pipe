function writepeak(peak, rois, delim, outname)

global CCN;

contrnames = fieldnames(CCN.contr.contrs);
nopts = length(peak.(contrnames{1}).labpeak);

fh = fopen(outname, 'w');

for contridx = 1 : length(contrnames)
    
    contrname = contrnames{contridx};
    
    fprintf(fh, '%s_lh%s', contrname, delim);
    fprintf(fh, '%s_rh%s', contrname, delim);
    fprintf(fh, '%s_mm_lh%s', contrname, delim);
    fprintf(fh, '%s_mm_rh%s', contrname, delim);
    
    for roiidx = 1 : length(rois)
        
        roi = rois{roiidx};
        fprintf(fh, '%s_mm_%s%s', contrname, roi, delim);
        
    end
    
end

fprintf(fh, '\n');

for optidx = 1 : nopts
    
    for contridx = 1 : length(contrnames)
        
        contrname = contrnames{contridx};
        
        fprintf(fh, '%s%s', ...
            peak.(contrname).labpeak{optidx, 1, 6}, delim);
        fprintf(fh, '%s%s', ...
            peak.(contrname).labpeak{optidx, 2, 6}, delim);
        
        fprintf(fh, '%f:%f:%f%s', ...
            peak.(contrname).mmpeak(optidx, 1, 1), ...
            peak.(contrname).mmpeak(optidx, 1, 2), ...
            peak.(contrname).mmpeak(optidx, 1, 3), ...
            delim);
        fprintf(fh, '%f:%f:%f%s', ...
            peak.(contrname).mmpeak(optidx, 2, 1), ...
            peak.(contrname).mmpeak(optidx, 2, 2), ...
            peak.(contrname).mmpeak(optidx, 2, 3), ...
            delim);
        
        for roiidx = 1 : length(rois)
            
            fprintf(fh, '%f:%f:%f%s', ...
                peak.(contrname).mmpeak(optidx, roiidx + 2, 1), ...
                peak.(contrname).mmpeak(optidx, roiidx + 2, 2), ...
                peak.(contrname).mmpeak(optidx, roiidx + 2, 3), ...
                delim);
            
        end
        
    end
    
    fprintf(fh, '\n');
    
end

fclose(fh);