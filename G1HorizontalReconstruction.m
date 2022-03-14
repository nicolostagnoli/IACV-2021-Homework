%% ######## G1 Rectification ########
close all;
clear;
clc;

%open image with recovered affine properties
imgAffRect = imread('affineRectHorizontalCrop.jpg');

figure;
imshow(imgAffRect);

%scaling matrix
[rows, columns, numberOfColorChannels] = size(imgAffRect);
Hs = [1/rows 0 0
      0 1/columns 0
      0 0 1];

%load saved lines
lines = load("savedLinesG1Metric.mat").lines;

j = lines{1};
k = lines{2};
z = lines{3};
t = lines{4};

syms a b;
C = [a b 0; b 1 0; 0 0 0];

%see report for this equations
eqn1 = sym(j.' * C * k == 0);
eqn2 = sym(t.' * C * z == cosd(75.6) * sqrt(t.' * C * t * z.' * C * z));

[aS, bS] = vpasolve([eqn1, eqn2], [a, b]);
C = [aS bS 0; bS 1 0; 0 0 0];
C = double(C);

%find matrix using svd
[U,D,V] = svd(C);
A = U*sqrt(D)*V';
H = eye(3);
H(1,1) = A(1,1);
H(1,2) = A(1,2);
H(2,1) = A(2,1);
H(2,2) = A(2,2);

Hrect = inv(H);

tform = projective2d(Hrect);
J = imwarp(imgAffRect,tform);
figure;
imshow(J);
imwrite(J, "output/G1HorizontalMetricReconstruction.png");


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