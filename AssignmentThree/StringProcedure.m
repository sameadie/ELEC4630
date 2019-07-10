%Load image
image = imread('string/String3_1.jpg');
grayImage = rgb2gray(image);
bw = ~imbinarize(grayImage, adaptthresh(grayImage, 0.70));

%Remove boundary objects
boundaryThreshold = 10;
boundaryRemoved = bw;

stats = regionprops('table', boundaryRemoved, 'Centroid', 'PixelIdxList');
for component = 1:size(stats, 1)
    if(stats.Centroid(component, 1) < boundaryThreshold || stats.Centroid(component, 1) > size(bw, 1) - boundaryThreshold || ...
       stats.Centroid(component, 2) < boundaryThreshold || stats.Centroid(component, 2) > size(bw, 2) - boundaryThreshold)
            boundaryRemoved(stats.PixelIdxList{component}) = 0;
    end
end

%Skeletonise Image
skeleton = bwskel(boundaryRemoved);

%Enumerate pixel count
numPixels = sum(skeleton(:));

%Convert pixel count to distance 
PIXEL_TO_LENGTH_CONVERSION = 8.0670;
cmDistance = numPixels / PIXEL_TO_LENGTH_CONVERSION;

subplot(2,3,1);imshow(image);title('Original Image');
subplot(2,3,2);imshow(grayImage);title('Grayscale Image');
subplot(2,3,3);imshow(bw);title('Binarized Image');
subplot(2,3,4);imshow(boundaryRemoved);title('Remove Boundary Objects');
subplot(2,3,5);imshow(skeleton);title('Skeletonised Image');
