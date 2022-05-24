function [stats,predictions,mRSquared,design] = afxKFold(x,y,masks,space,design)
    
    nPatients = size(x,1);
    
    % shuffle design and data
    pIdx = randperm(nPatients);
    design = afxPartialDesign(design,pIdx);
    x = x(pIdx,:,:);
    y = y(pIdx,:);
    % patients in testset per fold
    perFold = nPatients/design.nFold;
    % copy design matrix before generating intaractions
    xCopy = x;
    [x,design] = afxAddInteractions(x,design);
    
    % perform folds
    patientsNew = struct([]);
    for iFold = 1:design.nFold
        design.fold = iFold;
        % get idx for training and test-data
        idxTest = false(1,nPatients);
        idxTest(round(perFold*(iFold-1)+1):round(iFold*perFold)) = true;
        idxTrain = ~idxTest;
        for i = find(idxTest), design.patients(i).fold = iFold; end
        % fit and save GLM (training data)
        [stats,scale] = afxLogisitcGLMfit(x(idxTrain,:,:),y(idxTrain,:));
        mRSquared(iFold,:) = afxSaveModel(stats,masks,space,scale,afxPartialDesign(design,idxTrain));
        % generate design matix for sucessfull and unsucessful reka and
        % predict (it's complicated, becaus all interactions need to be
        % recalculated in the design matrix)
        idxTICI = find(strcmpi(design.predictors,'tici'),1);
        xReka = xCopy(idxTest,:,:);
        xReka(:,idxTICI,:) = 0;
        [xReka,~] = afxAddInteractions(xReka,design);
        predictions.reka0 = afxLogisticGLMval([stats.beta],xReka,scale);
        xReka = xCopy(idxTest,:,:);
        xReka(:,idxTICI,:) = 1;
        [xReka,~] = afxAddInteractions(xReka,design);
        predictions.reka1 = afxLogisticGLMval([stats.beta],xReka,scale);
        clear xReka;
        % calculate mismatch
        predictions.mismatch = predictions.reka0-predictions.reka1;
        % calculate threshold (min abs.vol.diff.)
        yfit = afxLogisticGLMval([stats.beta],x(idxTrain,:,:),scale);
        optThr = afxOptimalThreshold(yfit,y(idxTrain,:),.001,false);
        % save predictions
        patientsGLMTest = afxSavePredictions(predictions,y(idxTest,:),masks,space,afxPartialDesign(design,idxTest),optThr);
        % threshold variant
        thresholdMaps = afxThresholdModel(x,y,idxTrain,design,space,masks);
        designTest = design; designTest.patients = patientsGLMTest;
        for iThrMap = 1:length(thresholdMaps)
            thresholdMaps(iThrMap).dat = thresholdMaps(iThrMap).dat(idxTest,:);
        end
        patientsNew = [patientsNew afxSaveThreshold(thresholdMaps,masks,space,designTest)];
    end
    % save mean R squared (mean of all folds)
    destDir = fullfile(design.dataDir,'output',strcat(design.analysisName,'-s',num2str(design.FWHM)));
    afxWritePredictors(fullfile(destDir,'models','meanRSquared.txt'),design.predictors,mean(mRSquared,1));
    % update design ()
    design.patients = patientsNew;
    save(fullfile(destDir,'design.mat'),'design');
end

function design = afxPartialDesign(design,idx)
    design.patients = design.patients(idx);
end
