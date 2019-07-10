files = dir('MRIheart/*.png');

xCrop = 250:475;
yCrop = 150:400;
xNum = 4;
yNum = 4;
xSize = length(xCrop);
ySize = length(yCrop);

collage = uint8(zeros(xNum * xSize, yNum * ySize, 3));
for index = 1:length(files)
    scan = imread(strcat('MRIheart/', files(index).name)); 
    segmenter = HeartSegmenter(scan);

    mask = segmenter.getHeartMask();
    [centroid, diameter] = segmenter.getCentroid(mask);
    centreMarked = insertMarker(scan, centroid);

    [insidePath, outsidePath] = segmenter.getOutlines();
    
    innerMarked = insertMarker(centreMarked, insidePath, '*', 'Color', 'blue', 'Size', 1);
    outerMarked = insertMarker(innerMarked, outsidePath, '*', 'Color', 'green', 'Size', 1);
   
    croppedImage = outerMarked(xCrop, yCrop, :);
   
    positions = [(floor((index - 1) / xNum) * xSize) + 1, ...
                 (floor((index - 1) / xNum) + 1) * xSize, ...
                 (mod(index - 1, yNum) * ySize) + 1, ...
                 (mod(index - 1, yNum) + 1) * ySize];
    collage(positions(1):positions(2) , ...
            positions(3):positions(4) , :) = croppedImage;
    imshow(collage);
   
end

imshow(collage);