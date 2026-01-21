==== BEGIN Timotej Topčievski | Timotej Topčievski_22789_assignsubmission_file | vaja4.m ====
% Vaja 4
%% Naloga 1
A = imread('hotel.jpg');
Sivinska = rgb2gray(A);
imshow(Sivinska);

Sivinska = im2double(Sivinska);

Sx = [1  0 -1; 
      2  0 -2; 
      1  0 -1;];

Sy = [1  2  1; 
      0  0  0; 
     -1 -2 -1;];

Gx = imfilter(Sivinska, Sx, 'replicate', 'conv');
Gy = imfilter(Sivinska, Sy, 'replicate', 'conv');

G = sqrt(Gx.^2 + Gy.^2);

T = 1.00;
BW_sobel = G > T;

% imshow(BW_sobel)

BW_canny = edge(Sivinska, 'canny');

% Prikaz rezultatov
figure('Name','Vaja 4 - Naloga 1 (Sobel vs Canny)');
subplot(2,3,1); imshow(Sivinska); title('Sivinska slika');

subplot(2,3,2); imshow(G,[]); title('Sobel: magnituda |G|');
subplot(2,3,3); imshow(BW_sobel); title(sprintf('Sobel binarno (T = %.2f)', T));

subplot(2,3,5); imshow(BW_canny); title('Canny binarno');

% za primerjavo še overlay:
subplot(2,3,6);
imshow(Sivinska); hold on;
[y1,x1] = find(BW_sobel);
plot(x1,y1,'y.','MarkerSize',1);
title('Sobel robovi čez sliko');

figure('Name','Canny overlay');
imshow(Sivinska); hold on;
[y2,x2] = find(BW_canny);
plot(x2,y2,'g.','MarkerSize',1);
title('Canny robovi čez sliko');

%% Naloga 2

A = imread('hotel.jpg');

I = rgb2gray(A);
I = im2double(I);

% Detekcija robov (Canny)
BW = edge(I, 'canny');

% 2) Parametri Hough prostora po navodilih
kMin = -2;  kMax =  2;
nMin = -200; nMax = 200;
numParts = 400;      % 400 delov -> 401 točk

Nlines = 5;         
supK = 8;           % supresija okolice
supN = 8;

% Hough za obe binarni sliki
[A1, kVals, nVals, lines1] = houghova_transformacija(BW_sobel, Nlines, kMin, kMax, nMin, nMax, numParts, supK, supN);
[A2, ~,    ~,    lines2]  = houghova_transformacija(BW_canny, Nlines, kMin, kMax, nMin, nMax, numParts, supK, supN);

% Prikaz akumulatorja + premic

A3 = rot90(A1,1);
A4 = rot90(A2,1);

% Sobel akumulator
figure('Name','Houghova transformacija - Sobel');
subplot(1,2,1);
imagesc(kVals, nVals, A3); axis xy;
xlabel('k'); ylabel('n'); title('Akumulator A(k,n) - Sobel');
axis square
colormap(gray);
colorbar;

subplot(1,2,2);
imshow(A); hold on; title('N premic - Sobel');
draw_lines(lines1, size(A));

% Canny akumulator
figure('Name','Houghova transformacija - Canny');
subplot(1,2,1);
imagesc(nVals, kVals, A4); axis xy;
xlabel('n'); ylabel('k'); title('Akumulator A(k,n) - Canny');
axis square
colormap(gray);
colorbar;

subplot(1,2,2);
imshow(A); hold on; title('N premic - Canny');
draw_lines(lines2, size(A));

% Izpis najdenih premic

disp('SOBEL: (k, n, votes)');
for i = 1:numel(lines1)
    fprintf('%2d) k = %+0.3f, n = %+0.1f, votes = %d\n', i, lines1(i).k, lines1(i).n, lines1(i).votes);
end

disp('CANNY: (k, n, votes)');
for i = 1:numel(lines2)
    fprintf('%2d) k = %+0.3f, n = %+0.1f, votes = %d\n', i, lines2(i).k, lines2(i).n, lines2(i).votes);
end

%% Naloga 3

videoFile = 'squash.avi';
v = VideoReader(videoFile);

step = 10;        % 10 -> ~80 slik, 20 -> ~40 slik
maxKeep = 80;     % za step=20 daj 40

% prva slika za dimenzije
firstFrame = readFrame(v);
[H,W,C] = size(firstFrame);

frames = zeros(H, W, C, maxKeep, 'uint8');
frames(:,:,:,1) = firstFrame;

keep = 1;
idx  = 1;

while hasFrame(v) && keep < maxKeep
    fr = readFrame(v);
    idx = idx + 1;

    if mod(idx-1, step) == 0
        keep = keep + 1;
        frames(:,:,:,keep) = fr;
    end
end

frames = frames(:,:,:,1:keep);

% Ozadje z MODE
bg = uint8(mode(frames, 4));

figure;
imshow(bg);
title(sprintf('Ozadje (mode), step=%d, N=%d', step, keep));

imwrite(bg, 'background.png');

%% Naloga 4 in 5

% Parametri 
T = 55;         
% Morfološke nastavitve
nClose = 3;
nOpen  = 2;

% Prikaži primer
v = VideoReader(videoFile);
fr0 = readFrame(v);

D0 = rgb_evklidska_razdalja(fr0, bg); 

figure('Name','Slika razlike');
imagesc(D0); axis image; colorbar;
colormap gray;                  
title('Slika razlike (RGB evklidska razdalja)');

% Upragovljanje na sliki razlike
BW0 = D0 > T;

% Ničlanje robov
w = 10;                          % 5..20
BW0(1:w, :) = 0;                 % zgoraj
BW0(end-w+1:end, :) = 0;         % spodaj
BW0(:, 1:w) = 0;                 % levo
BW0(:, end-w+1:end) = 0;         % desno

% Morfološke operacije
BWm0 = BW0;
BWm0 = bwmorph(BWm0,'clean');
BWm0 = bwmorph(BWm0,'majority', 2);
BWm0 = bwmorph(BWm0,'open',  nOpen);
BWm0 = bwmorph(BWm0,'close', nClose);
BWm0 = bwmorph(BWm0,'fill');

% Shrani posamezne slike
D0_u8 = uint8(255 * mat2gray(D0));  % normalizacija v [0,255]
imwrite(D0_u8, 'primer_razlika.png');

imwrite(uint8(BW0)*255,  'primer_prag.png');
imwrite(uint8(BWm0)*255, 'primer_morfologija2.png');

% shrani 3-v-1
fig2 = figure('Visible','off');
subplot(1,3,1); imshow(D0,[]); title('Razlika D'); colormap gray;
subplot(1,3,2); imshow(BW0);   title('Po pragu');
subplot(1,3,3); imshow(BWm0);  title('Po morfologiji');
exportgraphics(fig2, 'primer_vse_skupaj.png', 'Resolution', 200);
close(fig2);

% Nastavi writer za izhodni video
v = VideoReader(videoFile);
vw = VideoWriter('squash_track2.avi');
vw.FrameRate = v.FrameRate;
open(vw);

% figure za risanje
fig = figure('Visible','off');
ax = axes(fig);

% Naloga 5: referenčni barvni hist
vRef = VideoReader(videoFile);
refFrame = read(vRef, 20);    % 20. frame

% ROI koordinate
ROI_red   = refFrame(157:168, 110:116, :);
ROI_white = refFrame(95:105,   80:89,  :);

nH = 18;              % 12..24
nS = 6;               % 4..8
satThr = 0.20;        % 0.15..0.30
valThr = 0.10;        % 0.05..0.20

% Izračun histogramov
hist_red   = computeHistogramHS(ROI_red,   nH, nS, satThr, valThr);
hist_white = computeHistogramHS(ROI_white, nH, nS, satThr, valThr);

% 2. video writer za nalogo 5
vw5 = VideoWriter('squash_track_hist3.avi');
vw5.FrameRate = v.FrameRate;
open(vw5);

% figure za nalogo 5
fig5 = figure('Visible','off');
ax5 = axes(fig5);

while hasFrame(v)
    fr = readFrame(v);
    
    take = [];
    stats = [];

    % slika razlike (RGB evklidska razdalja)
    D = rgb_evklidska_razdalja(fr, bg);

    % pragovanje -> binarna slika (igralca=1, ozadje=0)
    BW = D > T;
    
    % Ničlanje robov
    w = 15;                         % 5..20
    BW(1:w, :) = 0;                 % zgoraj
    BW(end-w+1:end, :) = 0;         % spodaj
    BW(:, 1:w) = 0;                 % levo
    BW(:, end-w+1:end) = 0;         % desno

    % morfološke operacije za zmanjšanje šuma (bwmorph)
    BW = bwmorph(BW,'clean');            % odstrani izolirane pike
    BW = bwmorph(BW,'majority', 4);      % dodatno zgladi šum
    BW = bwmorph(BW,'open',  nOpen);     % odstrani manjši šum
    BW = bwmorph(BW,'close', nClose);    % poveže in zapre luknje
    BW = bwmorph(BW,'fill');             % zapolni notranjost področij

    % label + najdi 2 največji področji (igralca)
    [L, num] = bwlabel(BW, 8);

    boxes = []; cents = [];
    if num > 0
        stats = regionprops(L, 'Area', 'Centroid', 'BoundingBox', 'PixelIdxList');
        areas = [stats.Area];
        [~, order] = sort(areas, 'descend');
        take = order(1:min(2,num));  % največ 2

        boxes = vertcat(stats(take).BoundingBox);
        cents = vertcat(stats(take).Centroid);
    end

    % Naloga 5: klasifikacija 2 regij po barvnem histogramu
    ids = strings(size(boxes,1),1);   % "r" ali "w"
    

    for j = 1:numel(take)
        pixIdx = stats(take(j)).PixelIdxList;
    
        % izloči RGB piksle regije (Nx3)
        fr2 = reshape(fr, [], 3);
        regRGB = fr2(pixIdx, :);

        regRGB_1x3 = reshape(regRGB, [], 1, 3);

        Hreg = computeHistogramHS(regRGB_1x3, nH, nS, satThr, valThr);

        score_red   = histIntersection2D(Hreg, hist_red);
        score_white = histIntersection2D(Hreg, hist_white);

        if score_red > score_white
            ids(j) = "r";   % rdeč igralec
        else
            ids(j) = "w";   % bel igralec
        end
    end

    % izris čez original + zapis v video
    imshow(fr, 'Parent', ax); hold(ax,'on');

    for i = 1:size(boxes,1)
        rectangle(ax, 'Position', boxes(i,:), 'EdgeColor','y', 'LineWidth', 2);
    end

    hold(ax,'off');
    axis(ax,'image'); axis(ax,'off');

    F = getframe(ax);
    writeVideo(vw, F.cdata);

    out5 = fr;

    % nariši barvne okvirje + oznake
    for i = 1:size(boxes,1)
        if ids(i) == "r"
            col = 'red';  label = 'B';
        else
            col = 'white'; label = 'A';
        end
    
        out5 = insertShape(out5, 'Rectangle', boxes(i,:), 'Color', col, 'LineWidth', 3);
        out5 = insertText(out5,[boxes(i,1) max(1,boxes(i,2)-25)],label,'TextColor',col,'BoxOpacity',0,'FontSize',18);
    end
    
    writeVideo(vw5, out5);

    cla(ax);
end

close(vw);
close(fig);
close(vw5);
disp('Končano: squash_track.avi (naloga 4) in squash_track_hist.avi (naloga 5)');

%% Funkcije

function [A, kVals, nVals, lines] = houghova_transformacija(BW, Nlines, kMin, kMax, nMin, nMax, numParts, supK, supN)
% Houghova transformacija za premice y = kx + n
% A je velikosti 401x401 (n indeks po vrsticah, k indeks po stolpcih)

    dk = (kMax - kMin)/numParts;
    dn = (nMax - nMin)/numParts;

    kVals = kMin:dk:kMax; % 401
    nVals = nMin:dn:nMax; % 401

    Nk = numel(kVals);
    Nn = numel(nVals);

    [y, x] = find(BW);         % robne točke (x=stolpec, y=vrstica)
    x = double(x);
    y = double(y);


    A = zeros(Nn, Nk, 'uint16');

    % Glasovanje: za vsak k izračunaj n = y - kx, potem akumuliraj
    for ki = 1:Nk
        nAll = y - kVals(ki)*x;                     % n za vse robne točke pri tem k

        nIdx = round((nAll - nMin)/dn) + 1;         % mapiranje na indeks 1..Nn
        valid = (nIdx >= 1) & (nIdx <= Nn);

        % štetje glasov za n indekse
        counts = accumarray(nIdx(valid), 1, [Nn, 1]);
        A(:,ki) = uint16(counts);
    end

    % Poišči Nlines najmočnejših maksimumov
    Awork = double(A);
    lines = struct('k', {}, 'n', {}, 'votes', {}, 'kIdx', {}, 'nIdx', {});

    for t = 1:Nlines
        [maxVal, linIdx] = max(Awork(:));
        if maxVal <= 0
            break;
        end

        [nI, kI] = ind2sub(size(Awork), linIdx);

        lines(t).k = kVals(kI);
        lines(t).n = nVals(nI);
        lines(t).votes = round(maxVal);
        lines(t).kIdx = kI;
        lines(t).nIdx = nI;

        % supresija okolice
        kLo = max(1, kI - supK);  kHi = min(Nk, kI + supK);
        nLo = max(1, nI - supN);  nHi = min(Nn, nI + supN);
        Awork(nLo:nHi, kLo:kHi) = 0;
    end
end

function draw_lines(lines, imgSize)
% Izriši y = kx + n čez sliko (od x=1 do x=W)
    H = imgSize(1);
    W = imgSize(2);

    for i = 1:numel(lines)
        k = lines(i).k;
        n = lines(i).n;

        x1 = 1;   y1 = k*x1 + n;
        x2 = W;   y2 = k*x2 + n;

        plot([x1 x2], [y1 y2], 'r', 'LineWidth', 1);

    end
end

% pomožna funkcija: RGB evklidska razlika ---
function D = rgb_evklidska_razdalja(frameRGB, bgRGB)
    fr = double(frameRGB);
    bg = double(bgRGB);
    dR = fr(:,:,1) - bg(:,:,1);
    dG = fr(:,:,2) - bg(:,:,2);
    dB = fr(:,:,3) - bg(:,:,3);
    D  = sqrt(dR.^2 + dG.^2 + dB.^2);
end

function H = computeHistogramHS(rgbData, nH, nS, satThr, valThr)
% 2D histogram v HSV prostoru (H,S).
% Vrne nH x nS, normalizirano.

    rgbData = im2double(rgbData);
    hsv = rgb2hsv(rgbData);

    Hh = hsv(:,:,1);    % [0,1)
    Ss = hsv(:,:,2);    % [0,1]
    Vv = hsv(:,:,3);    % [0,1]

    mask = (Ss > satThr) & (Vv > valThr);  % izloči “bele/sive” in temne piksle

    h = Hh(mask);
    s = Ss(mask);

    if isempty(h)
        H = zeros(nH, nS);
        return;
    end

    hBin = floor(h * nH) + 1;
    sBin = floor(s * nS) + 1;

    hBin = min(max(hBin, 1), nH);
    sBin = min(max(sBin, 1), nS);

    H = accumarray([hBin, sBin], 1, [nH, nS], @sum, 0);

    H = H / max(1, sum(H(:)));
end

function score = histIntersection2D(H1, H2)
% intersection score (vecji = bolj podobno)
    score = sum(min(H1, H2), 'all');
end


==== END Timotej Topčievski | Timotej Topčievski_22789_assignsubmission_file | vaja4.m ====

