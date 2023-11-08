function x = afxCreateLesionProbabilityMap (x,y,mask,design,space,indexFold)


        nLesions = sum(y,1); %number of observed lesions in voxel
        LPM = nLesions./size(y,1); % P(lesion) = nlesions /nObservations
        % smooth LPM & add to predictors 
        LPM = afxDeMask(mask,LPM);
        LPMNaN = isnan(LPM);
        LPM(LPMNaN) = 0;
        LPM = afxFastSmooth(LPM,design.FWHM,space.dim,space.mat);
        LPM(LPMNaN) = [];
        for index = find(indexFold) %insert at 12th position
            x(index,12,:) = LPM;
        end


end