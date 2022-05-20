clear all
addpath('scripts');

[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');

inputDir = 'data\Radiomics\input';
dPat = dir(inputDir);
patients = {dPat(3:end).name};

% load data
for i = 1:length(patients)
    patDir = fullfile(inputDir,patients{i},'radiomics');
    lesion{i} = fullfile(patDir,'NormalizedLesion_.nii');
    f{i,1} = matchFile(fullfile(patDir,'NormalizedCT-N_*'));
    f{i,2} = matchFile(fullfile(patDir,'NormalizedCT-A_*'));
    f{i,3} = matchFile(fullfile(patDir,'NormalizedCT-P_CBF_*'));
    f{i,4} = matchFile(fullfile(patDir,'NormalizedCT-P_CBV_*'));
    f{i,5} = matchFile(fullfile(patDir,'NormalizedCT-P_Tmax_*'));
end

design.patients = patients;
design.predictors = {'CT-N' 'CT-A' 'CBF' 'CBV' 'Tmax' 'tici' 'r2'};
design.xRaw = [f num2cell(randn(length(patients),2)+.5)];
design.yRaw = lesion;
design.dataDir = 'data\Radiomics';
design.analysisName = 'testanalyse';
design.FWHM = 5;
design.nFold = 5;
design.fold = 0;
design.minPerfusion = 1; % 10;
design.minLesion = .1; %.05;

tic;
[x,y,masks] = afxPrepareDesign(design,space);
[stats,predictions,mRSquared] = afxKFold(x,y,masks,space,design);
toc;

rmpath('scripts');

% Resample all images: 2 minutes
% Smooth all images: 3 minutes
% GLM (5-Folds): 20 minutes
% Save GLMs: 5 seconds
% Save Predictions: 3 minutes


function f = matchFile(f)
    d = dir(f);
    [p,~,~] = fileparts(f);
    f = fullfile(p,d.name);
end