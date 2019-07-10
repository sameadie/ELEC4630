function [hough, theta, rho] = myHough(BW)
    [numRows, numCols] = size(BW);

    %Calculate theta, rho ranges
    theta = linspace(-90, 89, 180);
    D = sqrt((numRows - 1)^2 + (numCols - 1)^2); 
    nrho = 2*ceil(D) + 1; 
    rho = linspace(-ceil(D), ceil(D), nrho);
    
    %Initialise discretised hough space
    hough = double(zeros(length(rho), length(theta)));
    
    %Find white pixels in image
    [y, x] = find(BW);
    
    %Transform image to parameter space
    for index = 1:numel(x)
        calculatedRho = int16(x(index) * cos(pi * theta / 180) + y(index) * sin(pi * theta / 180));
        hough = hough + double(transpose(rho) == calculatedRho); 
    end
end