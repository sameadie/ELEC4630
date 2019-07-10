function [silhouette] = createDinoSilhouette(image)
    % Threshold in HSV space
    I = rgb2hsv(image);
    minHSV = 0.792;
    maxHSV = 0.566;
    mask = (I(:,:,1) >= minHSV) | (I(:,:,1) <= maxHSV);
    
    %Select largest component
    silhouette = zeros(size(mask));
    stats = regionprops('table', mask, 'Area', 'PixelIdxList');
    [~, sortingIndex] = sort(stats.Area, 'descend');
    silhouette(stats.PixelIdxList{sortingIndex(1)}) = 1;
end
