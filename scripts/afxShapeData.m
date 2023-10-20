function yfitNewShape = afxShapeData(yfit,nPatients)
% yfit ... nObservationvoxel x 1
% xNormalShape ... nPatients x mPredictors x lVoxel
% function: shape yfit
% return: yfit... nObservation x mVoxel

    
    startvoxel = 1;
    anzahlvoxel = size(yfit,1)/nPatients;
    yfitNewShape = nan(sizeX(1),sizeX(3));
    for i = 1:sizeX(1) %nPatients
        yfitNewShape(i,:) = yfit(startvoxel:anzahlvoxel)';
        startvoxel = startvoxel + anzahlvoxel;
    end
end