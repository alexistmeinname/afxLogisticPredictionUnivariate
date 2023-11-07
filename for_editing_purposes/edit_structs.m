

%loading a struct from .mat file
load('..\data\Radiomics_Training_Leipzig\input\demographics\design.mat');
%adding column to cellarray-fiel in substruct

for ipatient = 1: length(design.patients)
  xRaws = design.patients(ipatient).xRaw;
  xRaws(12) = {'masks\gmTPM.nii'};
  design.patients(ipatient).xRaw = xRaws;
end

% adding predictor
predictors = design.predictors;
predictors(end+1) = {'LPM'};
design.predictors = predictors;

%saving struct to file
save('design.mat','design')

