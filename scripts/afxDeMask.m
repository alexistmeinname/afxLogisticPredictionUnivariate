function img = afxDeMask(mask,dat,val)
    img = zeros(size(mask));
    if exist('val','var')
        img(:) = val;
    end
    img(mask) = dat;
end