%% Fourier Peak Analysis for Image Processing
% This script analyzes images by applying Fourier transformation and detecting peaks
% in the frequency domain. It quantifies spectral characteristics through various
% metrics related to peak distribution and prominence.
%
% The script processes a directory of images, calculates FFT for each image,
% detects significant frequency peaks, and computes metrics such as peak count,
% average distance from center, weighted distances, and other spectral properties.
% Results are saved as a MATLAB table for further analysis.
%
% Main Functions:
% --------------
% - visualize_fourier_and_peaks: Visualizes original image, FFT spectrum, and detected peaks
% - count_peaks: Detects peaks and calculates distance metrics in the FFT spectrum
% - analyze_peaks: Processes images and computes peak-related metrics
% - compute_and_save_metrics: Wrapper function that runs the analysis and saves results
%
% Parameters:
% ----------
% - prominencia_umbral: Minimum prominence threshold for peak detection (default: 65)
% - threshold: Distance threshold for "diminishing peak importance" (default: 19)
% - window_size: Size of local neighborhood average amplitude value calculation (default: 3)
%
% Usage:
% ------
% 1. Set the input parameters (prominencia_umbral, threshold, window_size)
% 2. Set the path to your dataset folder containing the images
% 3. Set the output folder for results
% 4. Run the script to process images and generate the metrics table
% 5. Additionally, you can visualize the peaks by uncommenting last line of count peaks function
%
% Output:
% -------
% A MATLAB table (.mat file) containing the following metrics for each image:
% - ImageName: Filename of the processed image
% - NumPeaks: Number of detected peaks in the Fourier spectrum
% - SumDistances: Sum of distances of peaks from the center
% - SumSquaredDistances: Sum of squared distances of peaks from the center
% - AvgDistance: Average distance of peaks from the center
% - AvgSquaredDistance: Average squared distance of peaks from the center
% - SumWeightedDistance: Sum of distances weighted by proximity to threshold
% - RELEVANT: SumWeightedAmplitudeDistance: Sum of distances weighted by peak amplitude and proximity
%
% Example:
% --------
% ```matlab
% % Set parameters
% prominencia_umbral = 45;  
% threshold = 19;           
% window_size = 3;          
%
% % Set paths
% datasetpath = 'datasets/dataset_buildings';
% results_folder = 'ResultsTables';
%
% % Run analysis
% finalTable = compute_and_save_metrics(datasetpath, prominencia_umbral, threshold, window_size, results_folder, '*.tif');
% ```
%
% Notes:
% ------
% - Peaks close to the DC component (center) are excluded using a radius mask
% - Regional maxima are identified using 8-connectivity
% - Peak prominence is calculated as the difference between the peak value and average local neighborhood
%
% Dependencies:
% -------------
% - MATLAB Image Processing Toolbox
% - process_img function (for image preprocessing, not included in this script)

function visualize_fourier_and_peaks(image_path, imFFT, num_peaks, local_maxima)
    % Visualizes the original image, Fourier spectrum, and detected peaks.

    original_img = imread(image_path);
    fig = figure; % Store figure handle
    subplot(1, 3, 1);
    imshow(original_img);
    title('Original Image');

    subplot(1, 3, 2);
    surf(imFFT);
    colormap('jet');
    colorbar;
    title('Fourier Spectrum (Log Scale)');

    subplot(1, 3, 3);
    imagesc(log(imFFT));
    hold on;

    [peak_rows, peak_cols] = find(local_maxima);
    plot(peak_cols, peak_rows, 'r+', 'MarkerSize', 10, 'LineWidth', 1.5);

    colormap('jet');
    colorbar;
    title(['Fourier Spectrum with Peaks (', num2str(num_peaks), ' Peaks)']);
    hold off;

    set(fig, 'Position', [100, 100, 1400, 400]);

    % Pause execution until figure is closed
    waitfor(fig);
end


function [num_picos, avg_distance, sum_distances, sum_squared_distances, avg_squared_distance, sum_weight_dist, sum_ampl_weighted_dist] = count_peaks(imFFT, prominencia_umbral, threshold, window_size, image_path)
    % Detección de picos en el espectro de Fourier y cálculo de la distancia promedio,
    % distancia al cuadrado promedio desde el centro y la métrica ponderada

    spec_size = size(imFFT, 1);
    centerX = floor(spec_size / 2);
    centerY = floor(spec_size / 2);

    radius = 10;  % Cutoff radius para las componentes cerca del DC.

    [X, Y] = meshgrid(1:spec_size, 1:spec_size);
    distances = sqrt((X - centerX).^2 + (Y - centerY).^2);
    mask = distances > radius;  
    
    maskedFFT = imFFT .* mask;
    local_maxima = imregionalmax(maskedFFT, 8); % We check for regional maxima via comparison with the 8 adjacent pixels (3x3 grid around the pixel)
    [peak_rows, peak_cols] = find(local_maxima);  
    
    valid_peaks = false(size(local_maxima));
    sum_distances = 0;
    sum_squared_distances = 0;
    sum_weight_dist= 0;  
    sum_ampl_weighted_dist = 0;
    
    for i = 1:length(peak_rows)
        row = peak_rows(i);
        col = peak_cols(i);
        peak_value = maskedFFT(row, col);
        
        % Calcular el valor promedio en una ventana alrededor del pico
        local_region = maskedFFT(max(1, row-window_size):min(spec_size, row+window_size), ...
                                 max(1, col-window_size):min(spec_size, col+window_size));
        
        avg_valley = mean(local_region(:));  % Promedio en la vecindad del pico
        
        % Calcular la prominencia como diferencia entre el pico y el promedio local
        prominencia = peak_value - avg_valley;
        
        if prominencia > prominencia_umbral
            valid_peaks(row, col) = true;
            distance = distances(row, col);
            sum_distances = sum_distances + distance;
            sum_squared_distances = sum_squared_distances + distance^2;
            
            % Cálculo de la métrica ponderada según la distancia
            if distance < threshold
                weight = 1 - ((threshold - distance) / threshold);  
            else
                weight = 1;  
            end
            sum_weight_dist = sum_weight_dist + weight^2 * distance;
            sum_ampl_weighted_dist = sum_ampl_weighted_dist + peak_value*distance*weight^2;
        end
    end
    
    num_picos = sum(valid_peaks(:));
    
    if num_picos > 0
        avg_distance = sum_distances / num_picos;  
        avg_squared_distance = sum_squared_distances / num_picos;  
    else
        avg_distance = 0;
        avg_squared_distance = 0;
    end
    %visualize_fourier_and_peaks(image_path, imFFT, num_picos, valid_peaks); % uncomment the line to visualize peaks
end


function resultsTable = analyze_peaks(origpath, prominencia_umbral, threshold, window_size, ext)
    % Análisis de imágenes: computa la FFT y cuenta los picos en el espectro
    
    spec_size = 256;  
    imagefiles = dir(fullfile(origpath, ext));
    imagefileslength = length(imagefiles);

    results = cell(imagefileslength, 8);  

    for i = 1:imagefileslength
        disp(['Processing image: ', imagefiles(i, 1).name])
        testpic = fullfile(origpath, imagefiles(i, 1).name);
        im = imread(testpic);

        img = process_img('lum', 'rgb2gray', 256, im);
        imFFT = abs(fftshift(fft2(img, spec_size, spec_size)));  

        [numPeaks, avgDistance, sumDistances, sumSquaredDistances, avgSquaredDistance, SumWeightedDistance, SumWeightedAmplitudeDistance] = ...
            count_peaks(abs(imFFT), prominencia_umbral, threshold, window_size, testpic);
        
        results{i, 1} = imagefiles(i).name;  
        results{i, 2} = numPeaks;    
        results{i, 3} = sumDistances;
        results{i, 4} = sumSquaredDistances;
        results{i, 5} = avgDistance; 
        results{i, 6} = avgSquaredDistance;
        results{i, 7} = SumWeightedDistance;
        results{i, 8} = SumWeightedAmplitudeDistance;
    end

    resultsTable = cell2table(results, ...
        'VariableNames', {'ImageName', 'NumPeaks', 'SumDistances', 'SumSquaredDistances', ...
                          'AvgDistance', 'AvgSquaredDistance', 'SumWeightedDistance', 'SumWeightedAmplitudeDistance'});
end


function finalTable = compute_and_save_metrics(origpath, prominencia_umbral, threshold, window_size, results_folder, ext)
    % Computes peak detection metrics and saves the results as a .mat file

    % Analyze peaks and compute metrics
    finalTable = analyze_peaks(origpath, prominencia_umbral, threshold, window_size, ext);  
    
    % Save results to "TableResults" folder
    filename = sprintf('xortia_finalTable_prom_%d_thresh_%d_window_%d.mat', prominencia_umbral, threshold, window_size);
    filepath = fullfile(results_folder, filename);
    save(filepath, 'finalTable');
    
    disp(['Metrics table saved in: ', filepath]);
end

% Input / Output location
datasetpath = 'datasets/dataset_buildings';
results_folder = 'ResultsTables';
ext = '*.tif';

% Set parameters
prominencia_umbral = 45;  
threshold = 19;           
window_size = 3;          


% Ensure results folder exists
if ~exist(results_folder, 'dir')
    mkdir(results_folder);
end

% Run analysis and save table
finalTable = compute_and_save_metrics(datasetpath, prominencia_umbral, threshold, window_size, results_folder, ext);

disp("Processing complete. Metrics table saved in 'TableResults' folder.");
