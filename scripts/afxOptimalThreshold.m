function [optThr,absDiff] = afxOptimalThreshold(yfit,y,tol,inverse)
    sumVol = sum(y,2);
    boundaries = [ min(yfit(:))  max(yfit(:))];
    while abs(diff(boundaries)) > tol
        boundaries = afxFindMinGrid(yfit,sumVol,inverse,boundaries,10);
    end
    optThr = round(mean(boundaries),floor(-log10(tol)));
    absDiff = afxAbsDiff(yfit,sumVol,optThr,inverse);
end
    
function absDiff = afxAbsDiff(yfit,sumVol,threshold,inverse)
    if inverse
        absDiff = sum(abs(sumVol-sum(yfit<threshold,2)));
    else
        absDiff = sum(abs(sumVol-sum(yfit>threshold,2)));
    end
end

function boundaries = afxFindMinGrid(yfit,sumVol,inverse,boundaries,n)
    thrs = boundaries(1):(boundaries(2)-boundaries(1))/(n-1):boundaries(2);
    absDiffs = nan(1,length(thrs));
    for i = 1:length(thrs)
        absDiffs(i) = afxAbsDiff(yfit,sumVol,thrs(i),inverse);
    end
    %plot(thrs,absDiffs);
    [~,idx] = sort(absDiffs);
    d = thrs(2)-thrs(1);
    boundaries = thrs(idx(1))+[-d d];
end