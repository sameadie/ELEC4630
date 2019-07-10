function [resultLines] = groupLines(houghLines, attribute, attributeThreshold)     
     groupLines = zeros(length(houghLines), 6);        
    
    for index = 1:length(groupLines)
        groupLines(index,:) = [houghLines(index).point1 houghLines(index).point2 houghLines(index).theta houghLines(index).rho];         
    end
    
    %Sort lines by theta 
    [sortedThetas, sortingIndex] = sort(groupLines(:, attribute), 'ascend');
    sortedLines = groupLines(sortingIndex, :);
    
    %Group close thetas together
    linesProcessed = 0;
    index = 0;
    while(linesProcessed < length(groupLines))
        groupedLines = sortedLines(abs(sortedLines(:, attribute) - sortedLines(linesProcessed + 1, attribute)) < attributeThreshold, :);
        groupedLine = [min([groupedLines(:,1); groupedLines(:,3)]) ...
                                            min([groupedLines(:,2); groupedLines(:,4)]) ...
                                            max([groupedLines(:,1); groupedLines(:,3)]) ...
                                            max([groupedLines(:,2); groupedLines(:,4)])];
        if groupedLines(1, 5) > 0
            groupedLine = [groupedLine(3) groupedLine(2) groupedLine(1) groupedLine(4)];
        end
        index = index + 1;
        resultLines(index,:) = groupedLine;
        linesProcessed = linesProcessed + size(groupedLines, 1);
    end
end