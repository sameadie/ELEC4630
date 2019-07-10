theVideoFilename = 'Eric_Video';
theVideoAnnotation = '_labelled';
theVideoFiletype = '.avi';

theVideoReader = VideoReader(strcat(theVideoFilename, theVideoFiletype));
theVideoWriter = VideoWriter(strcat(theVideoFilename, theVideoAnnotation, theVideoFiletype));

open(theVideoWriter);

theVideoProcessor = PantographVideoProcessor(theVideoReader, theVideoWriter);
theVideoProcessor.processVideoToEnd();

close(theVideoWriter);  

plot(theVideoProcessor.theTouchingIntersections);
title("Pantograph Video Processing");
xlabel("Frame Number");
ylabel("Powerline position on carbon brush");