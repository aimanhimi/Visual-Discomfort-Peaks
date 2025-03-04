function [Resid,names] = analyse_images(struct,image_folder)
% [gop 19 02 16: get images, get cone, fit cone with or without csf weigthing]

% ----- construct reference 1 over f cone/load anisotropic cone -----
spec_size = struct.spec_size; % size of the spectrum
bnd_inf = 1; % see below for components around DC
bnd_sup = spec_size/2;
[xf,yf] = meshgrid((-spec_size/2+1:spec_size/2),(-spec_size/2+1:spec_size/2));
ff = sqrt(xf.^2+yf.^2); % spatial frequencies involved in the Fourier domain
I = find(ff<bnd_inf);   % get_rid of DC and high frequencies
J = find(ff>bnd_sup);
if strcmp(struct.isotropy,'isotropic')
    cone = 1./ff;
    cone(cone == Inf) = 0; % figure,surf(log(cone))
elseif strcmp(struct.isotropy,'anisotropic')
    % here we use a more realistic amplitude spectrum
    load('nat_spec_256.mat');
    cone = meanspec_grey;
    cone(cone == max(cone(:))) = 0; % figure,surf(log(cone))
end

% ----- get images from folder -----
origpath = image_folder.where;
ext = image_folder.extension;
imagefiles = dir(fullfile(origpath,ext));
imagefileslength = length(imagefiles);

% ----- build name list for Excel output -----
names = cell(1,imagefileslength);
for i = 1:imagefileslength
    names{i} = imagefiles(i,1).name;
end

% ----- process images -----
% pre-allocate output
Resid = zeros(1,imagefileslength);
for i = 1:imagefileslength
    % ----- get image i -----
    display(['Processing image ' imagefiles(i,1).name])
    testpic= fullfile(origpath,imagefiles(i,1).name);
    im = double(imread(testpic));
    % get the image in the right format (size,luminance/color)
    img = hget_image(struct.channel,struct.lum_choice,spec_size,im);
    roundHeight = spec_size; roundWidth = spec_size;
    imFFT = abs(fftshift(fft2(img,roundHeight,roundWidth)));
    % remove DC
    imFFT(spec_size/2+1,spec_size/2+1) = 0; % spec_size is always an even number
    % remove small frequencies (see below as well)
    imFFT(I) = 0; cone(I) = 0;
    % and high frequencies
    imFFT(J) = 0; cone(J) = 0;
    % ----- weigh/don't weigh residuals -----
    % new parameter a to adjust the conversion to cpd to the original
    % size of the image
    a = 1;
    % csf according to Mannos and Sakrison 1974 (ieee 20(4), 525-536)
    weight = 2.6*(0.0192+0.114*convert2cpd(ff/a)).*exp(-(0.114*convert2cpd(ff/a)).^1.1);
    weight = weight/max(weight(:)); % normalise
    weight(ff<5) = 0;               % get rid of 4 components around DC
    if strcmp(struct.csf,'no_csf')
        weight(weight>0) = 1; % equalise all weights (ie, get rid of weigthing...)
    end
    % ----- compute residual for image i -----
    Resid(i) = hlogopt_v11_2D(cone,weight,imFFT);
end

end