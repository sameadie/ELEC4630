figure();

%Load the images
difficulty = 'easy';
fileName = 'hi';
image = imread(sprintf('HEP-2 segmentation/%s/%s_FITC.tif', difficulty, fileName));
comparisonImage = imread(sprintf('HEP-2 segmentation/%s/%s_Mask.tif', difficulty, fileName));
subplot(3,2,1); imshow(image); title('Original Image');
subplot(3,2,2); imshow(comparisonImage); title('Comparison Image');

%Perform 1D k-means clustering
[indexes, centroids] = bwKmeansImage(image, 2);
subplot(3,2,3); imshow(indexes); title('K-means clustering');

%Evaluate intermediary performance
kmeansDifference = xor(indexes, comparisonImage == 255);
kmeansError = 100 * sum(kmeansDifference(:)) / (size(kmeansDifference, 1) * size(kmeansDifference, 2))
subplot(3,2,4); imshowpair(indexes, comparisonImage); title('K-means comparison');

%Fill cells
filled = imfill(indexes, 'holes');
subplot(3,2,5); imshow(filled); title('Filled image');

%Evaluate final performance
filledDifference = xor(filled, comparisonImage == 255);
filledError = 100 * sum(filledDifference(:)) / (size(filledDifference, 1) * size(filledDifference, 2))
subplot(3,2,6); imshowpair(filled, comparisonImage); title('Filled image comparison');