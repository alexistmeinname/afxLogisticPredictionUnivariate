clear all
clc

dEval = [ ...
    dir('data\*\output\reduced_model_07*-s9\evaluation\eval.mat'); ...
    dir('data\*\output\reduced_model_07*-s5\evaluation\eval.mat') ...
    ];
idx = contains({dEval.folder},'excl_tici_2a');
dEval(idx) = [];

analysisNames = {};
tblM = struct([]);
tblErr = struct([]);

metrics = {'GLM_AbsVolDiff' 'GLM_ROCAUC' 'GLM_Dice' 'GLM_MCC' 'Thr_AbsVolDiff' 'Thr_ROCAUC' 'Thr_Dice' 'Thr_MCC'};
ticiNames = {' all' '0' '1'};

addpath('scripts');
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
            m = metric;
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

    fprintf('--- %s ----------------',ticiNames{iTici})
    
    for iMetric = 1:length(metrics)/2

        yr(1).v = tblM.(metrics{iMetric})(3).s9';
        yr(2).v = tblM.(metrics{iMetric+4})(3).s5';
        yr(3).v = tblM.(metrics{iMetric})(2).s9';
        yr(4).v = tblM.(metrics{iMetric+4})(2).s5';
        yr(5).v = tblM.(metrics{iMetric})(1).s9';
        yr(6).v = tblM.(metrics{iMetric+4})(1).s5';
        y = nan(304,6);
        for i = 1:6
            y(1:length(yr(i).v),i) = yr(i).v;
        end

        labels = {'Training LE GLM','Training LE Thr','Test LE GLM','Test LE Thr','Test DD GLM','Test DD Thr'};
        
        p1 = signrank(y(:,1),y(:,2));
        p2 = signrank(y(:,3),y(:,4));
        p3 = signrank(y(:,5),y(:,6));

        [~,~,ci] = ttest(y);
        
        disp(' ')
        disp(metrics{iMetric}(5:end))
        disp([' ', labels; 'val = ', num2cell(nanmean(y));[{'ci = ';' '} num2cell(ci)];{'p = ' [] p1 [] p2 [] p3}])
        

    end
    
end
rmpath('scripts');