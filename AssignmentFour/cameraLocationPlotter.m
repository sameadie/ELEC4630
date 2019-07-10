% Load projection matrices
projectionMatrices = loadProjectionMatrices();

% Get camera locations and directions
cameraLocations = zeros(size(projectionMatrices,3), 3); 
cameraDirections = zeros(size(projectionMatrices,3), 3);
for i = 1:36
    [cameraLocations(i,:), cameraDirections(i,:)] = getCameraLocation(projectionMatrices(:,:,i));
    cameraDirections(i,:) = cameraDirections(i,:) ./ norm(cameraDirections(i,:));
end

quiver3(cameraLocations(:,1), cameraLocations(:,2), -1*cameraLocations(:,3), ...
        cameraDirections(:,1), cameraDirections(:,2), -1*cameraDirections(:,3), ...
        0.5);
    
axis([-2000 2000 -2000 2000 0 1000])