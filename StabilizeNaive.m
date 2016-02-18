function [] = StabilizeNaive( AVIFilename )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
hVideoSrc = vision.VideoFileReader(AVIFilename, 'ImageColorSpace', 'Intensity');
% 
% imgA = step(hVideoSrc); % Read first frame into imgA
% imgB = step(hVideoSrc); % Read second frame into imgB
% 
% figure; imshowpair(imgA, imgB, 'montage');
% title(['Frame A', repmat(' ',[1 70]), 'Frame B']);
% 
% ptThresh = 0.1;
% pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);
% pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);
% 
% % Display corners found in images A and B.
% figure; imshow(imgA); hold on;
% plot(pointsA);
% title('Corners in A');
% 
% figure; imshow(imgB); hold on;
% plot(pointsB);
% title('Corners in B');
% 
% [featuresA, pointsA] = extractFeatures(imgA, pointsA);
% [featuresB, pointsB] = extractFeatures(imgB, pointsB);
% 
% indexPairs = matchFeatures(featuresA, featuresB);
% pointsA = pointsA(indexPairs(:, 1), :);
% pointsB = pointsB(indexPairs(:, 2), :);
% 
% figure; showMatchedFeatures(imgA, imgB, pointsA, pointsB);
% legend('A', 'B');
% 
% [tform, pointsBm, pointsAm] = estimateGeometricTransform(...
%     pointsB, pointsA, 'affine');
% imgBp = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
% pointsBmp = transformPointsForward(tform, pointsBm.Location);
% 
% 
% figure;
% showMatchedFeatures(imgA, imgBp, pointsAm, pointsBmp);
% legend('A', 'B');
% 
% % Extract scale and rotation part sub-matrix.
% H = tform.T;
% R = H(1:2,1:2);
% % Compute theta from mean of two possible arctangents
% theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
% % Compute scale from mean of two stable mean calculations
% scale = mean(R([1 4])/cos(theta));
% % Translation remains the same:
% translation = H(3, 1:2);
% % Reconstitute new s-R-t transform:
% HsRt = [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)]; ...
%   translation], [0 0 1]'];
% tformsRT = affine2d(HsRt);
% 
% imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
% imgBsRt = imwarp(imgB, tformsRT, 'OutputView', imref2d(size(imgB)));
% 
% figure(2), clf;
% imshowpair(imgBold,imgBsRt,'ColorChannels','red-cyan'), axis image;
% title('Color composite of affine and s-R-t transform outputs');
% 
% 




% Reset the video source to the beginning of the file.
reset(hVideoSrc);

hVPlayer = vision.VideoPlayer; % Create video viewer

% Process all frames in the video
movMean = step(hVideoSrc);
imgB = movMean;
imgBp = imgB;
correctedMean = imgBp;
ii = 0;
Hcumulative = eye(3);
v = VideoWriter('myFirstTryAVI.avi');    open(v);
% figure;

while ~isDone(hVideoSrc) 
    % Read in new frame
    imgA = imgB; % z^-1
    imgAp = imgBp; % z^-1
    imgB = step(hVideoSrc);
    movMean = movMean + imgB;

    % Estimate transform from frame A to frame B, and fit as an s-R-t
    H = cvexEstStabilizationTform(imgA,imgB);
    HsRt = cvexTformToSRT(H);
    Hcumulative = HsRt * Hcumulative;
    imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));

    % Display as color composite with last corrected frame
    step(hVPlayer, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'));
    correctedMean = correctedMean + imgBp;
%     map = colormap('gray');
    theComposite = (imfuse(imgAp,imgBp, 'blend','Scaling','joint'));
%     k = waitforbuttonpress;
    colormap('gray');
%     truesize();
%     frame = im2frame(theComposite);
    writeVideo(v, theComposite);
    
end
close(v);
correctedMean = correctedMean/(ii-2);
movMean = movMean/(ii-2);

% Here you call the release method on the objects to close any open files
% and release memory.
release(hVideoSrc);
release(hVPlayer);

end

