classdef LineTracker < handle
properties
        theSpiralSearchSize = 100;
        theForecastLength = 5;
        
        theBW;
        theTrack;
        theTrackIndex;
        isTracking;
        theSpiral;
end
    
methods
    function self = LineTracker(bw)
        self.theBW = bw;
        self.theTrackIndex = 0;
        self.isTracking = 0;
        
        %Spiral search
        spir = spiral(self.theSpiralSearchSize);
        [~, idx] = sort(spir(:));
        [spiralRow, spiralCol] = ind2sub([self.theSpiralSearchSize, self.theSpiralSearchSize], idx);
        spiralRow = spiralRow - round(self.theSpiralSearchSize / 2);
        spiralCol = spiralCol - round(self.theSpiralSearchSize / 2);
        self.theSpiral = [spiralRow spiralCol];
    end

    function trackFrom(self, start)
        self.theTrack = [start; self.getFirstPoint(start)];
        self.theTrackIndex = 2;   
        self.isTracking = 1;
        
        self.trackNextPoint();
        while(self.isTracking)
            self.trackNextPoint();
        end
    end

    function [secondPosition] = getFirstPoint(self, start)
        for i = [-1 0 1]
            for j = [-1 0 1]
                if(self.theBW(start(1) + i, start(2) + j) == 0 || ...
                  (i==0 && j == 0))
                    continue;
                end
                secondPosition = start + [i j];
            end
        end   
    end

    function trackNextPoint(self)

        neighbourhood = self.theBW(self.theTrack(self.theTrackIndex, 1)-1:self.theTrack(self.theTrackIndex, 1)+1, ...
                                   self.theTrack(self.theTrackIndex, 2)-1:self.theTrack(self.theTrackIndex, 2)+1);
        if(sum(neighbourhood(:)) <= 2)
            self.isTracking = 0;
        elseif(sum(neighbourhood(:)) == 3)
            self.handleNormalCase();
        else
            if(self.theTrackIndex <= 5)
                self.isTracking = 0;
            else
                self.handleIntersectionCase();
            end
        end
    end

    function handleNormalCase(self)
        currentPos = self.theTrack(self.theTrackIndex, :);
        lastPos = self.theTrack(self.theTrackIndex - 1, :);

        for i = [-1 0 1]
            for j = [-1 0 1]
                if(self.theBW(currentPos(1) + i, currentPos(2) + j) && ... %Dont choose a non-white point
                  (i ~= 0 || j ~= 0) && ...                                %Dont choose centre point - that was the last point
                   sum((lastPos - currentPos - [i j]) ~= [0 0]))           %Dont turn around and choose old point
                        self.theTrack(self.theTrackIndex + 1, :) = currentPos + [i j];
                        self.theTrackIndex = self.theTrackIndex + 1;
                        return
                end
            end
        end        
    end

    function [pointNAhead] = linearForecastN(self, N)
        nPointsAgo = self.theTrack(self.theTrackIndex - N, :);
        diff = self.theTrack(self.theTrackIndex, :) - nPointsAgo;
        pointNAhead = self.theTrack(self.theTrackIndex, :) + diff;
    end
    
    function [pointNAhead] = momentumForecastN(self, N, lookBackM)
        history = self.theTrack(self.theTrackIndex-N-lookBackM+1:self.theTrackIndex - N, :);
        
        diffs = self.theTrack(self.theTrackIndex, :) - history;
        normalisedDiffs = diffs ./ linspace((lookBackM + N)/N, 1, lookBackM)';
        forecasts = self.theTrack(self.theTrackIndex, :) + normalisedDiffs;
        
        adjustedForecasts = forecasts - forecasts(end, :);
        forecastWeights = 1 .^ linspace(lookBackM - 1, 0, lookBackM)';
        weightedForecasts = adjustedForecasts .* forecastWeights;
        
        pointNAhead = round(forecasts(end, :) + mean(weightedForecasts(1:end-1, :)));
    end
    
    function [pointNAhead] = derivativeForecastN(self, backN, filterLength, forwardM)
         history = self.theTrack(self.theTrackIndex-backN:self.theTrackIndex, :);
         dHistory = diff(history);
         filter = ones(filterLength, 1) / filterLength;
         
         smoothdHist = conv2(dHistory, filter, 'valid');
         forecastDeriv = [polyval(polyfit(transpose(1:size(smoothdHist, 1)), smoothdHist(:,1), 1), size(smoothdHist, 1) + 1) ...
                          polyval(polyfit(transpose(1:size(smoothdHist, 1)), smoothdHist(:,2), 1), size(smoothdHist, 1) + 1)];
         
         pointNAhead = round(history(end, :) + (forwardM * forecastDeriv));
    end
    
    
    function handleIntersectionCase(self)
        forecastPos = self.derivativeForecastN(30, 5, 5);

        for index = 1:size(self.theSpiral, 1)
            searchPos = forecastPos + self.theSpiral(index, :);
            if(self.theBW(searchPos(1), searchPos(2)) && ...
               ~sum(ismember(self.theTrack, searchPos, 'rows')))
                    futurePos = searchPos;
                    break
            end
        end

        index = 1;
        for i = [-1 0 1]
            for j = [-1 0 1]
                if(self.theBW(futurePos(1) + i, futurePos(2) + j) && ...   %Dont choose a non-white point
                   (i ~= 0 || j ~= 0))                              %Dont choose centre point
                        possiblePoints(index, :) = futurePos + [i j];
                        index = index + 1;
                end
            end
        end
        self.theTrack(self.theTrackIndex + 1, :) = futurePos;
        self.theTrackIndex = self.theTrackIndex + 1;
        
        [~, furthestIndex] = pdist2(possiblePoints, self.theTrack(self.theTrackIndex - 1, :), 'squaredeuclidean', 'Largest', 1);
        
        self.theTrack(self.theTrackIndex + 1, :) = possiblePoints(furthestIndex, :);
        self.theTrackIndex = self.theTrackIndex + 1;
    end
end
end
