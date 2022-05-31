clear
addpath('scripts');

% rduction
% #1: Tmax x tici
% #2: sex

FWHM = [5 9 13];

[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');

for i = 1:length(FWHM)
    s = tic;
    % design
    load('data\Radiomics_Training_Leipzig\input\demographics\design.mat');
    design.analysisName = 'reduced_model_02';
    design.FWHM = FWHM(i);      % spatial smoothing 5,9,13
    design.nFold = 5;           % number of folds in k-fold cross validation
    design.minPerfusion = 10;   % minimum perfusion maps per parameter
    design.minLesion = .05;     % minimum lesion coverage
    design.interactions(1).val = {'CBF' 'tici'};
    design.interactions(2).val = {'CBV' 'tici'};
    % daten laden
    [x,y,masks,design] = afxPrepareDesign(design,space);
    % remove facors
    [x,design] = afxEliminateFactor(x,design,'sex');
    % k-fold crossvalidation (fitting des glms, prediction, abspeichern aller ergebnisse)
    designFile = afxKFold(x,y,masks,space,design);
    % evaluation
    afxEvaluatePredictions(designFile);
    fprintf('Elapsed time is %.1f min.\n',toc(s)/60);
end

rmpath('scripts');