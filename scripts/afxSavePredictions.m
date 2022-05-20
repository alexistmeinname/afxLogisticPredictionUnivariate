function [] = afxSavePredictions(predictions,y,masks,space,design)
   
    % file prefix
    prefix = 'LogisticGLM_';

    % destination directory
    destDir = fullfile(design.dataDir,'output',strcat(design.analysisName,'-s',num2str(design.FWHM)),'predictions');
    
    predNames = fieldnames(predictions);
    for iPatient = 1:length(design.patients)
        % patient dir
        patDestDir = fullfile(destDir,design.patients{iPatient});
        mkdir(patDestDir);
        % save predictions and prediction mask
        for iPrediction = 1:length(predNames)
            fname = sprintf('%sprediction_%s.nii',prefix,predNames{iPrediction});
            afxVolumeWrite(fullfile(patDestDir,fname),afxDeMask(masks.analysis,predictions.(predNames{iPrediction})(iPatient,:)),space.dim,'int16',space.mat);
        end
        fname2 = sprintf('%sprediction_mask.nii',prefix);
        afxVolumeWrite(fullfile(patDestDir,fname2),afxDeMask(masks.analysis,~isnan(predictions.(predNames{1})(iPatient,:))),space.dim,'uint8',space.mat);
        % save groundtruth
        afxVolumeWrite(fullfile(patDestDir,'groundtruth.nii'),afxDeMask(masks.analysis,y(iPatient,:)),space.dim,'uint8',space.mat);
        % save predictors
        afxSaveVars(fullfile(patDestDir,'predictors'),['intercept' design.predictors],[1 design.xRaw(iPatient,:)]);
        % save info
        afxSaveVars(fullfile(patDestDir,'info'),{'fold' 'FWHM' 'minPerfusion' 'minLesion'},{design.fold design.FWHM design.minPerfusion design.minLesion});
    end
end

function afxSaveVars(fname,names,vals)
    fileID = fopen([fname '.txt'],'w');
    for i = 1:length(names)
        val = vals{i};
        info(i).name = names{i};
        info(i).value = val;
        if isnumeric(val), val = num2str(val); end
        if strcmp(val,'')
            fprintf('\n')
        else
            fprintf(fileID,'% 20s:    %s\n',names{i},val);
        end
    end
    fclose(fileID);
    save([fname '.mat'],'info');
end