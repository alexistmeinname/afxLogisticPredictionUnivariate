function [stats,scale] = afxLogisitcGLMfit(x,y)
    % [stats,scale] = afxLogisitcGLM(x,y)
    %
    % x          ... predictors (observations x predictors x voxels)
    % y          ... response (observations x voxels)
    %
    % stats.beta ... betas
    % stats.t    ... t-values
    % stats.dfe  ... degrees of freedom
    % stats.sse  ... sum of squared errors
    % scale      ... scale factors for x (scale.mean, scale.std)
    %
    % NaNs in x or y are treated as missing values
    s = tic;
    % fit logistic glm for every voxel
    fprintf('Fitting logistic GLMs [');
    ws = warning('off');
  
    % reshape input data (x, y) and clear x,y (for freeing memory)
    [x,y] = afxReshapeData(x,y);
    
    % delete observations with NaNs
    xnan = any(isnan(x),2);
    x(xnan,:) = [];
    y(xnan) = [];
    
    % random stratified undersampling
    idxOverweigt = y==round(mean(y));
    nDel = nnz(idxOverweigt)-nnz(~idxOverweigt);
    idxOverweigt = find(idxOverweigt);
    idxOverweigt = idxOverweigt(randperm(nnz(idxOverweigt)));
    idxDel = idxOverweigt(1:nDel);
    x(idxDel,:) = [];
    y(idxDel) = [];
    
    % scale input data
    scale.mean = nanmean(x,1);
    scale.std = nanstd(x,1);
    x = (x-scale.mean)./scale.std;
   
    
    % fit GLM
    [b,~,statistics] = glmfit(x,y,'binomial','link','logit');
    stats = struct('t',{statistics.t},'beta',{b},'dfe',{statistics.dfe},'mse',{nanmean(statistics.resid.^2)});

    warning(ws);
    fprintf('] (%.2f min)\n',toc(s)/60);
end