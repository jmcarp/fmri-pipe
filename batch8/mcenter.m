function cmtx = mcenter(mtx)
    
    cmtx = mtx - repmat(mean(mtx), size(mtx, 1), 1);
    
end