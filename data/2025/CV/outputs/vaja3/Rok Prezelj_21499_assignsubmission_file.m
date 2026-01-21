==== BEGIN Rok Prezelj | Rok Prezelj_21499_assignsubmission_file | main.m ====
%% Naloga 1 – Barvni prostori HSV in Lab
clc; clear; close all;

% Slike iz naloge
slike = { ...
    'yosemite_meadows.jpg', ...
    'coloured_pencils.jpg' ...
};

for idx = 1:length(slike)
    img = imread(slike{idx});
    img_name = slike{idx};
    img_name = img_name(1:end-4);

    fprintf("Obdelujem sliko: %s\n", slike{idx});

    % --- HSV PRETVORBA ---
    hsv_img = rgb2hsv(img);

    H = hsv_img(:,:,1);
    S = hsv_img(:,:,2);
    V = hsv_img(:,:,3);

    % Prikaz HSV komponent
    fig = figure('Name',['HSV - ' slike{idx}], ...
             'Position',[50 50 1600 500]);

    tiledlayout(1,3,'TileSpacing','compact','Padding','compact');

    nexttile; imagesc(H); axis image off; colormap(gray);
    title('H komponenta');

    nexttile; imagesc(S); axis image off; colormap(gray);
    title('S komponenta');

    nexttile; imagesc(V); axis image off; colormap(gray);
    title('V komponenta');

    filename = "1." + img_name + "_HSV.png";
    exportgraphics(fig, filename, 'Resolution',300);


    % --- Lab PRETVORBA ---
    lab_img = rgb2lab(img);

    L = lab_img(:,:,1);
    a = lab_img(:,:,2);
    b = lab_img(:,:,3);

    % Normalizacija za prikaz (Lab ni v [0,1])
    Ln = mat2gray(L);   % samodejno skalarira v 0–1
    an = mat2gray(a);
    bn = mat2gray(b);

    fig = figure('Name',['Lab - ' slike{idx}], ...
             'Position',[50 50 1600 500]);

    tiledlayout(1,3,'TileSpacing','compact','Padding','compact');

    nexttile;imagesc(Ln); axis image off; colormap(gray);
    title('L komponenta');

    nexttile;imagesc(an); axis image off; colormap(gray);
    title('a komponenta');

    nexttile;imagesc(bn); axis image off; colormap(gray);
    title('b komponenta');

    filename = "1."+ img_name + "_LAB.png";
    exportgraphics(fig, filename, 'Resolution',300);
end

%% Naloga 2 – Vpliv posameznih komponent na rekonstruirano RGB sliko
clc; clear; close all;

% Slike iz naloge
slike = { ...
    'yosemite_meadows.jpg', ...
    'coloured_pencils.jpg' ...
};

for idx = 1:length(slike)
    img = im2double(imread(slike{idx}));
    img_name = string(slike{idx}(1:end-4));

    fprintf("Obdelujem sliko: %s\n", slike{idx});

    % ---------------- HSV PROSTOR ----------------
    hsv_img = rgb2hsv(img);

    H = hsv_img(:,:,1);
    S = hsv_img(:,:,2);
    V = hsv_img(:,:,3);

    % Konstante iz navodil:
    constH = 0.5;     % ali mean(H(:))
    constS = 0.5;
    constV = 0.5;

    % Rekonstrukcije
    hsv_H = hsv_img; hsv_H(:,:,1) = constH;
    img_H = hsv2rgb(hsv_H);

    hsv_S = hsv_img; hsv_S(:,:,2) = constS;
    img_S = hsv2rgb(hsv_S);

    hsv_V = hsv_img; hsv_V(:,:,3) = constV;
    img_V = hsv2rgb(hsv_V);

    % Prikaz HSV rezultatov
    fig = figure('Name', ['Vpliv HSV komponent - ' slike{idx}]);

    subplot(2,2,1), imshow(img), title('Original');
    subplot(2,2,2), imshow(img_H), title('H = konst');
    subplot(2,2,3), imshow(img_S), title('S = konst');
    subplot(2,2,4), imshow(img_V), title('V = konst');

    filename = append("2.", img_name, "_HSV.png");
    saveas(fig, filename)

    % ---------------- Lab PROSTOR ----------------
    lab_img = rgb2lab(img);

    L = lab_img(:,:,1);
    a = lab_img(:,:,2);
    b = lab_img(:,:,3);

    % Konstante – po navodilih so dovoljeni poljubni (srednje vrednosti)
    constL = 50;     % L je 0–100
    consta = 0;              % a v [-128, 127]
    constb = 0;              % b v [-128, 127]

    % Rekonstrukcije
    lab_L = lab_img; lab_L(:,:,1) = constL;
    img_L = lab2rgb(lab_L);

    lab_a = lab_img; lab_a(:,:,2) = consta;
    img_a = lab2rgb(lab_a);

    lab_b = lab_img; lab_b(:,:,3) = constb;
    img_b = lab2rgb(lab_b);

    % Prikaz Lab rezultatov
    fig = figure('Name', ['Vpliv Lab komponent - ' slike{idx}]);

    subplot(2,2,1), imshow(img), title('Original');
    subplot(2,2,2), imshow(img_L), title('L = konst');
    subplot(2,2,3), imshow(img_a), title('a = konst');
    subplot(2,2,4), imshow(img_b), title('b = konst');

    filename = append("2.", img_name, "_Lab.png");
    saveas(fig, filename)
end


%% Naloga 3 – Ročna segmentacija na podlagi barve
clc; clear; close all;

video = VideoReader('ladja.avi');

frame = read(video, 41); % Frame z največ vode
frame_HSV = im2double(frame);

figure; imshow(frame_HSV);
title('Izbrani frame za analizo barv');

% --- Omogoči prikaz RGB ob kliku na piksel ---
dcm = datacursormode(gcf);
dcm.Enable = 'on';
dcm.UpdateFcn = @(obj,event) myClickCallback(event, frame_HSV);

% --- Callback funkcija (MORA BITI NA KONCU DATOTEKE) ---
function l = myClickCallback(event, img)
    pos = round(event.Position);
    x = pos(1);
    y = pos(2);
    R = img(y,x,1);
    G = img(y,x,2);
    B = img(y,x,3);

    fprintf("Klik na piksel (%d, %d): R=%.3f  G=%.3f  B=%.3f\n", ...
        x, y, R, G, B);
    l = true;
end


%% Določevanje moraj RGB
Rmin = 0.10;  Rmax = 0.30;
Gmin = 0.15;  Gmax = 0.40;
Bmin = 0.10;  Bmax = 0.35;

output_RGB = VideoWriter('3.segmentacija_RGB.avi');
output_RGB.FrameRate = video.FrameRate;
open(output_RGB);

video.CurrentTime = 0;

while hasFrame(video)
    frm = im2double(readFrame(video));

    R = frm(:,:,1);
    G = frm(:,:,2);
    B = frm(:,:,3);

    mask = (R > Rmin & R < Rmax & ...
            G > Gmin & G < Gmax & ...
            B > Bmin & B < Bmax);

    bin_img = uint8(mask) * 255;  % črno-beli prikaz

    writeVideo(output_RGB, bin_img);
end

close(output_RGB);
fprintf("segmentacija_RGB.avi ustvarjen.\n");

%% Pridobivanje HSV moraj
clc;
video = VideoReader('ladja.avi');

frame = read(video, 41); % Frame z največ vode
frame_RGB = im2double(frame);
frame_HSV = rgb2hsv(frame_RGB);

figure; imshow(frame_RGB);
title('Izbrani frame za analizo barv');

% --- Omogoči prikaz RGB ob kliku na piksel ---
dcm = datacursormode(gcf);
dcm.Enable = 'on';
dcm.UpdateFcn = @(obj,event) myClickCallbackHSV(event, frame_HSV);

% --- Callback funkcija (MORA BITI NA KONCU DATOTEKE) ---
function l = myClickCallbackHSV(event, img)
    pos = round(event.Position);
    x = pos(1);
    y = pos(2);
    H = img(y,x,1);
    S = img(y,x,2);
    V = img(y,x,3);

    fprintf("Klik na piksel (%d, %d): H=%.3f  S=%.3f  V=%.3f\n", ...
        x, y, H, S, V);
    l = true;
end
%% Določevanje moraj RGB
Hmin = 0.32;  Hmax = 0.46;
Smin = 0.15;  Smax = 0.60;
Vmin = 0.25;  Vmax = 0.45;

output_HSV = VideoWriter('3.segmentacija_HSV.avi');
output_HSV.FrameRate = video.FrameRate;
open(output_HSV);

video.CurrentTime = 0;

while hasFrame(video)
    frm = rgb2hsv(im2double(readFrame(video)));

    H = frm(:,:,1);
    S = frm(:,:,2);
    V = frm(:,:,3);

    mask = (H > Hmin & H < Hmax & ...
            S > Smin & S < Smax & ...
            V > Vmin & V < Vmax);

    bin_img = uint8(mask) * 255;  % črno-beli prikaz

    writeVideo(output_HSV, bin_img);
end

close(output_HSV);
fprintf("segmentacija_HSV.avi ustvarjen.\n");
%% Naloga 4 – Avtomatska segmentacija
clc; clear; close all;

video = VideoReader('ladja.avi');
frame = im2double(read(video, 41));

figure; imshow(frame);
title('Izberite pravokotni ROI za morje');

roi = drawrectangle();
mask = roi.createMask(frame);   % 2D logična maska

% Izrez "patcha" za histogram
[y, x] = find(mask);
patch = frame(min(y):max(y), min(x):max(x), :);

% figure; imshow(patch);
title('Izrezana tipična barva morja');

% --- 2) Izračun 3D RGB histograma nxnxn ---
for bins = [2, 4, 6, 8, 16]
    R = patch(:,:,1);
    G = patch(:,:,2);
    B = patch(:,:,3);

    % Indeksi za vsak kanal
    Ri = floor(R * bins) + 1;  Ri(Ri > bins) = bins;
    Gi = floor(G * bins) + 1;  Gi(Gi > bins) = bins;
    Bi = floor(B * bins) + 1;  Bi(Bi > bins) = bins;

    hist3D = zeros(bins, bins, bins);

    for i = 1:numel(Ri)
        r = Ri(i); g = Gi(i); b = Bi(i);
        hist3D(r, g, b) = hist3D(r, g, b) + 1;
    end

    % --- 3) Normalizacija histograma ---
    max_val = max(hist3D(:));
    if max_val > 0
        hist3D = hist3D / max_val * 255;
    end

    % --- 4) Uporaba histograma za obdelavo videa ---
    video = VideoReader('ladja.avi');
    filename = append('4.segmentacija_histogram_' , string(bins), '.avi');
    output = VideoWriter(filename);
    output.FrameRate = video.FrameRate;
    open(output);

    while hasFrame(video)
        frm = im2double(readFrame(video));

        Rf = frm(:,:,1);
        Gf = frm(:,:,2);
        Bf = frm(:,:,3);

        % Indeksi binov
        Ri = floor(Rf * bins) + 1; Ri(Ri > bins) = bins;
        Gi = floor(Gf * bins) + 1; Gi(Gi > bins) = bins;
        Bi = floor(Bf * bins) + 1; Bi(Bi > bins) = bins;

        % Sivinska slika, kjer vsak piksel dobi vrednost histograma
        gray_img = zeros(size(Rf));

        for y = 1:size(frm,1)
            for x = 1:size(frm,2)
                r = Ri(y,x);
                g = Gi(y,x);
                b = Bi(y,x);
                gray_img(y,x) = hist3D(r,g,b);
            end
        end

        gray_img = uint8(gray_img);

        writeVideo(output, gray_img);
    end
    close(output)
    fig = figure; hold on;

    for r = 1:bins
        for g = 1:bins
            for b = 1:bins
                v = hist3D(r,g,b);   % vrednost
                if v > 0
                    scatter3(r, g, b, v/2, [r g b] / bins, 'filled');
                end
            end
        end
    end
    grid on;
    view(45, 30);
    xlabel('R bin');
    ylabel('G bin');
    zlabel('B bin');
    title('3D RGB histogram');
    figurename = append('4.segmentacija_histogram_' , string(bins), '.png');
    saveas(fig, figurename)
    rotate3d on;
end


%% Naloga 5 – Histogram intersection segmentacija (4x4x4 + bloki 8x8)
clc; clear; close all;

video = VideoReader('ladja.avi');

frame = im2double(read(video, 41));
figure; imshow(frame);
title('Izberite pravokotnik, ki predstavlja morje');
rectangle = drawrectangle();

mask = rectangle.createMask(frame);
[y, x] = find(mask);
selected_part_of_frame = frame(min(y):max(y), min(x):max(x), :);

% --- 2) Izračun referenčnega 4×4×4 histograma ---
bins = 4;
hist_ref = rgb_histogram(selected_part_of_frame, bins);
norm_hist_ref = hist_ref / sum(hist_ref);

fig = figure; bar(norm_hist_ref);
title('Referenčni histogram morja (4×4×4)');

saveas(fig, "5.referecni_diagram.png");

% --- 3) Obdelava videa v blokih 8×8 ---
video = VideoReader('ladja.avi');
out = VideoWriter('5.segmentacija_intersection.avi');
out.FrameRate = video.FrameRate;
open(out);

block_size = 8;

while hasFrame(video)
    frm = im2double(readFrame(video));
    [h, w, ~] = size(frm);
    out_img = zeros(h, w);

    for row = 1:block_size:h-block_size+1
        for col = 1:block_size:w-block_size+1

            block = frm(row:row+block_size-1, col:col+block_size-1, :);

            hist_blk = rgb_histogram(block, bins);
            hist_blk = hist_blk / sum(hist_blk);

            % I = sum(min(norm_hist_ref, hist_blk));
            I = sum(min(hist_ref, hist_blk)) / sum(hist_ref);

            out_img(row:row+block_size-1, col:col+block_size-1) = I * 256;
        end
    end

    writeVideo(out, uint8(out_img));
end

close(out);

fprintf("segmentacija_intersection.avi ustvarjen.\n");

function H = rgb_histogram(img, bins)
    img = im2double(img);
    R = img(:,:,1); G = img(:,:,2); B = img(:,:,3);

    Ri = floor(R * bins) + 1; Ri(Ri > bins) = bins;
    Gi = floor(G * bins) + 1; Gi(Gi > bins) = bins;
    Bi = floor(B * bins) + 1; Bi(Bi > bins) = bins;

    H3 = zeros(bins, bins, bins);

    for i = 1:numel(Ri)
        H3(Ri(i), Gi(i), Bi(i)) = H3(Ri(i), Gi(i), Bi(i)) + 1;
    end

    H = H3(:);   % 64-dim vektor
end
==== END Rok Prezelj | Rok Prezelj_21499_assignsubmission_file | main.m ====

