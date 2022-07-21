clear
addpath('scripts');

% reduction
% #1: Tmax x tici
% #2: sex
% #3: tToImg
% #4: age
% #5: ct-a
% #6: ct-n
% #7: nihss

[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');

s = tic;
% design
load('data\Radiomics_Test_Leipzig\input\demographics\design.mat');
d2 = load('data\Radiomics_Training_Leipzig\input\demographics\design.mat');
nTest = length(design.patients);
nTrain = length(d2.design.patients);
design.patients = [design.patients d2.design.patients];
design.crossval.test = [true(1,nTest) false(1,nTrain)];
design.crossval.train = ~design.crossval.test;
design.analysisName = 'reduced_model_07_test_Leipzig';
design.FWHM = 9;            % spatial smoothing 5,9,13
design.minPerfusion = 10;   % minimum perfusion maps per parameter
design.minLesion = .05;     % minimum lesion coverage
design.interactions(1).val = {'CBF' 'tici'};
design.interactions(2).val = {'CBV' 'tici'};
% remove facors
[design] = afxEliminateFactor(design,'sex');
[design] = afxEliminateFactor(design,'tToImg');
[design] = afxEliminateFactor(design,'age');
[design] = afxEliminateFactor(design,'CT-A');
[design] = afxEliminateFactor(design,'CT-N');
[design] = afxEliminateFactor(design,'nihss');
% daten laden
[x,y,masks,design] = afxPrepareDesign(design,space,design.crossval.train);
% external crossvalidation (fitting des glms, prediction, abspeichern aller ergebnisse)
designFile = afxExternalValidation(x,y,masks,space,design);
% evaluation
afxEvaluatePredictions(designFile);
fprintf('Elapsed time is %.1f min.\n',toc(s)/60);

rmpath('scripts');