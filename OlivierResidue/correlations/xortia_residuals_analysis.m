% This script analyzes the correlation between the Xortia dataset residuals and discomfort ratings.
% It calculates both Pearson and Spearman correlations, visualizes the relationship with scatter plots, 
% and examines the distribution of discomfort ratings and residuals.

%% Load the residuals data
% This file contains:
% - 'names': Cell array (1x50) with image identifiers
% - 'Resid': Numeric array (1x50) with the computed residuals
load("residuals/residuals_xortia.mat"); 

%% Load the table of discomfort ratings
% The ratings table should contain image discomfort ratings with columns:
% - 'Image': Image identifier
% - 'MeanRating': Mean discomfort rating per image
load("ratings_Xortia.mat");

%% Add the residuals to the ratings table
% Transpose 'Resid' to align dimensions and add as a new column
ratingsTable.Residuals = transpose(Resid);

%% Extract relevant columns for correlation analysis
metric = ratingsTable.Residuals; % Residual values (predictor)
discomfortRatings = ratingsTable.MeanRating; % Mean discomfort ratings (response)

%% Pearson Correlation
[r_pearson, p_pearson] = corr(log(metric), discomfortRatings, 'Type', 'Pearson');

%% Spearman Correlation
[r_spearman, p_spearman] = corr(log(metric), discomfortRatings, 'Type', 'Spearman');

% Display results
disp('Correlation Analysis Results (Filtered Images Only):');
fprintf('Pearson: r=%.4f, p=%.4g\n', r_pearson, p_pearson);
fprintf('Spearman: r=%.4f, p=%.4g\n', r_spearman, p_spearman);

%% Scatter Plot: Metric vs Discomfort Rating
figure;
scatter((metric), discomfortRatings, 'filled');
xlabel('(Residuals)');
ylabel('Discomfort Rating (Mean)');
title('Residuals vs Discomfort Rating');
grid on;

%% Plot Distribution of Discomfort Ratings
figure;
histogram(discomfortRatings, 'BinWidth', 0.5, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
xlabel('Discomfort Rating (Mean)');
ylabel('Frequency');
title('Distribution of Discomfort Ratings');

%% Plot Distribution of Residuals (Filtered)
figure;
histogram(ratingsTable.Residuals, 'BinWidth', max(ratingsTable.Residuals)/30, 'FaceColor', 'red', 'FaceAlpha', 0.7);
xlabel('Residuals');
ylabel('Frequency');
title('Distribution of Residuals');
