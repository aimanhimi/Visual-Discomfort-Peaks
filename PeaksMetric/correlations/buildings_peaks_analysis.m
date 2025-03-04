%% Building Metrics Correlation Analysis
% Analyzes correlation between Fourier spectral metrics of building images and 
% discomfort ratings from human subjects.
%
% Summary:
% --------
% This script loads pre-computed Fourier spectrum metrics and discomfort ratings,
% calculates Pearson correlation, and visualizes the relationship between spectral 
% characteristics and visual discomfort.
%
% Files:
% ------
% - Input: "ResultsTables/buildings_finalTable_prom_95_thresh_19_window_3.mat"
% - Input: "ratings_buildings.mat"
%
% Process:
% --------
% 1. Load and merge metrics and ratings tables
% 2. Filter by peak count (min: 0, max: 1000)
% 3. Calculate Pearson correlation between SumWeightedAmplitudeDistance and MeanRating
% 4. Generate visualizations:
%    - Scatter plot (log-transformed metric vs ratings)
%    - Histograms of ratings and peak counts
%
% Output:
% -------
% - Correlation statistics (r value and p-value)
% - Three visualizations showing relationship patterns
%
% Usage:
% ------
% Run the script with the appropriate input files in the specified paths
% to generate correlation analysis between building metrics and discomfort.

%% Load metrics table of buildings
load("ResultsTables/buildings_finalTable_prom_95_thresh_19_window_3.mat"); % Loads finalTable

%% Load table of discomfort ratings
load("ratings_buildings.mat"); % Loads ratingsTable

%% Join the final table with the ratings table based on Image index.
% Both tables are in the same order and have the same number of rows (74 * 2), so we concatenate columns directly.
finalTable.Image = (1:height(finalTable))'; % Explicitly create image indices 1 to 148

% Merge by "Image"
combinedTable = innerjoin(finalTable, ratingsTable, 'Keys', 'Image');

%% Filter rows based on the number of peaks (avoid problematic images)
minPeaks = 0;
maxPeaks = 1000;
filteredTable = combinedTable(combinedTable.SumDistances >= minPeaks & combinedTable.SumDistances <= maxPeaks, :);

%% Extract the relevant columns after filtering
metric = filteredTable.SumWeightedAmplitudeDistance;
discomfortRatings = filteredTable.MeanRating;

%% Pearson Correlation Analysis
[r, p] = corr(metric, discomfortRatings, 'Type', 'Pearson');

fprintf('Pearson Correlation Results (Filtered by NumPeaks > %d and < %d). Images considered after filter: %d/%d \n', ...
    minPeaks, maxPeaks, height(filteredTable), height(combinedTable));
fprintf('Correlation coefficient (r): %.4f\n', r);
fprintf('p-value: %.4g\n', p);

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
histogram(filteredTable.NumPeaks, 'BinWidth', max(filteredTable.NumPeaks)/30, 'FaceColor', 'red', 'FaceAlpha', 0.7);
xlabel('NumPeaks');
ylabel('Frequency');
title('Distribution of NumPeaks (Filtered)');

