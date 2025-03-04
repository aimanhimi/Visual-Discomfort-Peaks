%% Correlation Analysis Between Building Metrics and Discomfort Ratings
% This script analyzes the correlation between Fourier spectrum metrics of building 
% images and their corresponding discomfort ratings collected from human subjects.
%
% Purpose:
% --------
% The script loads pre-computed metrics (from Fourier analysis) and discomfort 
% ratings, then calculates and visualizes their correlation. It helps identify
% whether specific frequency domain characteristics of art images are
% associated with visual discomfort reported by viewers.
%
% Workflow:
% ---------
% 1. Load metrics table with Fourier analysis results from building images
% 2. Load table containing discomfort ratings from human subjects
% 3. Merge tables based on image indices
% 4. Filter out problematic images based on number of detected peaks
% 5. Calculate Pearson and Spearman correlations between metrics and ratings
% 6. Generate visualizations:a
%    - Scatter plot of metric vs. discomfort rating
%    - Histogram of discomfort ratings distribution
%    - Histogram of number of peaks distribution
%
% Input Files:
% -----------
% - "ResultsTables/becca_finalTable_prom_40_thresh_19_window_3.mat"
%   Contains Fourier metrics for building images (output from analyze_peaks function)
%
% - "ratings_Becca.mat"
%   Contains discomfort ratings collected from human subjects
%
% Parameters:
% ----------
% - minPeaks: Minimum number of peaks in images for filtering (default: 0)
% - maxPeaks: Maximum number of peaks in images for filtering (default: 10000)
%
% Key Metrics Analyzed:
% -------------------
% - SumWeightedAmplitudeDistance: Primary metric correlated with discomfort
%
% Outputs:
% -------
% - Printed correlation coefficients (Pearson and Spearman) with p-values
% - Scatter plot showing relationship between metric and discomfort ratings
% - Histogram showing distribution of discomfort ratings
% - Histogram showing distribution of number of peaks
%
% Usage:
% -----
% 1. Ensure the required .mat files are in the correct locations
% 2. Run the script to generate correlation results and visualizations
%
% Notes:
% -----
% - The script uses logarithmic transformation for plotting the metric values
% - The analysis is limited to images within specified peak count range,
% (only used with MSC dataset, the rest of datasets considered all images) 
% - Both Pearson (linear) and Spearman (rank-based) correlations are reported

%% Load metrics table of buildings
load("ResultsTables/becca_finalTable_prom_40_thresh_19_window_3.mat"); % Loads finalTable

%% Load table of discomfort ratings
load("ratings_Becca.mat"); % Loads ratingsTable

%% Join the final table with the ratings table based on Image index.
% Both tables are in the same order and have the same number of rows (50), so we concatenate columns directly.
finalTable.Image = (1:height(finalTable))'; % Explicitly create image indices 1 to 100

% Merge by "Image"
combinedTable = innerjoin(finalTable, ratingsTable, 'Keys', 'Image');

%% Filter rows based on the number of peaks (avoid problematic images)
minPeaks = 0;
maxPeaks = 10000;
filteredTable = combinedTable(combinedTable.SumDistances >= minPeaks & combinedTable.SumDistances <= maxPeaks, :);

%% Extract the relevant columns after filtering
metric = filteredTable.SumWeightedAmplitudeDistance;
discomfortRatings = filteredTable.MeanRating;

%% Pearson Correlation Analysis
[r_pearson, p_pearson] = corr(metric, discomfortRatings, 'Type', 'Pearson');

%% Spearman Correlation Analysis
[r_spearman, p_spearman] = corr(metric, discomfortRatings, 'Type', 'Spearman');

%% Print Results
fprintf('Correlation Results (Filtered by NumPeaks > %d and < %d). Images considered after filter: %d/%d \n', ...
    minPeaks, maxPeaks, height(filteredTable), height(combinedTable));

fprintf('Pearson Correlation Coefficient: %.4f (p-value: %.4g)\n', r_pearson, p_pearson);
fprintf('Spearman Correlation Coefficient: %.4f (p-value: %.4g)\n', r_spearman, p_spearman);


%% Scatter Plot: Metric vs Discomfort Rating
figure;
scatter(log(metric), discomfortRatings, 'filled');
xlabel('log(SumWeightedAmplitudeDistance)');
ylabel('Discomfort Rating (Mean)');
title('SumWeightedAmplitudeDistance vs Discomfort Rating (Filtered by Peaks)');
grid on;

%% Plot Distribution of Discomfort Ratings
figure;
histogram(discomfortRatings, 'BinWidth', 0.5, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
xlabel('Discomfort Rating (Mean)');
ylabel('Frequency');
title('Distribution of Discomfort Ratings (Filtered by Peaks)');

%% Plot Distribution of NumPeaks (Filtered)
figure;
histogram(filteredTable.NumPeaks, 'BinWidth', max(filteredTable.NumPeaks)/50, 'FaceColor', 'red', 'FaceAlpha', 0.7);
xlabel('NumPeaks');
ylabel('Frequency');
title('Distribution of NumPeaks (Filtered)');

