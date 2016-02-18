function [ output_args ] = runall( MP4NameIn, MergedFilenameOut )
MP4toAVI( MP4NameIn, 'tempName.avi' );

StabilizeNaive( 'tempName.avi', 'toBeMerged.avi' );

MergeVideo( 'toBeMerged.avi', MergedFilenameOut );


end

