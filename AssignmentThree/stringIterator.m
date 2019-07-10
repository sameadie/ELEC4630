stringLengths = [13.0 15.5];
ratios = [];
figure();
for stringNum = 1:2
    for fileNum = 1:5
        image = imread(sprintf('string/String%d_%d.jpg', stringNum, fileNum));
        grayImage = rgb2gray(image);        
        bw = ~imbinarize(grayImage, adaptthresh(grayImage, 0.7));
        
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
        
        skeleton = bwskel(boundaryRemoved);
        numPixels = sum(skeleton(:));
        
        ratios = [ratios (numPixels / stringLengths(stringNum))];
        subplot(5,4,(4*(fileNum-1)) + (2*(stringNum-1))+1); imshow(image); title(sprintf('String %d, Image %d', stringNum, fileNum));
        subplot(5,4,(4*(fileNum-1)) + (2*(stringNum-1))+2); imshow(skeleton); title(sprintf('Conversion Factor = %1.3f px/cm' , (numPixels / stringLengths(stringNum)))); 
    end
end

ratios
mean(ratios)
figure();
stringNum = 3;
stringThreeLengths = [];
for fileNum = 1:5
    image = imread(sprintf('string/String%d_%d.jpg', stringNum, fileNum));
    grayImage = rgb2gray(image);
    bw = ~imbinarize(grayImage, adaptthresh(grayImage, 0.7));

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

    skeleton = bwskel(boundaryRemoved);
    numPixels = sum(skeleton(:));

    stringThreeLengths = [stringThreeLengths (numPixels / mean(ratios))];
    
    subplot(2,5, fileNum); imshow(image); title(sprintf('String 3 Image %d', fileNum));
    subplot(2, 5, fileNum + 5); imshow(skeleton); title(sprintf('String Length = %1.3f cm', (numPixels / mean(ratios))));
end

stringThreeLengths
mean(stringThreeLengths)