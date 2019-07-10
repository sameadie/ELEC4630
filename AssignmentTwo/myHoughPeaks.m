function [P]  = myHoughPeaks(hough, numPeaks, proximity)
    P = zeros(numPeaks, 2);
    
    for index = 1:numPeaks
        %Find first peak
        [row, col] = find(hough == max(max(hough)));
        P(index, :) = [row(1) col(1)];
        
        %Set cells in proximity to zero
        distance = round(proximity / 2);
        hough(max(1,row(1)-distance):min(size(hough,1),row(1)+distance), ...
              max(1,col(1)-distance):min(size(hough,2),col(1)+distance)) = 0;
    end
end