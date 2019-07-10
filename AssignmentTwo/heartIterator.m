files = dir('MRIheart/*.png');

area = zeros(length(files), 1);
innerArea = zeros(length(files), 1);
outerArea = zeros(length(files), 1);

theFigure = figure();
for index = 1:length(files)
    scan = imread(strcat('MRIheart/', files(index).name)); 
    segmenter = HeartSegmenter(scan);

    mask = segmenter.getHeartMask();
    [centroid, diameter] = segmenter.getCentroid(mask);
    centreMarked = insertMarker(scan, centroid);

    [insidePath, outsidePath] = segmenter.getOutlines();
    [area(index), innerArea(index), outerArea(index)] = segmenter.getArea(insidePath, outsidePath);
    
    innerMarked = insertMarker(centreMarked, insidePath, '*', 'Color', 'blue', 'Size', 1);
    outerMarked = insertMarker(innerMarked, outsidePath, '*', 'Color', 'green', 'Size', 1);
   
    imshow(outerMarked);
    
%     xlim([150, 400]);
%     ylim([250, 475]);
    title(files(index).name);
    
    waitforbuttonpress;
    
end
close all;

innerArea = conv2(innerArea, [0.5 0.5], 'same');
outerArea = conv2(outerArea, [0.5 0.5], 'same');

figure();
plot(area); hold on;
plot(innerArea);
plot(outerArea);
title('Cross-Sectional Area of Left Ventricle');
legend('Net Area', 'Inner Area', 'Outer Area');
xlabel('Frame Number');
ylabel('Area (pixesls)');