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
    % scale input data
    scale.mean = nanmean(x,1);
    scale.std = nanstd(x,1);
    x = (x-scale.mean)./scale.std;
    % fit logistic glm for every voxel
    stats = struct([]);
    pct = floor(size(x,3)/50);
    fprintf('Fitting logistic GLMs [');
    ws = warning('off');
    for iVoxel = 1:size(x,3)
        [stats(iVoxel).beta,~,tmpstats] = glmfit(x(:,:,iVoxel),y(:,iVoxel),'binomial','link','logit');
        stats(iVoxel).t = tmpstats.t;
        stats(iVoxel).dfe = tmpstats.dfe;
        stats(iVoxel).mse = nanmean(tmpstats.resid.^2);
        if mod(iVoxel,pct) == 0, fprintf('.'); end
    end
    warning(ws);
    fprintf('] (%.2f min)\n',toc(s)/60);
end