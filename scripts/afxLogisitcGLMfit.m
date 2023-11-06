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
<<<<<<< Updated upstream
    % NaNs in x or y are treated as missing values

    s = tic;
=======
    %NaNs in x or y are treated as missing values
    s = tic;
    % fit logistic glm for every voxel
    fprintf('Fitting logistic GLMs [');
    %ws = warning('off');
    y = cast(y,"single");
    x = cast(x,"single");
    
    
    
    % random stratified undersampling
  
    matrixOverweigt = y==round(mean(y));  %patients x voxel, 1== keine Läsion, 0 == Läsion
    % round geht pro patient immer auf 0, weil mehr voxel ohne läsion
    % vorhanden; dadurch invertierung der matrix (alle mit 0 werden 1 und
    % andersherum
    
    %mark all values that are nan in x 
    nanMatrixOverweigt =  squeeze(any(isnan(x),2));
    
    for patient = 1: size(matrixOverweigt,1)
        nDel = nnz(matrixOverweigt(patient,:))-nnz(~matrixOverweigt(patient,:))-nnz(nanMatrixOverweigt(patient,:));
        indexOverweigt = find(matrixOverweigt(patient,:)); %indices aller voxel mit 1 (inklusive Nans)
        indexnanOverweigt = find(nanMatrixOverweigt(patient,:));%indices aller NaN-voxel
        indexOverweigt = setdiff(indexOverweigt,indexnanOverweigt); %delete all voxel with nans from indesOverweigt
        indexOverweigt = indexOverweigt(randperm(nnz(indexOverweigt)));
        if nDel <= length(indexOverweigt)
            idxDel = indexOverweigt(1:nDel);
        else
            nDel = length(indexOverweigt);
            idxDel = indexOverweigt(1:nDel);
        end
        x(patient,:,idxDel) = NaN;
    end
   
    clearvars -except x y s;
    % reshape input data (x, y) and clear x,y (for freeing memory)
    [x,y] = afxReshapeData(x,y);
    
    % delete observations with NaNs (were either NaN from the beginning or
    % to be deleted due to Random Stratified Undersampling
    xnan = any(isnan(x),2);
    x(xnan,:) = [];
    y(xnan) = [];
    
    x = cast(x, "double")
    y = cast(y,"double");
    
>>>>>>> Stashed changes
    % scale input data
    scale.mean = nanmean(x,1);
    scale.std = nanstd(x,1);
    x = (x-scale.mean)./scale.std;
<<<<<<< Updated upstream
    % fit logistic glm for every voxel
    stats = struct([]);
    pct = size(x,3)/50;
    fprintf('Fitting logistic GLMs [');
    ws = warning('off');
    for iVoxel = 1:size(x,3)
        [stats(iVoxel).beta,~,tmpstats] = glmfit(x(:,:,iVoxel),y(:,iVoxel),'binomial','link','logit');
        stats(iVoxel).t = tmpstats.t;
        stats(iVoxel).dfe = tmpstats.dfe;
        stats(iVoxel).mse = nanmean(tmpstats.resid.^2);
        if mod(iVoxel,pct) < 1, fprintf('.'); end
    end
    warning(ws);
=======
   
    
    % fit GLM
    [b,~,statistics] = glmfit(x,y,'binomial','link','logit');
    stats = struct('t',{statistics.t},'beta',{b},'dfe',{statistics.dfe},'mse',{nanmean(statistics.resid.^2)});

    %warning(ws);
>>>>>>> Stashed changes
    fprintf('] (%.2f min)\n',toc(s)/60);
    
    
    
 
end