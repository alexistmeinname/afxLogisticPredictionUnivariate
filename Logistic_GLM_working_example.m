clear all
addpath('scripts');

% hier das working example (ein paar echte bilder und zwei zufallsvariablen, keine echte analyse)
% daten liegen in data\Radiomics\input
% ergebnisse in data\Radiomics\output
%   - models: modelle (beta, t, masken, ...)
%   - predictions: pr�diktionen (maps, pr�diktoren, info �ber fold, ...)
% gerechnet wird im 2x2x2 mm space (n ~80000 voxel)

% 2x2x2 mm voxel space, sehr kleines field of view (spart daten bei der
% ausgabe)
[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');

% beispieldesign laden
load('design.mat');

%        patients: {1�60 cell}
%                  namen (ids) der patienten
%      predictors: {'CT-N'  'CT-A'  'CBF'  'CBV'  'Tmax'  'tici'  'r2'}
%                  namen der pr�diktoren (aus "cbf" wird die
%                  perfusionsmaske extrahiert, "tici" wird f�r die
%                  mismatch-pr�diktion herangezogen
%            xRaw: {60�7 cell}
%                  design-matrix, tici und r2 sind hier zufallsdaten
%            yRaw: {1�60 cell}
%                  response, also l�sionen (die altl�sion muss noch erg�nzt werden)
%         dataDir: 'data\Radiomics'
%                  ordner f�r input und output
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
%                  mindestl�sionsabdeckung in % (eigentlich 0.05)
pat = design.patients;
design.patients = struct([]);
for i = 1:length(pat)
    design.patients(i).name = pat{i};
    design.patients(i).yRaw = design.yRaw{i};
    design.patients(i).yRawOld = '';
    design.patients(i).xRaw = design.xRaw(i,:);
    design.patients(i).name = pat{i};
end
tic;
% design vorbereiten (images laden, maske generieren, smoothen)
% das laden der daten habe ich lokal gemacht. auf broca d�rfte es l�nger
% dauern
[x,y,masks] = afxPrepareDesign(design,space);
% intaraktionen
[x,design] = afxAddInteraction(x,design,{'CBF' 'TICI'});
[x,design] = afxAddInteraction(x,design,{'CBV' 'TICI'});
[x,design] = afxAddInteraction(x,design,{'Tmax' 'TICI'});
% k-fold crossvalidation (fitting des glms, prediction, abspeichern aller
% ergebnisse)
[stats,predictions,mRSquared,design] = afxKFold(x,y,masks,space,design);
toc; % ~ 15 minuten f�r 60 pat, 7 pr�diktoren und ~70000 voxel, f�r den vollen datensatz vmtl. 30-45 min, evtl. auch l�nger

rmpath('scripts');