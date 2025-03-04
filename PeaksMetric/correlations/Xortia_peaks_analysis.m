% Script to check the correlation between the merged buildings0 and buildings1 datasets and their discomfort ratings, given the metrics table.

%% Load metrics table of buildings
load("ResultsTables/xortia_finalTable_prom_45_thresh_19_window_3.mat"); % Loads finalTable

%% Load table of discomfort ratings
load("ratings_Xortia.mat"); % Loads ratingsTable

%% Join the final table with the ratings table based on Image index.
% Both tables are in the same order and have the same number of rows (50), so we concatenate columns directly.
finalTable.Image = (1:height(finalTable))'; % Explicitly create image indices 1 to 100

% Merge by "Image"
combinedTable = innerjoin(finalTable, ratingsTable, 'Keys', 'Image');

%% Filter rows based on the number of peaks (avoid problematic images)
minPeaks = 0;
maxPeaks = 4000;
filteredTable = combinedTable(combinedTable.SumDistances >= minPeaks & combinedTable.SumDistances <= maxPeaks, :);

%% Extract the relevant columns after filtering
metric = filteredTable.SumWeightedDistance;
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
scatter((metric), discomfortRatings, 'filled');
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
