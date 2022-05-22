function [optThr] = afxOptimalThreshold(yfit,y,tol,inverse)
    sumVol = nnz(y);
    boundaries = [ min(yfit(:))  max(yfit(:))];
    while abs(diff(boundaries)) > tol
        boundaries = afxFindMinGrid(yfit,sumVol,inverse,boundaries,3);
    end
    optThr = round(mean(boundaries),floor(-log10(tol)));
end
    
function absDiff = afxAbsDiff(yfit,sumVol,threshold,inverse)
    if inverse
        absDiff = abs(sumVol-nnz(yfit<threshold));
    else
        absDiff = abs(sumVol-nnz(yfit>threshold));
    end
end

function boundaries = afxFindMinGrid(yfit,sumVol,inverse,boundaries,n)
    thrs = boundaries(1):(boundaries(2)-boundaries(1))/n:boundaries(2);
    absDiffs = nan(1,length(thrs));
    for i = 1:length(thrs)
        absDiffs(i) = afxAbsDiff(yfit,sumVol,thrs(i),inverse);
    end
    [~,idx] = sort(absDiffs);
    boundaries = sort(thrs(idx(1:2)));
end