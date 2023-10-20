clear all
clc

dirMeanR_2 = dir('data\Radiomics_Training_Leipzig\output\*model*\models\meanRSquared.mat');
% sorting the model predictors by mean squared rs 
for iMeanR_2 = 1:length(dirMeanR_2)
    data = load(fullfile(dirMeanR_2(iMeanR_2).folder,dirMeanR_2(iMeanR_2).name));
    % get data as an array and remove unnecessary dimensions
    data_array = squeeze(struct2cell(data.info)); % 2 x 14 cell array
    % sort parameters by values 
    data_matrix = cell2mat(data_array(2,:));
    [data_sorted, index]= sort(data_matrix);
    data_array_names = data_array(1,:);
    names_sorted = data_array_names(index);
    %display parameters
    model = extractAfter(dirMeanR_2(iMeanR_2).folder,"output\") 
    names_sorted
end
