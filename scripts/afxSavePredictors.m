function afxSavePredictors(fname,predictors,meanRSquared)
    fileID = fopen(fname,'w');
    fprintf(fileID,'no.  mean(RSquared)  name');
    predictors = [ 'intercept' predictors ];
    for i = 1:length(meanRSquared)
        fprintf(fileID,'\n%03i  %.6f        %s',i,meanRSquared(i),predictors{i});
    end
    fclose(fileID);
end