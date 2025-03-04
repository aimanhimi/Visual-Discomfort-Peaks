% This script processes image ratings from an Excel file from builings0, building1, Becca and Xortia datasets:
% 1. Loads ratings data and filters out excluded subjects.
% 2. Computes mean, median, and standard deviation for each unique image.
% 3. Stores the computed statistics in a table and saves it to a .mat file.

% Parameters: 
%      filename : input dataset data in .xlsx format.
%      output name : returns a ".mat table with the columns: Image | MeanRating | StdRating". Manually change the name of the last line according to the dataset

% Load Excel file
filename = 'ratings/ratings_buildings_combined.xlsx'; % Path to the input Excel file
data = readtable(filename); % Read the data into a table

% Filter out excluded rows (rows where 'excluded' is 1 are removed)
data = data(data.excluded == 0, :);

% Initialize variables to store image statistics
unique_images = unique(data.image); % Identify unique images
num_images = length(unique_images); % Count the number of unique images
median_ratings = nan(num_images, 1); % Preallocate median ratings array
mean_ratings = nan(num_images, 1);   % Preallocate mean ratings array
std_ratings = nan(num_images, 1);    % Preallocate standard deviation array

% Process each unique image and compute statistics
for i = 1:num_images
    img_id = unique_images(i); % Get the current image ID
    
    % Extract ratings for the current image
    img_ratings = data.rating(data.image == img_id);
    
    % If there are valid (non-NaN) ratings, compute statistics
    if ~isempty(img_ratings) && any(~isnan(img_ratings)) 
        mean_ratings(i) = mean(img_ratings, 'omitnan'); % Mean rating
        median_ratings(i) = median(img_ratings, 'omitnan'); % Median rating
        std_ratings(i) = std(img_ratings, 'omitnan'); % Standard deviation
    else
        % If no valid ratings exist, assign NaN values and log the issue
        mean_ratings(i) = NaN;
        median_ratings(i) = NaN;
        std_ratings(i) = NaN;  
        disp("troll %d", i); % Output a message if invalid data is found
    end
end

% Create a table containing the computed statistics for each image
ratingsTable = table(unique_images, mean_ratings, median_ratings, std_ratings, ...
    'VariableNames', {'Image', 'MeanRating', 'MedianRating','StdRating'});

% Display the results in the MATLAB console
disp(ratingsTable);

% Save the results table to a .mat file for future use
save("ratings/ratings_buildings_combined.mat", "ratingsTable");
