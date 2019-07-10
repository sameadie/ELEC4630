%%%%%%Load Image%%%%%%
image = imread('TajMahal.jpg');
image = imresize(image, 0.5);
imshow(image);

%%%%%%Separate Background and Foreground%%%%%%
grayImage = rgb2gray(image);
imshow(grayImage);

bwImage = imbinarize(grayImage);
imshow(bwImage);

%Remove all but largest component
largestComponent = bwImage;
stats = regionprops('table', bwImage, 'Area', 'PixelIdxList');
[sortedAreas, sortingIndex] = sort(stats.Area, 'descend');

for index = 2:length(sortingIndex)
    largestComponent(stats.PixelIdxList{sortingIndex(index)}) = 0;
end

%Find convex hull 
minaretsMask = bwconvhull(largestComponent);
waterMask = ~minaretsMask;

%Apply Masks
minaretsImage = image .* uint8(repmat(minaretsMask,[1,1,3]));
waterImage = image .* uint8(repmat(waterMask,[1,1,3]));
imshow(minaretsImage);
imshow(waterImage);

%%%%%%Minaret Processing%%%%%%
%Threshold minarets
bwMinaret = minaretThresholder(minaretsImage);
imshow(bwMinaret);

%Remove noise
minarets = bwMinaret;
stats = regionprops('table', minarets, 'Area', 'PixelIdxList');
[sortedAreas, sortingIndex] = sort(stats.Area, 'descend');

for index = 2:length(sortingIndex)
    minarets(stats.PixelIdxList{sortingIndex(index)}) = 0;
end

%Fill Image
filled = imfill(minarets, 'holes');
imshow(filled);

%Close Image
closed = imclose(filled, strel('line', 10, 90));
imshow(closed);

%Erode image
eroded = imerode(closed, strel('line', 10, 90));
imshow(eroded);

%Outline Image
gradient = imgradient(eroded);
imshow(gradient);

%Hough Transform
[H,T,R] = hough(gradient);
H1 = H(:, find(T==70-90):find(T==89-90));
H2 = H(:, find(T==91-90):find(T==110-90));

T1 = T(find(T==70-90):find(T==89-90));
T2 = T(find(T==91-90):find(T==110-90));

P1  = houghpeaks(H1,5, 'Threshold', 0.3*max(H1(:)));
P2  = houghpeaks(H2,5, 'Threshold', 0.3*max(H1(:)));
L1 = houghlines(eroded,T1,R,P1,'FillGap',5,'MinLength', 15);
L2 = houghlines(eroded,T2,R,P2,'FillGap',5,'MinLength', 15);
myLines = [L1 L2];

%Group Hough Lines by rho
groupedLines = groupLines(myLines, 6, 3);

%Select left/right most four lines respectively
[sortedX, sortingIndex] = sort(groupedLines(:,1), 'ascend');
leftLines = groupedLines(sortingIndex(1:4), :); 
rightLines = groupedLines(sortingIndex(size(groupedLines, 1) - 3:size(groupedLines, 1)), :);
minaretLines = [leftLines; rightLines];

plotted = insertShape(image, 'line', minaretLines, 'LineWidth',6,'Color','red');
imshow(plotted);

%Calculate angles
angles = zeros(size(minaretLines, 1), 1);
for index = 1:size(minaretLines, 1)
    angle = atand((minaretLines(index, 4) - minaretLines(index, 2)) ./ ...
                  (minaretLines(index, 3) - minaretLines(index, 1)));
    if(angle >= 0)
        angles(index) = angle;
    else
        angles(index) = angle + 180;
    end
end

angles

%%%%%%Water Feature Processing%%%%%%
% Threshold in LAB domain
bwWater = waterThresholder(waterImage);
imshow(bwWater);

%Denoise image
denoised = bwareaopen(bwWater, 1000);
imshow(denoised);

%Close Image
closed = imclose(denoised, strel('line', 5, 90));
imshow(closed);

%Outline Image
gradient = imgradient(closed);
imshow(gradient);

%Hough Transform
[H,T,R] = hough(gradient);
H1 = H(:, find(T==140-90):find(T==160-90)); %-140 to -160 degrees
H2 = H(:, find(T==93-90):find(T==100-90));  %-93  to -100 degrees
H3 = H(:, find(T==70-90):find(T==80-90));   %-70  to -80  degrees

T1 = T(find(T==140-90):find(T==160-90));
T2 = T(find(T==93-90):find(T==100-90));
T3 = T(find(T==70-90):find(T==80-90));

P1 = houghpeaks(H1,5, 'NHoodSize', [51, 1], 'Threshold', 0.3*max(H1(:)));
P2 = houghpeaks(H2,5, 'NHoodSize', [51, 1], 'Threshold', 0.3*max(H2(:)));
P3 = houghpeaks(H3,5, 'NHoodSize', [51, 1], 'Threshold', 0.3*max(H3(:)));
L1 = houghlines(closed,T1,R,P1,'FillGap',5,'MinLength', 15);
L2 = houghlines(closed,T2,R,P2,'FillGap',5,'MinLength', 15);
L3 = houghlines(closed,T3,R,P3,'FillGap',5,'MinLength', 15);
myLines = [L1 L2 L3];

%Group lines by theta
waterLines = groupLines(myLines, 5, 5);
plotted = insertShape(image, 'line', waterLines, 'LineWidth',6,'Color','red');
imshow(plotted);

%Combined
combinedPlot = insertShape(image, 'line', [minaretLines; waterLines], 'LineWidth', 6, 'Color', 'red');
imshow(combinedPlot);
