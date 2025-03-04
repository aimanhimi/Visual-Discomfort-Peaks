function [Resid] = main_discomfort() 
    % [gop 19 02 16: compute measure of non-adherence to the power spectrum of natural
    % images according to Penacchio and Wilkins, Visual discomfort and the spatial
    % distribution of Fourier energy, Vision Research 108 (2015), 1-7]
    % main file: define image folder, output format and computational settings
 
    % ----- address of folder/format of images ----
    origpath = 'datasets/Xortia_luminance';
    ext = '*.png';
    image_folder.where = origpath;  
    image_folder.extension = ext;  
 
    % ----- computation parameters -----
    % type of output (simple matrix or Excel file)
    struct.output = 'excel_file';  % should be 'excel_file' for output in Excel format
    % use weighting ('csf'/'no_csf')
    struct.csf = 'csf';     % 'csf' for applying the weighting, 'no_csf' otherwise
    % anisotropy
    struct.isotropy = 'anisotropic';    % 'isotropic' for an isotropic reference cone, 'anisotropic' otherwise 
    % size of spectrum (sample images and spectrum to size spec_size x spec_size)  
    struct.spec_size = 256; % size of amplitude spectrum
    % from colour image to luminance 
    struct.lum_choice = 'rgb2gray'; % other version are possible
    % channel (luminance or chromatic)
    struct.channel = 'lum';  % only luminance is available
 
    % ----- process images in folder -----
    [Resid, names] = analyse_images(struct, image_folder);
 
    % ----- write residuals on Excel file -----
    if strcmp(struct.output, 'excel_filee')
        % Create a table with names and residuals
        data = table(names', Resid', 'VariableNames', {'ImageNames', 'Residuals'});
        
        % Specify the output file name (modify as needed)
        output_file = fullfile(pwd+"/excel_results", 'buildings_combined.xlsx');  % Use .xlsx for better compatibility

        % Write the table to an Excel file
        writetable(data, output_file);
    end
 
    save('residuals_xortia.mat', 'Resid', 'names', 'struct');
end