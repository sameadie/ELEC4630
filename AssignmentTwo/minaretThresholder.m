function [BW,maskedRGBImage] = minaretThresholder(RGB)
% Convert RGB image to chosen color space
I = rgb2lab(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 40.183;
channel1Max = 99.829;

% Define thresholds for channel 2 based on histogram settings
channel2Min = -13.270;
channel2Max = 32.516;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 2.835;
channel3Max = 35.441;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
