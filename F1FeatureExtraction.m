%% ######## F1 Feature extraction ########
clear, close all, clear HX;
img = imread('villa.png');
% converts image's values in double notation
img = im2double(img);


% Histogram equalization
% converts the 3 channels image to one channel image
img_edge = img;
img_edge = rgb2gray(img_edge);

% applies the adaptive histogram equalization
img_edge = adapthisteq(img_edge);

% applies the canny algorithm
edges = edge(img_edge, 'canny', [0.1, 0.2], 3);
imshow(edges);

% Detecting lines
% applies the Hough transformation
[H,T,R] = hough(edges, "Theta", (-90:0.5:89), 'RhoResolution', 1);
% selects the peaks in the parameters plane
P = houghpeaks(H, 100,'threshold', ceil(0.1*max(H(:))), "NHoodSize", [15,15]);

% searches the segments lines in the image given the peak lines
lines = houghlines(edges, T, R, P,'FillGap', 8,'MinLength', 25);

figure; imshow(img_edge), hold on;
draw_lines(lines);


% Features detection
img_corners = img;
% converts the image to gray scale
img_corners = rgb2gray(img_corners);
% applies the histogram equalization
img_corners = adapthisteq(img_corners);

% applies the SURF algorithm
corners = detectSURFFeatures(img_corners);

figure; imshow(img_corners), hold on;

% plots the strongest features
plot(corners.selectStrongest(100));

function draw_lines(lines)
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

        % Plot beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
end
