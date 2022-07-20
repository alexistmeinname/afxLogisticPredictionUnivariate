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
% #8: CBF x tici

FWHM = [9 13 5];

[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');

for i = 1:length(FWHM)
    s = tic;
    % design
    load('data\Radiomics_Training_Leipzig\input\demographics\design.mat');
    design.analysisName = 'reduced_model_08';
    design.FWHM = FWHM(i);      % spatial smoothing 5,9,13
    design.nFold = 5;           % number of folds in k-fold cross validation
    design.minPerfusion = 10;   % minimum perfusion maps per parameter
    design.minLesion = .05;     % minimum lesion coverage
    %design.interactions(1).val = {'CBF' 'tici'};
    design.interactions(1).val = {'CBV' 'tici'};
    %design.interactions(3).val = {'Tmax' 'tici'};
    %design.interactions = struct([]);    
    % remove facors
    [design] = afxEliminateFactor(design,'sex');
    [design] = afxEliminateFactor(design,'tToImg');
    [design] = afxEliminateFactor(design,'age');
    [design] = afxEliminateFactor(design,'CT-A');
    [design] = afxEliminateFactor(design,'CT-N');
    [design] = afxEliminateFactor(design,'nihss');
    % daten laden
    [x,y,masks,design] = afxPrepareDesign(design,space);
    % k-fold crossvalidation (fitting des glms, prediction, abspeichern aller ergebnisse)
    designFile = afxKFold(x,y,masks,space,design);
    % evaluation
    afxEvaluatePredictions(designFile);
    fprintf('Elapsed time is %.1f min.\n',toc(s)/60);
end

rmpath('scripts');