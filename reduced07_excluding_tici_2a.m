clear
addpath('scripts');

% reduction
% #1: Tmax x tici
% #2: sex
% #3: age
% #4: tToImg
% #5: ct-a
% #6: ct-n
% #7: nihss

data(1).mode = 'kfold';
data(1).design(1).file = 'data\Radiomics_Training_Leipzig\input\demographics\design.mat';
data(1).analysisName = 'reduced_model_07';

data(2).mode = 'crossval';
data(2).design(1).file = 'data\Radiomics_Test_Leipzig\input\demographics\design.mat';
data(2).design(2).file = 'data\Radiomics_Training_Leipzig\input\demographics\design.mat';
data(2).analysisName = 'reduced_model_07_test_Leipzig';

data(3).mode = 'crossval';
data(3).design(1).file = 'data\Radiomics_Test_Dresden\input\demographics\design.mat';
data(3).design(2).file = 'data\Radiomics_Training_Leipzig\input\demographics\design.mat';
data(3).analysisName = 'reduced_model_07_test_Dresden';

FWHM = [5 9];

[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');

for iData = 1:length(data)
    for iFWHM = 1:length(FWHM)
        s = tic;
        % design
        design = load_excl_2a(data(iData).design(1).file);
        if strcmp(data(iData).mode,'crossval')
            design2 = load_excl_2a(data(iData).design(2).file);
            nTest = length(design.patients);
            nTrain = length(design2.patients);
            design.patients = [design.patients design2.patients];
            design.crossval.test = [true(1,nTest) false(1,nTrain)];
            design.crossval.train = ~design.crossval.test;
        else
            design.nFold = 5;       % number of folds in k-fold cross validation
        end
        design.analysisName = strcat(data(iData).analysisName,'_excl_tici_2a');
        design.FWHM = FWHM(iFWHM);  % spatial smoothing 5,9,13 (,0)
        design.minPerfusion = 10;   % minimum perfusion maps per parameter
        design.minLesion = .05;     % minimum lesion coverage
        design.interactions(1).val = {'CBF' 'tici'};
        design.interactions(2).val = {'CBV' 'tici'};
        %design.interactions(3).val = {'Tmax' 'tici'};
        % remove facors
        [design] = afxEliminateFactor(design,'sex');
        [design] = afxEliminateFactor(design,'age');
        [design] = afxEliminateFactor(design,'tToImg');
        [design] = afxEliminateFactor(design,'CT-A');
        [design] = afxEliminateFactor(design,'CT-N');
        [design] = afxEliminateFactor(design,'nihss');
        % daten laden
        [x,y,masks,design] = afxPrepareDesign(design,space);
        % k-fold crossvalidation (fitting des glms, prediction, abspeichern aller ergebnisse)
        if strcmp(data(iData).mode,'crossval')
            designFile = afxExternalValidation(x,y,masks,space,design);
        else
            designFile = afxKFold(x,y,masks,space,design);
        end
        % evaluation
        afxEvaluatePredictions(designFile);
        fprintf('Elapsed time is %.1f min.\n',toc(s)/60);
    end
end
    
rmpath('scripts');


function design = load_excl_2a(f)
    load(f);
    idx = strcmp({design.patients.tici},'2a');
    design.patients(idx) = [];
end