function GUI
    %Create figure
    figHeight = 700;
    figWidth = 1400;
    f = figure('Visible','off','Position',[25, 50, figWidth, figHeight]);
        
    %Load eigenfaces
    images = [];
    imagesAxes = [];
    subplotNums = [1 2 3 7 8 9];
    for i = 1:6
        hold on;
        [image, map] = imread(sprintf('faces/eig/%da.bmp', i));
        image = rgb2gray(ind2rgb(image, map));
        images = cat(3, images, image);
        imagesAxes = [imagesAxes subplot(2,6,subplotNums(i))];
        imshow(images(:,:,i), [0 max(max(images(:,:,i)))]);
        title(sprintf('Face %d', i));
    end
    hold off;
    
    %Create eigenface recognizer
    recognizer = EigenfaceRecognizer(images);
    
    % Test Image plot
    testImageAxes = subplot(2, 6, [4 5 6 10 11 12]);
    
    %Create menubar
    menubar = uimenu(f, 'Text', 'File');
    newFileMenu = uimenu(menubar, 'Text', 'New File', 'MenuSelectedFcn', @newFileCallback);
    closeMenu = uimenu(menubar, 'Text', 'Exit', 'MenuSelectedFcn', @closeCallback);      
    
    function updateImageClasses(classification)
        for i = 1:6
            axes(imagesAxes(i))
            if i ~= classification 
                imshow(0.25 * images(:,:,i), [0 max(max(images(:,:,i)))]);
                title(sprintf('Face %d', i));
            else
                imshow(images(:,:,i), [0 max(max(images(:,:,i)))]);
                title(sprintf('Face %d', i));
            end
            hold on;
        end
        hold off;
    end

    function newFileCallback(~, ~)
        [file, path] = uigetfile("*.bmp");
        if ~isequal(file, 0)
            [testImage, map] = imread(fullfile(path, file));
            testImage = rgb2gray(ind2rgb(testImage, map));
            
            axes(testImageAxes)
            imshow(testImage, [0 max(testImage(:))]);
            title(sprintf('Test Image: %s', file));
            
            classification = recognizer.recognizeFace(testImage);
            updateImageClasses(classification);
        end
    end

    function closeCallback(~, ~)
        close all
    end
    
    newFileCallback(0, 0);
    
    % Make the UI visible.
    f.Visible = 'on';
end