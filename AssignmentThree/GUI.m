function GUI
    figHeight = 700;
    figWidth = 700;
    f = figure('Visible','off','Position',[25, 50, figWidth, figHeight]);

    % Image plot
    imageAxes = axes('Units','Pixels','Position',[25,25,figWidth-125,figHeight-50]); 
    image = imread('sesame.tif');
    [bw, endPoints] = lineTrackingPreprocessing(image);
    tracker = LineTracker(bw);
    [endPointRows, endPointCols] = find(endPoints);
    endPoints = [endPointRows endPointCols];
    imageHandle = imshow(image, 'Parent', imageAxes);
    imageHandle.ButtonDownFcn = @imageClickCallback;
    hold on;

    % Reset Button
    resetButtonHandle = uicontrol('Style','pushbutton','String','Reset', ...
                                 'Position',[figWidth-100, figHeight/2, 70,25], ...
                                 'Callback',{@resetButtonCallback});
    align(resetButtonHandle,'Center','None');

    % Make the UI visible.
    f.Visible = 'on';

    function resetButtonCallback(source, eventData)
        disp('Reset Button pressed');
        hold off;
        imageHandle = imshow(image, 'Parent', imageAxes);
        imageHandle.ButtonDownFcn = @imageClickCallback;
        hold on;
    end

    function imageClickCallback(source, eventData)
        disp('Image was clicked');
        clickPoint = get(gca, 'CurrentPoint');
        xy = [clickPoint(1, 2) clickPoint(1,1)];

        [~, closestIndex] = pdist2(endPoints, xy, 'squaredeuclidean', 'Smallest', 1);
        selectedEndPoint = endPoints(closestIndex, :);

        tracker.trackFrom(selectedEndPoint);
        scatter(tracker.theTrack(:,2), tracker.theTrack(:,1), 2, '*');
    end


    function [skeleton, endPoints] = lineTrackingPreprocessing(image)
        quantisedImage = kmeansImage(image, 4);
        grayImage = rgb2gray(quantisedImage);
        bw = imbinarize(grayImage, 0.8);

        linesRemoved = imopen(bw, ones(5));
        lines = linesRemoved ~= bw;

        justLine = zeros(size(lines));
        stats = regionprops('table', lines, 'Area', 'PixelIdxList');
        [~, sortingIndex] = sort(stats.Area, 'descend');
        justLine(stats.PixelIdxList{sortingIndex(1)}) = 1;
        justLine = justLine == 1;

        skeleton = bwskel(justLine);
        endPoints = bwmorph(skeleton, 'endpoints');
    end
end