==== BEGIN Adnan Halilović | Adnan Halilović_21507_assignsubmission_file | RV_3_1.m ====
% Naloga 1 
% Prikaz komponent HSV in Lab

clear all; close all; clc;

% 1) prebere sliki
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
==== END Adnan Halilović | Adnan Halilović_21507_assignsubmission_file | RV_3_1.m ====

==== BEGIN Adnan Halilović | Adnan Halilović_21507_assignsubmission_file | RV_3_2.m ====
%           NALOGA 2 
% Vpliv posameznih komponent HSV in Lab na končno RGB sliko

clear all; close all; clc;

% Branje slik
img1 = imread('yosemite_meadows.jpg');
img2 = imread('coloured_pencils.jpg');

images = {img1, img2};
names = {'Yosemite', 'Pencils'};


% HSV ANALIZA
for k = 1:2
    img = images{k};
    name = names{k};

    hsvImg = rgb2hsv(img);

    H = hsvImg(:,:,1);
    S = hsvImg(:,:,2);
    V = hsvImg(:,:,3);

    % konstante (polovica maksimalne vrednosti = 0.5)
    constH = 0.5;
    constS = 0.5;
    constV = 0.5;

    % --- 1) Vpliv H
    hsvMod = hsvImg;
    hsvMod(:,:,1) = constH;
    rgbH = hsv2rgb(hsvMod);

    figure('Name',[name ' - HSV brez H']);
    imshow(rgbH); title([name ' - konstanten H']);

    % --- 2) Vpliv S
    hsvMod = hsvImg;
    hsvMod(:,:,2) = constS;
    rgbS = hsv2rgb(hsvMod);

    figure('Name',[name ' - HSV brez S']);
    imshow(rgbS); title([name ' - konstanten S']);

    %% --- 3) Vpliv V
    hsvMod = hsvImg;
    hsvMod(:,:,3) = constV;
    rgbV = hsv2rgb(hsvMod);

    figure('Name',[name ' - HSV brez V']);
    imshow(rgbV); title([name ' - konstanten V']);

end


%       Lab ANALIZA
for k = 1:2
    img = images{k};
    name = names{k};

    labImg = rgb2lab(img);

    L = labImg(:,:,1);
    a = labImg(:,:,2);
    b = labImg(:,:,3);

    % konstante (sredina intervala)
    constL = 50;
    consta = 0;
    constb = 0;

    % --- 1) Vpliv L
    labMod = labImg;
    labMod(:,:,1) = constL;
    rgbL = lab2rgb(labMod);

    figure('Name',[name ' - Lab brez L']);
    imshow(rgbL); title([name ' - konstanten L']);

    % --- 2) Vpliv a
    labMod = labImg;
    labMod(:,:,2) = consta;
    rgbA = lab2rgb(labMod);

    figure('Name',[name ' - Lab brez a']);
    imshow(rgbA); title([name ' - konstanten a']);

    % --- 3) Vpliv b
    labMod = labImg;
    labMod(:,:,3) = constb;
    rgbB = lab2rgb(labMod);

    figure('Name',[name ' - Lab brez b']);
    imshow(rgbB); title([name ' - konstanten b']);

end
==== END Adnan Halilović | Adnan Halilović_21507_assignsubmission_file | RV_3_2.m ====

==== BEGIN Adnan Halilović | Adnan Halilović_21507_assignsubmission_file | RV_3_3.m ====
clear; close all; clc;


%          NALOGA 3
%  Segmentacija morja z ROI (pravokotnik)

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

%   MEJE V RGB (iz pravokotnika)

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
==== END Adnan Halilović | Adnan Halilović_21507_assignsubmission_file | RV_3_3.m ====

==== BEGIN Adnan Halilović | Adnan Halilović_21507_assignsubmission_file | RV_3_4.m ====
clear; close all; clc;


%          NALOGA 3


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


%   MEJE V RGB (iz pravokotnika)

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
==== END Adnan Halilović | Adnan Halilović_21507_assignsubmission_file | RV_3_4.m ====

==== BEGIN Adnan Halilović | Adnan Halilović_21507_assignsubmission_file | RV_3_5.m ====
clear all; close all; clc;

%     NALOGA 5 
% Histogram Intersection (4x4x4)


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


%     Izračun 4x4x4 RGB histograma MORJA

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
            %HISTOGRAM INTERSECTION 
            HI = sum(min(hist_block(:), hist_sea(:)));

            val = uint8(HI * 255);

            frameGray(y:y+blockSize-1, x:x+blockSize-1) = val;
        end
    end

    writeVideo(out, frameGray);
    fprintf('Frame %d / %d obdelan.\n', k, video.NumFrames);
end

close(out);
disp('Končano: ladja_hist_intersection.avi');
==== END Adnan Halilović | Adnan Halilović_21507_assignsubmission_file | RV_3_5.m ====

