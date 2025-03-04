function [im] = process_img(channel, lum_choice, spec_size, im)
% This function preprocesses an input image by performing the following steps:
% 1. Ensures the image is square by cropping to the central square if needed.
% 2. Resizes the image to a specified size ('spec_size').
% 3. Converts the image to grayscale if it is RGB and normalizes pixel values to the [0,1] range.
% 4. Applies a custom 2D Hann window for reducing edge effects (personalized_hann).

    % Get image dimensions (rows = height, cols = width)
    [rows, cols, ~] = size(im);

    % Step 1: Crop to a central square if the image is not already square
    if rows ~= cols
        % Find the smaller dimension to define the square size
        smallerSize = min(rows, cols);
        
        % Calculate starting points to crop the central square
        rowStart = floor((rows - smallerSize) / 2) + 1;
        colStart = floor((cols - smallerSize) / 2) + 1;
        
        % Crop the image to the central square region
        im = im(rowStart:rowStart + smallerSize - 1, colStart:colStart + smallerSize - 1, :);
    end

    % Step 2: Resize the image to the target size (spec_size x spec_size)
    im = imresize(im, [spec_size, spec_size]);

    % Step 3: Normalize pixel values to [0,1] and convert to grayscale if RGB
    if size(im,3) == 3
        % If the image is RGB, convert it to grayscale after normalization
        im = rgb2gray(im2double(im));
    else
        % If not RGB, simply normalize the image
        im = im2double(im);
    end

    % Step 4: Apply a personalized 2D Hann window to the image
    % This reduces edge artifacts when applying the Fourier transform
    hann1 = personalized_hann(spec_size, 0.0175); % '0.0175' controls the window's shape (adjust if necessary)
    H = hann1 * hann1'; % Create a 2D Hann window by multiplying 1D windows
    im = double(im) .* H; % Apply the Hann window to the image


% The preprocessed image is now ready for further analysis or feature extraction.

end
