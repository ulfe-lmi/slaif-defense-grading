==== BEGIN Rok Prezelj | Rok Prezelj_26674_assignsubmission_file | main.m ====
%% Naloga 1
vidObjPath = "Holywood2-t00427-rgb.avi";

vidNameNear = "1.near_";
vidNameBilinear = "1.bilinear_";
vidNameBilinearAliasing = "1.bilinearAliasing_";

for scale = [0.5, 0.25, 0.125]

    vidObj = VideoReader(vidObjPath);

    vidNear = VideoWriter(vidNameNear + string(scale) + ".avi", "Motion JPEG AVI");
    vidBilinear = VideoWriter(vidNameBilinear + string(scale) + ".avi", "Motion JPEG AVI");
    vidBilinearAliasing = VideoWriter(vidNameBilinearAliasing + string(scale) + ".avi", "Motion JPEG AVI");

    vidNear.FrameRate = vidObj.FrameRate;
    vidBilinear.FrameRate = vidObj.FrameRate;
    vidBilinearAliasing.FrameRate = vidObj.FrameRate;

    open(vidNear);
    open(vidBilinear);
    open(vidBilinearAliasing);

    while hasFrame(vidObj)
        vidFrame = readFrame(vidObj);

        frameNear = imresize(vidFrame, scale, "nearest");
        frameBilinear = imresize(vidFrame, scale, "bilinear", "Antialiasing", false);
        frameBilinearAliasing = imresize(vidFrame, scale, "bilinear", "Antialiasing", true);

        writeVideo(vidNear, frameNear);
        writeVideo(vidBilinear, frameBilinear);
        writeVideo(vidBilinearAliasing, frameBilinearAliasing);
    end

    close(vidNear);
    close(vidBilinear);
    close(vidBilinearAliasing);
end

%% Izlocitev igrisca iz posnetka (median background + avtomatska ROI)
vidObj = VideoReader("squash.avi");
frames = [];
idx = 1;

while hasFrame(vidObj)
    f = readFrame(vidObj);
    frames(:,:,:,idx) = f;
    idx = idx + 1;
end

court = uint8(round(median(frames, 4)));
imshow(court)

imwrite(court, "igrisce.png", "PNG");

%% Naloga 2.0
vidObj = VideoReader("squash.avi");
vidFrame = readFrame(vidObj);

% Bounding box igralca
% imshow(vidFrame);
% title("Klikni meje pravokotnika igralca.");
% [x, y] = ginput(2)
% close(vidObj)
x = [91; 63]; y = [96; 82]; % Bel igralec
% x = [95; 120]; y = [135; 116]; % Rdec igralec
x_min = round(min(x));
x_max = round(max(x));
y_min = round(min(y));
y_max = round(max(y));

% Pozicija igralca
x_i_original = round((x_min + x_max) / 2);
y_i_original = round((y_min + y_max) / 2);

%% Naloga 2.1 – primerjanje s predlogo, Evklidska razdalja
vidObj = VideoReader("squash.avi");

igrisce = double(imread("igrisce.png"));
piksliIgralca = double(vidFrame(y_min:y_max, x_min:x_max, :));
piksliIgralcaBrezIgrisca = double(piksliIgralca) - double(igrisce(y_min:y_max, x_min:x_max, :));

% Template ki ga bomo iskali na video posneku/frameih.
template = double(piksliIgralcaBrezIgrisca);

% Velikost območja ki ga bomo iskali. bbox + epsilon
epsilon_x = 20;
epsilon_y = 15;

% Velikost igralca v pikslih
bbox_h = size(template, 1);
bbox_w = size(template, 2);

cx_off = floor(bbox_w/2);
cy_off = floor(bbox_h/2);

writer = VideoWriter("2.1.Evklidska-bel.avi", "Motion JPEG AVI");
writer.FrameRate = vidObj.FrameRate;
open(writer);

x_i = x_i_original;
y_i = y_i_original;

while hasFrame(vidObj)
    frame = double(readFrame(vidObj));
    frameBrezIgrisca = frame - igrisce;

    H = size(frameBrezIgrisca, 1);
    W = size(frameBrezIgrisca, 2);

    % Area in which we search for the player (top-left corner search range)
    x_search_min = max(1, x_i - cx_off - epsilon_x);
    x_search_max = min(W - bbox_w + 1, x_i - cx_off + epsilon_x);

    y_search_min = max(1, y_i - cy_off - epsilon_y);
    y_search_max = min(H - bbox_h + 1, y_i - cy_off + epsilon_y);

    best_dist = Inf;
    best_x_i = x_i;
    best_y_i = y_i;

    for y = y_search_min:y_search_max
        for x = x_search_min:x_search_max
            patch = frameBrezIgrisca(y:y+bbox_h-1, x:x+bbox_w-1, :);
            diff = patch - template;
            dist = sum(diff(:).^2);

            if dist < best_dist
                best_dist = dist;
                best_x_i = x + cx_off;
                best_y_i = y + cy_off;
            end
        end
    end

    x_i = best_x_i;
    y_i = best_y_i;

    imshow(uint8(frame));
    rectangle('Position', [x_i - cx_off, y_i - cy_off, bbox_w, bbox_h], ...
              'EdgeColor', 'r', 'LineWidth', 2);
    drawnow;

    fr = getframe(gca);
    writeVideo(writer, fr.cdata);
end
close(writer)

%% Naloga 2.2 Histogram (chi-square)
vidObj = VideoReader("squash.avi");

igrisce = double(imread("igrisce.png"));
piksliIgralca = double(vidFrame(y_min:y_max, x_min:x_max, :));

bbox_h = size(piksliIgralca, 1);
bbox_w = size(piksliIgralca, 2);

templateDiff = abs(piksliIgralca - igrisce(y_min:y_max, x_min:x_max, :));
templateGray = rgb2gray(uint8(templateDiff));

nbins = 64;
templateHist = imhist(templateGray, nbins);
templateHist = templateHist / (sum(templateHist) + eps);

epsilon_x = 20;
epsilon_y = 15;

cx_off = floor(bbox_w/2);
cy_off = floor(bbox_h/2);

writer = VideoWriter("2.2.Histogram-bel.avi", "Motion JPEG AVI");
writer.FrameRate = vidObj.FrameRate;
open(writer);

x_i = x_i_original;
y_i = y_i_original;

while hasFrame(vidObj)
    frame = double(readFrame(vidObj));

    % Odštej igrišče (spet: abs razlika)
    frameDiff = abs(frame - igrisce);

    H = size(frameDiff, 1);
    W = size(frameDiff, 2);

    % Lokalno iskanje (top-left koordinata izseka)
    x_search_min = max(1, x_i - cx_off - epsilon_x);
    x_search_max = min(W - bbox_w + 1, x_i - cx_off + epsilon_x);

    y_search_min = max(1, y_i - cy_off - epsilon_y);
    y_search_max = min(H - bbox_h + 1, y_i - cy_off + epsilon_y);

    best_dist = Inf;
    best_x_i = x_i;
    best_y_i = y_i;

    for y = y_search_min:y_search_max
        for x = x_search_min:x_search_max

            patch = frameDiff(y:y+bbox_h-1, x:x+bbox_w-1, :);
            patchGray = rgb2gray(uint8(patch));

            hPatch = imhist(patchGray, nbins);
            hPatch = hPatch / (sum(hPatch) + eps);

            % χ² razdalja (stabilna verzija)
            dist = sum((hPatch - templateHist).^2 ./ (hPatch + templateHist + eps));

            if dist < best_dist
                best_dist = dist;
                best_x_i = x + cx_off;
                best_y_i = y + cy_off;
            end
        end
    end

    x_i = best_x_i;
    y_i = best_y_i;

    imshow(uint8(frame));
    rectangle('Position', [x_i - cx_off, y_i - cy_off, bbox_w, bbox_h], ...
              'EdgeColor', 'r', 'LineWidth', 2);
    drawnow;

    fr = getframe(gca);
    writeVideo(writer, fr.cdata);
end

%% Naloga 3
vidObj = VideoReader("squash.avi");

igrisce = double(imread("igrisce.png"));
piksliIgralca = double(vidFrame(y_min:y_max, x_min:x_max, :));

bbox_h = size(piksliIgralca, 1);
bbox_w = size(piksliIgralca, 2);

templateDiff = abs(piksliIgralca - igrisce(y_min:y_max, x_min:x_max, :));
templateGray = rgb2gray(uint8(templateDiff));

nbins = 64;
templateHist = imhist(templateGray, nbins);
templateHist = templateHist / (sum(templateHist) + eps);
originalTemlpateHist = templateHist;

epsilon_x = 20;
epsilon_y = 15;

cx_off = floor(bbox_w/2);
cy_off = floor(bbox_h/2);

writer = VideoWriter("3.Sprotno_ucenje-bel.avi", "Motion JPEG AVI");
writer.FrameRate = vidObj.FrameRate;
open(writer);

x_i = x_i_original;
y_i = y_i_original;

while hasFrame(vidObj)
    frame = double(readFrame(vidObj));

    % Odštej igrišče (spet: abs razlika)
    frameDiff = abs(frame - igrisce);

    H = size(frameDiff, 1);
    W = size(frameDiff, 2);

    % Lokalno iskanje (top-left koordinata izseka)
    x_search_min = max(1, x_i - cx_off - epsilon_x);
    x_search_max = min(W - bbox_w + 1, x_i - cx_off + epsilon_x);

    y_search_min = max(1, y_i - cy_off - epsilon_y);
    y_search_max = min(H - bbox_h + 1, y_i - cy_off + epsilon_y);

    best_dist = Inf;
    best_x_i = x_i;
    best_y_i = y_i;

    for y = y_search_min:y_search_max
        for x = x_search_min:x_search_max

            patch = frameDiff(y:y+bbox_h-1, x:x+bbox_w-1, :);
            patchGray = rgb2gray(uint8(patch));

            hPatch = imhist(patchGray, nbins);
            hPatch = hPatch / (sum(hPatch) + eps);

            % χ² razdalja (stabilna verzija)
            dist = sum((hPatch - templateHist).^2 ./ (hPatch + templateHist + eps));

            if dist < best_dist
                bestHist = hPatch;
                best_dist = dist;
                best_x_i = x + cx_off;
                best_y_i = y + cy_off;
            end
        end
    end

    x_i = best_x_i;
    y_i = best_y_i;

    templateHist = (bestHist + originalTemlpateHist)/2;

    imshow(uint8(frame));
    rectangle('Position', [x_i - cx_off, y_i - cy_off, bbox_w, bbox_h], ...
              'EdgeColor', 'r', 'LineWidth', 2);
    drawnow;

    fr = getframe(gca);
    writeVideo(writer, fr.cdata);
end
==== END Rok Prezelj | Rok Prezelj_26674_assignsubmission_file | main.m ====

