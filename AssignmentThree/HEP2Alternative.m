%Load the image
difficulty = 'easy';
fileName = 'hi';
image = imread(sprintf('HEP-2 segmentation/%s/%s_FITC.tif', difficulty, fileName));
comparisonImage = imread(sprintf('HEP-2 segmentation/%s/%s_Mask.tif', difficulty, fileName));
figure();
subplot(2,2,1); imshow(image); title('Original Image');

%Create grayscale histogram
subplot(2,2,2); histogram(image(:)); title('Grey Scale Histogram');
[N,edges] = histcounts(image(:));

%Find two highest peaks
[values,locs] = findpeaks(N);
[sortedValues, sortingIndex] = sort(values, 'descend');
sortedLocs = locs(sortingIndex);
topTwo = sortedLocs(1:2);

%Find minimum value between peaks
[minValue, minLocation] = min(N(min(topTwo):max(topTwo)));
minIndex = min(topTwo) + minLocation;
threshold = edges(minIndex);
peaks = edges(topTwo);

hold on; plot(peaks, N(topTwo), 'r*', 'MarkerSize', 18); plot(threshold, N(minIndex), 'g*', 'MarkerSize', 18); hold off;

%Binarize Image
histSegmented = image > threshold;
subplot(2,2,3); imshow(histSegmented); title('Thresholded Image');

%Compute performance metrics and comparison
histDifference = xor(histSegmented, comparisonImage == 255);
errorPercentage = 100 * sum(histDifference(:)) / (size(histDifference, 1) * size(histDifference, 2));
subplot(2,2,4); imshowpair(histSegmented, comparisonImage); title(sprintf('Comparison Image: Error = %1.3f%%', errorPercentage));