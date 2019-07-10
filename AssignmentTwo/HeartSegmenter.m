classdef HeartSegmenter    
    properties
        %Constants
        theBinaryThreshold = 0.15;
        theMaxRadius = 100;
        theDefaultThetaSpacing = 0.5;
        theDefaultNumRadii = 200;
        theDefaultInnerLambda = 1.475; %1.95;
        theDefaultOuterLambda = 1.3 % 3.1;
        theDefaultRadiiThreshold = 2;
        theBlurrerSize = 7;
        
        theMinCircularity = 0.7;
        theMaxCircularity = 1.3;
      
        %Additional metrics
        theCircularityCosts;
        theGradientCosts;
        theWeightedCosts;
        theMomentumCosts;
        
        theOriginalScan;
        theScan;
        theGradMags;
        theGradDirs;
        theMaxGradMag;
        
    end
    
    methods
        function self = HeartSegmenter(scan)
            self.theOriginalScan = scan;
            
            kernel = ones(self.theBlurrerSize)./(self.theBlurrerSize.^2);
            self.theScan = uint8(conv2(scan, kernel, 'same'));
            
            [self.theGradMags, self.theGradDirs] = imgradient(scan);
            self.theGradDirs(self.theGradDirs < 0) = self.theGradDirs(self.theGradDirs < 0) + 180;
            self.theMaxGradMag = max(max(self.theGradMags));
        end
        
        function mask = getHeartMask(self)
            mask = imbinarize(self.theScan, self.theBinaryThreshold);
            
            %Threshold on circularity
            stats = regionprops('table', mask, 'PixelIdxList', 'MajorAxisLength', 'EquivDiameter');
            circularity = stats.MajorAxisLength ./ stats.EquivDiameter;

            for index = 1:length(circularity)
                if circularity(index) < self.theMinCircularity || ...
                   circularity(index) > self.theMaxCircularity
                    mask(stats.PixelIdxList{index}) = 0;
                end
            end
            
            %Redefine components in image and their size
            connectedComponents = bwconncomp(mask);
            numPixels = cellfun(@numel,connectedComponents.PixelIdxList);

            [largestNum, idx] = max(numPixels);

            %Remove all but largest component
            for index = 1:length(connectedComponents.PixelIdxList)
                if index ~= idx
                    mask(connectedComponents.PixelIdxList{index}) = 0;
                end
            end
            
            %Convert to conxex hull
            mask = bwconvhull(mask);
        end
        
        function [centroid, diameter] = getCentroid(self, mask)
            stats = regionprops('table', mask, 'centroid', 'EquivDiameter');
            centroid = stats.Centroid;
            diameter = stats.EquivDiameter;
        end
        
        function [radii, thetas, xs, ys] = getPolarCoordinates(self, centroid, numRadii, thetaSpacing)
            if nargin < 4
                thetaSpacing = self.theDefaultThetaSpacing;
            end
            if nargin < 3
                numRadii = self.theDefaultNumRadii;
            end
            
            radii = double(linspace(1, self.theMaxRadius, numRadii));
            thetas = 0:thetaSpacing:359;
            xs = round(centroid(1) + transpose(radii) * cos(pi*thetas/180));
            ys = round(centroid(2) - transpose(radii) * sin(pi*thetas/180));
        end
        
        function [startingRadii] = getStartingRadii(self, xs, ys)
            theStartingMags = self.theGradMags(sub2ind(size(self.theGradMags), ys(:,1), xs(:,1)));
            [peakValues, peakIndexes] = findpeaks(theStartingMags);
            
            [sortedVals, sortedIndex] = sort(peakValues, 'descend');
            sortedPeakIndexes = peakIndexes(sortedIndex);
            
            startingRadii = xs(sortedPeakIndexes(1:2), 1);
        end
        
        function [minCartesianPath, minRadiiPath] = findMinimumPath(self, centroid, startingRadius, lambda, radiiThreshold)
            if nargin < 6
                radiiThreshold = self.theDefaultRadiiThreshold;
            end
            if nargin < 5
                lambda = self.theDefaultLambda;
            end
           
            %Initialise polar coordinate system
            [radii, thetas, xVals, yVals] = self.getPolarCoordinates(centroid);
           
            %Pre-allocate memory for minimum radius path
            minRadiiPath = zeros(length(thetas), 1);
                        
            %Find starting point
            [value, index] = min(abs(xVals(:,1) - startingRadius));
            minRadiiPath(1) = index;

            %Preallocate memory for metric tracking
            self.theCircularityCosts = zeros(length(thetas), 1);
            self.theGradientCosts = zeros(length(thetas), 1);
            self.theWeightedCosts = zeros(length(thetas), 1);
            self.theMomentumCosts = zeros(length(thetas), 1);
            
            minRadiiPath(2) = minRadiiPath(1);
            %Traverse around
            for t = 3:length(thetas)
                %Calculate costs
                circularityCost = transpose(abs(radii - mean(radii(minRadiiPath(1:t-1))))) / max(radii);
                momentumCost = transpose(abs(2.*radii - radii(minRadiiPath(t-1)) - radii(minRadiiPath(t-2)))) / max(radii);
                gradientCost = self.theGradMags(sub2ind(size(self.theGradMags), yVals(:,t), xVals(:, t))) ./ self.theMaxGradMag;
                weightedCost = lambda.*(momentumCost + (t / length(thetas) .* circularityCost)) + (1 - gradientCost);
                
                %Choose minimum cost radii
                [value, index] = min(weightedCost(max(minRadiiPath(t-1) - radiiThreshold, 1): ...
                                                  min(minRadiiPath(t-1) + radiiThreshold, length(radii))));
                index = index(1);
                minRadiiPath(t) = minRadiiPath(t-1) - radiiThreshold + index - 1;
                minRadiiPath(t) = min(max(minRadiiPath(t), 1), length(radii));
                
                %Record metrics
                self.theCircularityCosts(t-1) = circularityCost(index);
                self.theMomentumCosts(t-1) = momentumCost(index);
                self.theGradientCosts(t-1) = gradientCost(index);
                self.theWeightedCosts(t-1) = weightedCost(index);
            end
            
            %Convert polar to cartesian
            minCartesianPath = [xVals(sub2ind(size(xVals), minRadiiPath, transpose(1:length(thetas)))) ...
                                yVals(sub2ind(size(yVals), minRadiiPath, transpose(1:length(thetas))))];
        end
        
        function [innerPath, outerPath] = getOutlines(self, innerLambda, outerLambda, radiiThreshold)
            if nargin < 4
                radiiThreshold = self.theDefaultRadiiThreshold;
            end
            if nargin < 3
                outerLambda = self.theDefaultOuterLambda;
            end
            if nargin < 2
                innerLambda = self.theDefaultInnerLambda;
            end
            
            %Initial Segmentation
            mask = self.getHeartMask();
            
            %Find Centroid
            [centroid, diameter] = self.getCentroid(mask);
            
            %Establish Polar Coordinates
            [radii, thetas, xs, ys] = self.getPolarCoordinates(centroid);
            
            %Find starting points
            startingRadii = self.getStartingRadii(xs, ys);
            innerRadius = min(startingRadii);
            outerRadius = max(startingRadii) - 5;
            
            %Minimum Cost Traversal
            [innerPath, innerRadii] = self.findMinimumPath(centroid, innerRadius, innerLambda, radiiThreshold);
            [outerPath, outerRadii] = self.findMinimumPath(centroid, outerRadius, outerLambda, radiiThreshold);
        end
        
        function [area, innerArea, outerArea] = getArea(self, innerPath, outerPath)
            [innerBoundary, innerArea] = boundary(innerPath);
            [outerBoundary, outerArea] = boundary(outerPath);
            area = outerArea - innerArea;
        end
    end
end

