clear
addpath('scripts');

FWHM = [5 9 13];

[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');
load('data\Radiomics_Training_Leipzig\input\demographics\design.mat');

design.analysisName = 'full_model';
design.FWHM = NaN;          % spatial smoothing 5,9,13
design.nFold = 5;           % number of folds in k-fold cross validation
design.fold = NaN;          % dummy var
design.minPerfusion = 10;   % minimum perfusion maps per parameter
design.minLesion = .05;     % minimum lesion coverage

for i = 1:length(FWHM)
    s = tic;
    % daten laden
    [x,y,masks] = afxPrepareDesign(design,space);
    % intaraktionen
    [x,design] = afxAddInteraction(x,design,{'CBF' 'tici'});
    [x,design] = afxAddInteraction(x,design,{'CBV' 'tici'});
    [x,design] = afxAddInteraction(x,design,{'Tmax' 'tici'});
    % k-fold crossvalidation (fitting des glms, prediction, abspeichern aller ergebnisse)
    [stats,predictions,mRSquared,design] = afxKFold(x,y,masks,space,design);
    fprintf('Elapsed time is %.1f min.\n',toc(s)/60);
end

rmpath('scripts');