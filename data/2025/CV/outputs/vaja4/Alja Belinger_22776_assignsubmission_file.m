==== BEGIN Alja Belinger | Alja Belinger_22776_assignsubmission_file | labvaja4_1.m ====
clear all; close all; clc;
%% labvaja4_1
%% 1) pretvormo prvo v sivinsko
img = imread('hotel.jpg');      
gray = rgb2gray(img);

%% 2) Sobelova operatorja Sx in Sy
Sx = [ 1 0 -1;
       2 0 -2;
       1 0 -1 ];

Sy = [ 1  2  1;
       0  0  0;
      -1 -2 -1 ];

%% 3) Konvoluciji gx gy slike s filtrom
Gx = imfilter(double(gray), Sx, 'replicate');
Gy = imfilter(double(gray), Sy, 'replicate');

%% 4) Gradient
G = sqrt(Gx.^2 + Gy.^2);

% normalizacija 
Gnorm = uint8(255 * mat2gray(G));



% Če je na sliki preveč robov → prag gor
% Če jih je premau → prag dol
threshold = 50;     

edges_sobel = G > threshold;

%% 6) Cannyjev detektor robov
edges_canny = edge(gray, 'Canny');

%% 7) Prikaz rezultatov
figure;
subplot(1,3,1); imshow(gray); title('Sivinska slika');
subplot(1,3,2); imshow(edges_sobel); title(['Sobel (threshold = ', num2str(threshold), ')']);
subplot(1,3,3); imshow(edges_canny); title('Canny');
==== END Alja Belinger | Alja Belinger_22776_assignsubmission_file | labvaja4_1.m ====

==== BEGIN Alja Belinger | Alja Belinger_22776_assignsubmission_file | labvaja4_2.m ====
%% labvaja4_2_withDraw.m
% funkcija drawLines na konc

clear all; close all; clc;

%% tle se nalozi slika in robovi iz naloge 1
img = imread('hotel.jpg');
gray = rgb2gray(img);

edges_sobel = edge(gray, 'Sobel');
edges_canny = edge(gray, 'Canny');

% izberi eno
edges = edges_canny;

%% Priprava parametrov k in n
k_min = -2;   k_max = 2;
n_min = -200; n_max = 200;
num_k = 401;  num_n = 401;
k_values = linspace(k_min, k_max, num_k);
n_values = linspace(n_min, n_max, num_n);
A = zeros(num_k, num_n);   % akumulator

%% Hough glasovanje
[H, W] = size(edges);
for y = 1:H
    for x = 1:W
        if edges(y,x)
            for ki = 1:num_k
                k = k_values(ki);
                n = y - k*x;
                if n >= n_min && n <= n_max
                    nj = round((n - n_min) / (n_max - n_min) * (num_n - 1)) + 1;
                    A(ki, nj) = A(ki, nj) + 1;
                end
            end
        end
    end
end

%% Najdi N največjih premic
N = 5;
A_flat = A(:);
[~, idx] = maxk(A_flat, N);
[k_idx, n_idx] = ind2sub(size(A), idx);
k_list = k_values(k_idx);
n_list = n_values(n_idx);

%% Pokliči lokalno funkcijo, ki je definirana spodaj
drawLines(img, k_list, n_list);

% ------------------------------
% Funkcija drawLines (lokalna)
% ------------------------------
function drawLines(imageRGB, k_list, n_list)
    [H, W, ~] = size(imageRGB);
    figure; imshow(imageRGB); hold on;
    x_vals = 1:W;
    colors = lines(max(1,length(k_list))); % lep nabor barv
    for i = 1:length(k_list)
        k = k_list(i);
        n = n_list(i);
        y_vals = k * x_vals + n;
        valid = y_vals >= 1 & y_vals <= H;
        plot(x_vals(valid), y_vals(valid), 'LineWidth', 2, 'Color', colors(mod(i-1,size(colors,1))+1,:));
        % napiši labelo ob sredini premice
        midx = round(W/2);
        midy = k*midx + n;
        if midy >= 1 && midy <= H
            text(midx, midy, sprintf('%d', i), 'Color', 'y', 'FontSize', 12, 'FontWeight', 'bold');
        end
    end
    title(['Najdenih premic: ', num2str(length(k_list))]);
    hold off;
end
==== END Alja Belinger | Alja Belinger_22776_assignsubmission_file | labvaja4_2.m ====

==== BEGIN Alja Belinger | Alja Belinger_22776_assignsubmission_file | labvaja4_3.m ====
%% labvaja4_3

clear all; close all; clc;

video = VideoReader('squash.avi');

% vzem vsak 10. frame
step = 10;

frames = {};   % za shranjevanje posameznih frameov
count = 1;

%% 2) Preberemo izbrane frame iz videja
while hasFrame(video)
    frame = readFrame(video);

    if mod(count, step) == 0
        frames{end+1} = frame;   % shran sliko
    end

    count = count + 1;
end

numFrames = length(frames);
disp(['Uporabljenih frameov: ', num2str(numFrames)]);

%% 3) Zloži frame v 4D matriko: H × W × 3 × N
H = size(frames{1},1);
W = size(frames{1},2);

stack = zeros(H, W, 3, numFrames, 'uint8');

for i = 1:numFrames
    stack(:,:,:,i) = frames{i};
end

%% 4)  MEDIANA
background = median(stack, 4);   % median po 4. dimenziji

background = uint8(background);

%% 5) Prikaž rezultat
figure;
imshow(background);
title('Izračunano ozadje squash igrišča');

save('background.mat','background');
==== END Alja Belinger | Alja Belinger_22776_assignsubmission_file | labvaja4_3.m ====

==== BEGIN Alja Belinger | Alja Belinger_22776_assignsubmission_file | labvaja4_4.m ====
%% labvaja4_4 

clear all; close all; clc;

%% 1) Naloži video
video = VideoReader('squash.avi');

%% 2) Naloži ozadje iz naloge 3
load('background.mat');   % -> background spremenljivka

background = uint8(background);

%% 3) Pripravi video zapisovalnik
out = VideoWriter('squash_tracking.mp4','MPEG-4');
out.FrameRate = video.FrameRate;
open(out);

%% 4) Parametri
threshold = 40;
minArea = 150;
se = strel('disk',4);

figure;  % ena figura za vse frame, zarad hitrosti

%% 5) Frame-by-frame obdelava
while hasFrame(video)

    frame = readFrame(video);

    % Razlika med sliko in ozadjem
    D = double(frame) - double(background);
    diff = sqrt(sum(D.^2, 3));

    % Threshold
    bw = diff > threshold;

    % Morfologija
    bw = imopen(bw, se);
    bw = imclose(bw, se);
    bw = bwareaopen(bw, minArea);

    % Komponente
    CC = bwlabel(bw);
    stats = regionprops(CC, 'Area','BoundingBox','Centroid');

    % Pripravi prikaz
    imshow(frame);
    hold on;

    if ~isempty(stats)
        % Izber največja 2 objekta
        [~, idx] = sort([stats.Area], 'descend');
        idx = idx(1:min(2, length(idx)));

        % Nariši
        for k = 1:length(idx)
            bb = stats(idx(k)).BoundingBox;
            c  = stats(idx(k)).Centroid;

            rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2);
            plot(c(1), c(2), 'yo', 'MarkerSize', 10, 'LineWidth', 2);
        end
    end

    hold off;

    % Zajemi frame iz figure
    F = getframe(gcf);
    writeVideo(out, F.cdata);

end

close(out);
==== END Alja Belinger | Alja Belinger_22776_assignsubmission_file | labvaja4_4.m ====

==== BEGIN Alja Belinger | Alja Belinger_22776_assignsubmission_file | labvaja4_5.m ====
%% labvaja4_5
clear all; close all; clc;

% BRANJE VZORCEV

% beli vzorec
whiteSample = imread('belavzorec1.jpg');
whiteHSV = rgb2hsv(im2double(whiteSample));
whiteHist = imhist(whiteHSV(:,:,2)); % histogram saturacije
whiteHist = whiteHist / sum(whiteHist);

% rdeč vzorec
% redSample = uint8(zeros(50,50,3));
% redSample(:,:,1) = 180;  % R
% redSample(:,:,2) = 20;   % G
% redSample(:,:,3) = 20;   % B
redSample = imread('rdecavzorec.jpg');
redHSV = rgb2hsv(im2double(redSample));
redHist = imhist(redHSV(:,:,2));
redHist = redHist / sum(redHist);

% Video in ozadje
video = VideoReader('squash.avi');
load background.mat;
background = uint8(background);

out = VideoWriter('squash_colorID.mp4','MPEG-4');
out.FrameRate = video.FrameRate;
open(out);

% Parametri segmentacije
th = 25;
minArea = 250;
se = strel('disk',3);

figure;


% prevIsRed = [];  

while hasFrame(video)

    frame = readFrame(video);

    
    D = double(frame) - double(background);
    diff = sqrt(sum(D.^2,3));
    bw = diff > th;

    bw = imopen(bw,se);
    bw = imclose(bw,se);
    bw = bwareaopen(bw,minArea);
    bw = imfill(bw,'holes');

    L = bwlabel(bw);
    stats = regionprops(L,'Area','Centroid','BoundingBox');

    imshow(frame); hold on;

if ~isempty(stats)
    [~,idx] = sort([stats.Area],'descend');
    idx = idx(1:min(2, numel(idx)));

    M = numel(idx);
    redScoreList = zeros(1,M);
    BBlist = zeros(M,4);
    Clist = zeros(M,2);

    % redscore
    for i = 1:M
        p = stats(idx(i));
        BBlist(i,:) = p.BoundingBox;
        Clist(i,:) = p.Centroid;

        BB = p.BoundingBox;
        x1 = max(1, floor(BB(1)));
        y1 = max(1, floor(BB(2)));
        x2 = min(size(frame,2), ceil(BB(1)+BB(3)-1));
        y2 = min(size(frame,1), ceil(BB(2)+BB(4)-1));
        sub = frame(y1:y2, x1:x2, :);

        Hs = size(sub,1);
        Ws = size(sub,2);
        
        % višina torza 
        yA = round(Hs*0.15);
        yB = round(Hs*0.40);
        
        % dinamična širina
        aspect = Ws / Hs;
        
        if aspect < 0.55
            xA = round(Ws*0.40);
            xB = round(Ws*0.60);
        else
            xA = round(Ws*0.30);
            xB = round(Ws*0.70);
        end
        
        shirt = sub(yA:yB, xA:xB, :);


        Hsv = rgb2hsv(im2double(shirt));
        H = Hsv(:,:,1);
        S = Hsv(:,:,2);

        % maska
        mask = S > 0.15;

        if nnz(mask) < 50
            redScoreList(i) = 0;
        else
            d = min(abs(H-0), abs(H-1));      % razdalja do rdece
            redScoreList(i) = mean(d(mask) < 0.14);
        end
    end

    % Dodeli identiteto: bolj rdec = A, drugi = B
    if M == 2
        [~, ridx] = max(redScoreList);
        widx = 3 - ridx;

        labels = strings(1,2);
        cols = strings(1,2);
        labels(ridx) = "A (rdeci)"; cols(ridx) = "red";
        labels(widx) = "B (beli)";  cols(widx) = "white";

    end

    % Narisi
    for i = 1:M
        rectangle('Position', BBlist(i,:), 'EdgeColor','g','LineWidth',2);
        plot(Clist(i,1), Clist(i,2), 'go','MarkerSize',8,'LineWidth',2);
        text(Clist(i,1), Clist(i,2)-20, labels(i), 'Color', cols(i), ...
             'FontSize',14,'FontWeight','bold');
    end
end


    F = getframe(gcf);
    writeVideo(out, F.cdata);
    hold off;

end

close(out);
==== END Alja Belinger | Alja Belinger_22776_assignsubmission_file | labvaja4_5.m ====

