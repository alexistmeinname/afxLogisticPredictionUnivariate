function [x,design] = afxEliminateFactor(x,design,factor)

    idxFactor = find(strcmpi(design.predictors,factor),1);
    if isempty(idxFactor)
    	error(['Interaktion mit unbekanntem Praediktor "' factor '".']);
	end
    x(:,idxFactor,:) = [];
    design.predictors(idxFactor) = [];
    
    for iPatient = 1:length(design.patients)
        design.patients(iPatient).xRaw(idxFactor) = [];
    end
end
