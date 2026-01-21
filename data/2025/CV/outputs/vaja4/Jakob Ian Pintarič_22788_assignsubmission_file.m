==== BEGIN Jakob Ian Pintarič | Jakob Ian Pintarič_22788_assignsubmission_file | vaja4.m ====
%% naloga 1

hotel = imread('hotel.jpg');
imgGray = rgb2gray(hotel);
imgGray = double(imgGray);

Sx = [ 1  0 -1;
       2  0 -2;
       1  0 -1 ];

Sy = [ 1  2  1;
       0  0  0;
      -1 -2 -1 ];

Gx = conv2(imgGray, Sx, 'same');
Gy = conv2(imgGray, Sy, 'same');

G = sqrt(Gx.^2 + Gy.^2);

G = G / max(G(:));

BW_sobel = G > 0.25;

BW_canny = edge(uint8(imgGray), 'canny');

% Primerjava
figure;
subplot(1,3,1); imshow(uint8(imgGray));title('Sivinska');
subplot(1,3,2); imshow(BW_sobel); title('Sobel');
subplot(1,3,3); imshow(BW_canny); title('Canny');

%% nalgoa 2

H_sobel = HoughTransform(BW_sobel);
H_canny = HoughTransform(BW_canny);

N = 5;

drawLines(hotel, H_sobel, N, 'Hough + Sobel');
drawLines(hotel, H_canny, N, 'Hough + Canny');

%% naloga 3

v = VideoReader('squash.avi');

step = 10;          
frames = [];

cnt = 1;
idx = 1;

while hasFrame(v)
    frame = readFrame(v);

    if mod(cnt, step) == 0
        frames(:,:,:,idx) = frame;
        idx = idx + 1;
    end

    cnt = cnt + 1;
end

background = median(frames, 4);
background = uint8(background);

figure;
imshow(background);
title('Ozadje posnetka');
%% naloga 4
v = VideoReader('squash.avi');
out = VideoWriter('squash_sledenje.avi');
open(out);

frame_id = 0;

while hasFrame(v)
    frame = readFrame(v);
    frame_id = frame_id + 1;

    % 1. Slika razlike (evklidska razdalja RGB)
    diffImg = double(frame) - double(background);
    diffImg = sqrt( diffImg(:,:,1).^2 + diffImg(:,:,2).^2 + diffImg(:,:,3).^2 );

    % 2. Prikaz slike razlike
    if frame_id == 1
        figure;
        imagesc(diffImg);
        colormap gray;
        colorbar;
        title('Slika razlike');
    end

    % 3. Pragovanje
    BW = diffImg > 40;

    % 4. Morfološke operacije za odstranjevanje šuma
    BW = bwmorph(BW, 'open');
    BW = bwmorph(BW, 'close');
    BW = bwmorph(BW, 'fill');

    % 5. Označevanje povezanih področij
    [L, num] = bwlabel(BW);

    stats = regionprops(L, 'Area', 'Centroid', 'BoundingBox');

    % 6. Izris pozicij na izvirno sliko
    figure(1); clf;
    imshow(frame);
    hold on;

    for i = 1:num
        if stats(i).Area > 300
            c = stats(i).Centroid;
            rectangle('Position', stats(i).BoundingBox, ...
                      'EdgeColor', 'r', 'LineWidth', 2);
            plot(c(1), c(2), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
        end
    end

    hold off;

    % 7. Zapis v video
    F = getframe(gca);
    writeVideo(out, F.cdata);
end

close(out);

%% naloga 5
v = VideoReader('squash.avi');
out = VideoWriter('squash_sledenje1.avi');
open(out);

frame_id = 0;

while hasFrame(v)

    frame = readFrame(v);
    frame_id = frame_id + 1;

    diffImg = double(frame) - double(background);
    diffImg = sqrt( diffImg(:,:,1).^2 + diffImg(:,:,2).^2 + diffImg(:,:,3).^2 );

    if frame_id == 1
        figure;
        imagesc(diffImg);
        colormap gray;
        colorbar;
        title('Slika razlike');
    end

    BW = diffImg > 40;

    BW = bwmorph(BW, 'open');
    BW = bwmorph(BW, 'close');
    BW = bwmorph(BW, 'fill');

    [L, num] = bwlabel(BW);
    stats = regionprops(L, 'Area', 'Centroid', 'BoundingBox');

    figure(1); clf;
    imshow(frame);
    hold on;

    candidates = [];

    for i = 1:num
        if stats(i).Area > 300

            bb = round(stats(i).BoundingBox);
            bb(1) = max(bb(1),1);
            bb(2) = max(bb(2),1);
            bb(3) = min(bb(3), size(frame,2)-bb(1));
            bb(4) = min(bb(4), size(frame,1)-bb(2));

            roi = frame(bb(2):bb(2)+bb(4), bb(1):bb(1)+bb(3), :);

            meanR = mean(roi(:,:,1),'all');
            meanG = mean(roi(:,:,2),'all');
            meanB = mean(roi(:,:,3),'all');

            redScore = meanR - (meanG + meanB)/2;

            candidates = [candidates; i, redScore];
        end
    end

    if size(candidates,1) >= 2

        [~, idx] = max(candidates(:,2));
        idx_red = candidates(idx,1);

        for i = 1:num
            if stats(i).Area > 300

                bb = stats(i).BoundingBox;
                c = stats(i).Centroid;

                if i == idx_red
                    label = 'Igralec 1';
                    color = 'r';
                else
                    label = 'Igralec 2';
                    color = 'b';
                end

                rectangle('Position', bb, ...
                          'EdgeColor', color, 'LineWidth', 2);

                plot(c(1), c(2), 'o', ...
                     'Color', color, 'MarkerSize', 8, 'LineWidth', 2);

                text(bb(1), bb(2)-10, label, ...
                     'Color', color, 'FontSize', 12, 'FontWeight', 'bold');
            end
        end
    end

    hold off;

    F = getframe(gca);
    writeVideo(out, F.cdata);

end

close(out);

%% H transform
function H = HoughTransform(BinaryImage)

% Parametrski prostor
k = linspace(-2, 2, 401);
n = linspace(-200, 200, 401);

H = zeros(length(k), length(n));

[rows, cols] = size(BinaryImage);

% Poišči robne točke
[y_idx, x_idx] = find(BinaryImage == 1);

% Glasovanje
for i = 1:length(x_idx)
    x = x_idx(i);
    y = y_idx(i);

    for ki = 1:length(k)
        ni = round(y - k(ki)*x);

        % preveri, ali je n znotraj intervala
        if ni >= -200 && ni <= 200
            n_index = ni + 201;
            H(ki, n_index) = H(ki, n_index) + 1;
        end
    end
end
end
==== END Jakob Ian Pintarič | Jakob Ian Pintarič_22788_assignsubmission_file | vaja4.m ====

