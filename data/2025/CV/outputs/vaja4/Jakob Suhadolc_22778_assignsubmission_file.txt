==== BEGIN Jakob Suhadolc | Jakob Suhadolc_22778_assignsubmission_file | drawLines.m ====
% Function: drawLines
% Author: Marija Ivanovska
% Description: This function draws N lines with maximum number of votes,
% defined by Hough transformation.
% Usage example:
% hotelRGB=imread('hotel.jpg'); % input image
% N = 5; % number of lines we want to draw
% HoughSpace = HoughTransform(BinaryImage)
% drawLines(hotelRGB,HoughSpace,N,'Sobel');
function []=drawLines(image,HoughSpace,N,Operator)
k=-2:0.01:2;
n=-200:1:200;
maximum=zeros(N,2);
for p=1:N % (k,n)
[max1,index]=max(HoughSpace);
[max2,columnId]=max(max1);
rowId=index(columnId);
maximum(p,1)=k(rowId);
maximum(p,2)=n(columnId);
HoughSpace(rowId,columnId)=0;
for i=1:481
    j=round(k(rowId)*i+n(columnId));
    for widthVar=1:size(j)
        image(j,i,1)=255;
        image(j,i,2)=0;
        image(j,i,3)=0;
    end
end
end
figure('Name',Operator);imshow(image);
==== END Jakob Suhadolc | Jakob Suhadolc_22778_assignsubmission_file | drawLines.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_22778_assignsubmission_file | Naloga1in2_Vaja4.m ====
% Naloga 1 Izlocanje robov 
% Mihaela Temelkova & Jakob Suhadolc

img = imread('hotel.jpg');
Igray = rgb2gray(img);


Sx = [1 0 -1; 2 0 -2; 1 0 -1];
Sy = [1 2 1; 0 0 0; -1 -2 -1];

Gx = conv2(Igray, Sx);
Gy = conv2(Igray, Sy);

G=uint8(sqrt(Gx.^2+Gy.^2));
edges_sobel=G>200;

edges_sobel(1:2, :)       = 0;          
edges_sobel(end-1:end, :) = 0;          
edges_sobel(:, 1:2)       = 0;          
edges_sobel(:, end-1:end) = 0;   

edges_canny = edge(Igray, 'canny');

figure;
subplot(2,2,1); imshow(Igray); title('Sivinska slika');
subplot(2,2,3); imshow(edges_sobel); title('Sobel');
subplot(2,2,4); imshow(edges_canny); title('Canny');

%% Naloga 2 Detekcija podrocij in morfoloske operacije

%Uporabimo na sliko iz sobela in cannyja HoughTransform
H_sobel = HoughTransform(edges_sobel);
H_canny = HoughTransform(edges_canny);

k = -2:0.01:2;
n = -200:1:200;

figure;
imagesc(n, k, H_sobel); colormap('gray'); colorbar; xlabel('n'); ylabel('k'); title('Hough – Sobel');
figure;
imagesc(n, k, H_canny); colormap('gray'); colorbar; xlabel('n'); ylabel('k'); title('Hough – Canny');

% Uporabimo gotovo funkcijo za risanje 5 premic
N = 5;
drawLines(img, H_sobel, N, 'Sobel');
drawLines(img, H_canny, N, 'Canny');


% Houghov algoritam
function HoughSpace = HoughTransform(image)

%definiramo intervali in houhgov prostor
k = -2:0.01:2;
n = -200:1:200;
HoughSpace = zeros(length(k), length(n));

%Najdemo vse piksle ki so svetli, rob
[ys, xs] = find(image);

% za vsak piksel gre cez vsake k in poracuna n, preveri ce je ta n v
% intervalu in steje glas, ki ga posamezen piksel za kombinacijo ki,ni da 
for idx = 1:numel(xs)
    x = xs(idx);
    y = ys(idx);
    for ki = 1:length(k)
        kval = k(ki);
        nval = y - kval * x;
        if nval >= -200 && nval <= 200
            ni = round(nval + 200) + 1;
            HoughSpace(ki, ni) = HoughSpace(ki, ni) + 1;
        end
    end
end
end
==== END Jakob Suhadolc | Jakob Suhadolc_22778_assignsubmission_file | Naloga1in2_Vaja4.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_22778_assignsubmission_file | Naloga3_Vaja4.m ====
% Naloga 3 – Izračun slike ozadja iz videa 
% Mihaela Temelkova & Jakob Suhadolc
 
v = VideoReader('squash.avi');
frames = read(v, [1 Inf]);
video_size=size(frames);
stack = frames(:,:,:,1:20:end); %grem po cel posnetek oz frame za 20 korak

% Izračun slike ozadja z mode
bg_double = mode(stack, 4);  

% Pretvori v uint8 in prikaži
bg = uint8(bg_double);
figure;
imshow(bg);
title('Ozadje');
imwrite(bg, 'background_squash.png');
==== END Jakob Suhadolc | Jakob Suhadolc_22778_assignsubmission_file | Naloga3_Vaja4.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_22778_assignsubmission_file | Naloga4_Vaja4.m ====
% Naloga 4 Detekcija podrocij in morfoloske operacije
% Mihaela Temelkova & Jakob Suhadolc


% preberemo sliko ozadja in video
bg = imread('background_squash.png');
v  = VideoReader('squash.avi');

% vzamemo prvi frame in izračunamo razliko z ozadjem - prikaz
frame = readFrame(v);
diff  = double(frame) - double(bg);      % razlika po RGB kanalih            
diff  = sqrt(sum(diff.^2, 3));           % evklidska razdalja v RGB

figure;
imagesc(diff);
colormap gray;
colorbar;
title('Prikaz razlike');

% testiranje morfoloske operacije
threshold = 60;
bw = diff > threshold;
bw = bwmorph(bw, 'open',2);
bw = bwmorph(bw, 'close',2);
bw = bwmorph(bw, 'clean');
bw = bwmorph(bw, 'majority');
figure
imagesc(bw)
colormap gray;
colorbar;

%%
% vrnemo se na začetek in preberemo vse frame-e v 4D matriko
v.CurrentTime = 0;
frames = read(v, [1 Inf]);              
video_size = size(frames);

% pripravimo nov video za rezultat
new_video = zeros(video_size, 'uint8');

% prag med igralcem in ozadjem
threshold = 60;

% območje igrišča (brez publike)
row_min = 50; row_max = 250;
col_min = 50; col_max = 320;

for f = 1:video_size(4)

    % vzamemo f-ti frame
    frame = frames(:,:,:,f);

    % izračunamo sliko razlike
    diff  = double(frame) - double(bg);
    diff  = sqrt(sum(diff.^2, 3));

    % 1 = dovolj drugačno od ozadja → kandidat za igralca
    bw = diff > threshold;

    % zadržimo samo pixle v območju igrišča, ostalo = 0
    bw_filtered = false(size(bw));
    bw_filtered(row_min:row_max, col_min:col_max) = ...
        bw(row_min:row_max, col_min:col_max);
    bw = bw_filtered;

    % morfološko čiščenje binarne slike
    bw = bwmorph(bw, 'open',2);
    bw = bwmorph(bw, 'close',2);
    bw = bwmorph(bw, 'clean');
    bw = bwmorph(bw, 'majority');

    % označimo povezane komponente
    [labels, num] = bwlabel(bw);
    stats = regionprops(labels, 'Area', 'BoundingBox');

    boxes   = [];   % seznam pravokotnikov ali krogov
    centers = [];   % težišča igralcev

    if num >= 1
        areas = [stats.Area];
        [~, order] = sort(areas, 'descend');
        k = min(2, num);     % največ 2 igralca

        for i = 1:k
            s = stats(order(i));

            boxes   = [boxes;   s.BoundingBox];
          
        end
    end

    % narišemo označbe direktno v sliko (brez figure, brez ax)
    if ~isempty(boxes)
        % pravokotniki okoli igralcev
        frame = insertShape(frame, 'Rectangle', boxes, ...
                            'Color', 'red', 'LineWidth', 2);
    end

    % shranimo obdelan frame v novi video
    new_video(:,:,:,f) = frame;
end

% zapišemo novi video na disk
writer_object = VideoWriter('squash_tracking.avi');
open(writer_object);
writeVideo(writer_object, new_video);
close(writer_object);
==== END Jakob Suhadolc | Jakob Suhadolc_22778_assignsubmission_file | Naloga4_Vaja4.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_22778_assignsubmission_file | Naloga5_Vaja4.m ====
% NALOGA 5 – sledenje igralcev in razpoznavanje po barvi majice
% % Mihaela Temelkova & Jakob Suhadolc

% preberemo sliko ozadja in video
bg = imread('background_squash.png');
v  = VideoReader('squash.avi');

v.CurrentTime = 0;
frames     = read(v, [1 Inf]);      % vsi frame-i videa
video_size = size(frames);

% pripravimo nov video za rezultat
new_video = zeros(video_size, 'uint8');

threshold = 60;              % prag za sliko razlike

% območje igrišča (brez publike)
row_min = 50; row_max = 250;
col_min = 50; col_max = 320;

for f = 1:video_size(4)

    % vzamemo f-ti frame
    frame = frames(:,:,:,f);

    % evklidska razdalja v RGB
    diff  = double(frame) - double(bg);
    diff  = sqrt(sum(diff.^2, 3));

    % binarna slika: 1 = dovolj drugačno od ozadja
    bw = diff > threshold;

    % maska igrišča, da publika odpade
    bw_filtered = false(size(bw));
    bw_filtered(row_min:row_max, col_min:col_max) = ...
        bw(row_min:row_max,  col_min:col_max);
    bw = bw_filtered;

    % morfološko čiščenje
    bw = bwmorph(bw, 'open', 3);
    bw = bwmorph(bw, 'close', 3);
    bw = bwmorph(bw, 'clean');
    bw = bwmorph(bw, 'majority');

    % povezana področja
    [labels, num] = bwlabel(bw);
    stats = regionprops(labels, 'Area', 'Centroid', ...
                                 'BoundingBox', 'PixelIdxList');

    boxes       = [];   % pravokotniki okoli igralcev
    centers     = [];   % težišča igralcev
    labels_text = {};   % oznake igralcev (A\B)

    if num >= 1
        % sortiramo regije po velikosti in vzamemo največ 2
        areas = [stats.Area];
        [~, order] = sort(areas, 'descend');
        k = min(2, num);          % največ 2 igralca

        % RGB kanali trenutnega frame-a za razpoznavanje barve
        R = double(frame(:,:,1));
        G = double(frame(:,:,2));
        B = double(frame(:,:,3));

        red_dom_vec = zeros(k,1);   % rdečost vsake regije

        for i = 1:k
            s = stats(order(i));

            % geometrija (detekcija)
            boxes   = [boxes;   s.BoundingBox];
            centers = [centers; s.Centroid];

            % barva (razpoznavanje)
            pix   = s.PixelIdxList;
            meanR = mean(R(pix));
            meanG = mean(G(pix));
            meanB = mean(B(pix));

            % rdečost: koliko je R večji od G in B
            red_dom_vec(i) = meanR - max(meanG, meanB);
        end

        % klasifikacija: B - bolj rdeč, A - manj rdeč
        labels_text = cell(k,1);
        if k == 2
            [~, idxRed]  = max(red_dom_vec);
            idxWhite     = 3 - idxRed;   % ker sta samo 1 in 2

            labels_text{idxRed}   = 'B';   % rdeč igralec
            labels_text{idxWhite} = 'A';   % bel igralec
            
        elseif k == 1
            if red_dom_vec(1) > 0
                labels_text{1} = 'B';
            else
                labels_text{1} = 'A';
            end
        end
    end

   if ~isempty(boxes) && ~isempty(centers)
    for i = 1:size(boxes,1)

        if strcmp(labels_text{i}, 'B')      % rdeč igralec
            rectColor = 'red';
            textColor = 'red';             % tudi črka rdeča
        else                                % bel igralec (A)
            rectColor = 'white';
            textColor = 'white';           % črka bela
        end

        % pravokotnik samo za tega igralca
        frame = insertShape(frame, 'Rectangle', boxes(i,:), ...
                            'Color', rectColor, 'LineWidth', 2);

        % črka samo za tega igralca
        frame = insertText(frame, centers(i,:), labels_text{i}, ...
                           'BoxOpacity', 0, ...
                           'TextColor', textColor, ...
                           'FontSize', 16, 'AnchorPoint', 'Center');
    end
end

    % shranimo obdelan frame v novi video
    new_video(:,:,:,f) = frame;
end

% zapišemo novi video na disk
writer_object = VideoWriter('squash_tracking_color.avi');
open(writer_object);
writeVideo(writer_object, new_video);
close(writer_object);
==== END Jakob Suhadolc | Jakob Suhadolc_22778_assignsubmission_file | Naloga5_Vaja4.m ====

