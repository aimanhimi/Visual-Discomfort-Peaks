% This script analyzes the correlation between the Becca dataset residuals and discomfort ratings.
% It calculates both Pearson and Spearman correlations, visualizes the relationship with scatter plots, 
% and examines the distribution of discomfort ratings and residuals.

%% Load the residuals data
% This file contains:
% - 'names': Cell array (1x50) with image identifiers
% - 'Resid': Numeric array (1x50) with the computed residuals
load("residuals/residuals_becca.mat"); 

%% Load the table of discomfort ratings
% The ratings table should contain image discomfort ratings with columns:
% - 'Image': Image identifier
% - 'MeanRating': Mean discomfort rating per image
load("ratings_Becca.mat");

%% Add the residuals to the ratings table
% Transpose 'Resid' to align dimensions and add as a new column
ratingsTable.Residuals = transpose(Resid);

%% Extract relevant columns for correlation analysis
metric = ratingsTable.Residuals;        % Residual values (predictor)
discomfortRatings = ratingsTable.MeanRating; % Mean discomfort ratings (response)

%% Compute Pearson correlation (linear relationship)
% Pearson measures the linear association between residuals and discomfort ratings.
[r_pearson, p_pearson] = corr(metric, discomfortRatings, 'Type', 'Pearson');

%% Compute Spearman correlation (rank-based relationship)
% Spearman assesses the monotonic relationship, useful for non-linear associations.
[r_spearman, p_spearman] = corr(metric, discomfortRatings, 'Type', 'Spearman');

%% Display correlation results
disp('Correlation Analysis Results (Filtered Images Only):');
fprintf('Pearson: r=%.4f, p=%.4g\n', r_pearson, p_pearson);
fprintf('Spearman: r=%.4f, p=%.4g\n', r_spearman, p_spearman);

%% Scatter plot: Residuals vs. Discomfort Ratings (Log-Scale Residuals)
% Visualizes the relationship between the residuals and discomfort ratings.
figure;
scatter(log(metric), discomfortRatings, 'filled'); % Log-scale improves visualization for skewed data
xlabel('Log(Residuals)');
ylabel('Discomfort Rating (Mean)');
title('Residuals vs Discomfort Rating');
grid on;

%% Plot the distribution of discomfort ratings
% Shows the frequency of different mean discomfort ratings.
figure;
histogram(discomfortRatings, 'BinWidth', 0.5, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
xlabel('Discomfort Rating (Mean)');
ylabel('Frequency');
title('Distribution of Discomfort Ratings');

%% Plot the distribution of residuals
% Displays how the residuals are distributed across images.
figure;
histogram(ratingsTable.Residuals, 'BinWidth', max(ratingsTable.Residuals)/30, 'FaceColor', 'red', 'FaceAlpha', 0.7);
xlabel('Residuals');
ylabel('Frequency');
title('Distribution of Residuals');
