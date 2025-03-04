%% Function to normalize data, compute correlations, and plot:
% This function takes residuals and the proposed peak-based metric, normalizes them,
% and visualizes their relationship. It also calculates Pearson and Spearman
% correlations, displaying the correlation coefficients and p-values.

% Parameters:
% - ResidualsFile: Path to the .mat file containing residuals array ("Resid" variable).
% - FinalTableFile: Path to the .mat file containing the metric table (table with SumWeightedAmplitudeDistance column) ("finalTable").
% - titleText: Title for the generated scatter plot.

function compareAndPlot(ResidualsFile, FinalTableFile, titleText)
    % Load data
    load(ResidualsFile); % Loads residuals array (Resid)
    load(FinalTableFile); % Loads finalTable with .SumWeightedAmplitudeDistance

    % Min-max normalization of the data
    normalizedResiduals = (Resid - min(Resid)) / (max(Resid) - min(Resid));
    normalizedMetric = transpose((finalTable.SumWeightedAmplitudeDistance - min(finalTable.SumWeightedAmplitudeDistance)) / (max(finalTable.SumWeightedAmplitudeDistance) - min(finalTable.SumWeightedAmplitudeDistance)));

    % Scatter plot of normalized metric vs normalized residuals
    figure;
    scatter(normalizedMetric, normalizedResiduals);
    hold on;

    % Plot the line x = y (reference line)
    plot([0, 1], [0, 1], 'r--');
    xlabel('Normalized SumWeightedAmplitudeDistance');
    ylabel('Normalized Residuals');
    title(titleText);
    legend('Data', 'x = y Line');
    hold off;

    % Compute Pearson and Spearman correlations
    [pearsonCorr, pearsonP] = corr(normalizedMetric', normalizedResiduals', 'Type', 'Pearson');
    [spearmanCorr, spearmanP] = corr(normalizedMetric', normalizedResiduals', 'Type', 'Spearman');

    % Display correlation results
    fprintf('%s:\n', titleText);
    fprintf('Pearson Correlation: %.4f (p-value: %.4f)\n', pearsonCorr, pearsonP);
    fprintf('Spearman Correlation: %.4f (p-value: %.4f)\n\n', spearmanCorr, spearmanP);
end

% Call to function
compareAndPlot("Residuals/residuals_buildings.mat", "ResultsTables/buildings_finalTable_prom_95_thresh_19_window_3.mat", 'Buildings: Normalized SumWeightedAmplitudeDistance vs Residuals');

compareAndPlot("Residuals/residuals_msc.mat", "ResultsTables/msc_finalTable_prom_60_thresh_25_window_3.mat", 'MSC: Normalized SumWeightedAmplitudeDistance vs Residuals');

compareAndPlot("Residuals/residuals_becca.mat", "ResultsTables/becca_finalTable_prom_45_thresh_19_window_3", 'Becca: Normalized SumWeightedAmplitudeDistance vs Residuals');

compareAndPlot("Residuals/residuals_xortia.mat", "ResultsTables/xortia_finalTable_prom_45_thresh_19_window_3", 'Xortia: Normalized SumWeightedAmplitudeDistance vs Residuals');
