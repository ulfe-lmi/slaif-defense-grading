==== BEGIN Adnan Halilović | Adnan Halilović_26670_assignsubmission_file | labvaja5_1.m ====
%% RV vaja 5 – 1. naloga: Podvzorčenje slik

% Primerjava treh metod interpolacije pri zmanjsevanju locljivosti

clear;
close all;
clc;

%% Branje videa
videoFile = 'Holywood.avi';
v = VideoReader(videoFile);

% Preberemo prvi frame
frame = readFrame(v);

figure;
imshow(frame);
title('Originalna slika');

%% Faktorji zmanjsanja
scales = [1/2, 1/4, 1/8];

%% Skupni figure
figure;
sgtitle('Primerjava metod interpolacije pri podvzorcenju');

%% METODA 1: Nearest Neighbor
disp('Metoda 1: Nearest Neighbor');

for i = 1:length(scales)
    s = scales(i);

    img_nn = imresize(frame, s, 'nearest');

    subplot(3,3,i);
    imshow(img_nn);
    title(['Nearest neighbor, faktor = ', num2str(s)]);
    
    % shranjevanje
    imwrite(img_nn, ...
        ['NN_scale_', num2str(s*100), '.png']);
end

%% METODA 2: Bilinear brez filtriranja (antialiasing OFF)
disp('Metoda 2: Bilinear brez filtriranja');

for i = 1:length(scales)
    s = scales(i);

    img_bl_noaa = imresize(frame, s, ...
        'bilinear', 'Antialiasing', false);

    subplot(3,3,i+3);
    imshow(img_bl_noaa);
    title(['Bilinear brez AA, faktor = ', num2str(s)]);
    
    imwrite(img_bl_noaa, ...
        ['BL_noAA_scale_', num2str(s*100), '.png']);
end

%% METODA 3: Bilinear s filtriranjem (antialiasing ON)
disp('Metoda 3: Bilinear s filtriranjem');

for i = 1:length(scales)
    s = scales(i);

    img_bl_aa = imresize(frame, s, ...
        'bilinear', 'Antialiasing', true);

    subplot(3,3,i+6);
    imshow(img_bl_aa);
    title(['Bilinear z AA, faktor = ', num2str(s)]);
    
    imwrite(img_bl_aa, ...
        ['BL_AA_scale_', num2str(s*100), '.png']);
end
==== END Adnan Halilović | Adnan Halilović_26670_assignsubmission_file | labvaja5_1.m ====

==== BEGIN Adnan Halilović | Adnan Halilović_26670_assignsubmission_file | labvaja5_2_1.m ====
%% Vaja 5 – 2.1: Sledenje igralca (Evklidska razdalja v RGB, brez učenja)
clear; close all; clc;

v = VideoReader('squash.avi');

frameRGB = readFrame(v);

figure(1);
imshow(frameRGB);
title('Z dvema klikoma oznaci igralca (ROI naj bo majhen in informativen)');
[x, y] = ginput(2);

x = round(x); y = round(y);
x1 = min(x); x2 = max(x);
y1 = min(y); y2 = max(y);

w = x2 - x1;
h = y2 - y1;

template = frameRGB(y1:y2, x1:x2, :);   % RGB template

%% Parametri
epsilon = 25;      
numFrames = 150;   

writer = VideoWriter('sledenje_L2_RGB.avi');
open(writer);

prevX = x1;
prevY = y1;

k = 1;
while hasFrame(v)

    frameRGB = readFrame(v);

    bestDist = inf;
    bestX = prevX;
    bestY = prevY;

    for dx = -epsilon:epsilon
        for dy = -epsilon:epsilon
            x = prevX + dx;
            y = prevY + dy;

            if x < 1 || y < 1 || ...
               x+w > size(frameRGB,2) || ...
               y+h > size(frameRGB,1)
                continue;
            end

            patch = frameRGB(y:y+h, x:x+w, :);

            diff = double(patch) - double(template);
            dist = mean(diff(:).^2);    % L2 v RGB (normaliziran)

            if dist < bestDist
                bestDist = dist;
                bestX = x;
                bestY = y;
            end
        end
    end

    prevX = bestX;
    prevY = bestY;

    imshow(frameRGB); hold on;
    rectangle('Position',[bestX bestY w h], 'EdgeColor','r','LineWidth',2);
    hold off;

    writeVideo(writer, getframe(gca));
    k = k + 1;
end

close(writer);
disp('L2 RGB sledenje koncano');
==== END Adnan Halilović | Adnan Halilović_26670_assignsubmission_file | labvaja5_2_1.m ====

==== BEGIN Adnan Halilović | Adnan Halilović_26670_assignsubmission_file | labvaja5_2_2.m ====
%% Vaja 5 – 2.2: Sledenje igralca (Histogram + chi2) 
clear; close all; clc;

%% Branje videa
videoFile = 'squash.avi';
v = VideoReader(videoFile);

frameRGB = read(v,1);
frameGray = rgb2gray(frameRGB);

figure(1);
imshow(frameGray);
title('Z dvema klikoma oznaci igralca');
[x, y] = ginput(2);

x = round(x); y = round(y);
x1 = min(x); x2 = max(x);
y1 = min(y); y2 = max(y);

w = x2 - x1;
h = y2 - y1;

template = frameGray(y1:y2, x1:x2);

%% Histogram značilnica
numBins = 16;   % malo binov = stabilno
templateHist = imhist(template, numBins);
templateHist = templateHist / sum(templateHist);

%% Parametri
epsilon = 15;
numFrames = 150;

%% Izhodni video
writer = VideoWriter('sledenje_histogram_simple.avi');
open(writer);

prevX = x1;
prevY = y1;
k = 1;

%% Glavna zanka
while hasFrame(v)
    
    frameRGB = read(v, k);
    frameGray = rgb2gray(frameRGB);

    bestDist = inf;
    bestX = prevX;
    bestY = prevY;

    for dx = -epsilon:epsilon
        for dy = -epsilon:epsilon
            x = prevX + dx;
            y = prevY + dy;

            if x < 1 || y < 1 || ...
               x+w > size(frameGray,2) || ...
               y+h > size(frameGray,1)
                continue;
            end

            patch = frameGray(y:y+h, x:x+w);
            patchHist = imhist(patch, numBins);
            patchHist = patchHist / sum(patchHist);

            % chi2 razdalja
            chi2 = sum((patchHist - templateHist).^2);

            if chi2 < bestDist
                bestDist = chi2;
                bestX = x;
                bestY = y;
            end
        end
    end

    prevX = bestX;
    prevY = bestY;

    figure(1);
    imshow(frameRGB);
    hold on;
    rectangle('Position',[bestX bestY w h], ...
              'EdgeColor','g', 'LineWidth', 2);
    hold off;

    F = getframe(gca);
    writeVideo(writer, F);
    k = k + 1;
end

close(writer);

==== END Adnan Halilović | Adnan Halilović_26670_assignsubmission_file | labvaja5_2_2.m ====

==== BEGIN Adnan Halilović | Adnan Halilović_26670_assignsubmission_file | labvaja5_3.m ====
%% Vaja 5 – 2.3: Sledenje igralca (RGB histogram + Bhattacharyya)
clear; close all; clc;

v = VideoReader('squash.avi');

frameRGB = readFrame(v);

figure(1); imshow(frameRGB);
title('Z dvema klikoma oznaci igralca');
[x, y] = ginput(2);

x = round(x); y = round(y);
x1 = min(x); x2 = max(x);
y1 = min(y); y2 = max(y);

w = x2 - x1;
h = y2 - y1;

template = frameRGB(y1:y2, x1:x2, :);

%% Histogram značilnica (RGB posebej)
numBins = 16;
templateHist = rgbHist(template, numBins);

%% Parametri
epsilon = 15;   
alpha = 0.05;      % update histogram 


writer = VideoWriter('sledenje_hist_bhatt_RGB.avi');
open(writer);

prevX = x1;
prevY = y1;
k = 1;

while hasFrame(v) 
    frameRGB = readFrame(v);

    bestCost = inf;
    bestX = prevX;
    bestY = prevY;

    for dx = -epsilon:epsilon
        for dy = -epsilon:epsilon
            x = prevX + dx;
            y = prevY + dy;

            if x < 1 || y < 1 || ...
               x+w > size(frameRGB,2) || ...
               y+h > size(frameRGB,1)
                continue;
            end

            patch = frameRGB(y:y+h, x:x+w, :);
            patchHist = rgbHist(patch, numBins);

            % Bhattacharyya distance
            bc = sum(sqrt(patchHist .* templateHist));
            dist = 1 - bc;

            % kazen za velike premike 
            motionPenalty = 1e-4 * (dx^2 + dy^2);
            cost = dist + motionPenalty;

            if cost < bestCost
                bestCost = cost;
                bestX = x;
                bestY = y;
            end
        end
    end

    prevX = bestX;
    prevY = bestY;

    % Posodabljanje histograma 
    if alpha > 0
        newPatch = frameRGB(bestY:bestY+h, bestX:bestX+w, :);
        newHist = rgbHist(newPatch, numBins);
        templateHist = (1-alpha)*templateHist + alpha*newHist;
        templateHist = templateHist / sum(templateHist);
    end

    imshow(frameRGB); hold on;
    rectangle('Position',[bestX bestY w h], 'EdgeColor','b','LineWidth',2);
    hold off;

    writeVideo(writer, getframe(gca));
    k = k + 1;
end

close(writer);
disp('Histogram Bhattacharyya (RGB) sledenje koncano');

%% -------- lokalna funkcija --------
function h = rgbHist(imgRGB, numBins)
    imgRGB = uint8(imgRGB);

    r = imgRGB(:,:,1);
    g = imgRGB(:,:,2);
    b = imgRGB(:,:,3);

    hr = imhist(r, numBins);
    hg = imhist(g, numBins);
    hb = imhist(b, numBins);

    h = double([hr; hg; hb]);
    h = h / sum(h);
end
==== END Adnan Halilović | Adnan Halilović_26670_assignsubmission_file | labvaja5_3.m ====

