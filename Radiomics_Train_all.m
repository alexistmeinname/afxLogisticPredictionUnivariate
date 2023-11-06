clear
addpath('scripts');

reduce(1).type = 'interaction';
reduce(1).val = 3; % Tmax x tici
reduce(2).type = 'factor';
reduce(2).val = 'sex';
reduce(3).type = 'factor';
reduce(3).val = 'age';
reduce(4).type = 'factor';
reduce(4).val = 'tToImg';
reduce(5).type = 'factor';
reduce(5).val = 'CT-A';
reduce(6).type = 'factor';
reduce(6).val = 'CT-N';
reduce(7).type = 'factor';
reduce(7).val = 'nihss';
reduce(8).type = 'interaction';
<<<<<<< Updated upstream
reduce(8).val = 1; % CBF x tici
reduce(9).type = 'interaction';
reduce(9).val = 1; % CBV x tici
=======
reduce(8).val = 3; %CBV x gmTPM
reduce(9).type = 'factor';
reduce(9).val = 'gmTPM'; % actually very small mean r^2, but can't be deleted before interactions
>>>>>>> Stashed changes
reduce(10).type = 'factor';
reduce(10).val = 'CBV';

FWHM = [9 13 5 0];

[~,space.XYZmm,space.dim,space.mat] = afxVolumeLoad('masks\space2mm_small.nii');

<<<<<<< Updated upstream
for iReduce = 0:length(reduce)
=======

for iReduce = 0:0%length(reduce)
>>>>>>> Stashed changes
    for iFWHM = 1:length(FWHM)
        s = tic;
        % design
        load('data\Radiomics_Training_Leipzig\input\demographics\design.mat');
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
<<<<<<< Updated upstream
        [x,y,masks,design] = afxPrepareDesign(design,space);
        % k-fold crossvalidation (fitting des glms, prediction, abspeichern aller ergebnisse)
=======
        [x,y,masks,design] = afxPrepareDesign(design,space,brainMask);
        
        % k-fold crossvalidation 
>>>>>>> Stashed changes
        designFile = afxKFold(x,y,masks,space,design);
        % evaluation
        afxEvaluatePredictions(designFile);
        fprintf('Elapsed time is %.1f min.\n',toc(s)/60);
    end
end

rmpath('scripts');