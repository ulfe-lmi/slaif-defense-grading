==== BEGIN Dunja Mihajlović | Dunja Mihajlović_22784_assignsubmission_file | naloga1.m ====
clc;
clear;
close all;

img = imread('hotel.jpg');

if size(img,3) == 3
    img_gray = rgb2gray(img);
else
    img_gray = img;
end

img_gray = double(img_gray);

Sx = [ 1  0 -1;
       2  0 -2;
       1  0 -1 ];

Sy = [ 1  2  1;
       0  0  0;
      -1 -2 -1 ];

Gx = imfilter(img_gray, Sx, 'replicate');
Gy = imfilter(img_gray, Sy, 'replicate');

G = sqrt(Gx.^2 + Gy.^2);
G = G / max(G(:));

threshold = 0.25;
edges_sobel = G > threshold;

edges_canny = edge(uint8(img_gray), 'canny');

save('edges_hotel.mat', 'edges_sobel', 'edges_canny', 'img');

imwrite(edges_sobel, 'edges_sobel.png');
imwrite(edges_canny, 'edges_canny.png');

figure;

subplot(2,2,1);
imshow(uint8(img_gray));

subplot(2,2,2);
imshow(G, []);

subplot(2,2,3);
imshow(edges_sobel);

subplot(2,2,4);
imshow(edges_canny);
==== END Dunja Mihajlović | Dunja Mihajlović_22784_assignsubmission_file | naloga1.m ====

==== BEGIN Dunja Mihajlović | Dunja Mihajlović_22784_assignsubmission_file | naloga2.m ====
clc;
clear;
close all;

load('edges_hotel.mat');

k_min = -2;
k_max =  2;
n_min = -200;
n_max =  200;

num_bins = 400;

k_vals = linspace(k_min, k_max, num_bins+1);
n_vals = linspace(n_min, n_max, num_bins+1);

edges_all = {edges_sobel, edges_canny};
titles = {'Hough – Sobel robovi', 'Hough – Canny robovi'};

N = 5;

for t = 1:2

    edges = logical(edges_all{t});
    [rows, cols] = size(edges);

    accumulator = zeros(length(k_vals), length(n_vals));

    for y = 1:rows
        for x = 1:cols
            if edges(y,x)
                for ki = 1:length(k_vals)
                    k = k_vals(ki);
                    n = y - k * x;

                    if n >= n_min && n <= n_max
                        ni = round((n - n_min) / (n_max - n_min) * num_bins) + 1;
                        accumulator(ki, ni) = accumulator(ki, ni) + 1;
                    end
                end
            end
        end
    end

    acc = accumulator;
    lines = zeros(N,2);

    for i = 1:N
        [~, idx] = max(acc(:));
        [ki, ni] = ind2sub(size(acc), idx);

        lines(i,1) = k_vals(ki);
        lines(i,2) = n_vals(ni);

        acc(ki, ni) = 0;
    end

    figure;
    imshow(img);
    hold on;

    x_vals = 1:cols;

    for i = 1:N
        k = lines(i,1);
        n = lines(i,2);
        y_vals = k * x_vals + n;
        plot(x_vals, y_vals, 'r', 'LineWidth', 2);
    end

    title(titles{t});
    hold off;
end
==== END Dunja Mihajlović | Dunja Mihajlović_22784_assignsubmission_file | naloga2.m ====

==== BEGIN Dunja Mihajlović | Dunja Mihajlović_22784_assignsubmission_file | naloga3.m ====
clc;
clear;
close all;

% Branje videa
videoFile = 'squash.avi';
vidObj = VideoReader(videoFile);

% Parametri
frameStep = 10;  % vsaka 10. slika
framesToUse = floor(vidObj.NumFrames / frameStep);

% Preberi izbrane slike in jih shrani v 4D matriko
sampleFrames = zeros(vidObj.Height, vidObj.Width, 3, framesToUse, 'uint8');

count = 1;
for i = 1:frameStep:vidObj.NumFrames
    frame = read(vidObj, i);
    sampleFrames(:,:,:,count) = frame;
    count = count + 1;
end


% Median je najbolj primerna statistična funkcija za ozadje
bgImage = median(sampleFrames, 4);   % median po 4. dimenziji (frame)
bgImage = uint8(bgImage);            % pretvorba v 8-bit

figure;
imshow(bgImage);
title('Izračunano ozadje posnetka (median)');

==== END Dunja Mihajlović | Dunja Mihajlović_22784_assignsubmission_file | naloga3.m ====

==== BEGIN Dunja Mihajlović | Dunja Mihajlović_22784_assignsubmission_file | naloga4.m ====
clc;
clear;
close all;

videoFile = 'squash.avi';
vidObj = VideoReader(videoFile);

frameStep = 10;
framesToUse = floor(vidObj.NumFrames / frameStep);

sampleFrames = zeros(vidObj.Height, vidObj.Width, 3, framesToUse, 'uint8');
count = 1;

for i = 1:frameStep:vidObj.NumFrames
    frame = read(vidObj, i);
    sampleFrames(:,:,:,count) = frame;
    count = count + 1;
end

bgImage = median(sampleFrames, 4);
bgImage = uint8(bgImage);

vidObj.CurrentTime = 0;
testFrame = readFrame(vidObj);

diffTest = sqrt(sum((double(testFrame) - double(bgImage)).^2, 3));

figure;
imagesc(diffTest);
colormap gray;
colorbar;
title('Slika razlike (evklidska RGB razdalja)');

outputFile = 'squash_tracked.avi';
vidWriter = VideoWriter(outputFile);
open(vidWriter);

thresholdDiff = 50;
markerSize = 5;

vidObj.CurrentTime = 0;

while hasFrame(vidObj)
    frame = readFrame(vidObj);

    diffImage = sqrt(sum((double(frame) - double(bgImage)).^2, 3));

    bw = diffImage > thresholdDiff;

    bw = bwmorph(bw,'close');
    bw = bwmorph(bw,'open');

    [labeled, num] = bwlabel(bw);
    stats = regionprops(labeled,'Centroid','Area');

    if num > 0
        areas = [stats.Area];
        [~, idx] = sort(areas, 'descend');
        idx = idx(1:min(2,length(idx)));

        for k = idx
            cx = round(stats(k).Centroid(1));
            cy = round(stats(k).Centroid(2));

            xRange = max(cx-markerSize,1):min(cx+markerSize,size(frame,2));
            yRange = max(cy-markerSize,1):min(cy+markerSize,size(frame,1));

            frame(yRange,xRange,1) = 255;
            frame(yRange,xRange,2) = 0;
            frame(yRange,xRange,3) = 0;
        end
    end

    writeVideo(vidWriter, frame);
end

close(vidWriter);

disp(['Video saved as: ', outputFile]);
==== END Dunja Mihajlović | Dunja Mihajlović_22784_assignsubmission_file | naloga4.m ====

==== BEGIN Dunja Mihajlović | Dunja Mihajlović_22784_assignsubmission_file | naloga5.m ====
clc; clear; close all;

%% Load video
squash = VideoReader('squash.avi');
H = squash.Height;
W = squash.Width;
numFrames = squash.NumFrames;

%% Compute background using median of sampled frames
frameStep = 10;
sampleCount = floor(numFrames/frameStep);
sampleFrames = zeros(H,W,3,sampleCount,'uint8');

for f = 1:sampleCount
    sampleFrames(:,:,:,f) = read(squash,f*frameStep);
end

frameNew = zeros(H,W,3,'uint8');
for c = 1:3
    frameNew(:,:,c) = mode(sampleFrames(:,:,c,:),4);
end

%% Prepare video writer
vidWriter = VideoWriter('squash_tracked_colors.avi');
vidWriter.FrameRate = squash.FrameRate;
open(vidWriter);

%% Process video frame by frame
for k = 1:numFrames
    frame = read(squash,k);
    
    % Euclidean distance from background
    diffImage = sqrt(sum((double(frame)-double(frameNew)).^2,3));
    
    % Threshold & morphology
    bw = diffImage > 50;
    bw = bwmorph(bw,'close');
    bw = bwmorph(bw,'open');
    
    % Label and select two largest blobs
    [L,n] = bwlabel(bw);
    stats = regionprops(L,'Area','Centroid','PixelIdxList');
    areas = [stats.Area];
    if length(areas) < 2
        writeVideo(vidWriter, frame);
        continue
    end
    [~,idxSort] = sort(areas,'descend');
    players = stats(idxSort(1:2));
    centroid = reshape([players.Centroid],2,[])';
    
    % Shirt color detection
    red = 0; white = 0;
    for i = round(centroid(1,2))-10 : round(centroid(1,2))+10
        for j = round(centroid(1,1))-10 : round(centroid(1,1))+10
            if i>0 && i<=H && j>0 && j<=W
                if frame(i,j,1)>100 && frame(i,j,2)<130 && frame(i,j,3)<130
                    red = red +1;
                elseif frame(i,j,1)>100 && frame(i,j,2)>150 && frame(i,j,3)>150
                    white = white +1;
                end
            end
        end
    end
    
    % Draw colored circles
    RGB = frame;
    if red > white
        color1 = [255 0 0]; % Player 1 red
        color2 = [0 0 255]; % Player 2 blue
    else
        color1 = [0 0 255]; % Player 1 blue
        color2 = [255 0 0]; % Player 2 red
    end
    RGB = insertShape(RGB,'circle',[centroid(1,1) centroid(1,2) 20],'Color',color1,'LineWidth',3);
    RGB = insertShape(RGB,'circle',[centroid(2,1) centroid(2,2) 20],'Color',color2,'LineWidth',3);
    
    writeVideo(vidWriter, RGB);
end

close(vidWriter);
disp('Video saved: squash_tracked_colors.avi');
==== END Dunja Mihajlović | Dunja Mihajlović_22784_assignsubmission_file | naloga5.m ====

