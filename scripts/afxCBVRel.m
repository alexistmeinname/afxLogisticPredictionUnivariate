function CBVRel = afxCBVRel(x,y,design,space,masks)
    idxCBV = find(strcmpi(design.predictors,'CBV'),1);
    CBVRel = nan(size(x,1),1,size(x,3));
    for iPatient = 1:size(x,1)
        tmpCBV = reshape(afxDeMask(masks.analysis,x(iPatient,idxCBV,:),NaN),space.dim);
        tmpLesion = reshape(afxDeMask(masks.analysis,y(iPatient,:),NaN),space.dim);
        lh = tmpLesion(1:floor(end/2),:,:); lh = nansum(lh(:));
        rh = tmpLesion(ceil(end/2):end,:,:); rh = nansum(rh(:));
        if lh > rh
            tmpCBVHemi = (tmpCBV(ceil(end/2):end,:,:));
        else
            tmpCBVHemi = (tmpCBV(1:floor(end/2),:,:));
        end
        tmpCBVHemiMean = nanmean(tmpCBVHemi(:));
        tmpCBVRel = tmpCBV(:)./tmpCBVHemiMean;
        CBVRel(iPatient,1,:) = tmpCBVRel(masks.analysis);
    end
end