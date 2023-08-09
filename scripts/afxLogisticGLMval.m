function [yfit] = afxLogisticGLMval(betas,x,scale)
    % [yfit] = afxLogisticGLMval(betas,x,scale)
    %
    % betas ... model parameters
    % x     ... predictors (observations x predictors x voxels)
    % scale ... scale factors to scale x
    %
    % predicts responses based using logistic GLM
    % yfit  ... predicted responses (observations x voxels)
    
     % reshape input data (x)  and clear x (for freeing memory)
    x = afxReshapeData(x);
  
    % delete observations with NaNs
    xnan = any(isnan(x),2);
    x(xnan,:) = [];
    
    % scale x
    if ~isempty(scale)
        x = (x-scale.mean)./scale.std;
    end
    
  
    % predict response
    yfit = glmval(betas,x,'logit');
    
end
