function [processedImage] = blurThresholding(originalImage, blurrerSize)

    if nargin < 2 
        blurrerSize = 60;
    end
    
    blurrerKernel = ones(blurrerSize, blurrerSize) ./ (blurrerSize .^ 2);

    grayImage = rgb2gray(originalImage);
    thresholdAverages = conv2(grayImage, blurrerKernel, 'same');                          
                            
    max(max(grayImage))
    max(max(thresholdAverages))
    
    processedImage = grayImage > thresholdAverages;
    
end