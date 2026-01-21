==== BEGIN Alja Belinger | Alja Belinger_21501_assignsubmission_file | RV_3_1.m ====

clear all; close all; clc;
%% ===============================
%          NALOGA 1
%   Prikaz komponent HSV in Lab
% ================================

%% 1) prebere sliki
img1 = imread('yosemite_meadows.jpg');
img2 = imread('coloured_pencils.jpg');


%   HSV ZA YOSEMITE

hsv1 = rgb2hsv(img1);

H1 = hsv1(:,:,1);
S1 = hsv1(:,:,2);
V1 = hsv1(:,:,3);

figure('Name','Yosemite - HSV');
subplot(1,3,1); imagesc(H1); colormap(gray); axis image off; title('H');
subplot(1,3,2); imagesc(S1); colormap(gray); axis image off; title('S');
subplot(1,3,3); imagesc(V1); colormap(gray); axis image off; title('V');



%  Lab ZA YOSEMITE

lab1 = rgb2lab(img1);

L1 = lab1(:,:,1);
a1 = lab1(:,:,2);
b1 = lab1(:,:,3);

figure('Name','Yosemite - Lab');
subplot(1,3,1); imagesc(L1); colormap(gray); axis image off; title('L');
subplot(1,3,2); imagesc(a1); colormap(gray); axis image off; title('a');
subplot(1,3,3); imagesc(b1); colormap(gray); axis image off; title('b');


% HSV ZA PENCILS

hsv2 = rgb2hsv(img2);

H2 = hsv2(:,:,1);
S2 = hsv2(:,:,2);
V2 = hsv2(:,:,3);

figure('Name','Pencils - HSV');
subplot(1,3,1); imagesc(H2); colormap(gray); axis image off; title('H');
subplot(1,3,2); imagesc(S2); colormap(gray); axis image off; title('S');
subplot(1,3,3); imagesc(V2); colormap(gray); axis image off; title('V');


%  Lab ZA PENCILS

lab2 = rgb2lab(img2);

L2 = lab2(:,:,1);
a2 = lab2(:,:,2);
b2 = lab2(:,:,3);

figure('Name','Pencils - Lab');
subplot(1,3,1); imagesc(L2); colormap(gray); axis image off; title('L');
subplot(1,3,2); imagesc(a2); colormap(gray); axis image off; title('a');
subplot(1,3,3); imagesc(b2); colormap(gray); axis image off; title('b');
==== END Alja Belinger | Alja Belinger_21501_assignsubmission_file | RV_3_1.m ====

==== BEGIN Alja Belinger | Alja Belinger_21501_assignsubmission_file | RV_3_2.m ====
clear all; close all; clc;
%% ===============================
%          NALOGA 2
%  Vpliv posameznih komponent HSV in Lab na končno RGB sliko
% ================================

%% Branje slik
img1 = imread('yosemite_meadows.jpg');
img2 = imread('coloured_pencils.jpg');

images = {img1, img2};
names = {'Yosemite', 'Pencils'};


%% HSV ANALIZA 
for k = 1:2
    img = images{k};
    name = names{k};

    hsvImg = rgb2hsv(img);

    % KONSTANTE
    constH = 0.5;
    constS = 0.5;
    constV = 0.5;

    % 1) Konstanten H
    hsvMod = hsvImg;
    hsvMod(:,:,1) = constH;
    rgbH = hsv2rgb(hsvMod);

    % 2) Konstanten S
    hsvMod = hsvImg;
    hsvMod(:,:,2) = constS;
    rgbS = hsv2rgb(hsvMod);

    % 3) Konstanten V
    hsvMod = hsvImg;
    hsvMod(:,:,3) = constV;
    rgbV = hsv2rgb(hsvMod);

    % ---- RISANJE NA ENO FIGURO ----
    figure('Name',[name ' - HSV vpliv komponent']);
    sgtitle([name ' – vpliv konstantnega H, S in V']);

    subplot(1,3,1); imshow(rgbH); title('Konstanten H');
    subplot(1,3,2); imshow(rgbS); title('Konstanten S');
    subplot(1,3,3); imshow(rgbV); title('Konstanten V');
end


%%  Lab ANALIZA 
for k = 1:2
    img = images{k};
    name = names{k};

    labImg = rgb2lab(img);

    % KONSTANTE
    constL = 50;
    consta = 0;
    constb = 50;

    % 1) Konstanten L
    labMod = labImg;
    labMod(:,:,1) = constL;
    rgbL = lab2rgb(labMod);

    % 2) Konstanten a
    labMod = labImg;
    labMod(:,:,2) = consta;
    rgbA = lab2rgb(labMod);

    % 3) Konstanten b
    labMod = labImg;
    labMod(:,:,3) = constb;
    rgbB = lab2rgb(labMod);

    % ---- RISANJE NA ENO FIGURO ----
    figure('Name',[name ' - Lab vpliv komponent']);
    sgtitle([name ' – vpliv konstantnega L, a in b']);

    subplot(1,3,1); imshow(rgbL); title('Konstanten L');
    subplot(1,3,2); imshow(rgbA); title('Konstanten a');
    subplot(1,3,3); imshow(rgbB); title('Konstanten b');
end
==== END Alja Belinger | Alja Belinger_21501_assignsubmission_file | RV_3_2.m ====

==== BEGIN Alja Belinger | Alja Belinger_21501_assignsubmission_file | RV_3_3.m ====
clear; close all; clc;

%% ===============================
%          NALOGA 3
%  Segmentacija morja
% ===============================

video = VideoReader('ladja.avi');

% število frejmov
numF = floor(video.FrameRate * video.Duration);

% vzamemo testni frame
frame0 = read(video,50);

figure, imshow(frame0)
title('Označi pravokotnik območja MORJA in 2x klikni');

% izberemo pravokotnik
roi = drawrectangle;
wait(roi);

% izrežemo območje
area = imcrop(frame0, roi.Position);

%% ===============================
%   MEJE V RGB (iz pravokotnika)
%% ===============================

Rmin = min(area(:,:,1),[],'all');
Rmax = max(area(:,:,1),[],'all');

Gmin = min(area(:,:,2),[],'all');
Gmax = max(area(:,:,2),[],'all');

Bmin = min(area(:,:,3),[],'all');
Bmax = max(area(:,:,3),[],'all');

%   SEGMENTACIJA RGB


outRGB = VideoWriter('ladja_segment_RGB.avi');
outRGB.FrameRate = video.FrameRate;
open(outRGB);

for k = 1:numF
    frame = read(video,k);

    mask = frame(:,:,1) >= Rmin & frame(:,:,1) <= Rmax & ...
           frame(:,:,2) >= Gmin & frame(:,:,2) <= Gmax & ...
           frame(:,:,3) >= Bmin & frame(:,:,3) <= Bmax;

    writeVideo(outRGB, uint8(mask)*255);
end

close(outRGB);



%     MEJE V HSV


hsv_area = rgb2hsv(area);

Hmin = min(hsv_area(:,:,1),[],'all');
Hmax = max(hsv_area(:,:,1),[],'all');

Smin = min(hsv_area(:,:,2),[],'all');
Smax = max(hsv_area(:,:,2),[],'all');


%     SEGMENTACIJA HSV


outHSV = VideoWriter('ladja_segment_HSV.avi');
outHSV.FrameRate = video.FrameRate;
open(outHSV);

for k = 1:numF
    frame = read(video,k);
    hsv = rgb2hsv(frame);

    % samo H + S
    mask = hsv(:,:,1) >= Hmin & hsv(:,:,1) <= Hmax & ...
           hsv(:,:,2) >= Smin & hsv(:,:,2) <= Smax;

    writeVideo(outHSV, uint8(mask)*255);
end

close(outHSV);

==== END Alja Belinger | Alja Belinger_21501_assignsubmission_file | RV_3_3.m ====

==== BEGIN Alja Belinger | Alja Belinger_21501_assignsubmission_file | RV_3_4.m ====
clear all; close all; clc;

%% ===============================
%      NALOGA 4 – 3D RGB HISTOGRAM
% ================================

video = VideoReader('ladja.avi');
numF = floor(video.FrameRate * video.Duration);

%% --- 1. OKVIR IN IZREŽEMO MORJE ---
frame = read(video, 50);  % isti kot prej

figure; imshow(frame); title('Označi pravokotnik z MORJEM (tipično območje)');
rect = round(getrect());   % uporabnik z miško označi ROI

% izrez
roi = imcrop(frame, rect);

figure; imshow(roi); title('Izrez morja');

%% --- 2. KONSTRUKCIJA 3D HISTOGRAMA (8 × 8 × 8) ---

bins = 8;              % št. binov po osi R, G, B
binSize = 256 / bins;  % velikost posameznega intervala

% 3D histogram
H = zeros(bins, bins, bins);

% napolnimo histogram iz ROI
for y = 1:size(roi,1)
    for x = 1:size(roi,2)

        R = roi(y,x,1);
        G = roi(y,x,2);
        B = roi(y,x,3);

        % izračun bin indeksa
        Rbin = floor(double(R) / binSize) + 1;
        Gbin = floor(double(G) / binSize) + 1;
        Bbin = floor(double(B) / binSize) + 1;

        % omejitev (če je R==255 → pade v zadnji bin)
        Rbin = min(Rbin, bins);
        Gbin = min(Gbin, bins);
        Bbin = min(Bbin, bins);

        H(Rbin, Gbin, Bbin) = H(Rbin, Gbin, Bbin) + 1;
    end
end

%% --- 3. NORMALIZACIJA HISTOGRAMA (max = 255) ---

H = H * (255 / max(H(:)));


%% --- 4. SEGMENTACIJA VIDEA S POMOČJO HISTOGRAMA ---

out = VideoWriter('ladja_segment_histogram.avi');
out.FrameRate = video.FrameRate;
open(out);

for k = 1:numF
    frame = read(video, k);

    % izhodna slika (sivinska)
    outFrame = zeros(size(frame,1), size(frame,2), 'uint8');

    for y = 1:size(frame,1)
        for x = 1:size(frame,2)

            R = frame(y,x,1);
            G = frame(y,x,2);
            B = frame(y,x,3);

            Rbin = floor(double(R) / binSize) + 1;
            Gbin = floor(double(G) / binSize) + 1;
            Bbin = floor(double(B) / binSize) + 1;

            Rbin = min(Rbin, bins);
            Gbin = min(Gbin, bins);
            Bbin = min(Bbin, bins);

            % sivinska vrednost = vrednost histograma tega 3D bin-a
            outFrame(y,x) = uint8(H(Rbin, Gbin, Bbin));
        end
    end

    % VideoWriter zahteva 3-kanalno sliko, zato sivinsko ponovimo v RGB
    rgbFrame = repmat(outFrame, [1 1 3]);

    writeVideo(out, rgbFrame);
end

close(out);

==== END Alja Belinger | Alja Belinger_21501_assignsubmission_file | RV_3_4.m ====

==== BEGIN Alja Belinger | Alja Belinger_21501_assignsubmission_file | RV_3_5.m ====
clear all; close all; clc;

%% ===============================================
%     NALOGA 5 – Histogram Intersection (4x4x4)
% ================================================

% Preberi video
video = VideoReader('ladja.avi');

% Vzamemo en okvir za učenje (npr. 50)
frame = read(video, 50);
figure; imshow(frame); title('Klikni izsek MORJA (pravokotnik)');
h = imrect;
pos = wait(h);   % uporabnik izbere ROI

% Izreži učni del
x1 = round(pos(1)); 
y1 = round(pos(2));
w  = round(pos(3));
h_ = round(pos(4));

roi = frame(y1:y1+h_-1, x1:x1+w-1, :);   % <-- popravek (w_ ni obstajal!)

figure; imshow(roi); title('Izsek morja za učenje');

%% ===============================================
%     Izračun 4x4x4 RGB histograma MORJA
% ================================================

bins = 4;
binSize = 256 / bins;

hist_sea = zeros(bins, bins, bins);

for y = 1:size(roi,1)
    for x = 1:size(roi,2)

        R = roi(y,x,1);
        G = roi(y,x,2);
        B = roi(y,x,3);

        r_bin = min(floor(double(R)/binSize) + 1, bins);
        g_bin = min(floor(double(G)/binSize) + 1, bins);
        b_bin = min(floor(double(B)/binSize) + 1, bins);

        hist_sea(r_bin, g_bin, b_bin) = hist_sea(r_bin, g_bin, b_bin) + 1;
    end
end

hist_sea = hist_sea / sum(hist_sea(:));  % normalizacija

disp('Histogram MORJA pripravljen.');

%     PRIPRAVA IZHODNEGA VIDEA


out = VideoWriter('ladja_hist_intersection.avi');
out.FrameRate = video.FrameRate;
open(out);


%     OBDELAVA VIDEA


blockSize = 8;

for k = 1:video.NumFrames
    frame = read(video, k);

    % Izhodni sivinski frame
    frameGray = zeros(size(frame,1), size(frame,2), 'uint8');

    % Zanka po blokih
    for y = 1:blockSize:size(frame,1)-blockSize+1
        for x = 1:blockSize:size(frame,2)-blockSize+1

            block = frame(y:y+blockSize-1, x:x+blockSize-1, :);

            % histogram bloka
            hist_block = zeros(bins,bins,bins);

            for yy = 1:blockSize
                for xx = 1:blockSize

                    R = block(yy,xx,1);
                    G = block(yy,xx,2);
                    B = block(yy,xx,3);

                    r_bin = min(floor(double(R)/binSize) + 1, bins);
                    g_bin = min(floor(double(G)/binSize) + 1, bins);
                    b_bin = min(floor(double(B)/binSize) + 1, bins);

                    hist_block(r_bin, g_bin, b_bin) = ...
                        hist_block(r_bin, g_bin, b_bin) + 1;
                end
            end

            hist_block = hist_block / sum(hist_block(:));

         
            HI = sum(min(hist_block(:), hist_sea(:)));

            val = uint8(HI * 255);

            frameGray(y:y+blockSize-1, x:x+blockSize-1) = val;
        end
    end

    writeVideo(out, frameGray);
    fprintf('Frame %d / %d obdelan.\n', k, video.NumFrames);
end

close(out);

==== END Alja Belinger | Alja Belinger_21501_assignsubmission_file | RV_3_5.m ====

