classdef VideoProcessor < handle
    properties
        theVideoReader;
        theVideoWriter;
        theCurrentFrame;
        theNextFrame;
        theFrameNumber = 1;
        theNumFrames;
    end
    
    methods
        function self = VideoProcessor(aVideoReader, aVideoWriter)
            self.theVideoReader = aVideoReader;
            self.theVideoWriter = aVideoWriter;
            self.theNumFrames = aVideoReader.Duration * aVideoReader.FrameRate;
            
            if self.hasNext()
                self.theCurrentFrame = self.theVideoReader.readFrame();
            end
        end  
        
        function bool = hasNext(self)
            bool = self.theVideoReader.hasFrame();
        end
        
        function processFrame(self)
            self.theNextFrame = self.theVideoReader.readFrame();
          
            myProcessedFrame = self.processingFunction(self.theCurrentFrame, self.theNextFrame);
            
            self.theVideoWriter.writeVideo(myProcessedFrame);
            self.theCurrentFrame = self.theNextFrame;
            self.theFrameNumber = self.theFrameNumber + 1;
        end
        
        function processVideoToEnd(self)
            while self.hasNext()
                self.processFrame();
            end
        end
    end
    
    methods (Abstract)
        processedFrame = processingFunction(aCurrentFrame, aNextFrame);
    end
end

