function [stats,predictions,mRSquared,design] = afxKFold(x,y,masks,space,design)
    
    nPatients = size(x,1);
    
    % shuffle design and data
    pIdx = randperm(nPatients);
    design = afxPartialDesign(design,pIdx);
    x = x(pIdx,:,:);
    y = y(pIdx,:);
    % patients in testset per fold
    perFold = nPatients/design.nFold;
    
    % perform folds
    patientsNew = struct([]);
    for iFold = 1:design.nFold
        design.fold = iFold;
        % get idx for training and test-data
        idxTest = false(1,nPatients);
        idxTest(round(perFold*(iFold-1)+1):round(iFold*perFold)) = true;
        idxTrain = ~idxTest;
        % fit and save GLM (training data)
        [stats,scale] = afxLogisitcGLMfit(x(idxTrain,:,:),y(idxTrain,:));
        mRSquared(iFold,:) = afxSaveModel(stats,masks,space,scale,afxPartialDesign(design,idxTrain));
        % generate design matix for sucessfull and unsucessful reka and
        % predict
        idxTICI = find(strcmpi(design.predictors,'tici'),1);
        xReka0 = x; xReka0(:,idxTICI,:) = 0;
        predictions.reka0 = afxLogisticGLMval([stats.beta],xReka0(idxTest,:,:),scale);
        clear xReka0;
        xReka1 = x; xReka1(:,idxTICI,:) = 1;
        predictions.reka1 = afxLogisticGLMval([stats.beta],xReka1(idxTest,:,:),scale);
        clear xReka1;
        % calculate mismatch
        predictions.mismatch = predictions.reka0-predictions.reka1;
        % calculate threshold (min abs.vol.diff.)
        yfit = afxLogisticGLMval([stats.beta],x(idxTrain,:,:),scale);
        optThr = afxOptimalThreshold(yfit,y(idxTrain,:),.001,false);
        % save predictions
        patientsNew = [patietns afxSavePredictions(predictions,y(idxTest,:),masks,space,afxPartialDesign(design,idxTest),optThr)];
    end
    % save mean R squared (mean of all folds)
    destDir = fullfile(design.dataDir,'output',strcat(design.analysisName,'-s',num2str(design.FWHM)),'models');
    afxSavePredictors(fullfile(destDir,'meanRSquared.txt'),design.predictors,mean(mRSquared));
    % update design ()
    design.patients = patientsNew;
end

function design = afxPartialDesign(design,idx)
    design.patients = design.patients(idx);
end
