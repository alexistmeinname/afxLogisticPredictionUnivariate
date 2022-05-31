clear
addpath('scripts');

% rduction
% #1: Tmax x tici
% #2: sex
% #2: tToImg

FWHM = [5 9 13];

[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');

for i = 1:length(FWHM)
    s = tic;
    % design
    load('data\Radiomics_Training_Leipzig\input\demographics\design.mat');
    design.analysisName = 'reduced_model_03';
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
    [x,design] = afxEliminateFactor(x,design,'tToImg');
    % k-fold crossvalidation (fitting des glms, prediction, abspeichern aller ergebnisse)
    afxKFold(x,y,masks,space,design);
    design.analysisName = strcat(design.analysisName,'-one-fold');
    afxPrediction(x,y,masks,space,design,true(1,length(design.patients)),false(1,length(design.patients)));
    fprintf('Elapsed time is %.1f min.\n',toc(s)/60);
end

rmpath('scripts');