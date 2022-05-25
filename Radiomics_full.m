clear
addpath('scripts');

FWHM = [5 9 13];

[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');

for i = 1:length(FWHM)
    s = tic;
    % design
    load('data\Radiomics_Training_Leipzig\input\demographics\design.mat');
    design.analysisName = 'full_model';
    design.FWHM = FWHM(i);      % spatial smoothing 5,9,13
    design.nFold = 5;           % number of folds in k-fold cross validation
    design.fold = NaN;          % dummy var
    design.minPerfusion = 10;   % minimum perfusion maps per parameter
    design.minLesion = .05;     % minimum lesion coverage
    design.interactions(1).val = {'CBF' 'tici'};
    design.interactions(2).val = {'CBV' 'tici'};
    design.interactions(3).val = {'Tmax' 'tici'};
    % daten laden
    [x,y,masks,design] = afxPrepareDesign(design,space);
    % intaraktionen
    % k-fold crossvalidation (fitting des glms, prediction, abspeichern aller ergebnisse)
    afxKFold(x,y,masks,space,design);
    design.analysisName = strcat(design.analysisName,'-one-fold');
    afxPrediction(x,y,masks,space,design,true(1,length(design.patients)),false(1,length(design.patients)));
    fprintf('Elapsed time is %.1f min.\n',toc(s)/60);
end

rmpath('scripts');