easyFiles = dir('HEP-2 segmentation/easy/*.tif');
hardFiles = dir('HEP-2 segmentation/hard/*.tif');
extremeFiles = dir('HEP-2 segmentation/extreme/*.tif');
allFiles = [easyFiles hardFiles extremeFiles];

theFigure = figure();
for file = extremeFiles'
    image = imread(strcat('HEP-2 segmentation/easy/', file.name));
    [indexes, centroids] = bwKmeansImage(image, 2);
    imshowpair(image, indexes);
    
    waitforbuttonpress;
end

close all;
