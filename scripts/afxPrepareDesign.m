function [x,y,masks] = afxPrepareDesign(design,space)

    nPatients = size(design.xRaw,1);
    nPredictors = size(design.xRaw,2);
    nVoxels = prod(space.dim);

    % load images into design matrix x and response y
    fprintf('Loading images ... ');
    x = nan(nPatients,nPredictors,nVoxels);
    y = nan(nPatients,nVoxels);
    for iPatient = 1:nPatients
        for iPredictor = 1:nPredictors
            val = design.xRaw{iPatient,iPredictor};
            if isnumeric(val)
                x(iPatient,iPredictor,:) = val;
            else
                x(iPatient,iPredictor,:) = afxVolumeResample(val,space.XYZmm,1);
            end
        end
        y(iPatient,:) = afxVolumeResample(design.yRaw{iPatient},space.XYZmm,0);
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
    for j = 1:5
        x(:,j,:) = afxFastSmooth(x(:,j,:),design.FWHM,space.dim,space.mat);
    end
    % discard data outside mask
    y = y(:,masks.analysis);
    x = x(:,:,masks.analysis);
    fprintf('done.\n');
end