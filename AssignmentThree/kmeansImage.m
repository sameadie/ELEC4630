function [kImage, centroids, indexes] = kmeansImage(image, k)
    [numRows, numCols, three] = size(image);
    r = image(:,:,1);
    g = image(:,:,2);
    b = image(:,:,3);
    x = [r(:) g(:) b(:)];
    
    [classifications, centroids] = kmeans(double(x), k);
    
    indexes = reshape(classifications, numRows, numCols);
    kImage = ind2rgb(indexes, centroids ./ 256);
    
    centroids = uint8(centroids);
    kImage = uint8(kImage .* 256);
end