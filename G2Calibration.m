%% ######## G2 Calibration ########
clear, close all, clear HX;

im=imread('villa.png');
figure(1), imshow(im);
[rows, columns, numberOfColorChannels] = size(im);
Hs = [1/rows    0       0
      0         1/columns  0
      0         0       1];

hold on;

%load saved lines
parallelLines = load('savedLinesG2.mat').parallelLines;
linf = load('linf.mat').imLinfty;

%compute vanishing points
vx = cross(parallelLines{1}(1,:), parallelLines{1}(2,:));
vy = cross(parallelLines{2}(1,:), parallelLines{2}(2,:));
vz = cross(parallelLines{3}(1,:), parallelLines{3}(2,:));
va = cross(parallelLines{4}(1,:), parallelLines{4}(2,:));
vb = cross(parallelLines{5}(1,:), parallelLines{5}(2,:));
vx = vx * Hs;
vy = vy * Hs;
vz = vz * Hs;
va = va * Hs;
vb = vb * Hs;

Haff = Hs * load("Haff.mat").Haff;
Hrect = Hs * load("Hrect.mat").Hrect;
linf = linf * Hs;
H = inv(Hrect * Haff);
h1 = H(:,1).';
h2 = H(:,2).';

l1 = linf(1);
l2 = linf(2);
l3 = linf(3);
  
% vector product matrix
lx = [0 -l3 l2; l3 0 -l1; -l2 l1 0];

syms a b c d;
w = [a 0 b; 0 1 c; b c d];

%see report for this equations
eqn1 = sym(vx * w * vy.' == 0);
eqn2 = sym(vx * w * vz.' == 0);
%eqn3 = sym(h1 * w * h2.' == 0);
%eqn4 = sym(h1 * w * h1.' - h2 * w * h2.' == 0);
eqn3 = sym(vy * w * vz.' == 0);
eqn4 = sym(va * w * vb.' == 0);
%eqn3 = sym(lx(1,:) * w * vy.' == 0);
%eqn4 = sym(lx(2,:) * w * vy.' == 0);

[aS, bS, cS, dS] = solve([eqn1, eqn2 eqn3, eqn4], [a, b, c, d]);
w = [aS, 0 bS; 0 1 cS; bS cS dS];
w = double(w);

%find K with cholesky factorisation
if all(eigs(w) < 0)
	w = -w;
end
K = inv(Hs) * inv(chol(w));
K = K / K(3,3);
%text(K(1,3) * rows, K(2,3) * rows, 'P', 'FontSize', 15, 'Color', 'r')
disp(K)
disp("Aspect Ratio");
disp(K(1,1) / K(2,2));

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
