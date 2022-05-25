function [design] = afxKFold(x,y,masks,space,design)
    
    nPatients = size(x,1);
    % shuffle design and data
    pIdx = randperm(nPatients);
    design.patients = design.patients(pIdx);
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
        % save fold in patient struct
        for i = find(idxTest), design.patients(i).fold = iFold; end
        % perform prediction
        [patientsTest,mRSquared(iFold,:)] = afxPrediction(x,y,masks,space,design,idxTrain,idxTest);
        patientsNew = [patientsNew patientsTest];
    end
    % save mean R squared (mean of all folds)
    destDir = fullfile(design.dataDir,'output',strcat(design.analysisName,'-s',num2str(design.FWHM)));
    afxWritePredictors(fullfile(destDir,'models','meanRSquared.txt'),design.predictors,mean(mRSquared,1));
    % update and save design
    design.patients = patientsNew;
    save(fullfile(destDir,'design.mat'),'design');
end
