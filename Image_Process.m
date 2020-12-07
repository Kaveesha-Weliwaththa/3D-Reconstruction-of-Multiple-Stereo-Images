% Input stereo images
Left = imread('1.jpg');
Right = imread('3.jpg');

% Display Images
figure, imshowpair(Left, Right, 'montage'); 
title('Original Images');

% Convert images to grayscale
LeftG = rgb2gray(Left);
RightG = rgb2gray(Right);

% Display Images
figure,imshowpair(LeftG, RightG, 'montage');
title('Grayscaled Images');

% Load precomputed camera parameters
load upToScaleReconstructionCameraParameters.mat

% Remove Lens Distortion
%LeftG = undistortImage(Left, cameraParams);
%RightG = undistortImage(Right, cameraParams);
%figure, imshowpair(LeftG, RightG, 'montage');
%title('Undistorted Images');

% Find corresponding points between two images
% Detect feature points
imagePointsL = detectMinEigenFeatures(rgb2gray(Left), 'MinQuality', 0.1);


% Visualize detected points
figure, imshow(LeftG, 'InitialMagnification', 50);
title('300 Strongest Corners from the Left Image');
hold on
plot(selectStrongest(imagePointsL, 300));

%imagePointsR = detectMinEigenFeatures(rgb2gray(Right), 'MinQuality', 0.1);
%figure, imshow(RightG, 'InitialMagnification', 50);
%title('300 Strongest Corners from the Right Image');
%hold on
%plot(selectStrongest(imagePointsL, 300));

% Create the point tracker
tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);

% Initialize the point tracker
imagePointsL = imagePointsL.Location;
initialize(tracker, imagePointsL, LeftG);

% Track the points
[imagePointsR, validIdx] = step(tracker, RightG);
matchedPointsL = imagePointsL(validIdx, :);
matchedPointsR = imagePointsR(validIdx, :);

% Visualize correspondences
figure
showMatchedFeatures(LeftG, RightG, matchedPointsL, matchedPointsR);
title('Tracked Features');

% Estimate the fundamental matrix
[fMatrix, epipolarInliers] = estimateFundamentalMatrix(matchedPointsL, matchedPointsR, 'Method', 'MSAC', 'NumTrials', 10000);

% Find epipolar inliers
inlierPointsL = matchedPointsL;
inlierPointsR = matchedPointsR;

% Display inlier matches
figure
showMatchedFeatures(LeftG, RightG, inlierPointsL, inlierPointsR);
title('Epipolar Inliers');
