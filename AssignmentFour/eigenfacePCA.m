%Load eigenfaces
eigenImages = [];

for i = 1:6
    [image, map] = imread(sprintf('faces/eig/%da.bmp', i));
    image = rgb2gray(ind2rgb(image, map));
    eigenImages = cat(3, eigenImages, image);
end
    
%Create eigenface recognizer
recognizer = EigenfaceRecognizer(eigenImages);

%Project images onto two axes using PCA
basisVectors = recognizer.theEigens(:,1:2);

figure();
hold on;
colours = ['r', 'g', 'b', 'y', 'o', 'c'];
projections = [];
for i = 1:6
    groupProjection = [];
    files = dir(sprintf('faces/%d/*.bmp', i));
    for j = 1:length(files)
        [image, map] = imread(sprintf('faces/%d/%s', i, files(j).name));
        image = rgb2gray(ind2rgb(image, map));
        faceVector = image(:);
        faceVector = faceVector - recognizer.theMeanFaceVector;
        groupProjection = [groupProjection basisVectors' * faceVector];
    end
    scatter(groupProjection(1,:), groupProjection(2,:), 52, colours(i), 'DisplayName', sprintf('Face %d', i));
end

legend;
xlabel('Principal Component 1');
ylabel('Principal Component 2');
hold off;