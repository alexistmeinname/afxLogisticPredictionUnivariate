function img = afxDeMask(mask,dat,val)
    dat = gather(dat);
    img = nan(size(dat,1),size(mask,2));
    if exist('val','var')
        img(:) = val;
    end
    img(:,mask) = dat;
end