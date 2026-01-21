==== BEGIN Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | hsv1_min_max.m ====
%% HSV min i max

vid = VideoReader('ladja.avi');
frame = read(vid, 50);

figure; imshow(frame);
title('Klikni 15 tačaka na moru');

[x, y] = ginput(15);

% pretvori u HSV
frameHSV = rgb2hsv(frame);

Hvals = zeros(15,1);
Svals = zeros(15,1);
Vvals = zeros(15,1);

for i = 1:15
    xi = round(x(i));
    yi = round(y(i));

    Hvals(i) = frameHSV(yi, xi, 1);
    Svals(i) = frameHSV(yi, xi, 2);
    Vvals(i) = frameHSV(yi, xi, 3);
end

% prikaz min i max
Hmin = min(Hvals);  Hmax = max(Hvals);
Smin = min(Svals);  Smax = max(Svals);
Vmin = min(Vvals);  Vmax = max(Vvals);

fprintf('Hmin = %.4f , Hmax = %.4f\n', Hmin, Hmax);
fprintf('Smin = %.4f , Smax = %.4f\n', Smin, Smax);
fprintf('Vmin = %.4f , Vmax = %.4f\n', Vmin, Vmax);
==== END Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | hsv1_min_max.m ====

==== BEGIN Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | naloga1.m ====
clc; clear; close all;

%yosemite_meadows
rgb1 = im2double(imread('yosemite_meadows.jpg'));

% HSV
hsv1 = rgb2hsv(rgb1);
H1 = hsv1(:,:,1);
S1 = hsv1(:,:,2);
V1 = hsv1(:,:,3);

figure;
subplot(2,3,1); 
imshow(rgb1); 
title('RGB - Yosemite');

subplot(2,3,2); 
imagesc(H1); 
colormap gray;
axis image; 
title('H');

subplot(2,3,3); 
imagesc(S1); 
colormap gray; 
axis image; 
title('S');

subplot(2,3,4); 
imagesc(V1); 
colormap gray; 
axis image; 
title('V');

% Lab
lab1 = rgb2lab(rgb1);
L1 = lab1(:,:,1);
a1 = lab1(:,:,2);
b1 = lab1(:,:,3);

figure;
subplot(2,3,1); 
imshow(rgb1); 
title('RGB - Yosemite');

subplot(2,3,2); 
imagesc(L1); 
colormap gray; 
axis image; 
title('L');

subplot(2,3,3); 
imagesc(a1); 
colormap gray; 
axis image; 
title('a');

subplot(2,3,4); 
imagesc(b1); 
colormap gray; 
axis image; 
title('b');

%coloured_pencils
rgb2 = im2double(imread('coloured_pencils.jpg'));

% HSV
hsv2 = rgb2hsv(rgb2);
H2 = hsv2(:,:,1);
S2 = hsv2(:,:,2);
V2 = hsv2(:,:,3);

figure;
subplot(2,3,1); 
imshow(rgb2); 
title('RGB - Pencils');

subplot(2,3,2); 
imagesc(H2); 
colormap gray; 
axis image; 
title('H');

subplot(2,3,3); 
imagesc(S2); 
colormap gray; 
axis image; 
title('S');

subplot(2,3,4); 
imagesc(V2); 
colormap gray; 
axis image; 
title('V');

% Lab
lab2 = rgb2lab(rgb2);
L2 = lab2(:,:,1);
a2 = lab2(:,:,2);
b2 = lab2(:,:,3);

figure;
subplot(2,3,1); 
imshow(rgb2); 
title('RGB - Pencils');

subplot(2,3,2); 
imagesc(L2); 
colormap gray; 
axis image; 
title('L');

subplot(2,3,3); 
imagesc(a2); 
colormap gray; 
axis image; 
title('a');

subplot(2,3,4); 
imagesc(b2); 
colormap gray; 
axis image; 
title('b');
==== END Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | naloga1.m ====

==== BEGIN Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | naloga2.m ====
%HSV

%yosemite_meadows
rgb1 = im2double(imread('yosemite_meadows.jpg'));
hsv1 = rgb2hsv(rgb1);

h1 = hsv1(:,:,1);
s1 = hsv1(:,:,2);
v1 = hsv1(:,:,3);

% H konstantan
hsv1_Hconst = hsv1;
hsv1_Hconst(:,:,1) = 0.5;

% S konstantan
hsv1_Sconst = hsv1;
hsv1_Sconst(:,:,2) = 0.5;

% V konstantan
hsv1_Vconst = hsv1;
hsv1_Vconst(:,:,3) = 0.5;

figure;
subplot(2,2,1); 
imshow(rgb1);
title('Yosemite');

subplot(2,2,2); 
imshow(hsv2rgb(hsv1_Hconst)); 
title('H=const');

subplot(2,2,3); 
imshow(hsv2rgb(hsv1_Sconst)); 
title('S=const');

subplot(2,2,4); 
imshow(hsv2rgb(hsv1_Vconst)); 
title('V=const');


%coloured_pencils
rgb2 = im2double(imread('coloured_pencils.jpg'));
hsv2 = rgb2hsv(rgb2);

h2 = hsv2(:,:,1);
s2 = hsv2(:,:,2);
v2 = hsv2(:,:,3);

%H konstantan
hsv2_Hconst = hsv2;
hsv2_Hconst(:,:,1) = 0.5;

%S konstantan
hsv2_Sconst = hsv2;
hsv2_Sconst(:,:,2) = 0.5;

%V konstantan
hsv2_Vconst = hsv2;
hsv2_Vconst(:,:,3) = 0.5;

figure;
subplot(2,2,1); imshow(rgb2);
title('Pencils');

subplot(2,2,2); 
imshow(hsv2rgb(hsv2_Hconst)); 
title('H=const');

subplot(2,2,3); 
imshow(hsv2rgb(hsv2_Sconst)); 
title('S=const');

subplot(2,2,4); 
imshow(hsv2rgb(hsv2_Vconst)); 
title('V=const');

%Lab
%yosemite_meadows
lab1 = rgb2lab(rgb1);

L1 = lab1(:,:,1);
A1 = lab1(:,:,2);
B1 = lab1(:,:,3);

%L konstantan
lab1_Lconst = lab1;
lab1_Lconst(:,:,1) = 50;

%a konstantan
lab1_Aconst = lab1;
lab1_Aconst(:,:,2) = 0;

%b konstanatn
lab1_Bconst = lab1;
lab1_Bconst(:,:,3) = 0;

figure;
subplot(2,2,1); 
imshow(rgb1);
title('Yosemite');

subplot(2,2,2); 
imshow(lab2rgb(lab1_Lconst)); 
title('L=const');

subplot(2,2,3); 
imshow(lab2rgb(lab1_Aconst)); 
title('a=const');

subplot(2,2,4); 
imshow(lab2rgb(lab1_Bconst)); 
title('b=const');

%coloured_pencils
lab2 = rgb2lab(rgb2);

L2 = lab2(:,:,1);
A2 = lab2(:,:,2);
B2 = lab2(:,:,3);

%L konstanatn
lab2_Lconst = lab2;
lab2_Lconst(:,:,1) = 50;

%a konstanatn
lab2_Aconst = lab2;
lab2_Aconst(:,:,2) = 0;

%b konstantan
lab2_Bconst = lab2;
lab2_Bconst(:,:,3) = 0;

figure;
subplot(2,2,1); 
imshow(rgb2);
title('Pencils');

subplot(2,2,2); 
imshow(lab2rgb(lab2_Lconst)); 
title('L=const');

subplot(2,2,3); 
imshow(lab2rgb(lab2_Aconst)); 
title('a=const');

subplot(2,2,4); 
imshow(lab2rgb(lab2_Bconst)); 
title('b=const');

==== END Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | naloga2.m ====

==== BEGIN Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | naloga3.m ====
%% RGB

vid = VideoReader('ladja.avi');
frames = read(vid, [1 Inf]);

% Dimenzije videa
[H, W, ~, N] = size(frames);

% Izgled 50. framea (Opcionalno)
%frame_50 = frames(:, :, :, 50);

for m = 1:N
    for i = 1:H
        for j = 1:W

            R = frames(i, j, 1, m);
            G = frames(i, j, 2, m);
            B = frames(i, j, 3, m);

            %odredjeno iz koda za min i max vrijednosti
            if (33 <= R && R <= 114 && 63 <= G && G <= 139 && 37 <= B && B <= 129)
                frames(i, j, 1, m) = 255;
                frames(i, j, 2, m) = 255;
                frames(i, j, 3, m) = 255;
            else
                frames(i, j, 1, m) = 0;
                frames(i, j, 2, m) = 0;
                frames(i, j, 3, m) = 0;
            end
        end
    end
end

writer_object = VideoWriter('ladjaRGB.avi');
writer_object.FrameRate = 25;
open(writer_object);
writeVideo(writer_object, frames);
close(writer_object);

%% HSV1
vid = VideoReader('ladja.avi');
frames = read(vid, [1 Inf]);

% dimenzije
[H, W, ~, nFrames] = size(frames);

% konverzija svih frameova u HSV
framesHSV = zeros(H, W, 3, nFrames);
for m = 1:nFrames
    framesHSV(:,:,:,m) = rgb2hsv(frames(:,:,:,m));
end

%min i max za H
Hmin = 0.35;
Hmax = 0.45;

for m = 1:nFrames
    for i = 1:H
        for j = 1:W
            if Hmin <= framesHSV(i,j,1,m) && framesHSV(i,j,1,m) <= Hmax
                frames(i,j,1,m) = 255;
                frames(i,j,2,m) = 255;
                frames(i,j,3,m) = 255;
            else
                frames(i,j,1,m) = 0;
                frames(i,j,2,m) = 0;
                frames(i,j,3,m) = 0;
            end
        end
    end
end

% zapis videa
writer_object = VideoWriter('ladjaHSV1.avi');
writer_object.FrameRate = 25;
open(writer_object);
writeVideo(writer_object, frames);
close(writer_object);

%% HSV2

% Učitaj sve frameove videa
ladja  = VideoReader('ladja.avi');
frames = read(ladja,[1 Inf]);
[H, W, ~, nFrames] = size(frames);

% svi rameovi u HSV
framesHSV = zeros(H, W, 3, nFrames);
for k = 1:nFrames
    framesHSV(:,:,:,k) = rgb2hsv(frames(:,:,:,k));
end

% H i S, min i max
Hmin2 = 0.35;  
Hmax2 = 0.45;
Smin2 = 0.2;  
Smax2 = 0.45;

for m = 1:nFrames
    for i = 1:H
        for j = 1:W
            Hval = framesHSV(i,j,1,m);
            Vval = framesHSV(i,j,3,m);

            if (Hval >= Hmin2 && Hval <= Hmax2 && Vval >= Smin2 && Vval <= Smax2)
                frames(i,j,1,m) = 255;
                frames(i,j,2,m) = 255;
                frames(i,j,3,m) = 255;
            else
                frames(i,j,1,m) = 0;
                frames(i,j,2,m) = 0;
                frames(i,j,3,m) = 0;
            end
        end
    end
end

% rezultat
writer_object = VideoWriter('ladjaHSV2.avi');
writer_object.FrameRate = 25;
open(writer_object);
writeVideo(writer_object, frames);
close(writer_object);

%% HSV3

ladja   = VideoReader('ladja.avi');
frames  = read(ladja, [1 Inf]);
nFrames = size(frames, 4);

% Konverzija svih frameova u HSV
framesHSV = zeros(H,W,3,nFrames);
for m = 1:nFrames
    framesHSV(:,:,:,m) = rgb2hsv(frames(:,:,:,m));
end

% H,S,V min i max
Hmin3 = 0.35;  
Hmax3 = 0.45;
Smin3 = 0.2;  
Smax3 = 0.45;
Vmin = 0.3;  
Vmax = 0.49;

% piksel je bijel ako zadovoljava sva tri uslova, inače crn
[H, W, ~, ~] = size(frames);
for m = 1:nFrames
    for i = 1:H
        for j = 1:W
            Hval = framesHSV(i,j,1,m);
            Sval = framesHSV(i,j,2,m);
            Vval = framesHSV(i,j,3,m);

            if (Hval >= Hmin3 && Hval <= Hmax3 && Sval >= Smin3 && Sval <= Smax3 && Vval >= Vmin && Vval <= Vmax)
                frames(i,j,1,m) = 255;
                frames(i,j,2,m) = 255;
                frames(i,j,3,m) = 255;
            else
                frames(i,j,1,m) = 0;
                frames(i,j,2,m) = 0;
                frames(i,j,3,m) = 0;
            end
        end
    end
end

% rezultati
writer_object = VideoWriter('ladjaHSV3.avi');
writer_object.FrameRate = 25;
open(writer_object);
writeVideo(writer_object, frames);
close(writer_object);


==== END Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | naloga3.m ====

==== BEGIN Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | naloga3_min_max.m ====
%Jedan frame iz videa
vid = VideoReader('ladja.avi');
frame = read(vid, 50);

figure; imshow(frame);
title('Klikni 15 tocaka na moru');

[x, y] = ginput(15);

%Očitane RGB vrijednosti
vals = zeros(length(x), 3);

%Očitan RGB za svaku točku
for i = 1:length(x)
    xi = round(x(i));
    yi = round(y(i));
    vals(i, :) = frame(yi, xi, :);
end

%min i max
Rmin = min(vals(:,1));
Rmax = max(vals(:,1));
Gmin = min(vals(:,2));
Gmax = max(vals(:,2));
Bmin = min(vals(:,3));
Bmax = max(vals(:,3));

%Rezultati
fprintf('Rmin = %d , Rmax = %d\n', Rmin, Rmax);
fprintf('Gmin = %d , Gmax = %d\n', Gmin, Gmax);
fprintf('Bmin = %d , Bmax = %d\n', Bmin, Bmax);
==== END Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | naloga3_min_max.m ====

==== BEGIN Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | naloga4.m ====
%% NALOGA 4: Avtomatska segmentacija morja z 3D RGB histogramom
clear; close all; clc;

%% Naloži video
video = VideoReader('ladja.avi');

%%  Preberi prvi frame za učno območje
frame = read(video, 1);
imshow(frame); hold on;
title('Klikni vsaj 3 točke poligona za označitev morja, Enter ko končaš');

%%  Interaktivni poligon za morje
[x, y] = ginput;  % klikni več točk in pritisni Enter

% Preveri, da je vsaj 3 točke
if length(x) < 3
    error('Moraš klikniti vsaj 3 točke za poligon.');
end

% Prikaži poligon
plot([x; x(1)], [y; y(1)], 'r-', 'LineWidth', 2);

%% Ustvarjanje maske z inpolygon (brez poly2mask)
[XX, YY] = meshgrid(1:size(frame,2), 1:size(frame,1));
mask = inpolygon(XX, YY, x, y);

% Prikaz maske
figure;
imshow(mask);
title('Maska izbranega območja');

%%Ekstrakcija pikslov morja
R_sel = double(frame(:,:,1));
G_sel = double(frame(:,:,2));
B_sel = double(frame(:,:,3));

R_sel = R_sel(mask);
G_sel = G_sel(mask);
B_sel = B_sel(mask);

%% Ustvarjanje 3D RGB histograma
numBins = 8;                        % 8x8x8 binov
edges = linspace(0, 255, numBins+1);
hist3D = zeros(numBins, numBins, numBins);

for i = 1:length(R_sel)
    r_bin = find(edges >= R_sel(i),1)-1; r_bin = max(r_bin,1);
    g_bin = find(edges >= G_sel(i),1)-1; g_bin = max(g_bin,1);
    b_bin = find(edges >= B_sel(i),1)-1; b_bin = max(b_bin,1);
    hist3D(r_bin,g_bin,b_bin) = hist3D(r_bin,g_bin,b_bin) + 1;
end

% Normalizacija histograma (maksimalni bin = 255)
hist3D = uint8(255 * hist3D / max(hist3D(:)));

outVid = VideoWriter('naloga4_output.avi');
outVid.FrameRate = video.FrameRate;
open(outVid);

%%  Obdelava vseh frame-ov videa (vektorizirano)
video.CurrentTime = 0;
while hasFrame(video)
    frame = readFrame(video);

    Rf = double(frame(:,:,1));
    Gf = double(frame(:,:,2));6
    Bf = double(frame(:,:,3));

    % določitev binov
    r_bin = discretize(Rf, edges);
    g_bin = discretize(Gf, edges);
    b_bin = discretize(Bf, edges);

    % nadomestimo NaN z 1
    r_bin(isnan(r_bin)) = 1;
    g_bin(isnan(g_bin)) = 1;
    b_bin(isnan(b_bin)) = 1;

    % vektorizirana dodelitev sivinskega frame-a
    grayFrame = hist3D(sub2ind(size(hist3D), r_bin, g_bin, b_bin));
    grayFrame = uint8(grayFrame);

    writeVideo(outVid, grayFrame);
end

close(outVid);
disp('Video naloge 4 ustvarjen: naloga4_output.avi');
==== END Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | naloga4.m ====

==== BEGIN Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | naloga5.m ====
%% NALOGA 5: Segmentacija z histogram intersection
clear; close all; clc;

%% 1) Naloži video
video = VideoReader('ladja.avi');
frame = read(video,1);

%% 2) Interaktivni poligon za morje
imshow(frame); hold on;
title('Klikni vsaj 3 točke poligona za morje, Enter ko končaš');
[x, y] = ginput;
if length(x) < 3
    error('Moraš klikniti vsaj 3 točke za poligon.');
end
plot([x;x(1)],[y;y(1)],'r-','LineWidth',2);

[XX, YY] = meshgrid(1:size(frame,2), 1:size(frame,1));
mask = inpolygon(XX, YY, x, y);

%% 3) Histogram morja 4x4x4
numBins = 4;
edges = linspace(0,255,numBins+1);

R_sel = double(frame(:,:,1)); R_sel = R_sel(mask);
G_sel = double(frame(:,:,2)); G_sel = G_sel(mask);
B_sel = double(frame(:,:,3)); B_sel = B_sel(mask);

histSea = zeros(numBins,numBins,numBins);
for i = 1:length(R_sel)
    r_bin = find(edges >= R_sel(i),1)-1; r_bin = max(r_bin,1);
    g_bin = find(edges >= G_sel(i),1)-1; g_bin = max(g_bin,1);
    b_bin = find(edges >= B_sel(i),1)-1; b_bin = max(b_bin,1);
    histSea(r_bin,g_bin,b_bin) = histSea(r_bin,g_bin,b_bin) + 1;
end
histSea = histSea / sum(histSea(:)); % normaliziramo na vsoto 1

%% 4) Priprava output videa
outVid = VideoWriter('naloga5_output.avi');
outVid.FrameRate = video.FrameRate;
open(outVid);

blockSize = 8;  % 8x8 pikslov

%% 5) Obdelava frame-ov
video.CurrentTime = 0;
while hasFrame(video)
    frame = readFrame(video);
    [H, W, ~] = size(frame);
    
    % Število blokov
    H_blocks = floor(H/blockSize);
    W_blocks = floor(W/blockSize);
    
    grayFrame = zeros(H_blocks*blockSize, W_blocks*blockSize, 'uint8');
    
    % Obdelaj vsak blok
    for i = 1:H_blocks
        for j = 1:W_blocks
            rowIdx = (i-1)*blockSize + (1:blockSize);
            colIdx = (j-1)*blockSize + (1:blockSize);
            
            R_block = double(frame(rowIdx, colIdx,1));
            G_block = double(frame(rowIdx, colIdx,2));
            B_block = double(frame(rowIdx, colIdx,3));
            
            % histogram bloka
            histBlock = zeros(numBins,numBins,numBins);
            for r = 1:blockSize
                for c = 1:blockSize
                    r_bin = find(edges >= R_block(r,c),1)-1; r_bin = max(r_bin,1);
                    g_bin = find(edges >= G_block(r,c),1)-1; g_bin = max(g_bin,1);
                    b_bin = find(edges >= B_block(r,c),1)-1; b_bin = max(b_bin,1);
                    histBlock(r_bin,g_bin,b_bin) = histBlock(r_bin,g_bin,b_bin) + 1;
                end
            end
            histBlock = histBlock / sum(histBlock(:));
            
            % Histogram intersection
           intersectVal = sum(min(histSea(:), histBlock(:))) / sum(histSea(:));
            
            % Shrani v sivinski blok (0-256)
            grayBlock = uint8(intersectVal*256);
            grayFrame(rowIdx, colIdx) = grayBlock;
        end
    end
    
    writeVideo(outVid, grayFrame);
end

close(outVid);
disp('Video naloge 5 ustvarjen: naloga5_output.avi');
==== END Dunja Mihajlović | Dunja Mihajlović_21518_assignsubmission_file | naloga5.m ====

