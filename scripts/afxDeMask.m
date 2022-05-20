function img = afxDeMask(mask,dat)
    img = zeros(size(mask));
    img(mask) = dat;
end