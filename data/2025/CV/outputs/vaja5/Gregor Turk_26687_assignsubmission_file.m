==== BEGIN Gregor Turk | Gregor Turk_26687_assignsubmission_file | vaja5.m ====
%% Podvzorcenje slik - 9 verzij


holywood = VideoReader("Holywood.avi");

if ~exist("subsampled", "dir")
    mkdir("subsampled");
end

% Writerji
w_nn_2   = VideoWriter("subsampled/holywood_nn_polovica.avi");
w_nn_4   = VideoWriter("subsampled/holywood_nn_cetrtina.avi");
w_nn_8   = VideoWriter("subsampled/holywood_nn_osmina.avi");

w_bl_2   = VideoWriter("subsampled/holywood_interp_polovica.avi");
w_bl_4   = VideoWriter("subsampled/holywood_interp_cetrtina.avi");
w_bl_8   = VideoWriter("subsampled/holywood_interp_osmina.avi");

w_blaa_2 = VideoWriter("subsampled/holywood_interp_aa_polovica.avi");
w_blaa_4 = VideoWriter("subsampled/holywood_interp_aa_cetrtina.avi");
w_blaa_8 = VideoWriter("subsampled/holywood_interp_aa_osmina.avi");

writers = {w_nn_2,w_nn_4,w_nn_8,w_bl_2,w_bl_4,w_bl_8,w_blaa_2,w_blaa_4,w_blaa_8};

% odpri writerje, nastavi fps
for k = 1:numel(writers)
    writers{k}.FrameRate = holywood.FrameRate;
    open(writers{k});
end

scales = [1/2, 1/4, 1/8];

while hasFrame(holywood)
    frameRGB = readFrame(holywood);

    % 1) nearest neighbor
    f_nn_2 = imresize(frameRGB, scales(1), "nearest");
    f_nn_4 = imresize(frameRGB, scales(2), "nearest");
    f_nn_8 = imresize(frameRGB, scales(3), "nearest");

    % 2) bilinear, antialiasing OFF
    f_bl_2 = imresize(frameRGB, scales(1), "bilinear", "Antialiasing", false);
    f_bl_4 = imresize(frameRGB, scales(2), "bilinear", "Antialiasing", false);
    f_bl_8 = imresize(frameRGB, scales(3), "bilinear", "Antialiasing", false);

    % 3) bilinear, antialiasing ON
    f_blaa_2 = imresize(frameRGB, scales(1), "bilinear", "Antialiasing", true);
    f_blaa_4 = imresize(frameRGB, scales(2), "bilinear", "Antialiasing", true);
    f_blaa_8 = imresize(frameRGB, scales(3), "bilinear", "Antialiasing", true);

    % Zapis v 9 videov
    writeVideo(w_nn_2, f_nn_2);
    writeVideo(w_nn_4, f_nn_4);
    writeVideo(w_nn_8, f_nn_8);

    writeVideo(w_bl_2, f_bl_2);
    writeVideo(w_bl_4, f_bl_4);
    writeVideo(w_bl_8, f_bl_8);

    writeVideo(w_blaa_2, f_blaa_2);
    writeVideo(w_blaa_4, f_blaa_4);
    writeVideo(w_blaa_8, f_blaa_8);
end

% Zapri writerje
for k = 1:numel(writers)
    close(writers{k});
end

%% 2 sledenje igralca


squash = VideoReader("squash.avi");

frame = rgb2gray(read(squash, 1));
H = size(frame,1);
W = size(frame,2);

%figure;
%imshow(frame);
%impixelinfo;

% 100,122 -> levo zgoraj
% 115,121
% 115,129 -> desno zgoraj
znacilka = double(frame(118:130, 102:115));
h_znacilka = size(znacilka,1);
w_znacilka = size(znacilka,2);

%figure;
%imshow(znacilka);

res_l2 = VideoWriter("tracking_evklidska.avi");
res_l2.FrameRate = squash.FrameRate;   % enak fps kot original
open(res_l2);

squash = VideoReader("squash.avi");

eps = 18;
half_eps = floor(eps/2);
position = [118,102];

i = 1;
while hasFrame(squash) %&& i < 150
    frameRGB = readFrame(squash);
    frame = double(rgb2gray(frameRGB));
    
    % pregledamo obmocje okrog igralca
    y0 = max(1, position(1) - half_eps);
    x0 = max(1, position(2) - half_eps);
    y1 = min(H - h_znacilka + 1, position(1) + half_eps);
    x1 = min(W - w_znacilka + 1, position(2) + half_eps);
    
    % L2 razdalja
    best_l2 = inf;
    best_pos = position;
    for r = y0:y1
        for c = x0:x1
            patch = frame(r:r+h_znacilka-1, c:c+w_znacilka-1);

            razlika = patch - znacilka;
            l2 = sum(razlika(:).^2);
            if l2 < best_l2
                best_l2 = l2;
                best_pos = [r,c];
            end
        end
    end

    % izris kvadrata
    y_box = best_pos(1); x_box = best_pos(2);
    w_box = w_znacilka; h_box = h_znacilka;

    frameRGB = insertShape(frameRGB, "rectangle", [x_box, y_box, w_box, h_box], ...
        "Color", "red", "LineWidth", 2);
    frameRGB = insertShape(frameRGB, "rectangle", [x0, y0, (x1-x0+w_znacilka), (y1-y0+h_znacilka)], ...
    "Color", "yellow", "LineWidth", 1);

    position = best_pos;
    i = i+1;
    writeVideo(res_l2, frameRGB);
end

close(res_l2);


%% 3 sledenje igralca - hi-kvadrat
% histogram h kanala v HSV - iskali bomo rdecega to bo najbolje


squash = VideoReader("squash.avi");

frame = read(squash, 1);
H = size(frame,1);
W = size(frame,2);

%figure;
%imshow(frame);
%impixelinfo;

% 100,122 -> levo zgoraj
% 115,121
% 115,129 -> desno zgoraj
znacilka = frame(120:133, 100:121, :);
h_znacilka = size(znacilka,1);
w_znacilka = size(znacilka,2);

locljivost_hist = 32;
hist_znacilka = histogramH(znacilka, locljivost_hist);

%figure;
%imshow(znacilka);

res_hi = VideoWriter("tracking_hi2.avi");
res_hi.FrameRate = squash.FrameRate;   % enak fps kot original
open(res_hi);

squash = VideoReader("squash.avi");

eps = 20;
half_eps = floor(eps/2);
position = [120,100];

i = 1;
while hasFrame(squash) %&& i < 150
    frameRGB = readFrame(squash);
    
    % pregledamo obmocje okrog igralca
    y0 = max(1, position(1) - half_eps);
    x0 = max(1, position(2) - half_eps);
    y1 = min(H - h_znacilka + 1, position(1) + half_eps);
    x1 = min(W - w_znacilka + 1, position(2) + half_eps);
   
    % hi razdalja
    best_hi = inf;
    best_pos = position;
    for r = y0:y1
        for c = x0:x1
            patch = frameRGB(r:r+h_znacilka-1, c:c+w_znacilka-1,:);
            hist_patch = histogramH(patch, locljivost_hist);

            razlika = hist_patch - hist_znacilka;
            hi = sum((razlika.^2) ./ (hist_patch + hist_znacilka + 1e-12));
            if hi < best_hi
                best_hi = hi;
                best_pos = [r,c];
            end
        end
    end

    % izris pravokotnika
    y_box = best_pos(1); x_box = best_pos(2);
    w_box = w_znacilka; h_box = h_znacilka;

    frameRGB = insertShape(frameRGB, "rectangle", [x_box, y_box, w_box, h_box], ...
        "Color", "red", "LineWidth", 2);
    frameRGB = insertShape(frameRGB, "rectangle", [x0, y0, (x1-x0+w_znacilka), (y1-y0+h_znacilka)], ...
    "Color", "yellow", "LineWidth", 1);

    position = best_pos;
    i = i+1;
    writeVideo(res_hi, frameRGB);
end

close(res_hi);



%% 4. sprotno ucenje


squash = VideoReader("squash.avi");

frame = read(squash, 1);
H = size(frame,1);
W = size(frame,2);

%figure;
%imshow(frame);
%impixelinfo;

% 100,122 -> levo zgoraj
% 115,121
% 115,129 -> desno zgoraj
znacilka = frame(120:133, 110:120, :);
h_znacilka = size(znacilka,1);
w_znacilka = size(znacilka,2);

locljivost_hist = 32;
hist_znacilka = histogramH(znacilka, locljivost_hist);
hist_novi = hist_znacilka; % rabil ga bom kasneje za sprotno posodabljanje histograma

%figure;
%imshow(znacilka);

res_ucenje = VideoWriter("tracking_ucenje.avi");
res_ucenje.FrameRate = squash.FrameRate;   % enak fps kot original
open(res_ucenje);

squash = VideoReader("squash.avi");

eps = 10;
half_eps = floor(eps/2);
position = [120,110];

i = 1;
while hasFrame(squash) %&& i < 150
    frameRGB = readFrame(squash);
    
    % pregledamo obmocje okrog igralca
    y0 = max(1, position(1) - half_eps);
    x0 = max(1, position(2) - half_eps);
    y1 = min(H - h_znacilka + 1, position(1) + half_eps);
    x1 = min(W - w_znacilka + 1, position(2) + half_eps);
   
    % hi razdalja
    best_hi = inf;
    best_pos = position;
    hist_znacilka = hist_novi;
    for r = y0:y1
        for c = x0:x1
            patch = frameRGB(r:r+h_znacilka-1, c:c+w_znacilka-1,:);
            hist_patch = histogramH(patch, locljivost_hist);

            razlika = hist_patch - hist_znacilka;
            hi = sum((razlika.^2) ./ (hist_patch + hist_znacilka + 1e-12));
            if hi < best_hi
                best_hi = hi;
                best_pos = [r,c];
                hist_novi = hist_patch;
            end
        end
    end
    
    % izris pravokotnika
    y_box = best_pos(1); x_box = best_pos(2);
    w_box = w_znacilka; h_box = h_znacilka;

    frameRGB = insertShape(frameRGB, "rectangle", [x_box, y_box, w_box, h_box], ...
        "Color", "red", "LineWidth", 2);
    frameRGB = insertShape(frameRGB, "rectangle", [x0, y0, (x1-x0+w_znacilka), (y1-y0+h_znacilka)], ...
    "Color", "yellow", "LineWidth", 1);

    position = best_pos;
    hist_znacilka = hist_novi; % namesto znacilke na zacetku vzamem zadnji histogram
    i = i+1;
    writeVideo(res_ucenje, frameRGB);
end

close(res_ucenje);

%%

function hist = histogramH(img, locljivost)

    slikaHSV = rgb2hsv(img);
    H = slikaHSV(:,:,1); % H od 0 do 1
    height = size(H,1);
    width = size(H,2);

    hist = zeros(1,locljivost);
    
    for col = 1:width
        for row = 1:height
            bin = floor(H(row,col) * locljivost) + 1; % +1 ker se zacne z 1
            bin = min(max(bin,1), locljivost);
            hist(bin) = hist(bin) + 1;
        end
    end

    maxValue = max(hist(:));
    % vrednost najmocnejsega bina == 1
    hist_norm = (double(hist) / double(maxValue));

    hist = hist_norm;
    
end
==== END Gregor Turk | Gregor Turk_26687_assignsubmission_file | vaja5.m ====

