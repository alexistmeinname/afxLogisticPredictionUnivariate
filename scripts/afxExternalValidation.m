function [fDesignOut] = afxExternalValidation(x,y,masks,space,design)
    design.fold = 1;
    idxTest = design.crossval.test;
    idxTrain = design.crossval.train;
    % save fold in patient struct
    for i = find(idxTest), design.patients(i).fold = 1; end
    % perform prediction
    [patientsTest,~] = afxPrediction(x,y,masks,space,design,idxTrain,idxTest);
    % update and save design
    design.patients = patientsTest;
    fDesignOut = fullfile(destDir,'design.mat');
    save(fDesignOut,'design');
end
