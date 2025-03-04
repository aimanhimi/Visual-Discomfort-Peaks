function [im] = hget_image(channel,lum_choice,spec_size,im)
% put image in the desired format

imsize1 = size(im);
height = (imsize1(1));
width = (imsize1(2));
if height>width % adjust image size
    im = imresize((im),[round(height/width*spec_size),spec_size],'nearest');
else 
    im = imresize((im),[spec_size,round(width/height*spec_size)],'nearest');
end

% pick out central pixels
imsize2 = size(im);
vmarg = ((imsize2(1)-spec_size)/2);
hmarg = ((imsize2(2)-spec_size)/2);
limit1 = round(1+vmarg);
limit2 = limit1+spec_size-1;
limit3 = round(1+hmarg);
limit4 = limit3+spec_size-1;
im = im(limit1:limit2,limit3:limit4,:);

% anti-gamma correction?
% alphaR=;
% alphaG=;
% alphaB=;
% im(:,:,1)=im(:,:,1).^alphaR;
% im(:,:,2)=im(:,:,2).^alphaG;
% im(:,:,3)=im(:,:,3).^alphaB;

% normalization?
% imagemean=mean(im(:));
% imageSD=std(im(:));
% im=(im-imagemean)./imageSD;
% im=im.*25;
% im=im+256;

% added gop 17 06 2013 for .TIF images with four channels
if size(im,3) == 4
    im = im(:,:,1:3);
end

% channel
if strcmp(channel,'lum') && size(im,3) > 1
    if strcmp(lum_choice,'sum') % rough version
        imtemp = im(:,:,1)+im(:,:,2)+im(:,:,3);
        % output
        im = imtemp./3;
    elseif strcmp(lum_choice,'rgb2gray') % Matlab version (standard, by default)
        im = double(rgb2gray(uint8(im)));
    elseif strcmp(lum_choice,'new_rgb2gray') % Arnold and me, from calibration
        % should be adapted for different calibrations
        im = (255/37.6)*(1.8474*exp(0.0076*im(:,:,1))+...
            2.022*exp(0.0087*im(:,:,2))+...
            1.8646*exp(0.0047*im(:,:,3)));
    end
elseif strcmp(channel,'all')
    imtemp(:,:,1) = im(:,:,1)+im(:,:,2)+im(:,:,3); % or any solution above
    % red-green
    imtemp(:,:,2) = im(:,:,1)-im(:,:,2);
    % blue-yellow
    imtemp(:,:,3) = imtemp(:,:,2)-im(:,:,3);
    % output
    im = imtemp./3;
end

end