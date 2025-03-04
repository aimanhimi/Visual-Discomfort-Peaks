% Script to check the correlation of the MSC aesthetic rating given the metrics table

%% Load metrics table from ResultsTables directory
load("ResultsTables/msc_finalTable_prom_60_thresh_25_window_3.mat"); % Loads `finalTable`

% Rename ImageName column to Image if needed
if any(strcmp(finalTable.Properties.VariableNames, 'ImageName'))
    finalTable.Properties.VariableNames{'ImageName'} = 'Image';
end
finalTable.Image = string(finalTable.Image); % Ensure consistency

%% Load MSC Mu values
muData = readtable("ratings/dataset_msc.csv", 'VariableNamingRule', 'preserve');

% Rename column to match for joining
muData.Properties.VariableNames{'Filename'} = 'Image';
muData.Image = string(muData.Image);

% Convert Mu values (handle decimal commas)
muData.Mu = strrep(muData.Mu, ',', '.');
muData.Mu = str2double(muData.Mu);

%% Join tables on Image
combinedTable = innerjoin(finalTable, muData, 'Keys', 'Image');

% Filter to remove outliers: only keep rows with NumPeaks between 10 and 200
minPeaks = 14;
filteredTable = combinedTable(combinedTable.SumWeightedAmplitudeDistance > 45000, :);

% Extract relevant columns
metric = filteredTable.SumWeightedDistance;
muValues = filteredTable.Mu;

%% Save Filtered Image Names for Second Code
filteredImages = filteredTable.Image;
save("FilteredImages/filtered_msc_images.mat", "filteredImages");

disp("Filtered image names saved in 'filtered_msc_images.mat'.");

%% Pearson Correlation Analysis
[r, p] = corr(metric, muValues, 'Type', 'Pearson');


fprintf('Pearson Correlation Results (Filtered by NumPeaks > %d) Images considered after filter: %d/%d \n', ...
    minPeaks, height(filteredTable), height(finalTable));
fprintf('Correlation coefficient (r): %.4f\n', r);
fprintf('p-value: %.4g\n', p);

%% Scatter Plot: Metric vs Mu
figure;
scatter(log(metric), muValues, 'filled');
xlabel('log(SumWeightedAmplitudeDistance)');
ylabel('Mu (Aesthetic Rating)');
title('SumWeightedAmplitudeDistance vs Mu (MSC Dataset, Peaks)');
grid on;

%% Plot Distribution of Mu Values
figure;
histogram(muValues, 'BinWidth', 0.2, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
xlabel('Mu (Aesthetic Rating)');
ylabel('Frequency');
title('Distribution of Mu Values (Filtered)');

%% Plot Distribution of Metric Values
figure;
histogram(finalTable.NumPeaks, 'BinWidth', max(finalTable.NumPeaks)/30, 'FaceColor', 'red', 'FaceAlpha', 0.7);
xlabel('NumPeaks');
ylabel('Frequency');
title('Distribution of NumPeaks Values (Filtered)');
