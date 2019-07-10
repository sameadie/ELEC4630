classdef EigenfaceRecognizer
    properties
        theFaceVectors;
        theMeanFaceVector;
        theEigens;
        theProjections;
        theDistanceMetric = 'euclidean';
    end
    
    methods
        function self = EigenfaceRecognizer(images)
            %Vectorise face images
            self.theFaceVectors = reshape(images, [], size(images, 3));
            
            %Compute average face
            self.theMeanFaceVector = mean(self.theFaceVectors, 2);

            %Standardise face vectors
            faceDiffVectors = double(self.theFaceVectors) - self.theMeanFaceVector;
            
            %Compute covariance matrix as A*transpose(A)
            C = faceDiffVectors' * faceDiffVectors;
            
            %Compute eigenvectors of covariance
            [eVectors, ~] = eig(C);
            eVectors = faceDiffVectors * eVectors;
            
            %Normalise eigenvectors
            self.theEigens = eVectors ./ vecnorm(eVectors, 2, 1);
            
            %Characterise faces as linear combination of eigenface basis
            %vectors
            self.theProjections = zeros(size(self.theEigens, 2));
            for faceNum = 1:size(images, 3)
                self.theProjections(faceNum, :) = sum(self.theEigens .* faceDiffVectors(:,faceNum));
            end
        end
        
        function classification = recognizeFace(self, face)
            %Vectorise face image
            faceVector = face(:);
    
            %Project normalised face
            faceDiffVector = double(faceVector) - self.theMeanFaceVector;
            projection = sum(self.theEigens .* faceDiffVector);

            %Recognize face as closest projection
            distances  = pdist2(projection, self.theProjections, self.theDistanceMetric);
            [~, classification] = min(distances);
        end
    end
end

