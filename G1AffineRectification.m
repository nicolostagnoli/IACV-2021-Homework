%% ######## G1 Rectification ########
clear, close all, clear HX;
FNT_SZ = 15;

img = imread('villa.png');
% converts image's values in double notation
img = im2double(img);
figure; imshow(img);

%load saved lines
parallelLines = load("SavedLinesG1aff.mat").parallelLines;

%compute vanishing points
v1 = cross(parallelLines{1}(1,:), parallelLines{1}(2,:));
v2 = cross(parallelLines{2}(1,:), parallelLines{2}(2,:));

%compute line at infinity
imLinfty = cross(v1, v2);
imLinfty = imLinfty ./ (imLinfty(3));

%homography to recover affine properties
H = [eye(2),zeros(2,1); imLinfty(:)'];
tform = projective2d(H');
J = imwarp(img,tform);

figure;
imshow(J);

imwrite(J,'output/G1HorizontalAffineReconstruction.jpg');


function [l] = segToLine(pts)
% convert the endpoints of a line segment to a line in homogeneous
% coordinates.
%
% pts are the endpoits of the segment: [x1 y1;
%                                       x2 y2]

% convert endpoints to cartesian coordinates
a = [pts(1,:)';1];
b = [pts(2,:)';1];
l = cross(a,b);
l = l./norm(l);
end