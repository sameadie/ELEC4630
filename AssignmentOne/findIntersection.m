function [intersects] = findIntersection(lines, carbonBrush, offset)
if nargin < 3
    offset = [0 0];
end

carbonBrushY = mean(carbonBrush([1, 3]));

intersects = zeros(length(lines), 2);
    for i = 1:length(lines)
        pointA = lines(i).point1;
        pointB = lines(i).point2;

        %Creates a x = my + c model for the line
        linePoly = polyfit([pointA(2) pointB(2)], [pointA(1) pointB(1)], 1);

        intersects(i,:) = [polyval(linePoly, carbonBrushY) carbonBrushY] + offset;
    end
end

