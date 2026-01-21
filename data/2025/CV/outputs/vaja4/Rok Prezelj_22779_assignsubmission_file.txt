==== BEGIN Rok Prezelj | Rok Prezelj_22779_assignsubmission_file | main.m ====
%% Naloga 1
hotelRGB = imread('hotel.jpg');
hotelGray = double(rgb2gray(hotelRGB));

% BW1 = edge(hotelGray,'sobel');
% BW2 = edge(hotelGray,'canny');

Sx = [+1 0 -1
      +2 0 -2
      +1 0 -1];

Sy = [+1 +2 +1
      +0 +0 +0
      -1 -2 -1];

hotelGrayEdgeX = imfilter(hotelGray, Sx);
hotelGrayEdgeY = imfilter(hotelGray, Sy);

hotelGrayEdgeXY = sqrt(hotelGrayEdgeX.^2 + hotelGrayEdgeY.^2);
hotelGrayEdgeXY = uint8(255 * hotelGrayEdgeXY / max(max(hotelGrayEdgeXY)));

figure; imshow(hotelGrayEdgeXY)

thresHold = 112;
hotelGrayEdgeXYThreshold = hotelGrayEdgeXY > thresHold;
figure; imshow(hotelGrayEdgeXYThreshold)


hotelEdgeCanny = edge(hotelGray, 'canny');
figure; imshow(hotelEdgeCanny)

figure;
subplot(1, 2, 1)
imshow(hotelGrayEdgeXYThreshold)
subplot(1, 2, 2)
imshow(hotelEdgeCanny)

%% Naloga 2
imgSize = size(hotelGray);
xMin = 1;
xMax = imgSize(2);

yMin = 1;
yMax = imgSize(1);


parts = 400;

naklonMin = -2;
naklonMax = 2;
naklonStep = (naklonMax - naklonMin) / parts;

premikMin = -200;
premikMax = 200;
premikStep = (premikMax - premikMin) / parts;

nakloni = naklonMin:naklonStep:naklonMax;
premiki = premikMin:premikStep:premikMax;

figure; hold on;
akumulator = zeros([parts, parts]);
x = linspace(xMin, xMax);

kindex = 1;
for k = nakloni
    nindex = 1;
    for n = premiki
        count = 0;
        countCanny = 0;
        countSobel = 0;
        for x = xMin:1:xMax
            y = round(x*k + n);
            if y < 1 || y > yMax
                continue
            end
            count = count + hotelGrayEdgeXYThreshold(y, x);
        end
        akumulator(kindex, nindex) = count;
        nindex = nindex + 1;
    end
    kindex = kindex + 1;
end

figure; imshow(uint8(akumulator))

N = 10;

[values, linearIdx] = maxk(akumulator(:), N);

% Convert linear indices to row/column
[rowIdx, colIdx] = ind2sub(size(akumulator), linearIdx);

% Corresponding k and n values
k_vals = nakloni(rowIdx);
n_vals = premiki(colIdx);

figure; hold on; imshow(hotelRGB)

xValue = linspace(xMin, xMax);
for i = 1:1:N
    line(xValue, xValue * k_vals(i) + n_vals(i), linewidth = 2)
end

%% Naloga 3
vidObj = VideoReader("squash.avi");

step = 10;
count = 1;
idx = 1;

frames = [];

while hasFrame(vidObj)
    frame = readFrame(vidObj);

    if mod(count, step) == 0
        frames(:,:,:,idx) = frame;
        idx = idx + 1;
    end

    count = count + 1;
end

background = uint8(median(frames, 4));
imshow(background)
% rect = getrect
rect = [25, 37, 345, 212];

x = rect(1);
y = rect(2);
w = rect(3);
h = rect(4);

igrisce = background(y : y+h-1, x : x+w-1, :);
imshow(igrisce)

%% Naloga 5

vidObj = VideoReader("squash.avi");
writer = VideoWriter("squash_tracked_downscaled.avi");
open(writer);

intscale = 2;
scale = 1/intscale;

rect = [25, 37, 345, 212];
x = round(rect(1)*scale);
y = round(rect(2)*scale);
w = round(rect(3)*scale);
h = round(rect(4)*scale);

realImageOffset = [x, y] * intscale;

downscaledBG = imresize(background, scale);
downscaledBG = downscaledBG(y:y+h-1, x:x+w-1, :);
bg = double(downscaledBG);
i = 1;
tic;

while hasFrame(vidObj)

    frameOriginal = readFrame(vidObj);
    frameSmall = imresize(frameOriginal, scale);
    court = frameSmall(y:y+h-1, x:x+w-1, :);

    courtD = double(court);

    % Evklidska razdalja
    D = sqrt( ...
        (courtD(:,:,1) - bg(:,:,1)).^2 + ...
        (courtD(:,:,2) - bg(:,:,2)).^2 + ...
        (courtD(:,:,3) - bg(:,:,3)).^2 );
    if i == 1
        imagesc(double(D))
    end

    % binarizacija + morfologija
    BW = D > 40;
    BW = bwmorph(BW, 'open');
    BW = bwmorph(BW, 'fill');

    [L, num] = bwlabel(BW);
    stats = regionprops(L, 'Area', 'Centroid', 'BoundingBox');

    % izris na originalni sliki
    imshow(frameOriginal); hold on;

    if num > 0
        areas = [stats.Area];
        [~, idx] = sort(areas, 'descend');
        maxPlayers = min(2, num);   % 0, 1 ali 2

        for k = 1:maxPlayers
            s = stats(idx(k));

            % maska trenutnega območja
            mask = (L == idx(k));
            
            courtHSV = rgb2hsv(uint8(court));

            H = courtHSV(:,:,1);
            S = courtHSV(:,:,2);
            V = courtHSV(:,:,3);

            meanH = mean(H(mask));
            meanS = mean(S(mask));
            
            if meanS >= 0.40
                playerName  = 'Red';
                playerColor = 'r';
            
            elseif meanS < 0.40
                playerName  = 'White';
                playerColor = 'b';
            
            else
                playerName  = 'Unknown';
                playerColor = 'y';
            end

            % geometrija
            center = s.Centroid * intscale + realImageOffset;
            bbox = s.BoundingBox;
            radius = max(bbox(3), bbox(4)) / 2 * intscale;

            % izris
            viscircles(center, radius, 'Color', playerColor, 'LineWidth', 2);
            text(center(1), center(2)-10, playerName, ...
                 'Color', playerColor, 'FontSize', 12, 'FontWeight', 'bold');
        end
    end

    hold off;

    % zapis videa
    frameOut = getframe(gca);
    writeVideo(writer, frameOut);

    % ocena časa
    elapsed = toc;
    if i > 5 && mod(i,8) == 0
        timeLeft = (vidObj.NumFrames - i) * elapsed / i;
        fprintf('Remaining: %.1f s\n', timeLeft);
    end

    i = i + 1;
end


close(writer);
disp("Video successfully written.");
==== END Rok Prezelj | Rok Prezelj_22779_assignsubmission_file | main.m ====

