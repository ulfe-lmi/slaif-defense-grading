==== BEGIN Filip Kocjančič | Filip Kocjančič_22780_assignsubmission_file | Vaja_4_koncna.m ====
%% 1. naloga – Izločanje robov (Sobel + Canny)

slika = imread("hotel.jpg");
slika = rgb2gray(slika);

% Canny 
canny = edge(slika, "canny");

% Ročni Sobel
Sx = [1 0 -1; 2 0 -2; 1 0 -1];
Sy = [1 2 1; 0 0 0; -1 -2 -1];

Gx = imfilter(double(slika), Sx, "replicate");
Gy = imfilter(double(slika), Sy, "replicate");

Gmag = sqrt(Gx.^2 + Gy.^2);

prag_sobel = 220;
sobel_bin = Gmag > prag_sobel;

figure;
subplot(1,2,1);
imshow(canny);
title('Canny');

subplot(1,2,2);
imshow(sobel_bin);
title('Ročni Sobel – binarno');


%% 2. naloga – Houghova transformacija (Canny + Sobel)

k_interval = linspace(-2, 2, 401);
N = 8;  

% --- Hough za Canny ---
akumulator_c = zeros(401);

for y = 1:size(canny, 1)
    for x = 1:size(canny, 2)
        if canny(y, x) == 1
            for i = 1:length(k_interval)
                k_tmp = k_interval(i);
                n = round(y - x * k_tmp);
                if n >= -200 && n <= 200
                    akumulator_c(n+201, round(k_tmp*100 + 201)) = ...
                        akumulator_c(n+201, round(k_tmp*100 + 201)) + 1;
                end
            end
        end
    end
end

[~, indeksi] = sort(akumulator_c(:), 'descend');
indeksi_najvecjih = indeksi(1:N);
[vrstica, stolpec] = ind2sub(size(akumulator_c), indeksi_najvecjih);
n_c = vrstica - 201;
k_c = (stolpec - 201)/100;

x = 1:1:size(canny, 2);

figure;
imshow(canny);
title('Najdene premice na Canny');
hold on;
for i = 1:N
    y = k_c(i) * x + n_c(i);
    plot(x, y, 'r', 'LineWidth', 1);
end
hold off;

% --- Hough za Sobel ---
akumulator_s = zeros(401);

for y = 1:size(sobel_bin, 1)
    for x = 1:size(sobel_bin, 2)
        if sobel_bin(y, x) == 1
            for i = 1:length(k_interval)
                k_tmp = k_interval(i);
                n = round(y - x * k_tmp);
                if n >= -200 && n <= 200
                    akumulator_s(n+201, round(k_tmp*100 + 201)) = ...
                        akumulator_s(n+201, round(k_tmp*100 + 201)) + 1;
                end
            end
        end
    end
end

[~, indeksi] = sort(akumulator_s(:), 'descend');
indeksi_najvecjih = indeksi(1:N);
[vrstica, stolpec] = ind2sub(size(akumulator_s), indeksi_najvecjih);
n_s = vrstica - 201;
k_s = (stolpec - 201)/100;

x = 1:1:size(sobel_bin, 2);

figure;
imshow(sobel_bin);
title('Najdene premice na ročnem Sobel');
hold on;
for i = 1:N
    y = k_s(i) * x + n_s(i);
    plot(x, y, 'r', 'LineWidth', 1);
end
hold off;


%% 3. naloga – Pridobivanje ozadja (SKRAJŠAN video – kot v tvoji kodi)

videoObj = VideoReader("squash.avi");
video = read(videoObj, [1 Inf]); 

skrajsan_video = video(:, :, :, 1:20:size(video, 4));


preoblikovan_video = reshape(skrajsan_video, [], 3, size(skrajsan_video, 4));
ozadje = mode(preoblikovan_video, 3);
ozadje = reshape(ozadje, size(skrajsan_video, 1), size(skrajsan_video, 2), 3);

figure;
imshow(uint8(ozadje));
title('Ocenjeno ozadje (iz skrajšanega videa)');


%% 4. naloga – TVOJA DETEKCIJA + shranjevanje težišč

numFrames = size(skrajsan_video, 4);
tezisca = cell(1, numFrames);

for i = 1:numFrames

    trenutni_frame = skrajsan_video(:, :, :, i);
    razlika = sqrt(sum((ozadje - trenutni_frame).^2, 3));
    razlika = uint8(razlika / max(razlika(:)) * 255);
    razlika = imgaussfilt(razlika, 7.1);
    binarna_slika = imbinarize(razlika, 0.5);
    binarna_slika = bwmorph(binarna_slika, 'erode');
    binarna_slika = bwmorph(binarna_slika, 'erode');
    binarna_slika = bwmorph(binarna_slika, 'dilate');
    binarna_slika = bwmorph(binarna_slika, 'dilate');
    oznake = bwlabel(binarna_slika);
    tezisca{i} = regionprops(oznake, 'Centroid');



end

stranica = 10;


video_det = skrajsan_video;

for i = 1:numFrames

    trenutne_koordinate = tezisca{i};

    if size(trenutne_koordinate, 1) == 2

        for j = 1:2

            trenutna = trenutne_koordinate(j);
            x = round(trenutna.Centroid(1));
            y = round(trenutna.Centroid(2));

            y1 = max(1, y-stranica/2);
            y2 = min(size(video_det, 1), y+stranica/2);
            x1 = max(1, x-stranica/2);
            x2 = min(size(video_det, 2), x+stranica/2);

            video_det(y1:y2, x1:x2, 1, i) = 0;
            video_det(y1:y2, x1:x2, 2, i) = 255;
            video_det(y1:y2, x1:x2, 3, i) = 0;

        end

    elseif size(trenutne_koordinate, 1) == 1

        x = round(trenutne_koordinate.Centroid(1));
        y = round(trenutne_koordinate.Centroid(2));

        y1 = max(1, y-stranica/2);
        y2 = min(size(video_det, 1), y+stranica/2);
        x1 = max(1, x-stranica/2);
        x2 = min(size(video_det, 2), x+stranica/2);

        video_det(y1:y2, x1:x2, 1, i) = 0;
        video_det(y1:y2, x1:x2, 2, i) = 255;
        video_det(y1:y2, x1:x2, 3, i) = 0;

    end

end

implay(video_det);   

%% 5. naloga – Identifikacija igralcev

video_id  = skrajsan_video;
numFrames = size(video_id, 4);

stranica_id = 20;
pol_id      = stranica_id / 2;

imaInsertText = exist('insertText', 'file') == 2;

% Parametri HSV za rdečo
Smin = 0.65;
Hlo  = 0.03;
Hhi  = 0.97;

rad_patch = 5;

% Histereza
diffThresh  = 0.10;
minRedScore = 0.01;

prevIdxRed = [];
afterMerge = false;

for i = 1:numFrames

    objs = tezisca{i};
    nDet = numel(objs);

    if nDet == 0
        continue;
    end

    nObj = min(nDet, 2);
    objs = objs(1:nObj);

    frame_rgb = skrajsan_video(:, :, :, i);
    frame_out = frame_rgb;

    hsv = rgb2hsv(frame_rgb);
    H = hsv(:,:,1);
    S = hsv(:,:,2);

    redScore = zeros(1, nObj);
    cent = zeros(nObj, 2);

    for j = 1:nObj
        c = objs(j).Centroid;
        cent(j,:) = c;

        x = round(c(1));
        y = round(c(2));

        y1p = max(1, y - rad_patch);  
        y2p = min(size(H,1), y + rad_patch);
        x1p = max(1, x - rad_patch);  
        x2p = min(size(H,2), x + rad_patch);

        patchH = H(y1p:y2p, x1p:x2p);
        patchS = S(y1p:y2p, x1p:x2p);

        maskRed = (patchS > Smin) & (patchH < Hlo | patchH > Hhi);
        redScore(j) = sum(maskRed(:)) / numel(maskRed);
    end

    if nObj == 2

        if isempty(prevIdxRed) || afterMerge
            [~, idxRed] = max(redScore);
            prevIdxRed = idxRed;
            afterMerge = false;
        else
            [~, idxCand] = max(redScore);
            idxOther = 3 - idxCand;

            diffScore = redScore(idxCand) - redScore(idxOther);

            if max(redScore) < minRedScore
                idxRed = prevIdxRed;
            else
                if idxCand ~= prevIdxRed && diffScore <= diffThresh
                    idxRed = prevIdxRed;
                else
                    idxRed = idxCand;
                end
            end

            prevIdxRed = idxRed;
        end

        idxWhite = 3 - prevIdxRed;

        for j = 1:2
            x = round(cent(j,1));
            y = round(cent(j,2));

            y1 = max(1, y - pol_id);  
            y2 = min(size(frame_out,1), y + pol_id);
            x1 = max(1, x - pol_id);  
            x2 = min(size(frame_out,2), x + pol_id);

            if j == prevIdxRed
                oznaka      = '2';
                barvaKvadra = [255 0 0];
                barvaTeksta = 'yellow';
            else
                oznaka      = '1';
                barvaKvadra = [255 255 255];
                barvaTeksta = 'black';
            end

            frame_out(y1:y2, x1:x2, 1) = barvaKvadra(1);
            frame_out(y1:y2, x1:x2, 2) = barvaKvadra(2);
            frame_out(y1:y2, x1:x2, 3) = barvaKvadra(3);

            if imaInsertText
                frame_out = insertText(frame_out, [x, max(1,y1-10)], oznaka, ...
                    'FontSize', 18, 'BoxOpacity', 0, 'TextColor', barvaTeksta);
            end
        end

    else
        afterMerge = true;

        x = round(cent(1,1));
        y = round(cent(1,2));

        y1 = max(1, y - pol_id);  
        y2 = min(size(frame_out,1), y + pol_id);
        x1 = max(1, x - pol_id);  
        x2 = min(size(frame_out,2), x + pol_id);

        frame_out(y1:y2, x1:x2, 1) = 0;
        frame_out(y1:y2, x1:x2, 2) = 255;
        frame_out(y1:y2, x1:x2, 3) = 0;

        if imaInsertText
            frame_out = insertText(frame_out, [x, max(1,y1-10)], 'M', ...
                'FontSize', 18, 'BoxOpacity', 0, 'TextColor', 'yellow');
        end
    end

    video_id(:,:,:,i) = frame_out;
end

implay(video_id);

==== END Filip Kocjančič | Filip Kocjančič_22780_assignsubmission_file | Vaja_4_koncna.m ====

