function [x,y] = afxReshapeData(x,y)
    x = reshape(permute(x,[2 1 3]),size(x,2),size(x,1)*size(x,3))';
    if nargin > 1
        y = y(:);
    else
        y = [];
    end
end