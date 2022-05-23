function [meanRSquared] = afxSaveModel(stats,masks,space,scale,design)
    
    % file prefix
    prefix = 'LogisticGLM_';

    % destination directory
    destDir = fullfile(design.dataDir,'output',strcat(design.analysisName,'-s',num2str(design.FWHM)),'models');
    if isfield(design,'fold') && design.fold > 0
        destDir = fullfile(destDir,sprintf('fold%03i',design.fold));
    end
    mkdir(destDir);
    
    % write masks
    maskNames = fieldnames(masks);
    for i = 1:length(maskNames)
        afxVolumeWrite(fullfile(destDir,strcat(prefix,'mask_',maskNames{i},'.nii')),masks.(maskNames{i}),space.dim,'uint8',space.mat);
    end

    % write stats
    statNames = fieldnames(stats);
    for iStat = 1:length(statNames)
        % get values and threshold
        val = [stats.(statNames{iStat})];
        if strcmp(statNames{iStat},{'t'}),    val(val > 10) = 11; val(val < -10) = -11; end
        if strcmp(statNames{iStat},{'beta'}), val(val > 20) = 21; val(val < -20) = -21; end
        % write to disk
        for iParam = 1:size(val,1)
            if size(val,1) == 1
                fname = sprintf('%s%s.nii',prefix,statNames{iStat});
            else
                fname = sprintf('%s%s_%03i.nii',prefix,statNames{iStat},iParam);
            end
            afxVolumeWrite(fullfile(destDir,fname),afxDeMask(masks.analysis,val(iParam,:)),space.dim,'int16',space.mat);
        end
        clear val;
    end
    
    % save other data (disign, meanRSquared, scale)
    save(fullfile(destDir,strcat(prefix,'design.mat')),'design');
    save(fullfile(destDir,strcat(prefix,'scale.mat')),'scale');
    meanRSquared = nanmean([stats.t].^2./([stats.t].^2+[stats.dfe]),2);
    save(fullfile(destDir,strcat(prefix,'meanRSquared.mat')),'meanRSquared');
    % save info
    afxWritePredictors(fullfile(destDir,strcat(prefix,'info.txt')),design.predictors,meanRSquared)
end