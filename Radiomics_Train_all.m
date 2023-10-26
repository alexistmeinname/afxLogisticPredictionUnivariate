clear
addpath('scripts');

 % https://github.com/afx1337/afxStat/blob/main/masks/brainmask.nii

reduce(1).type = 'interaction';
reduce(1).val = 3; % Tmax x tici
reduce(2).type = 'factor';
reduce(2).val = 'CT-A';
reduce(3).type = 'factor';
reduce(3).val = 'sex';
reduce(4).type = 'factor';
reduce(4).val = 'age';
reduce(5).type = 'factor';
reduce(5).val = 'tToImg';
reduce(6).type = 'interaction';
reduce(6).val = 3; %CBF x gmTPM index after reducing Tmax x tici (line 63-65)
reduce(7).type ='interaction';
reduce(7).val = 4; %Tmax x gmTPM
reduce(8).type = 'interaction';
reduce(8).val = 3; %CBV x gmTPM
reduce(9).type = 'factor';CBV
reduce(9).val = 'gmTPM'; % actually very small mean r^2, but can't be deleted before interactions
reduce(10).type = 'factor';
reduce(10).val = 'CT-N';
reduce(11).type = 'interaction';
reduce(11).val = 1; % CBF x tici
reduce(12).type = 'interaction';
reduce(12).val = 1; % CBV x tici
reduce(13).type = 'factor';
reduce(13).val = 'nihss';
reduce(14).type = 'factor';
reduce(14).val = 'CBV';

FWHM = [9 13 5 0];     

[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');


for iReduce = 12:length(reduce)
    for iFWHM = 1:length(FWHM)
        s = tic;
        % get design 
        load('data\Radiomics_Training_Leipzig\input\demographics\design.mat'); 
        brainMask = fullfile('masks','brainmask.nii');
        %design.patients = design.patients(10:20);
        if iReduce == 0
            design.analysisName = 'full_model';
        else
            design.analysisName = sprintf('reduced_model_%02i',iReduce);
        end
        design.FWHM = FWHM(iFWHM);  % spatial smoothing 5,9,13
        design.nFold = 5;           % number of folds in k-fold cross validation
        design.minPerfusion = 10;   % minimum perfusion maps per parameter
        design.minLesion = .05;     % minimum lesion coverage
        design.interactions(1).val = {'CBF' 'tici'};
        design.interactions(2).val = {'CBV' 'tici'};
        design.interactions(3).val = {'Tmax' 'tici'};
        design.interactions(4).val = {'CBF' 'gmTPM'}; %interaction with grey matter probability map
        design.interactions(5).val = {'CBV' 'gmTPM'};
        design.interactions(6).val = {'Tmax' 'gmTPM'};
        % reduce model
        for i = 1:iReduce
            if strcmp(reduce(i).type,'interaction')
                design.interactions(reduce(i).val) = [];
            elseif strcmp(reduce(i).type,'factor')
                [design] = afxEliminateFactor(design,reduce(i).val);
            else
                error('something went wrong.');
            end
        end
        
        % daten laden
        [x,y,masks,design] = afxPrepareDesign(design,space,brainMask);
        % k-fold crossvalidation 
        designFile = afxKFold(x,y,masks,space,design);
        % evaluation
        afxEvaluatePredictions(designFile);
        fprintf('Elapsed time is %.1f min.\n',toc(s)/60);
        
        %free up memory
        clearvars -except FWHM iFWHM reduce iReduce space
    end
end

rmpath('scripts');
