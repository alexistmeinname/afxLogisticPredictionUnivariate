function [x,y,masks] = afxPrepareDesign(design,space)

    nPatients = length(design.patients);
    nPredictors = length(design.predictors);
    nVoxels = prod(space.dim);

    % load images into design matrix x and response y
    fprintf('Loading images ... ');
    x = nan(nPatients,nPredictors,nVoxels);
    y = nan(nPatients,nVoxels);
    for iPatient = 1:nPatients
        for iPredictor = 1:nPredictors
            val = design.patients(iPatient).xRaw{iPredictor};
            if isnumeric(val)
                x(iPatient,iPredictor,:) = val;
            else
                x(iPatient,iPredictor,:) = afxVolumeResample(val,space.XYZmm,1);
            end
        end
        y(iPatient,:) = afxVolumeResample(design.patients(iPatient).yRaw,space.XYZmm,0) > .5;
        % if a patient has a old lesion, remove from x and y
        if ~isempty(design.patients(iPatient).yRaw)
            ytmp = afxVolumeResample(design.patients(iPatient).yRawOld,space.XYZmm,0) > .5;
            y(iPatient,ytmp) = 0;
            x(iPatient,:,ytmp) = NaN;
        end
    end
    fprintf('done.\n');

    fprintf('Preparing masks and smoothing data ... ');
    % create masks
    idxCBF = find(strcmpi(design.predictors,'cbf'),1);
    masks.perfusion = squeeze(sum(~isnan(x(:,idxCBF,:))))';
    masks.lesions = sum(y);
    masks.analysis = masks.perfusion > design.minPerfusion*(nPredictors+1) & masks.lesions > nPatients*design.minLesion;
    % mask data
    x(:,:,~masks.analysis) = 0;
    % smoothing
    for j = 1:size(x,2)
        x(:,j,:) = afxFastSmooth(x(:,j,:),design.FWHM,space.dim,space.mat);
    end
    % discard data outside mask
    y = y(:,masks.analysis);
    x = x(:,:,masks.analysis);
    fprintf('done.\n');
end
