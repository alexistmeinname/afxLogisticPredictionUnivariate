clear

[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');

load('data\Radiomics_Training_Leipzig\input\demographics\design.mat');

design.analysisName = 'test01-reduced';
design.FWHM = 9;            % spatial smoothing 5,9,13
design.nFold = 5;           % number of folds in k-fold cross validation
design.fold = 0;            % dummy var
design.minPerfusion = 10;   % minimum perfusion maps per parameter
design.minLesion = .05;     % minimum lesion coverage

s = tic;
% daten laden
[x,y,masks] = afxPrepareDesign(design,space);
% intaraktionen
%[x,design] = afxAddInteraction(x,design,{'CBF' 'tici'});
%[x,design] = afxAddInteraction(x,design,{'CBV' 'tici'});
[x,design] = afxAddInteraction(x,design,{'Tmax' 'tici'});
[x,design] = afxEliminateFactor(x,design,'age');
[x,design] = afxEliminateFactor(x,design,'sex');
[x,design] = afxEliminateFactor(x,design,'CT-A');
% k-fold crossvalidation (fitting des glms, prediction, abspeichern aller
% ergebnisse)
[stats,predictions,mRSquared,design] = afxKFold(x,y,masks,space,design);
fprintf('Elapsed time is %.1f min.\n',toc(s)/60);