% Load stereo parameters
%load stereoParams
load('handshakeStereoParams.mat');

% Load and read stereo images
LeftCam = imread('1.jpg');
RightCam = imread('3.jpg');
%LeftCam = imrotate(LeftCam, -90);
%RightCam = imrotate(RightCam, -90);

% Display the images before rectification
subplot(2,1,1);
imshowpair(LeftCam, RightCam);
title('Unrectified Original Images');


% Rectifing the original  
[RecLeft, RecRight] = rectifyStereoImages(LeftCam, RightCam, stereoParams);

% Display the images after rectification
subplot(2,1,2);
imshowpair(RecLeft, RecRight);
title('Rectified Images')


% RGB to GrayScale conversion
LeftG = rgb2gray(RecLeft);
RightG = rgb2gray(RecRight);

% Disparity map generate
disparityMap = disparity(LeftG, RightG);

% Visualize the disparity map
figure, 
imshow(disparityMap);
title('Disparity Map');

% Make adjustments
figure, 
imshow(disparityMap, [0, 63]);
title('Disparity Map with Rectified Images');

% Changing the color map to add colors
colormap(gca, jet)

% Add colorbar to get some perspective
colorbar

figure, 
title('Disparity Map with Color');

% Generate point cloud
points3D = reconstructScene(disparityMap, stereoParams);

% Display point cloud
pcshow(points3D);
xlabel('x'); ylabel('y'); zlabel('z');

% Convert to meters and create a pointCloud object
points3D = points3D ./ 1000;
ptCloud = pointCloud(points3D, 'Color', RecLeft);

% Display point cloud
pcshow(ptCloud);
xlabel('x'); ylabel('y'); zlabel('z');

% Create a streaming point cloud viewer
player3D = pcplayer([-2, 2], [-2, 2], [0, 8.5], 'VerticalAxis', 'y', 'VerticalAxisDir', 'down');


% Visualize the point cloud
view(player3D, ptCloud);
