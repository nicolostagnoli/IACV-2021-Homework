%% ######## G4 Localization ########
clear, close all, clear HX;

%{
im=imread('villa.png');
figure(1), imshow(im);
hold on;
%}

%4 corners of facade 3 taken from original image
ul_image = [280, 486];
dl_image = [201, 1308];
dr_image = [803, 1294];
ur_image = [727, 504];

%ratio between width and height as in original image 
width = 150;
height = 206;

%projected points
dl = [0, 0];
dr = [width, 0];
ul = [0, height];
ur = [width, height];

%find relative pose
H = fitgeotrans([ul; dl; ur; dr], [ul_image; dl_image; ur_image; dr_image], 'projective');
H = H.T.';

%load saved calibration matrix K
K = double(load("savedK.mat").K);

h1 = H(:, 1);
h2 = H(:, 2);
h3 = H(:, 3);
l = 1 / norm(K \ h1);

r1 = (K \ h1) * l;
r2 = (K \ h2) * l;
r3 = cross(r1, r2);

%rotation matrix
R = [r1, r2, r3];

[U, S, V] = svd(R);
R = U * V.';
cameraRotation = R.';
p = K \ (l * h3);

%compute camera position
cameraPosition = -cameraRotation * p;
cameraPosition = cameraPosition / cameraPosition(2) * 1.5;

%compute camera orientation
thetaX = atan2(R(3,2), R(3,3));
thetaY = atan2(-R(3,1), sqrt(R(3,2)^2 + R(3,3)^2));
thetaZ = atan2(R(2,1), R(1,1));

disp("Position: ");
disp(cameraPosition);

disp("Orientation");
%corrections to have sound values for the angles
disp(180 - rad2deg(thetaX)); 
disp(-rad2deg(thetaY));
disp(rad2deg(thetaZ));  

figure
plotCamera('Location', cameraPosition, 'Orientation', R, 'Size', 5);
hold on
pcshow([[ul; dl; ur; dr], zeros(size([ul; dl; ur; dr;], 1), 1)], 'blue', 'VerticalAxisDir', 'up', 'MarkerSize', 120);
xlabel('X');
ylabel('Y');
zlabel('Z');