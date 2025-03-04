% geneate a Fourier amplitude "cone" averaging the spectra of many natural
% scenes
clear variables;

% Define the padding size
padSize = 128; % This will mirror the image by 128 pixels on each side

% Define the dataset directory dynamically from the current directory
datasetDir = fullfile(pwd, 'images_buildings_combined');  % Construct path to 'dataset' folder
imageFiles = dir(fullfile(datasetDir, '*.tif'));  % Load all jpg images from the dataset

% % Uncomment to diplay Olivier's average spectra
% -----------------------------------------------------
% load('nat_spec_256.mat');
% [row, col, pla] = size(meanspec);
% % Create a grid of coordinates corresponding to the image pixels
% [X, Y] = meshgrid(1:col, 1:row);
% 
% % Create a 3D surface plot
% h3 = figure; surf(X, Y, log(meanspec), 'EdgeColor', 'none');
% colormap default;
% colorbar;
% xlabel('X'); ylabel('Y');
% zlabel('Log Intensity');
% title('3D Plot of Fourier Spectra: meanspec');
% axis([0 row 0 col])
% % Adjust the view
% view(3);
% -----------------------------------------------------

% targetSize = [512, 512];
targetSize = [256, 256];
paddedSize = targetSize * 2;
meanspec = zeros(targetSize(1),targetSize(2), 3);
meanspec_hann = meanspec;
meanspec_grey = zeros(targetSize(1),targetSize(2), 1);
meanspec_hann_grey = meanspec_grey;

% Create a 2D Hann window
hann1 = hann(paddedSize(1));
hann2 = hann(paddedSize(2));
H = hann1 * hann2';
decod_gamma = 2.2;

% Loop through each image file
for k = 1:length(imageFiles)
    % Construct the full file path
    filePath = fullfile(imageFiles(k).folder, imageFiles(k).name);
    
    % Load the image
    img = imread(filePath); % Deleted double()
    % img = (double(img)./256) .^ (decod_gamma) .* 256; % gamma-decode
    % img = (double(img)) .^ decod_gamma;

    % Get the size of the image
    [rows, cols, pla] = size(img);
    if pla ==1
        img = repmat(img,1,1,3);
    end

    if rows ~= cols
        % crop the image
            smallerSize = min(rows, cols);        
            rowStart = floor((rows - smallerSize) / 2) + 1;
            colStart = floor((cols - smallerSize) / 2) + 1;
            imgCropped = img(rowStart:rowStart + smallerSize - 1, colStart:colStart + smallerSize - 1, :);
            processedImg = imgCropped;
    else
        processedImg = img;
    end

    processedImg = imresize(processedImg, targetSize);      
    % Pad the image using symmetric padding (mirroring)
    processedImg_g = rgb2gray(processedImg);

    %paddedImg = padarray(processedImg, [padSize padSize], 'symmetric');
    paddedImg = padarray(processedImg_g, [padSize padSize], 'symmetric');

    paddedImg_g = double(paddedImg)/double(256) .* H;

    [paddRows, paddCols, ~] = size(paddedImg);
    
%     % Display the original and padded images
%     figure;
%     subplot(1,2,1);
%     imagesc(processedImg/256);
%     title('Original Image');
%     
%     subplot(1,2,2);
%     imagesc(paddedImg/256);
%     title('Padded Image with Mirroring');


    % FTjunk = abs(fftshift(fft2(paddedImg,paddRows,paddCols)));
                  
    rowStart = floor((paddRows - targetSize(1)) / 2) + 1;
    colStart = floor((paddCols - targetSize(2)) / 2) + 1;    
    % meanspec = meanspec + FTjunk(rowStart:rowStart + targetSize(1) - 1, colStart:colStart + targetSize(2) - 1, :);

    FTjunk = abs(fftshift(fft2(paddedImg_g,paddRows,paddCols)));
    meanspec_grey = meanspec_grey + FTjunk(rowStart:rowStart + targetSize(1) - 1, colStart:colStart + targetSize(2) - 1, :);

%     % Apply the Hann window to the image
%     processedImg_h = processedImg .* H;
%     meanspec_hann = meanspec_hann + abs(fftshift(fft2(processedImg_h,targetSize(1),targetSize(2))));
% 
%     processedImg_hg = processedImg_g .* H;
%     meanspec_hann_grey = meanspec_hann_grey + abs(fftshift(fft2(processedImg_hg,targetSize(1),targetSize(2))));

    disp(['processing image ', num2str(k)]);
end

% meanspec = meanspec ./ k;
meanspec_grey = meanspec_grey ./ k;
% meanspec_hann = meanspec_hann ./ k;
% meanspec_hann_grey = meanspec_hann_grey ./k;


[row, col, pla] = size(meanspec_grey);
% Create a grid of coordinates corresponding to the image pixels
[X, Y] = meshgrid(1:col, 1:row);
h3 = figure; 
surf(X, Y, log(meanspec_grey), 'EdgeColor', 'none'); 
colormap default;
colorbar;
xlabel('X'); ylabel('Y');
zlabel('Log Intensity');
title('3D Plot of Fourier Spectra: filtered');
axis([0 row 0 col])
% Adjust the view
view(3);


% save nat_spec_512.mat meanspec meanspec_grey meanspec_hann meanspec_hann_grey;
save nat_spec_256_buildings.mat meanspec_grey % meanspec meanspec_hann meanspec_hann_grey;
