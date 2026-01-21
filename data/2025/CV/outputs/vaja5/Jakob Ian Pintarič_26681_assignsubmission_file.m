==== BEGIN Jakob Ian Pintarič | Jakob Ian Pintarič_26681_assignsubmission_file | nal1.m ====
%% VAJA 5 – 1. 
clc; clear; close all;

inputFile = 'Holywood2-t00427-rgb.avi';

if ~isfile(inputFile)
    alt = 'Holywood.avi';
    if isfile(alt)
        inputFile = alt;
    else
        error("Ne najdem videa '%s' (niti '%s') v trenutni mapi.", ...
              'Holywood2-t00427-rgb.avi', 'Holywood.avi');
    end
end

scales = [1/2, 1/4, 1/8];

methods(1).tag = "nearest";
methods(1).interp = "nearest";
methods(1).useAA = [];         

methods(2).tag = "bilinear_AAoff";
methods(2).interp = "bilinear";
methods(2).useAA = false;     

methods(3).tag = "bilinear_AAon";
methods(3).interp = "bilinear";
methods(3).useAA = true;      

for m = 1:numel(methods)
    for s = 1:numel(scales)

        v = VideoReader(inputFile); 

        outName = sprintf('%s_scale_%0.3f.avi', methods(m).tag, scales(s));
        w = VideoWriter(outName, 'Motion JPEG AVI');
        w.FrameRate = v.FrameRate; 
        open(w);

        while hasFrame(v)
            frame = readFrame(v);

            if methods(m).tag == "nearest"
                resized = imresize(frame, scales(s), methods(m).interp);
            else
                resized = imresize(frame, scales(s), methods(m).interp, ...
                                   'Antialiasing', methods(m).useAA);
            end

            writeVideo(w, resized);
        end

        close(w);
        fprintf("Shranjeno: %s\n", outName);
    end
end

disp("Končano: ustvarjenih 9 pomanjšanih posnetkov.");

%%
vN  = VideoReader('nearest_scale_0.125.avi');
vO  = VideoReader('bilinear_AAoff_scale_0.125.avi');
vI  = VideoReader('bilinear_AAon_scale_0.125.avi');

fN = readFrame(vN);
fO = readFrame(vO);
fI = readFrame(vI);

H = 288; W = 384; 
fN2 = imresize(fN,[H W],'nearest');
fO2 = imresize(fO,[H W],'nearest');
fI2 = imresize(fI,[H W],'nearest');

figure;
imshow([fN2 fO2 fI2]);
title('Nearest | Bilinear AA off | Bilinear AA on (vsi povečani z nearest)');

==== END Jakob Ian Pintarič | Jakob Ian Pintarič_26681_assignsubmission_file | nal1.m ====

==== BEGIN Jakob Ian Pintarič | Jakob Ian Pintarič_26681_assignsubmission_file | nal2.m ====
%% VAJA 5 – 2. 
clc; clear; close all;

videoFile = 'squash.avi';
if ~isfile(videoFile)
    error("Ne najdem '%s' v trenutni mapi.", videoFile);
end

epsN = 40;          
bins = 32;          
betaSSD = 0.30;     
maxFrames = inf;

minW = 60;
minH = 40;

v0 = VideoReader(videoFile);
frame0 = readFrame(v0);

figure('Name','ROI','NumberTitle','off');
imshow(frame0);
title('Klikni 2x: zgornji-levo in spodnji-desno (ROI igralca)');
roi = selectROI2Clicks(frame0, minW, minH);
close;

disp("ROI = [x y w h]:");
disp(roi);

track(videoFile,'2_1_euclidean_rgb.avi',roi,epsN,maxFrames,'ssd',bins,betaSSD);

track(videoFile,'2_2_chi2_hue.avi',roi,epsN,maxFrames,'chi2',bins,0);

implay('2_2_chi2_hue.avi');

%%
function track(videoFile,outFile,roi,epsN,maxFrames,mode,bins,beta)

v = VideoReader(videoFile);
w = VideoWriter(outFile,'Motion JPEG AVI');
w.FrameRate = v.FrameRate;
open(w);

frame = readFrame(v);
[x,y,W,H] = deal(roi(1),roi(2),roi(3),roi(4));

if strcmp(mode,'ssd')
    img = im2single(frame);
    ref = img(y:y+H-1, x:x+W-1, :);
    col = uint8([255 0 0]);
else
    img = hueU8(frame);
    ref = histN(img(y:y+H-1, x:x+W-1), bins);
    col = uint8([0 255 0]);
end

writeVideo(w, drawRect(frame,[x y W H],col,2));
k = 1;

while hasFrame(v) && k < maxFrames
    k = k + 1;
    frame = readFrame(v);

    if strcmp(mode,'ssd')
        img = im2single(frame);
        [xNew,yNew] = searchSSD(img, ref, x, y, W, H, epsN);

        x = round((1-beta)*x + beta*xNew);
        y = round((1-beta)*y + beta*yNew);

    else
        img = hueU8(frame);
        [x,y] = searchChi2(img, ref, x, y, W, H, epsN, bins);
    end

    x = max(1, min(size(frame,2)-W+1, x));
    y = max(1, min(size(frame,1)-H+1, y));

    writeVideo(w, drawRect(frame,[x y W H],col,2));
end

close(w);
end

%%
function [xBest,yBest] = searchSSD(img, ref, x0, y0, W, H, epsN)

Himg = size(img,1);
Wimg = size(img,2);

xMin = max(1,x0-epsN);
xMax = min(Wimg-W+1,x0+epsN);
yMin = max(1,y0-epsN);
yMax = min(Himg-H+1,y0+epsN);

lambda = 0.05;   % kazen za skoke

bestVal = inf;
xBest = x0; yBest = y0;

for y = yMin:yMax
    for x = xMin:xMax
        p = img(y:y+H-1, x:x+W-1, :);
        d = sum((p(:)-ref(:)).^2);
        penalty = lambda*((x-x0)^2 + (y-y0)^2);
        score = d + penalty;

        if score < bestVal
            bestVal = score;
            xBest = x;
            yBest = y;
        end
    end
end
end

%%
function [xBest,yBest] = searchChi2(imgU8, refH, x0, y0, W, H, epsN, bins)

Himg = size(imgU8,1);
Wimg = size(imgU8,2);

xMin = max(1,x0-epsN);
xMax = min(Wimg-W+1,x0+epsN);
yMin = max(1,y0-epsN);
yMax = min(Himg-H+1,y0+epsN);

bestVal = inf;
xBest = x0; yBest = y0;

for y = yMin:yMax
    for x = xMin:xMax
        patch = imgU8(y:y+H-1, x:x+W-1);
        h = histN(patch,bins);
        d = sum((h-refH).^2 ./ (h+refH+1e-12));

        if d < bestVal
            bestVal = d;
            xBest = x;
            yBest = y;
        end
    end
end
end

%%
function roi = selectROI2Clicks(frame, minW, minH)

Wimg = size(frame,2);
Himg = size(frame,1);

while true
    imshow(frame);
    title('Klikni 2x: zgornji-levo in spodnji-desno');
    [x,y] = ginput(2);
    x = round(x); y = round(y);

    x1 = max(1,min(Wimg,x(1))); y1 = max(1,min(Himg,y(1)));
    x2 = max(1,min(Wimg,x(2))); y2 = max(1,min(Himg,y(2)));

    xMin = min(x1,x2);
    yMin = min(y1,y2);

    w = max(abs(x2-x1)+1, minW);
    h = max(abs(y2-y1)+1, minH);

    roi = [xMin yMin w h];
    rectangle('Position',roi,'EdgeColor','r','LineWidth',2);

    ok = questdlg('ROI OK?','ROI','OK','Ponovi','OK');
    if strcmp(ok,'OK'), break; end
end
end

%%
function H = hueU8(rgb)
hsvI = rgb2hsv(rgb);
H = uint8(255*hsvI(:,:,1));
end

function h = histN(patch,bins)
h = double(imhist(patch,bins));
h = h/(sum(h)+1e-12);
end

%%
function imgOut = drawRect(imgIn, rect, color, lw)

imgOut = imgIn;
x = rect(1); y = rect(2);
W = rect(3); H = rect(4);

x1 = max(1,x); y1 = max(1,y);
x2 = min(size(imgOut,2),x+W-1);
y2 = min(size(imgOut,1),y+H-1);

R = color(1); G = color(2); B = color(3);

for t=0:lw-1
    imgOut(y1+t,x1:x2,1)=R; imgOut(y1+t,x1:x2,2)=G; imgOut(y1+t,x1:x2,3)=B;
    imgOut(y2-t,x1:x2,1)=R; imgOut(y2-t,x1:x2,2)=G; imgOut(y2-t,x1:x2,3)=B;
    imgOut(y1:y2,x1+t,1)=R; imgOut(y1:y2,x1+t,2)=G; imgOut(y1:y2,x1+t,3)=B;
    imgOut(y1:y2,x2-t,1)=R; imgOut(y1:y2,x2-t,2)=G; imgOut(y1:y2,x2-t,3)=B;
end
end
==== END Jakob Ian Pintarič | Jakob Ian Pintarič_26681_assignsubmission_file | nal2.m ====

==== BEGIN Jakob Ian Pintarič | Jakob Ian Pintarič_26681_assignsubmission_file | nal3.m ====
%% VAJA 5 – 3. 
clc;
close all;

video = VideoReader("squash.avi");
frame = readFrame(video);
gray = rgb2gray(frame);

alphaT = 0.03;
alphaP = 0.4;
search_radius = 40;
minScore = 0.45;       
learnScore = 0.65;
maxMove = 30;
border = 25;

lostCounter = 0;
lostLimit = 5;        

figure; imshow(frame);
title("Izberi 2 točki na rdečem igralcu");
p = round(ginput(2));
close;

x1 = min(p(:,1)); y1 = min(p(:,2));
x2 = max(p(:,1)); y2 = max(p(:,2));

w = x2 - x1;
h = y2 - y1;

template = gray(y1:y2, x1:x2);
cx = x1 + w/2;
cy = y1 + h/2;

fig = figure('visible','off');
ax = axes(fig);

videoout = VideoWriter("naloga3_sprotno_ucenje.avi","Uncompressed AVI");
open(videoout);

while hasFrame(video)

    frame = readFrame(video);
    gray = rgb2gray(frame);

    if lostCounter < lostLimit
        xs = max(1, round(cx - search_radius));
        ys = max(1, round(cy - search_radius));
        xe = min(size(gray,2), round(cx + search_radius + w));
        ye = min(size(gray,1), round(cy + search_radius + h));
    else
        xs = 1; ys = 1;
        xe = size(gray,2);
        ye = size(gray,1);
    end

    roi = gray(ys:ye, xs:xe);

    C = normxcorr2(template, roi);
    [peak, idx] = max(C(:));
    [ypeak, xpeak] = ind2sub(size(C), idx);

    xtl = xpeak - size(template,2) + 1;
    ytl = ypeak - size(template,1) + 1;

    xtl = max(1, min(xtl, size(roi,2)-w));
    ytl = max(1, min(ytl, size(roi,1)-h));

    cand_x = xs + xtl - 1;
    cand_y = ys + ytl - 1;

    cand_cx = cand_x + w/2;
    cand_cy = cand_y + h/2;

    dx = abs(cand_cx - cx);
    dy = abs(cand_cy - cy);

    if peak > minScore && dx < maxMove && dy < maxMove
        cx = (1-alphaP)*cx + alphaP*cand_cx;
        cy = (1-alphaP)*cy + alphaP*cand_cy;
        lostCounter = 0;
    else
        lostCounter = lostCounter + 1;
    end

    bx = round(cx - w/2);
    by = round(cy - h/2);

    bx = max(1, min(bx, size(gray,2)-w));
    by = max(1, min(by, size(gray,1)-h));

    if peak > learnScore && lostCounter == 0 && ...
       bx > border && by > border && ...
       bx+w < size(gray,2)-border && by+h < size(gray,1)-border

        patch = gray(by:by+h, bx:bx+w);
        template = uint8((1-alphaT)*double(template) + alphaT*double(patch));
    end

    cla(ax);
    imshow(frame, 'Parent', ax); hold(ax,'on');

    if peak > minScore
        rectangle(ax,'Position',[bx by w h],'EdgeColor','g','LineWidth',2);
    end

    text(ax,10,20,sprintf("score = %.2f",peak), ...
        'Color','y','FontSize',12,'FontWeight','bold');

    hold(ax,'off');

    F = getframe(ax);
    writeVideo(videoout, F.cdata);
end

close(videoout);
close(fig);

disp("NALOGA 3 KONČANA – algoritem je sproti pozabil, kaj je igralec se je naučil napačnega vzorca (ozadja). .");
==== END Jakob Ian Pintarič | Jakob Ian Pintarič_26681_assignsubmission_file | nal3.m ====

