theFigure = figure();

for carNumber = 1:26
    %Load image
    originalImage = imread(sprintf('numberplates/car%d.jpg', carNumber)); 
    originalImage = imresize(originalImage, 2);
    
    %Preprocessing
    grayImage = rgb2gray(originalImage);
    
    %Thresholding
    binarizedImage = ~imbinarize(grayImage, 0.5); 
    
    %Define components in image and their size
    connectedComponents = bwconncomp(binarizedImage);
    numPixels = cellfun(@numel,connectedComponents.PixelIdxList);
    
    %Remove largest component
    [largestNum, idx] = max(numPixels);
    binarizedImage(connectedComponents.PixelIdxList{idx}) = 0;
    
    %Clear speckles 
    for index = 1:length(connectedComponents.PixelIdxList)
        if(numPixels(index) < 20)
            binarizedImage(connectedComponents.PixelIdxList{index}) = 0;
        end
    end

    %Clear border
    binarizedImage = imclearborder(binarizedImage);   
    
    %Morphologically merge number plate letters into blob
    binarizedImage = imfill(binarizedImage, 'holes');   
    binarizedImage = imclose(binarizedImage, strel('line', 40, 0));
    binarizedImage = imfill(binarizedImage, 'holes');   
    binarizedImage = imopen(binarizedImage, strel('line', 3, 0));
    binarizedImage = imopen(binarizedImage, strel('line', 3, 90));
    
    %Remove objects with incorrect plate dimensions
    minPlateDimRatio = 3;
    maxPlateDimRatio = 8.3;
    
    stats = regionprops('table',binarizedImage, 'MajorAxisLength', ...
                                'MinorAxisLength', 'PixelIdxList');
    componentDimensions = stats.MajorAxisLength ./ stats.MinorAxisLength;
    
    for index = 1:length(componentDimensions)
        if componentDimensions(index) < minPlateDimRatio || ...
           componentDimensions(index) > maxPlateDimRatio
            binarizedImage(stats.PixelIdxList{index}) = 0;
        end
    end
    
    %Redefine components in image and their size
    connectedComponents = bwconncomp(binarizedImage);
    numPixels = cellfun(@numel,connectedComponents.PixelIdxList);
    
    [largestNum, idx] = max(numPixels);
    
    %Remove all but largest component
	for index = 1:length(connectedComponents.PixelIdxList)
        if index ~= idx
            binarizedImage(connectedComponents.PixelIdxList{index}) = 0;
        end
    end
    
    %Outline Convex Hull of number plate
    stats = regionprops('table',binarizedImage, 'ConvexHull');
    
    outline = transpose(cell2mat(stats.ConvexHull));
    outline = reshape(outline, 1, numel(outline));
    labelledImage = insertShape(originalImage, 'line', outline, ...
                                        'LineWidth', 3, 'Color', 'red');
    
    imshow(labelledImage);    
    
    waitforbuttonpress;
    cla(gca);
end

close all;