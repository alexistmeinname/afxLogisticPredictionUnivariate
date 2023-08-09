

%loading a struct from .mat file
load('\\medizin.uni-leipzig.de\data\Users\GroosAl\Eigene Dateien\MATLAB\afxLogisticPrediction-main\data\Radiomics_Training_Leipzig\input\demographics\design.mat', 'design');

%adding column to cellarray-fiel in substruct
for ipatient = 1: length(design.patients)
  xRaws = design.patients(ipatient).xRaw;
  xRaws(end+1) = {'masks\brainmask.nii'};
  design.patients(ipatient).xRaw = xRaws;
end
%adding predictor
predictors = design.predictors;
predictors(end+1) = {'brainmask'};
design.predictors = predictors;

%saving struct to file
save('design_bm1.mat','design')

