==== BEGIN Teodora Tanurkova | Teodora Tanurkova_26678_assignsubmission_file | vaja5.m ====
%% Naloga 1
Video = VideoReader('HolywoodPosnetek.avi');
IzhodniVidNN1 = VideoWriter('HolywoodPosnetekNN1');
IzhodniVidNN2 = VideoWriter('HolywoodPosnetekNN2');
IzhodniVidNN3 = VideoWriter('HolywoodPosnetekNN3');
open(IzhodniVidNN1);
open(IzhodniVidNN2);
open(IzhodniVidNN3);

IzhodniVidBAOF1 = VideoWriter('HolywoodPosnetekBAOF1');
IzhodniVidBAOF2 = VideoWriter('HolywoodPosnetekBAOF2');
IzhodniVidBAOF3 = VideoWriter('HolywoodPosnetekBAOF3');
open(IzhodniVidBAOF1);
open(IzhodniVidBAOF2);
open(IzhodniVidBAOF3);

IzhodniVidBAON1 = VideoWriter('HolywoodPosnetekBAON1');
IzhodniVidBAON2 = VideoWriter('HolywoodPosnetekBAON2');
IzhodniVidBAON3 = VideoWriter('HolywoodPosnetekBAON3');
open(IzhodniVidBAON1);
open(IzhodniVidBAON2);
open(IzhodniVidBAON3);

faktor = [0.5 0.25 0.125];

while hasFrame(Video)

    frame = readFrame(Video);
    
    for i = 1:numel(faktor)
        if i == 1
           FrameResizeNN = imresize(frame, faktor(i),"nearest");
           writeVideo(IzhodniVidNN1,FrameResizeNN);

           FrameResizeBAOF = imresize(frame, faktor(i),"bilinear","Antialiasing", false);
           writeVideo(IzhodniVidBAOF1,FrameResizeBAOF);

           FrameResizeBAON = imresize(frame, faktor(i),"bilinear","Antialiasing", true);
           writeVideo(IzhodniVidBAON1,FrameResizeBAON);

        elseif i==2
            FrameResizeNN = imresize(frame, faktor(i),"nearest");
            writeVideo(IzhodniVidNN2,FrameResizeNN);

            FrameResizeBAOF = imresize(frame, faktor(i),"bilinear","Antialiasing", false);
            writeVideo(IzhodniVidBAOF2,FrameResizeBAOF);

            FrameResizeBAON = imresize(frame, faktor(i),"bilinear","Antialiasing", true);
            writeVideo(IzhodniVidBAON2,FrameResizeBAON);
            
        else
            FrameResizeNN = imresize(frame, faktor(i),"nearest");
            writeVideo(IzhodniVidNN3,FrameResizeNN);

            FrameResizeBAOF = imresize(frame, faktor(i),"bilinear","Antialiasing", false);
            writeVideo(IzhodniVidBAOF3,FrameResizeBAOF);

            FrameResizeBAON = imresize(frame, faktor(i),"bilinear","Antialiasing", true);
            writeVideo(IzhodniVidBAON3,FrameResizeBAON);
        end
    end
end
close(IzhodniVidNN1);
close(IzhodniVidNN2);
close(IzhodniVidNN3);

close(IzhodniVidBAOF1);
close(IzhodniVidBAOF2);
close(IzhodniVidBAOF3);

close(IzhodniVidBAON1);
close(IzhodniVidBAON2);
close(IzhodniVidBAON3);

%% Naloga 2
% evklidska razdalja

Video2 = VideoReader('squash5.avi');
vsiOkviri = Video2.NumFrames;

frame1 = read(Video2, 1);
figure; 
imshow(frame1);
title('Izberi igralca evklid');

[znacilkaRGB, bbox] = imcrop(frame1);   
bbox = round(bbox);

znacilka = rgb2gray(znacilkaRGB);
w = bbox(3); %sirina
h = bbox(4); %visina

eps = 18;           % okolica iskanja

out = VideoWriter('squash_EVKLID.avi');
open(out);

for k = 1:vsiOkviri

    frame = read(Video2, k);
    gray  = rgb2gray(frame);

    xMin = max(1, bbox(1) - eps);
    yMin = max(1, bbox(2) - eps);
    xMax = min(size(gray,2) - w + 1, bbox(1) + eps);
    yMax = min(size(gray,1) - h + 1, bbox(2) + eps);

    bestD = inf;

    for y = yMin:yMax
        for x = xMin:xMax
            Dolocenizsek = gray(y:y+h-1, x:x+w-1);
            dif = double(Dolocenizsek) - double(znacilka);
            d = sum(dif(:).^2);

            if d < bestD
                bestD = d;
                bbox(1) = x;
                bbox(2) = y;
            end
        end
    end

    frameOut = insertShape(frame, 'Rectangle', bbox, 'LineWidth', 2);
    writeVideo(out, frameOut);
end

close(out);
%% Naloga 2 chi^2

Video3 = VideoReader('squash5.avi');
vsiOkviri3 = Video3.NumFrames;

frame1 = read(Video3, 1);
figure;
imshow(frame1);
title('Izberi igralca (chi^2)');

[znacilkaRGB3, bbox3] = imcrop(frame1);
bbox3 = round(bbox3);

znacilka3 = rgb2gray(znacilkaRGB3);
w3 = bbox3(3);      % širina
h3 = bbox3(4);      % višina

eps2  = 18;         % okolica iskanja
nbins = 32;         % št. binov histograma
binSize = 256 / nbins;

refHist = myHistGray(znacilka3, nbins, binSize);   % 1×nbins
refHist = refHist / sum(refHist);

out3 = VideoWriter('squash_CHI2.avi');
open(out3);

for k = 1:vsiOkviri3

    frame = read(Video3, k);
    gray  = rgb2gray(frame);

    xMin = max(1, bbox3(1) - eps2);
    yMin = max(1, bbox3(2) - eps2);
    xMax = min(size(gray,2) - w3 + 1, bbox3(1) + eps2);
    yMax = min(size(gray,1) - h3 + 1, bbox3(2) + eps2);

    bestD = inf;

    for y = yMin:yMax
        for x = xMin:xMax

            izsek = gray(y:y+h3-1, x:x+w3-1);

            hst = myHistGray(izsek, nbins, binSize);
            hst = hst / sum(hst);

            d = 0.5*sum(((refHist - hst).^2) ./ (refHist + hst + 1e-10));

            if d < bestD
                bestD = d;
                bbox3(1) = x;
                bbox3(2) = y;
            end
        end
    end

    frameOut = insertShape(frame, 'Rectangle', bbox3, 'LineWidth', 2);
    writeVideo(out3, frameOut);
end

close(out3);

%% funkcija histogram sivinske slike
function h = myHistGray(I, nbins, binSize)
    h = zeros(1, nbins);
    pixels = I(:);

    for i = 1:numel(pixels)
        bin = floor(double(pixels(i)) / binSize) + 1;
        if bin > nbins
            bin = nbins;
        end
        h(bin) = h(bin) + 1;
    end
end
==== END Teodora Tanurkova | Teodora Tanurkova_26678_assignsubmission_file | vaja5.m ====

==== BEGIN Teodora Tanurkova | Teodora Tanurkova_26678_assignsubmission_file | vaja5_naloga3.m ====
%% Naloga 3 evklidska razd

Video2 = VideoReader('squash5.avi');
vsiOkviri = Video2.NumFrames;

frame1 = read(Video2,1);
figure;
imshow(frame1);
title('Izberi igralca (Naloga 3 – L2)');

[znacilkaRGB, bbox] = imcrop(frame1);
bbox = round(bbox);

znacilka = rgb2gray(znacilkaRGB);
w = bbox(3);
h = bbox(4);

eps = 20;

out = VideoWriter('squash_EVKLIDNaloga3.avi');
open(out);

for k = 1:vsiOkviri
    frame = read(Video2, k);
    gray  = rgb2gray(frame);

    xMin = max(1, bbox(1) - eps);
    yMin = max(1, bbox(2) - eps);
    xMax = min(size(gray,2)-w+1, bbox(1)+eps);
    yMax = min(size(gray,1)-h+1, bbox(2)+eps);

    bestD = inf;

    for y = yMin:yMax
        for x = xMin:xMax
            izsek = gray(y:y+h-1, x:x+w-1);
            dif = double(izsek) - double(znacilka);
            d = sum(dif(:).^2);

            if d < bestD
                bestD = d;
                bbox(1) = x;
                bbox(2) = y;
            end
        end
    end

    znacilka = gray(bbox(2):bbox(2)+h-1, bbox(1):bbox(1)+w-1);

    frameOut = insertShape(frame, 'Rectangle', bbox, 'LineWidth', 2);
    writeVideo(out, frameOut);
end

close(out);

%% Naloga 3 

Video3 = VideoReader('squash5.avi');
vsiOkviri3 = Video3.NumFrames;

% 1) Prva slika + izbor igralca
frame1 = read(Video3, 1);
figure; 
imshow(frame1);
title('Izberi igralca (Naloga 3 – χ^2)');

[znacilkaRGB3, bbox3] = imcrop(frame1);
bbox3 = round(bbox3);

znacilka3 = rgb2gray(znacilkaRGB3);
w3 = bbox3(3);
h3 = bbox3(4);

eps3 = 18;
nbins = 32;
binSize = 256 / nbins;

refHist = myHistGray(znacilka3, nbins, binSize);
refHist = refHist / sum(refHist);

out3 = VideoWriter('squash_CHI2Naloga3.avi');
open(out3);

for k = 1:vsiOkviri3

    frame = read(Video3, k);
    gray  = rgb2gray(frame);

    xMin = max(1, bbox3(1) - eps3);
    yMin = max(1, bbox3(2) - eps3);
    xMax = min(size(gray,2) - w3 + 1, bbox3(1) + eps3);
    yMax = min(size(gray,1) - h3 + 1, bbox3(2) + eps3);

    bestD = inf;

    for y = yMin:yMax
        for x = xMin:xMax
            izsek = gray(y:y+h3-1, x:x+w3-1);

            hst = myHistGray(izsek, nbins, binSize);
            hst = hst / sum(hst);

            d = 0.5 * sum(((refHist - hst).^2) ./ (refHist + hst + 1e-10));

            if d < bestD
                bestD = d;
                bbox3(1) = x;
                bbox3(2) = y;
            end
        end
    end

    noviIzsek = gray(bbox3(2):bbox3(2)+h3-1, bbox3(1):bbox3(1)+w3-1);
    refHist = myHistGray(noviIzsek, nbins, binSize);
    refHist = refHist / sum(refHist);

    frameOut = insertShape(frame, 'Rectangle', bbox3, 'LineWidth', 2);
    writeVideo(out3, frameOut);
end

close(out3);

%% ročni histogram sivinske slike 
function h = myHistGray(I, nbins, binSize)
    h = zeros(1, nbins);
    pixels = I(:);

    for i = 1:numel(pixels)
        bin = floor(double(pixels(i)) / binSize) + 1;
        if bin > nbins
            bin = nbins;
        end
        h(bin) = h(bin) + 1;
    end
end
==== END Teodora Tanurkova | Teodora Tanurkova_26678_assignsubmission_file | vaja5_naloga3.m ====

