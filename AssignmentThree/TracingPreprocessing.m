%Load image
image = imread('sesame.tif');

%Image quantisation using K-means
quantisedImage = kmeansImage(image, 4);

%Conversion to grayscale
grayImage = rgb2gray(quantisedImage);

%Binarisation
bw = imbinarize(grayImage, 0.8);

%Morphological removing line
linesRemoved = imopen(bw, strel('diamond', 3));

%Difference gives back line
lines = linesRemoved ~= bw;

%Remove noise
justLine = zeros(size(lines));
stats = regionprops('table', lines, 'Area', 'PixelIdxList');
[sortedComponentAreas, sortingIndex] = sort(stats.Area, 'descend');
justLine(stats.PixelIdxList{sortingIndex(1)}) = 1;
justLine = justLine == 1;

%Skeletonisation
skeleton = bwskel(justLine);

subplot(4,2,1); imshow(image); title('Original Image');
subplot(4,2,2); imshow(quantisedImage); title('K-means quantisation');
subplot(4,2,3); imshow(grayImage); title('Grayscale Image');
subplot(4,2,4); imshow(bw); title('Binarised Image');
subplot(4,2,5); imshow(linesRemoved); title('Morphological Removal of Line');
subplot(4,2,6); imshow(lines); title('Removed Components');
subplot(4,2,7); imshow(justLine); title('Removing Noise');
subplot(4,2,8); imshow(skeleton); title('Skeletonisation');
