classdef PantographVideoProcessor < VideoProcessor
    properties (Constant)
        VERTICAL_RANGE = 2:485;
        HORIZONTAL_RANGE = 9:711;
        cropFrame = @(originalFrame) ...
            originalFrame(PantographVideoProcessor.VERTICAL_RANGE, ...
                          PantographVideoProcessor.HORIZONTAL_RANGE,:);
        thresholdFrame = @(aFrame, threshold) ...
            uint8(255 * ~imbinarize(rgb2gray(aFrame), threshold));
        
        TEMPLATE_CHANGE_THRESHOLD = 20;
        templateToLeftEdge = [-86 -327];
        templateToRightEdge = [-86 -101];
    end
    
    properties
        theTemplateImage;
        theLastTemplatePos = [0 0];
        theCarbonBrushes;
        theLeftIntersections;
        theRightIntersections;
        theTouchingIntersections;
    end
    
    methods
        function self = PantographVideoProcessor(aVideoReader, aVideoWriter)
            self@VideoProcessor(aVideoReader, aVideoWriter);
            self.theTemplateImage = imread('pantograph_template.png');
            
            self.theCarbonBrushes = zeros(self.theNumFrames, 4);
            self.theTouchingIntersections = zeros(self.theNumFrames, 1);
        end
        
        function processedFrame = processingFunction(self, aCurrentFrame, aNextFrame)
            aCroppedFrame = PantographVideoProcessor.cropFrame(aCurrentFrame);
            aCroppedNextFrame = PantographVideoProcessor.cropFrame(aNextFrame);
            processedFrame = self.finalApproach(aCroppedFrame, aCroppedNextFrame); 
        end
        
        function markTheSpot = finalApproach(self, aCurrentFrame, aNextFrame)
            %%%% Crossbar detection %%%%
            [carbonBrush, templatePosition] = self.carbonBrushDetection(aCurrentFrame);
            self.theCarbonBrushes(self.theFrameNumber, :) = carbonBrush;
            
            %%%%Mark the crossbar 
            markTheSpot = insertMarker(aCurrentFrame, templatePosition([2, 1]),'Size',3,'Color','red');
            markTheSpot = insertMarker(markTheSpot, carbonBrush([2, 1]),'Size',3,'Color','red');
            markTheSpot = insertMarker(markTheSpot, carbonBrush([4, 3]),'Size',3,'Color','red');
            markTheSpot = insertShape(markTheSpot, 'line', carbonBrush([2, 1, 4, 3]), 'LineWidth',2,'Color','green');
            
            %%%% Define power line search section as above carbon brush 
            verticalSearchSection = 1:carbonBrush(1);
            horizontalSearchSection = (carbonBrush(2):carbonBrush(4));
            searchSectionOffset = [horizontalSearchSection(1) 0];
            aCurrentFrameSearchSection = aCurrentFrame(verticalSearchSection, ...
                                                    horizontalSearchSection,:);
           
            %%%%Create skeleton of powerlines in search section
            linedSearchSection = ~imbinarize(rgb2gray(aCurrentFrameSearchSection), 0.3);
            linedSearchSection = uint8(255 * bwskel(linedSearchSection));
            linedSearchSection = imdilate(linedSearchSection, strel('rectangle', [3 1]));
            
            %%%%Find & plot power lines     
            [houghMatrix, theta, rho] = hough(linedSearchSection);
            
            %%%%Select relevant angles
            lineDeviation = 15;       
            houghMatrix = houghMatrix(:, 90 - lineDeviation:90 + lineDeviation);
            theta = theta(:, 90 - lineDeviation:90 + lineDeviation);
            
            P  = houghpeaks(houghMatrix, 10, 'NHoodSize', [15 15]);
            lines = houghlines(linedSearchSection, theta, rho, P, 'MinLength', 0.5* carbonBrush(1));
            
            %Plot power line
            markTheSpot = plotLines(markTheSpot, lines, searchSectionOffset);
            
            %Find & plot intersection points
            if(length(lines) == 0)
                self.theTouchingIntersections(self.theFrameNumber) = ...
                    self.theTouchingIntersections(self.theFrameNumber - 1);
            elseif length(lines) == 1
                intersections = findIntersection(lines, carbonBrush, searchSectionOffset);
                self.theTouchingIntersections(self.theFrameNumber) = ...
                                        intersections(1) - carbonBrush(2);
            elseif length(lines) >= 2
                [value, index] = max(abs(P(:,2)));
                lines = lines(index);
                intersections = findIntersection(lines, carbonBrush, searchSectionOffset);
                self.theTouchingIntersections(self.theFrameNumber) = ...
                                        intersections(1) - carbonBrush(2);
            end
            
            markTheSpot = insertMarker(markTheSpot, [carbonBrush(2) + ...
                        self.theTouchingIntersections(self.theFrameNumber) ...
                                carbonBrush(1)], 'Size',4,'Color','blue');
        end
        
        function [carbonBrush, templatePosition] = carbonBrushDetection(self, aFrame)
                %Threshold image to outline pantograph
                binarizedFrame = PantographVideoProcessor.thresholdFrame(aFrame, 0.3);

                %Morphological processing
                horizontalStrel = strel('line', 6, 0);
                verticalStrel = strel('line', 12, 90);
                edgedImage = imclose(binarizedFrame, horizontalStrel);
                dilatedEdgeFrame = imdilate(edgedImage, verticalStrel);
                cleanedEdgeImage = imclose(dilatedEdgeFrame, verticalStrel);
                thinnedEdgeImage = imerode(cleanedEdgeImage, verticalStrel);

                %Template matching 
                correlation = xcorr2(thinnedEdgeImage, self.theTemplateImage);
                [row, col] = find(correlation == max(max(correlation)), 1);
                templatePosition = [row(1) col(1)];
                
                %Temporal movement thresholding
                if (sum(self.theLastTemplatePos) == 0) || ...
                        (pdist2(self.theLastTemplatePos, templatePosition) ...
                            < self.TEMPLATE_CHANGE_THRESHOLD)
                    self.theLastTemplatePos = templatePosition;
                else
                    templatePosition = self.theLastTemplatePos; 
                end
                
                %Locate carbon brush relative to template
                carbonBrush = [templatePosition + self.templateToLeftEdge ...
                               templatePosition + self.templateToRightEdge];
            end
    end
    
    methods (Static)        
        function bwImageOutline = morphologicalApproach(aFrame)
            %Threshold image to outline pantograph
            binarizedFrame = PantographVideoProcessor.thresholdFrame(aFrame, 0.3);

            %Morphological processing
            horizontalStrel = strel('line', 6, 0);
            verticalStrel = strel('line', 12, 90);
            edgedImage = imclose(binarizedFrame, horizontalStrel);
            dilatedEdgeFrame = imdilate(edgedImage, verticalStrel);
            cleanedEdgeImage = imclose(dilatedEdgeFrame, verticalStrel);
            bwImageOutline = imerode(cleanedEdgeImage, verticalStrel);
        end
        
        function bwImageOutline = edgeDetectionApproach(aFrame)
            binarizedFrame = PantographVideoProcessor.thresholdFrame(aFrame, 0.3);
            bwImageOutline = edge(binarizedFrame, 'canny');
        end
        
        function bwImageOutline = temporalDiffApproach(aCurrentFrame, aNextFrame)
            frameDifference = imbinarize(rgb2gray(aNextFrame) - ...
                                            rgb2gray(aCurrentFrame), 0.2);
            bwImageOutline = imdilate(frameDifference, strel('line', 3, 0));
        end
    end
end

