function [yfit] = afxLogisticGLMval(betas,x,scale)
    % [yfit] = afxLogisticGLMval(betas,x,scale)
    %
    % betas ... model parameters
    % x     ... predictors (observations x predictors x voxels)
    % scale ... scale factors to scale x
    %
    % predicts responses based using logistic GLM
    % yfit  ... predicted responses (observations x voxels)
    
    % scale x
    if ~isempty(scale)
        xScaled = (x-scale.mean)./scale.std;
    end
    % initialize yfit
    yfit = nan(size(x,1),size(x,3));
    % predict response for every voxel
    for iVoxel = 1:size(x,3)
        yfit(:,iVoxel) = glmval(betas(:,iVoxel),xScaled(:,:,iVoxel),'logit');
    end
end