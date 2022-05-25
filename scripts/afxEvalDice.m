function dice = afxEvalDice(a,b)
    
    dice = nan(1,size(a,1));
    parfor iPatient = 1:size(a,1)
        % https://en.wikipedia.org/wiki/S%C3%B8rensen%E2%80%93Dice_coefficient
        dice(iPatient) = 2*nnz(a(iPatient,:)&b(iPatient,:))/(nnz(a(iPatient,:))+nnz(b(iPatient,:)));
    end
end