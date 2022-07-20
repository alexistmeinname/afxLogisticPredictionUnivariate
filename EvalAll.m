clear all
clc

dEval = dir('data\Radiomics_Training_Leipzig\output\*model*\evaluation\eval.mat');

analysisNames = {};
tblM = struct([]);
tblErr = struct([]);

metrics = {'GLM_AbsVolDiff' 'GLM_ROCAUC' 'GLM_Dice' 'GLM_MCC' 'Thr_AbsVolDiff' 'Thr_ROCAUC' 'Thr_Dice' 'Thr_MCC'};
ticiNames = {' all' '0' '1'};

for iTici = 1:length(ticiNames)
    for iEval = 1:length(dEval)
        % load evaluation metrics and design
        dat.eval = load(fullfile(dEval(iEval).folder,dEval(iEval).name));
        dat.design = load(fullfile(dEval(iEval).folder,'..\design.mat'));
        % get analysis name, tici and FWHM
        FWHM = dat.design.design.FWHM;
        ticiScore = [dat.eval.tbl.(strcat('pred',num2str(find(strcmp(dat.eval.predictors,'tici')))))] > .5;
        analysisName = dat.design.design.analysisName;
        for iMetric = 1:length(metrics)
            % target metric
            metric = [dat.eval.tbl.(metrics{iMetric})];
            if ticiNames{iTici} == '0'
                metric(ticiScore) = []; % del tici = 1
            elseif ticiNames{iTici} == '1'
                metric(~ticiScore) = []; % del tici = 0
            end
            % remove NaNs (e.g. Dice)
            metric(isnan(metric)) = [];
            % mean and 95%-ci
            m = mean(metric);
            %[~,~,ci,~] = ttest(metric);
            % save data to table
            idx = find(strcmp(analysisName,analysisNames));
            if isempty(idx)
              idx = length(analysisNames)+1;
              analysisNames = [analysisNames analysisName];
            end
            tblM(1).(metrics{iMetric})(idx).(['s' num2str(FWHM)]) = m;
            %tblErr(1).(metrics{iMetric})(idx).(['s' num2str(FWHM)]) = diff(ci)/2;
        end
    end

    figure('units','normalized','outerposition',[0 0 .85 .85]);
    ticiTitle = strcat('tici',ticiNames{iTici});
    sgtitle(ticiTitle);
    for iMetric = 1:length(metrics)
        % plot metric per FWHM and model
        subplot(2,4,iMetric)
        hold all;
        plot([tblM.(metrics{iMetric}).s5])
        plot([tblM.(metrics{iMetric}).s9])
        plot([tblM.(metrics{iMetric}).s13])
        %errorbar([tblM.s5],[tblErr.s5])
        %errorbar([tblM.s9],[tblErr.s9])
        %errorbar([tblM.s13],[tblErr.s13])
        xticks(1:length(analysisNames));
        xticklabels(strrep(strrep(analysisNames,'_',' '),' model',''));
        xtickangle(45)
        if iMetric > 4
            legend({'5 mm' '9 mm' '13 mm'},'Location','northoutside');
            legend('boxoff')
        end
        title(strrep(metrics{iMetric},'_',' '));
    end
    
    destDir = fullfile(dat.design.design.dataDir,'output','evaluation');
    mkdir(destDir);
    print(gcf,fullfile(destDir,[ticiTitle '.png']),'-dpng','-r120');
end