function [indexes, centroids] = bwKmeansImage(image, k)
    [numRows, numCols] = size(image);
    [classifications, centroids] = kmeans(double(image(:)), k);
    
    indexes = reshape(classifications, numRows, numCols) - 1;
    centroids = uint8(centroids);
    
    if(centroids(1) > centroids(2))
        indexes = ~indexes;
    end
end