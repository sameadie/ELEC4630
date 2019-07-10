theFigure = figure();

for stringNum = 1:3
    for photoNum = 1:5
        %Load image
        image = imread(sprintf('string/String%d_%d.jpg', stringNum, photoNum));
        
        %Binarize image with a locally adaptive threshold
        grayImage = rgb2gray(image);
        bw = ~imbinarize(grayImage, adaptthresh(grayImage, 0.70));

        %Remove boundary objects
        boundaryThreshold = 10;
        stats = regionprops('table', bw, 'Centroid', 'PixelIdxList');
        for component = 1:size(stats, 1)
            if(stats.Centroid(component, 1) < boundaryThreshold || stats.Centroid(component, 1) > size(bw, 1) - boundaryThreshold || ...
               stats.Centroid(component, 2) < boundaryThreshold || stats.Centroid(component, 2) > size(bw, 2) - boundaryThreshold)
                    bw(stats.PixelIdxList{component}) = 0;
            end
        end
        
        %Skeletonise string
        skeleton = bwskel(bw);
        
        %Calculate length
        numPixels = sum(skeleton(:));
        cmDistance = numPixels / mean([8; 7.871]);
        
        %Plot result
        subplot(3, 5, 5 * (stringNum - 1) + photoNum);
        imshowpair(image, skeleton, 'montage');
        title(sprintf('String%d_%d.jpg (%d -> %5fcm)', stringNum, photoNum, numPixels, cmDistance), 'Interpreter', 'None');
    end
end