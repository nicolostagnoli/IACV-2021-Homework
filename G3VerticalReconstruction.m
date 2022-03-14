%% ######## G3 Vertical Rectification ########
clear, close all, clear HX;
FNT_SZ = 15;

img = imread('villa.png');
% converts image's values in double notation
img = im2double(img);
figure; imshow(img);
[rows, columns, numberOfColorChannels] = size(img);
Hs = [1/rows    0       0
      0         1/rows  0
      0         0       1];

%load saved lines
parallelLines = load('savedLinesG3.mat').parallelLines;

%compute vanishing points
v1 = cross(parallelLines{1}(1,:), parallelLines{1}(2,:));
v2 = cross(parallelLines{2}(1,:), parallelLines{2}(2,:));
v1 = v1 * Hs;
v2 = v2 * Hs;

imLinf = cross(v1, v2);
imLinf = imLinf./(imLinf(3));

%load saved image of absolute conic
w = load("IAC.mat").w;
a = w(1, 1);
b = w(1, 3);
c = w(3, 2);
d = w(3, 3);

%see report for this equations
syms x y;
eqn1 = sym(a*x^2 + 2*b*x + y^2 + 2*c*y + d == 0);
eqn2 = sym(imLinf(1) * x + imLinf(2) * y + imLinf(3) == 0);
[aS, bS] = solve([eqn1, eqn2], [x y]);

%compute image of circulare points
jImg = [double(aS(1)) double(bS(1)) 1];
iImg = [double(aS(2)) double(bS(2)) 1];
CinfImg = iImg.' * jImg + jImg.' * iImg;
CinfImg = inv(Hs) * CinfImg;
CinfImg = CinfImg./norm(CinfImg);

%find Hrect woth svd
[U,D,V] = svd(CinfImg);
S = sqrt(D);
S(3,3) = 1;
Hrect = U.' * S.';
Hrect(3,3) = 1;

%rotate 180 degree (it is flipped)
theta = 180;
rot = [cosd(theta) -sind(theta) 0; sind(theta) cosd(theta) 0; 0 0 1];
Hrect = rot.' * Hrect;

tform = projective2d(Hrect');
J = imwarp(img,tform);
figure;
imshow(J);
imwrite(J, "output/G3VerticalReconstruction.png");


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