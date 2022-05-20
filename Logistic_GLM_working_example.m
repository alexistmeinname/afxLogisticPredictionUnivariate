clear all
addpath('scripts');

% hier das working example (ein paar echte bilder und zwei zufallsvariablen, keine echte analyse)
% daten liegen in data\Radiomics\input
% ergebnisse in data\Radiomics\output
%   - models: modelle (beta, t, masken, ...)
%   - predictions: prädiktionen (maps, prädiktoren, info über fold, ...)
% gerechnet wird im 2x2x2 mm space (n ~80000 voxel)

% 2x2x2 mm voxel space, sehr kleines field of view (spart daten bei der
% ausgabe)
[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');

% beispieldesign laden
load('design.mat');
%        patients: {1×60 cell}
%                  namen (ids) der patienten
%      predictors: {'CT-N'  'CT-A'  'CBF'  'CBV'  'Tmax'  'tici'  'r2'}
%                  namen der prädiktoren (aus "cbf" wird die
%                  perfusionsmaske extrahiert, "tici" wird für die
%                  mismatch-prädiktion herangezogen
%            xRaw: {60×7 cell}
%                  design-matrix, tici und r2 sind hier zufallsdaten
%            yRaw: {1×60 cell}
%                  response, also läsionen (die altläsion muss noch ergänzt werden)
%         dataDir: 'data\Radiomics'
%                  ordner für input und output
%    analysisName: 'testanalyse'
%            FWHM: 5
%                  in mm
%           nFold: 5
%                  anzahl der folds
%            fold: 0
%                  dummyvariable
%    minPerfusion: 1
%                  mindestanzahl perfusionsdaten pro parameter (eigentlich: 10)
%       minLesion: 0.1000
%                  mindestläsionsabdeckung in % (eigentlich 0.05)

tic;
% design vorbereiten (images laden, maske generieren, smoothen)
% das laden der daten habe ich lokal gemacht. auf broca dürfte es länger
% dauern
[x,y,masks] = afxPrepareDesign(design,space);
% k-fold crossvalidation (fitting des glms, prediction, abspeichern aller
% ergebnisse)
[stats,predictions,mRSquared] = afxKFold(x,y,masks,space,design);
toc; % ~ 15 minuten für 60 pat, 7 prädiktoren und ~70000 voxel, für den vollen datensatz vmtl. 30-45 min, evtl. auch länger

rmpath('scripts');