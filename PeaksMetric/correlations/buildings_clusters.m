%% Clustering Analysis of Building Metrics and Discomfort Ratings
% This script performs clustering analysis on building images based on 
% Fourier spectrum metrics and their corresponding discomfort ratings.
%
% Purpose:
% --------
% Categorizes building images into discomfort level clusters (Low, Medium, High)
% based on mean ratings, then visualizes the relationship between these clusters
% and spectral characteristics of the images.
%
% Workflow:
% ---------
% 1. Load metrics table with Fourier analysis results
% 2. Load discomfort ratings table
% 3. Merge tables by image index
% 4. Categorize images into discomfort levels (Low: ≤3, Medium: 3-5, High: ≥5)
% 5. Visualize clusters on a scatter plot (metric vs. rating)
%
% Input Files:
% -----------
% - "ResultsTables/buildings_finalTable_prom_95_thresh_19_window_3.mat"
% - "ratings_buildings.mat"
%
% Outputs:
% -------
% - Cluster counts summary
% - Scatter plot showing clustering of images by discomfort level
% - Histogram showing distribution of metrics by discomfort level
%

% Notes:
% -----
% - Log transformation is applied to the metric for better visualization
% - Color coding: Blue (Low), Yellow (Medium), Red (High) discomfort

%% Load metrics table of buildings
load("ResultsTables/buildings_finalTable_prom_95_thresh_19_window_3.mat"); % Loads finalTable

%% Load table of discomfort ratings
load("ratings_buildings.mat"); % Loads ratingsTable

% Ensure both tables align correctly using the "Image" index.
finalTable.Image = (1:height(finalTable))'; % Explicitly create image indices 1 to 148
combinedTable = innerjoin(finalTable, ratingsTable, 'Keys', 'Image');

%% Define Discomfort Levels (assign a DiscomfortLevel category to each row of a table based on the MeanRating column)
combinedTable.DiscomfortLevel = repmat("Medium", height(combinedTable), 1);
combinedTable.DiscomfortLevel(combinedTable.MeanRating <= 3) = "Low";
combinedTable.DiscomfortLevel(combinedTable.MeanRating >= 5) = "High";

% Display count of each cluster
disp('Cluster counts:');
disp(groupcounts(combinedTable, 'DiscomfortLevel'));

% Extract relevant columns
metric = combinedTable.SumWeightedAmplitudeDistance;
discomfort = combinedTable.MeanRating;
discomfortLevels = combinedTable.DiscomfortLevel;

%% Color Map (Using structure instead of containers.Map)
colors.Low = [0 0.4470 0.7410];    % Blue for Low discomfort
colors.Medium = [0.9290 0.6940 0.1250]; % Yellow for Medium discomfort
colors.High = [0.8500 0.3250 0.0980];   % Red for High discomfort

%% Scatter Plot: Metric vs MeanRating (Color by Discomfort Level)
figure;
hold on;
uniqueLevels = unique(discomfortLevels);
for i = 1:numel(uniqueLevels)
    level = uniqueLevels(i);
    mask = discomfortLevels == level;
    scatter(log(metric(mask)), discomfort(mask), 50, colors.(char(level)), 'filled');
end

xlabel('log(SumWeightedAmplitudeDistance)');
ylabel('Mean Rating (Discomfort Level)');
title('Clustering of Buildings by SumWeightedAmplitudeDistance');
legend(uniqueLevels, 'Location', 'best');
grid on;
hold off;

%% Function: Visualize Distribution of NumPeaks by Discomfort Level
function visualize_numpeaks_distribution(combinedTable, ratingsColumn)
    % Visualize the distribution of NumPeaks for different discomfort levels
    
    % Define discomfort categories
    low_discomfort = combinedTable.(ratingsColumn) < 3;
    medium_discomfort = combinedTable.(ratingsColumn) >= 3 & combinedTable.(ratingsColumn) <= 5;
    high_discomfort = combinedTable.(ratingsColumn) > 5;
    
    % Define colors and labels
    colors = {[0 0 1], [1 0.5 0], [1 0 0]};  % Blue, Orange (RGB), Red
    labels = {'Medium Discomfort', 'High Discomfort','Low Discomfort'};
    
    % Create figure for the distribution of NumPeaks
    figure;
    hold on;
    
    % Plot histograms for each discomfort category (with frequency)
    histogram(combinedTable.SumWeightedAmplitudeDistance(medium_discomfort), 30, 'FaceColor', colors{2}, 'FaceAlpha', 0.6, 'Normalization', 'count');
    histogram(combinedTable.SumWeightedAmplitudeDistance(high_discomfort), 30, 'FaceColor', colors{3}, 'FaceAlpha', 0.6, 'Normalization', 'count');
    histogram(combinedTable.SumWeightedAmplitudeDistance(low_discomfort), 30, 'FaceColor', colors{1}, 'FaceAlpha', 0.6, 'Normalization', 'count');
    
    % Customize plot appearance
    xlabel('SumWeightedAmplitudeDistance');
    ylabel('Frequency');
    title('Frequency of SumWeightedAmplitudeDistance by Discomfort Level');
    legend(labels, 'Location', 'northeast');
    grid on;
    hold off;
end

%% Call the function to visualize the NumPeaks distribution
visualize_numpeaks_distribution(combinedTable, 'MeanRating');
