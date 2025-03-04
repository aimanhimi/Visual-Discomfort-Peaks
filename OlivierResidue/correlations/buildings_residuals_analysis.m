% This script analyzes the correlation between the merged buildings0 and buildings1 datasets' 
% residuals and their discomfort ratings.
% It calculates Pearson and Spearman correlations, visualizes the relationship using scatter plots, 
% and examines the distributions of discomfort ratings and residuals.

%% Load the residuals data
% This file contains:
% - 'names': Cell array (1x148) with image identifiers (for buildings0 and buildings1 datasets)
% - 'Resid': Numeric array (1x148) with the computed residuals
load("residuals/residuals_buildings.mat"); 

%% Load the table of discomfort ratings
% The ratings table contains:
% - 'Image': Image identifier (matching 'names' from residuals)
% - 'MeanRating': Mean discomfort rating for each image
load("ratings_buildings.mat"); 

%% Add the residuals to the ratings table
% Transpose 'Resid' to align dimensions and add as a new column
ratingsTable.Residuals = transpose(Resid);

%% Extract relevant columns for correlation analysis
metric = ratingsTable.Residuals;        % Residual values (predictor)
discomfortRatings = ratingsTable.MeanRating; % Mean discomfort ratings (response)

%% Compute Pearson correlation (linear relationship)
% Pearson correlation measures the strength of the linear association 
% between residuals and discomfort ratings.
[r_pearson, p_pearson] = corr(metric, discomfortRatings, 'Type', 'Pearson');

%% Compute Spearman correlation (rank-based relationship)
% Spearman correlation measures the strength of a monotonic relationship 
% between residuals and discomfort ratings, handling non-linear trends.
[r_spearman, p_spearman] = corr(metric, discomfortRatings, 'Type', 'Spearman');

%% Display correlation results
disp('Correlation Analysis Results (Filtered Images Only):');
fprintf('Pearson: r=%.4f, p=%.4g\n', r_pearson, p_pearson);
fprintf('Spearman: r=%.4f, p=%.4g\n', r_spearman, p_spearman);

%% Scatter plot: Residuals vs. Discomfort Ratings (Log-Scale Residuals)
% Visualizes the relationship between the residuals and discomfort ratings.
% Log-transforming the residuals helps manage skewed data distributions.
figure;
scatter(log(metric), discomfortRatings, 'filled');
xlabel('log(Residuals)');
ylabel('Discomfort Rating (Mean)');
title('Residuals vs Discomfort Rating');
grid on;

%% Plot the distribution of discomfort ratings
% Displays the frequency distribution of mean discomfort ratings.
figure;
histogram(discomfortRatings, 'BinWidth', 0.5, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
xlabel('Discomfort Rating (Mean)');
ylabel('Frequency');
title('Distribution of Discomfort Ratings');

%% Plot the distribution of residuals
% Displays how the residuals are distributed across the images.
% Bin width is scaled relative to the maximum residual value for better visualization.
figure;
histogram(ratingsTable.Residuals, 'BinWidth', max(ratingsTable.Residuals)/30, 'FaceColor', 'red', 'FaceAlpha', 0.7);
xlabel('Residuals');
ylabel('Frequency');
title('Distribution of Residuals');
