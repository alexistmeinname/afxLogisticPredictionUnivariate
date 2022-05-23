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
%[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');
[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space3mm.nii');


% beispieldesign laden
load('design.mat');

%        patients: {1ï¿½60 cell}
%                  namen (ids) der patienten
%      predictors: {'CT-N'  'CT-A'  'CBF'  'CBV'  'Tmax'  'tici'  'r2'}
%                  namen der prädiktoren (aus "cbf" wird die
%                  perfusionsmaske extrahiert, "tici" wird für die
%                  mismatch-prädiktion herangezogen
%            xRaw: {60ï¿½7 cell}
%                  design-matrix, tici und r2 sind hier zufallsdaten
%            yRaw: {1ï¿½60 cell}
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
design.xRaw(:,6) = num2cell(randi(2,length(design.patients),1)-1);
pat = design.patients;
design.patients = struct([]);
for i = 1:length(pat)
    design.patients(i).name = pat{i};
    design.patients(i).yRaw = design.yRaw{i};
    design.patients(i).yRawOld = '';
    design.patients(i).xRaw = design.xRaw(i,:);
    design.patients(i).name = pat{i};
end
design = rmfield(design,'xRaw');
design = rmfield(design,'yRaw');
design.thresholdMaps(1).name = 'CBVrel';
design.thresholdMaps(1).tici = 1;
design.thresholdMaps(1).inverse = true;
design.thresholdMaps(2).name = 'Tmax';
design.thresholdMaps(2).tici = 0;
design.thresholdMaps(2).inverse = false;
tic;
% design vorbereiten (images laden, maske generieren, smoothen)
% das laden der daten habe ich lokal gemacht. auf broca dürfte es länger
% dauern
[x,y,masks] = afxPrepareDesign(design,space);
% intaraktionen
[x,design] = afxAddInteraction(x,design,{'CBF' 'TICI'});
[x,design] = afxAddInteraction(x,design,{'CBV' 'TICI'});
[x,design] = afxAddInteraction(x,design,{'Tmax' 'TICI'});
% k-fold crossvalidation (fitting des glms, prediction, abspeichern aller
% ergebnisse)
[stats,predictions,mRSquared,design] = afxKFold(x,y,masks,space,design);
toc; % ~ 15 minuten für 60 pat, 7 prädiktoren und ~70000 voxel, für den vollen datensatz vmtl. 30-45 min, evtl. auch länger

rmpath('scripts');