function CBVRel = afxCBFRel(x,y,design,space,masks)

    % find CBF
    idxCBF = find(strcmpi(design.predictors,'CBF'),1);
    CBVRel = nan(size(x,1),1,size(x,3));
    for iPatient = 1:size(x,1)
        % get 3d CBF and 3d lesion
        tmpCBF = reshape(afxDeMask(masks.analysis,x(iPatient,idxCBF,:),NaN),space.dim);
        tmpLesion = reshape(afxDeMask(masks.analysis,y(iPatient,:),NaN),space.dim);
        % calculate lesion in lh and rh
        lh = tmpLesion(1:floor(end/2),:,:); lh = nansum(lh(:));
        rh = tmpLesion(ceil(end/2):end,:,:); rh = nansum(rh(:));
        % get CBF from unaffected hemisphere
        if lh > rh
            tmpCBVHemi = (tmpCBF(ceil(end/2):end,:,:));
        else
            tmpCBVHemi = (tmpCBF(1:floor(end/2),:,:));
        end
        % mean CBF
        tmpCBVHemiMean = nanmean(tmpCBVHemi(:));
        % CBFrel
        tmpCBVRel = tmpCBF(:)./tmpCBVHemiMean;
        CBVRel(iPatient,1,:) = tmpCBVRel(masks.analysis);
    end
end