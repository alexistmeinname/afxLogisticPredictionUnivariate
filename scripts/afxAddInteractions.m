function [x,design] = afxAddInteractions(x,design)
    
    for iInteracton = 1:length(design.interactions)
        % https://stats.stackexchange.com/questions/11645/coding-an-interaction-between-a-nominal-and-a-continuous-predictor-for-logistic
        for iPredictor = 1:length(design.interactions(iInteracton).val)
            idxInteraction(iPredictor) = find(strcmpi(design.predictors,design.interactions(iInteracton).val{iPredictor}),1);
            if isempty(idxInteraction(iPredictor))
                error(['Interaktion mit unbekanntem Praediktor "' design.interactions(iInteracton).val{iPredictor} '".']);
            end
        end
        x(:,end+1,:) = prod(x(:,idxInteraction,:),2);
        design.predictors(end+1) = join(design.interactions(iInteracton).val,' x ');

        for iPatient = 1:length(design.patients)
            design.patients(iPatient).xRaw{end+1} = 'interaction';
        end
    end
end
