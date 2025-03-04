% This script analyzes the correlation between residuals from Olivier's model
% and aesthetic ratings (Mu) from the MSC dataset.
% It computes Pearson and Spearman correlations and visualizes the relationship
% and data distributions for a filtered subset of images.

%% Load residuals from Olivier's model
% This file contains:
% - 'names': Cell array (1x10001) with image identifiers
% - 'Resid': Numeric array (1x10001) with residuals from the model
load("residuals/residuals_msc_csf.mat");

%% Load filtered image names
% This file contains:
% - 'filteredImages': List of images to retain for analysis (from prior filtering)
load("filtered_msc_images.mat");

%% Load the full MSC Mu dataset (10,426 images)
% CSV contains image names and corresponding aesthetic ratings (Mu values)
muData = readtable("ratings/dataset_msc.csv", 'VariableNamingRule', 'preserve');

% Standardize column names for consistency
muData.Properties.VariableNames{'Filename'} = 'Image';
muData.Image = string(muData.Image); % Ensure image names are in string format

% Convert Mu values to numeric (handles decimal commas)
muData.Mu = strrep(muData.Mu, ',', '.');
muData.Mu = str2double(muData.Mu);

%% Convert residuals to table format
% This creates a table with image identifiers and their corresponding residuals
residualsTable = table(string(names)', Resid', 'VariableNames', {'Image', 'Residual'});

%% Join residuals with Mu values based on image identifiers
% This merges the residuals and aesthetic ratings by matching image names
combinedTable = innerjoin(residualsTable, muData, 'Keys', 'Image');

% Filter to retain only the images present in 'filteredImages'
filteredTable = combinedTable(ismember(combinedTable.Image, filteredImages), :);

% Extract the matched residuals and Mu values
residuals = filteredTable.Residual;
muValues = filteredTable.Mu;

%% Pearson Correlation (linear relationship)
% Pearson correlation assesses the linear association between residuals and Mu values
[r_pearson, p_pearson] = corr(residuals, muValues, 'Type', 'Pearson');

%% Spearman Correlation (rank-based relationship)
% Spearman correlation measures the strength of a monotonic relationship
[r_spearman, p_spearman] = corr(residuals, muValues, 'Type', 'Spearman');

%% Display correlation results
disp('Correlation Analysis Results (Filtered Images Only):');
fprintf('Pearson: r=%.4f, p=%.4g\n', r_pearson, p_pearson);
fprintf('Spearman: r=%.4f, p=%.4g\n', r_spearman, p_spearman);

%% Scatter Plot: Residuals vs. Mu (Aesthetic Rating)
% Visualizes the relationship between log-transformed residuals and Mu values
figure;
scatter(log(residuals), muValues, 'filled');
xlabel('log(Residuals)');
ylabel('Mu (Aesthetic Rating)');
title('Residuals vs Aesthetic Rating (Same filtered images as peaks)');
grid on;

%% Distribution of Aesthetic Ratings (Mu values)
% Displays the frequency distribution of aesthetic ratings
figure;
histogram(muValues, 'BinWidth', 0.2, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
xlabel('Aesthetic Rating (Mu)');
ylabel('Frequency');
title('Distribution of Aesthetic Ratings (Same filtered images as peaks)');

%% Distribution of Residuals
% Displays the distribution of residuals across the filtered images
figure;
histogram(residuals, 'BinWidth', max(residuals)/30, 'FaceColor', 'red', 'FaceAlpha', 0.7);
xlabel('Residuals');
ylabel('Frequency');
title('Distribution of Residuals (Same filtered images as peaks)');
