function [] = MergeVideo( inputFilename, outputFilename )

vid1 = vision.VideoFileReader( inputFilename );
vid2 = vision.VideoFileReader( outputFilename );

v = VideoWriter('sideBySide.avi');
open(v);

while ~isDone(vid2)
    imgA = step(vid1);
    imgB = step(vid2);
    
    imshowpair(imgA,imgB,'montage');
    frame = getframe;
    writeVideo(v, frame);
end

close(v);

end

