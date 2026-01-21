==== BEGIN Filip Kocjančič | Filip Kocjančič_21496_assignsubmission_file | koda_za_oddajo.m ====
close all;
clear;

yosemite_RGB = imread('yosemite_meadows.jpg');
pencils_RGB = imread('coloured_pencils.jpg');

yosemite_HSV = rgb2hsv(yosemite_RGB);
pencils_HSV = rgb2hsv(pencils_RGB);

yosemite_LAB = rgb2lab(yosemite_RGB);
pencils_LAB = rgb2lab(pencils_RGB);

sliki_HSV{1} = yosemite_HSV;
sliki_HSV{2} = pencils_HSV;

sliki_LAB{1} = yosemite_LAB;
sliki_LAB{2} = pencils_LAB;

%% 1 HSV

oznake_komponent = ["hue", "saturation", "value"];

for i = 1:3

    figure;
    imagesc(yosemite_HSV(:, :, i));
    colormap(gray);
    title(sprintf('yosemite\n%s', oznake_komponent(i)));

end

for i = 1:3

    figure;
    imagesc(pencils_HSV(:, :, i));
    colormap(gray);
    title(sprintf('pencils\n%s', oznake_komponent(i)));

end

%% 1 LAB

oznake_komponent = ["lightness", "a", "b"];

for i = 1:3

    figure;
    imagesc(yosemite_LAB(:, :, i));
    colormap(gray);
    title(sprintf('yosemite\n%s', oznake_komponent(i)));

end

for i = 1:3

    figure;
    imagesc(pencils_LAB(:, :, i));
    colormap(gray);
    title(sprintf('pencils\n%s', oznake_komponent(i)));

end

%% 2 – imena slik za naslove

imena_slik = {'yosemite', 'pencils'};

%% 2 HSV H=konst

for i = 1:2

    x = sliki_HSV{i};
    x(:, :, 1) = mean(x(:, :, 1), 'all');
    x_RGB = hsv2rgb(x);
    figure;
    imshow(x_RGB);
    title(sprintf('%s\nHSV, H = konst', imena_slik{i}));

end

% 2 HSV S=konst

for i = 1:2

    x = sliki_HSV{i};
    x(:, :, 2) = mean(x(:, :, 2), 'all');
    x_RGB = hsv2rgb(x);
    figure;
    imshow(x_RGB);
    title(sprintf('%s\nHSV, S = konst', imena_slik{i}));

end

% 2 HSV V=konst

for i = 1:2

    x = sliki_HSV{i};
    x(:, :, 3) = mean(x(:, :, 3), 'all');
    x_RGB = hsv2rgb(x);
    figure;
    imshow(x_RGB);
    title(sprintf('%s\nHSV, V = konst', imena_slik{i}));

end

%% 2 LAB L=konst

for i = 1:2

    x = sliki_LAB{i};
    x(:, :, 1) = mean(x(:, :, 1), 'all');
    x_RGB = lab2rgb(x);
    figure;
    imshow(x_RGB);
    title(sprintf('%s\nLab, L = konst', imena_slik{i}));

end

% 2 LAB a=konst

for i = 1:2

    x = sliki_LAB{i};
    x(:, :, 2) = mean(x(:, :, 2), 'all');
    x_RGB = lab2rgb(x);
    figure;
    imshow(x_RGB);
    title(sprintf('%s\nLab, a = konst', imena_slik{i}));

end

% 2 LAB b=konst

for i = 1:2

    x = sliki_LAB{i};
    x(:, :, 3) = mean(x(:, :, 3), 'all');
    x_RGB = lab2rgb(x);
    figure;
    imshow(x_RGB);
    title(sprintf('%s\nLab, b = konst', imena_slik{i}));

end

%% 3 RGB

video = VideoReader("ladja.avi");
frames = read(video, [1 Inf]);
zadnji_frame = frames(:, :, :, video.NumFrames);

x_min = 1;
x_max = size(zadnji_frame, 2);

y_min = size(zadnji_frame, 1) - 179;
y_max = size(zadnji_frame, 1);

vzorec_morja = zadnji_frame(y_min:y_max, x_min:x_max, :);

vzorec_morja_R = vzorec_morja(:, :, 1);
vzorec_morja_G = vzorec_morja(:, :, 2);
vzorec_morja_B = vzorec_morja(:, :, 3);

R_meje = [min(vzorec_morja_R(:)), max(vzorec_morja_R(:))];
G_meje = [min(vzorec_morja_G(:)), max(vzorec_morja_G(:))];
B_meje = [min(vzorec_morja_B(:)), max(vzorec_morja_B(:))];

video2 = zeros(video.Height, video.Width, video.NumFrames);

for i = 1:video.NumFrames
    for j = 1:video.Height
        for k = 1:video.Width

            if R_meje(1) <= frames(j, k, 1, i) && frames(j, k, 1, i) <= R_meje(2) && ...
               G_meje(1) <= frames(j, k, 2, i) && frames(j, k, 2, i) <= G_meje(2) && ...
               B_meje(1) <= frames(j, k, 3, i) && frames(j, k, 3, i) <= B_meje(2)

                video2(j, k, i) = 255;
            else
                video2(j, k, i) = 0;
            end

        end
    end
end

fprintf('Prikaz videa: naloga 3 – RGB segmentacija morja.\n');
h = implay(video2);
waitfor(h);

writer_RGB = VideoWriter('naloga3_RGB.avi');
open(writer_RGB);
for i = 1:video.NumFrames
    frame_gray = uint8(video2(:, :, i));
    writeVideo(writer_RGB, frame_gray);
end
close(writer_RGB);

%% 3 HSV

video = VideoReader("ladja.avi");
frames = read(video, [1 Inf]);
zadnji_frame = frames(:, :, :, video.NumFrames);

x_min = 1;
x_max = size(zadnji_frame, 2);

y_min = size(zadnji_frame, 1) - 179;
y_max = size(zadnji_frame, 1);

vzorec_morja = zadnji_frame(y_min:y_max, x_min:x_max, :);

vzorec_morja_HSV = rgb2hsv(vzorec_morja);

vzorec_morja_H = vzorec_morja_HSV(:, :, 1);
vzorec_morja_S = vzorec_morja_HSV(:, :, 2);
vzorec_morja_V = vzorec_morja_HSV(:, :, 3);

H_meje = [min(vzorec_morja_H(:)), max(vzorec_morja_H(:))];
S_meje = [min(vzorec_morja_S(:)), max(vzorec_morja_S(:))];
V_meje = [min(vzorec_morja_V(:)), max(vzorec_morja_V(:))];

frames_HSV = zeros(video.Height, video.Width, 3, video.NumFrames);

for i = 1:video.NumFrames
    frames_HSV(:, :, :, i) = rgb2hsv(frames(:, :, :, i));
end

video2 = zeros(video.Height, video.Width, video.NumFrames);

for i = 1:video.NumFrames
    for j = 1:video.Height
        for k = 1:video.Width

            if H_meje(1) <= frames_HSV(j, k, 1, i) && frames_HSV(j, k, 1, i) <= H_meje(2) && ...
               S_meje(1) <= frames_HSV(j, k, 2, i) && frames_HSV(j, k, 2, i) <= S_meje(2) && ...
               V_meje(1) <= frames_HSV(j, k, 3, i) && frames_HSV(j, k, 3, i) <= V_meje(2)

                video2(j, k, i) = 255;
            else
                video2(j, k, i) = 0;
            end

        end
    end
end

fprintf('Prikaz videa: naloga 3 – HSV segmentacija morja.\n');
h = implay(video2);
waitfor(h);

writer_HSV = VideoWriter('naloga3_HSV.avi');
open(writer_HSV);
for i = 1:video.NumFrames
    frame_gray = uint8(video2(:, :, i));
    writeVideo(writer_HSV, frame_gray);
end
close(writer_HSV);

%% 4 – 3D histogram morja (8x8x8) in preslikava v sivine

video = VideoReader("ladja.avi");
frames = read(video, [1 Inf]);
zadnji_frame = frames(:, :, :, video.NumFrames);

x_min = 1;
x_max = size(zadnji_frame, 2);

y_min = size(zadnji_frame, 1) - 179;
y_max = size(zadnji_frame, 1);

vzorec_morja = zadnji_frame(y_min:y_max, x_min:x_max, :);

st_binov = 8;
histogram_vzorca = zeros(st_binov, st_binov, st_binov);

for i = 1:size(vzorec_morja, 1)
    for j = 1:size(vzorec_morja, 2)

        r = floor(double(vzorec_morja(i, j, 1))/(256/st_binov)) + 1;
        g = floor(double(vzorec_morja(i, j, 2))/(256/st_binov)) + 1;
        b = floor(double(vzorec_morja(i, j, 3))/(256/st_binov)) + 1;
        
        histogram_vzorca(r, g, b) = histogram_vzorca(r, g, b) + 1;

    end
end

max_vrednost = max(histogram_vzorca(:));
norm_histogram = histogram_vzorca / max_vrednost * 255;

video2 = zeros(video.Height, video.Width, video.NumFrames);

for i = 1:video.NumFrames
    for j = 1:video.Height
        for k = 1:video.Width

            r = floor(double(frames(j, k, 1, i))/(256/st_binov)) + 1;
            g = floor(double(frames(j, k, 2, i))/(256/st_binov)) + 1;
            b = floor(double(frames(j, k, 3, i))/(256/st_binov)) + 1;

            video2(j, k, i) = norm_histogram(r, g, b);

        end
    end
end

fprintf('Prikaz videa: naloga 4 – 3D histogram barv morja (RGB).\n');
h = implay(video2);
waitfor(h);

writer_4 = VideoWriter('naloga4_histRGB.avi');
open(writer_4);
for i = 1:video.NumFrames
    frame_gray = uint8(video2(:, :, i));
    writeVideo(writer_4, frame_gray);
end
close(writer_4);

%% 5 – histogram intersection po 8x8 blokih (4x4x4, max-bin normalizacija)

video = VideoReader("ladja.avi");
frames = read(video, [1 Inf]);
zadnji_frame = frames(:, :, :, video.NumFrames);

x_min = 1;
x_max = size(zadnji_frame, 2);

y_min = size(zadnji_frame, 1) - 179;
y_max = size(zadnji_frame, 1);

vzorec_morja = zadnji_frame(y_min:y_max, x_min:x_max, :);

st_binov = 4;
binSize = 256 / st_binov;

% 5.1 Referenčni histogram morja (RGB, 4x4x4), nato normalizacija z max binom
histogram_vzorca = zeros(st_binov, st_binov, st_binov);

for i = 1:size(vzorec_morja, 1)
    for j = 1:size(vzorec_morja, 2)
        r = floor(double(vzorec_morja(i, j, 1)) / binSize) + 1;
        g = floor(double(vzorec_morja(i, j, 2)) / binSize) + 1;
        b = floor(double(vzorec_morja(i, j, 3)) / binSize) + 1;
        histogram_vzorca(r, g, b) = histogram_vzorca(r, g, b) + 1;
    end
end

% normalizacija modelnega histograma: deljenje z največjo vrednostjo (max bin)
max_model = max(histogram_vzorca(:));
histogram_vzorca_norm = histogram_vzorca / max_model;
vsota_modela_norm = sum(histogram_vzorca_norm(:));

clear vsote

% 5.2 Histogram intersection po 8x8 blokih (Swain & Ballard z max-normalizacijo)
for i = 1:video.NumFrames

    trenutni_frame = frames(:, :, :, i);

    % gremo po blokih 8x8, rob (če ostane) ignoriramo
    for j = 1:8:(video.Height-7)
        for k = 1:8:(video.Width-7)

            podrocje8x8 = trenutni_frame(j:j+7, k:k+7, :);   % 8x8x3, uint8

            Rbin = floor(double(podrocje8x8(:, :, 1)) / binSize) + 1;
            Gbin = floor(double(podrocje8x8(:, :, 2)) / binSize) + 1;
            Bbin = floor(double(podrocje8x8(:, :, 3)) / binSize) + 1;

            idx = sub2ind([st_binov, st_binov, st_binov], Rbin(:), Gbin(:), Bbin(:));

            % histogram bloka (4x4x4) v številu pikslov
            hist_block_vec = accumarray(idx, 1, [st_binov^3, 1]);
            hist_block = reshape(hist_block_vec, [st_binov, st_binov, st_binov]);

            % normalizacija histograma bloka: deljenje z največjo vrednostjo (max bin)
            max_block = max(hist_block(:));
            hist_block_norm = hist_block / max_block;

            % Swain & Ballard histogram intersection:
            % HI = sum_j min(I_j, M_j) / sum_j M_j
            presek = sum(min(hist_block_norm(:), histogram_vzorca_norm(:))) / vsota_modela_norm;

            vsote((j-1)/8+1, (k-1)/8+1, i) = presek;

        end
    end

end

% 5.3 Iz vsot naredimo video: presek (0..1) -> sivina (0..255) – navodila pravijo *256*

video2 = zeros(video.Height, video.Width, video.NumFrames, 'uint8');
visina_blokov  = 8 * size(vsote, 1);
sirina_blokov = 8 * size(vsote, 2);

for i = 1:video.NumFrames

    % presek * 256 za 8-bitno dinamiko (bo saturiralo pri 255)
    blok_sivine = uint8(vsote(:, :, i) * 256);

    % razširimo 8x8 blok v 8x8 pikslov
    video2(1:visina_blokov, 1:sirina_blokov, i) = ...
        kron(blok_sivine, ones(8, 'uint8'));

end

fprintf('Prikaz videa: naloga 5 – histogram intersection po 8x8 blokih.\n');
h = implay(video2);
waitfor(h);

writer_5 = VideoWriter('naloga5_histIntersection.avi');
open(writer_5);
for i = 1:video.NumFrames
    writeVideo(writer_5, video2(:, :, i));   
end
close(writer_5);

fprintf('Program je zaključen.\n');
==== END Filip Kocjančič | Filip Kocjančič_21496_assignsubmission_file | koda_za_oddajo.m ====

