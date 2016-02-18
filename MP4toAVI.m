function [success] = MP4toAVI( filename_in, filename_out )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

reader = VideoReader( filename_in );
writer = VideoWriter( filename_out, 'Uncompressed AVI' );

writer.FrameRate = reader.FrameRate;
open(writer);

while hasFrame(reader)
    img = readFrame(reader);
    writeVideo(writer,img);
end

close(writer);

end

