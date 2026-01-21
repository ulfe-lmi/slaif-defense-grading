==== BEGIN Nejc Ropič | Nejc Ropič_26692_assignsubmission_file | doloci_igralca.m ====
clc;
clear;
close all;

% 1. NALOŽI VIDEO
% ===============================
video = VideoReader('squash.avi');

firstFrame = readFrame(video);

%% za rocno izbiro
figure;
imshow(firstFrame);
title('Z dvema klikoma označi igralca');

% 2. IZBIRA PREDLOGE
% ===============================
[x, y] = ginput(2);
%% shranjena referenca
x = [110; 121];
y = [120; 131];
%%
x = round(x);
y = round(y);

x1 = min(x);
x2 = max(x);
y1 = min(y);
y2 = max(y);

w = x2 - x1;
h = y2 - y1;

templateRGB = firstFrame(y1:y2, x1:x2, :);
template = rgb2gray(templateRGB);
==== END Nejc Ropič | Nejc Ropič_26692_assignsubmission_file | doloci_igralca.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_26692_assignsubmission_file | vaja1.m ====
scales = [1/2, 1/4, 1/8];
methods = {'nearest', 'bilinear', 'bilinear'};
aa = [false, false, true];   % antialising izkljucn

for m = 1:length(methods)
    for s = 1:length(scales)

        scale = scales(s);

        vidIn = VideoReader('Holywood2-t00427-rgb.avi');

        outName = sprintf('out_%s_AA%d_scale_%g.avi', ...
                          methods{m}, aa(m), scale);

        vidOut = VideoWriter(outName);
        vidOut.FrameRate = vidIn.FrameRate;
        open(vidOut);

        while hasFrame(vidIn)
            frame = readFrame(vidIn);

            % pomanjšanje z imresize
            frame_resized = imresize( ...
                frame, scale, methods{m}, 'Antialiasing', aa(m));

            writeVideo(vidOut, frame_resized);
        end

        close(vidOut);
    end
end
==== END Nejc Ropič | Nejc Ropič_26692_assignsubmission_file | vaja1.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_26692_assignsubmission_file | vaja2_1.m ====
%% 2.1
video = VideoReader('squash.avi');
readFrame(video);   

epsilon = 10;

prevX = x1;
prevY = y1;

writer = VideoWriter('sledenje_L2.avi');
open(writer);

figure;
imshow(firstFrame);
hold on;
rectangle('Position', [prevX prevY w h], ...
          'EdgeColor', 'r', 'LineWidth', 2);
hold off;

F = getframe(gca);
writeVideo(writer, F.cdata);

while hasFrame(video)

    frame = readFrame(video);
    frameGray = rgb2gray(frame);

    bestDist = inf;
    bestX = prevX;
    bestY = prevY;

    xMin = max(1, prevX - epsilon);
    xMax = min(size(frameGray,2) - w, prevX + epsilon);
    yMin = max(1, prevY - epsilon);
    yMax = min(size(frameGray,1) - h, prevY + epsilon);

    for i = xMin:xMax
        for j = yMin:yMax

            patch = frameGray(j:j+h, i:i+w);

            dist = sum((double(patch(:)) - double(template(:))).^2);

            if dist < bestDist
                bestDist = dist;
                bestX = i;
                bestY = j;
            end
        end
    end

    prevX = bestX;
    prevY = bestY;

    % izris
    figure(1);
    imshow(frame);
    hold on;
    rectangle('Position', [bestX bestY w h], ...
              'EdgeColor', 'r', 'LineWidth', 2);
    hold off;

    F = getframe(gca);
    writeVideo(writer, F.cdata);
    drawnow;
end

close(writer);

==== END Nejc Ropič | Nejc Ropič_26692_assignsubmission_file | vaja2_1.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_26692_assignsubmission_file | vaja2_2.m ====
%% 2.2
video = VideoReader('squash.avi');
readFrame(video);   

prevX = x1;
prevY = y1;

writer = VideoWriter('sledenje_chi2.avi');
open(writer);

nbins = 32;
templateHist = imhist(template, nbins);
templateHist = templateHist / sum(templateHist);

while hasFrame(video)

    frame = readFrame(video);
    frameGray = rgb2gray(frame);

    bestDist = inf;
    bestX = prevX;
    bestY = prevY;

    xMin = max(1, prevX - epsilon);
    xMax = min(size(frameGray,2) - w, prevX + epsilon);
    yMin = max(1, prevY - epsilon);
    yMax = min(size(frameGray,1) - h, prevY + epsilon);

    for i = xMin:xMax
        for j = yMin:yMax

            patch = frameGray(j:j+h, i:i+w);
            patchHist = imhist(patch, nbins);
            patchHist = patchHist / sum(patchHist);

            dist = sum((templateHist - patchHist).^2 ./ ...
                       (templateHist + patchHist + eps));

            if dist < bestDist
                bestDist = dist;
                bestX = i;
                bestY = j;
            end
        end
    end

    prevX = bestX;
    prevY = bestY;

    imshow(frame); hold on;
    rectangle('Position',[bestX bestY w h], ...
              'EdgeColor','r','LineWidth',2);
    hold off;

    F = getframe(gca);
    writeVideo(writer, F.cdata);
    drawnow;
end

close(writer);
disp('Video uspešno shranjen: sledenje_chi2.avi');
==== END Nejc Ropič | Nejc Ropič_26692_assignsubmission_file | vaja2_2.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_26692_assignsubmission_file | vaja3.m ====
epsilon = 10;
nbins = 32;
alpha = 0.05;   % hitrost učenja

prevX = x1;
prevY = y1;

% referencni histogram
templateHist = imhist(template, nbins);
templateHist = templateHist / sum(templateHist);

writer = VideoWriter('sledenje_chi2_ucenje.avi');
open(writer);

video = VideoReader('squash.avi');
readFrame(video);

while hasFrame(video)

    frame = readFrame(video);
    frameGray = rgb2gray(frame);

    bestDist = inf;
    bestX = prevX;
    bestY = prevY;

    xMin = max(1, prevX - epsilon);
    xMax = min(size(frameGray,2) - w, prevX + epsilon);
    yMin = max(1, prevY - epsilon);
    yMax = min(size(frameGray,1) - h, prevY + epsilon);

    for i = xMin:xMax
        for j = yMin:yMax

            patch = frameGray(j:j+h, i:i+w);
            patchHist = imhist(patch, nbins);
            patchHist = patchHist / sum(patchHist);

            dist = sum((templateHist - patchHist).^2 ./ ...
                       (templateHist + patchHist + eps));

            if dist < bestDist
                bestDist = dist;
                bestX = i;
                bestY = j;
            end
        end
    end

    % nova pozicija
    prevX = bestX;
    prevY = bestY;

    % ucenje sproti
    newPatch = frameGray(bestY:bestY+h, bestX:bestX+w);
    newHist = imhist(newPatch, nbins);
    newHist = newHist / sum(newHist);

    templateHist = (1 - alpha)*templateHist + alpha*newHist;
    templateHist = templateHist / sum(templateHist);

    % plotanje
    imshow(frame); hold on;
    rectangle('Position',[bestX bestY w h], ...
              'EdgeColor','r','LineWidth',2);
    hold off;

    F = getframe(gca);
    writeVideo(writer, F.cdata);
    drawnow;
end

close(writer);
disp('Video uspešno shranjen: sledenje_chi2_ucenje.avi');
==== END Nejc Ropič | Nejc Ropič_26692_assignsubmission_file | vaja3.m ====

