function y=convert2cpd(x)
% 23 7 12
% convert frequencies (in pixels) into cycles per degree
% x is in cycles per image

% compute psi, the angle the image subtenses
screen_height = 40; 
viewing_distance = 90; 
psi = 2*atand((screen_height/2)/viewing_distance);
y=x./psi;
end