theVideoWriter = VideoWriter('MRIHeartOutline.avi');
theVideoWriter.FrameRate = 5;
theVideoWriter.open();

theCroppedVideoWriter = VideoWriter('MRIHeartOutlineCropped.avi');
theCroppedVideoWriter.FrameRate = 5;
theCroppedVideoWriter.open();

for index = 1:16
    scan = imread(sprintf('MRIheart/MRI1_%02d.png', index));
    
    segmenter = HeartSegmenter(scan);

    mask = segmenter.getHeartMask();
    [centroid, diameter] = segmenter.getCentroid(mask);
    centreMarked = insertMarker(scan, centroid, 'Color', 'red');

    [insidePath, outsidePath] = segmenter.getOutlines();

    innerMarked = insertMarker(centreMarked, insidePath, '*', 'Color', 'blue', 'Size', 1);
    outerMarked = insertMarker(innerMarked, outsidePath, '*', 'Color', 'green', 'Size', 1);
    
    theVideoWriter.writeVideo(outerMarked);
    theCroppedVideoWriter.writeVideo(outerMarked(250:475, 150:400,:));
end

theVideoWriter.close();
theCroppedVideoWriter.close();