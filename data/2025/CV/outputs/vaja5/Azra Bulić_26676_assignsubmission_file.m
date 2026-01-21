==== BEGIN Azra Bulić | Azra Bulić_26676_assignsubmission_file | naloga1.m ====
vid = VideoReader('Holywood.avi');

% Skale i metode (3x3 = 9 videa)
scales = [0.5, 0.25, 0.125];

methods = {
    struct('tag','nearest','method','nearest',  'aa',[]), struct('tag','bilinear_AAoff','method','bilinear', 'aa',false), struct('tag','bilinear_AAon','method','bilinear', 'aa',true)
    };

% Napravi 9 writer-a
writers = cell(numel(scales), numel(methods));
for s = 1:numel(scales)
    for m = 1:numel(methods)
        outFile = sprintf('%s_%g.avi', methods{m}.tag, scales(s));
        vw = VideoWriter(outFile);
        vw.FrameRate = vid.FrameRate;   % zadrži originalni FPS
        open(vw);
        writers{s,m} = vw;
    end
end

% Obradi video frame po frame
vid.CurrentTime = 0;
while hasFrame(vid) %vrati video na pocetak i obradi frame po frame
    frame = readFrame(vid);  % uint8 HxWx3

    for s = 1:numel(scales)
        scale = scales(s);

        for m = 1:numel(methods)
            meth = methods{m};

            if strcmp(meth.method,'nearest')
                frameSmall = imresize(frame, scale, 'nearest');
            else
                frameSmall = imresize(frame, scale, 'bilinear', 'Antialiasing', meth.aa);
            end

            writeVideo(writers{s,m}, frameSmall);
        end
    end
end

% Zatvori sve
for s = 1:numel(scales)
    for m = 1:numel(methods)
        close(writers{s,m});
    end
end
==== END Azra Bulić | Azra Bulić_26676_assignsubmission_file | naloga1.m ====

==== BEGIN Azra Bulić | Azra Bulić_26676_assignsubmission_file | naloga22.m ====
clear; clc; close all;


videoFile = 'squash.avi';
outFile   = 'squash_tracking_chi2.avi';

numBins = 32;      % število binov histograma
epsilon = 20;      % velikost lokalnega iskanja
useGray = true;    % sivinski prostor


vid = VideoReader(videoFile);
writer = VideoWriter(outFile);
open(writer);


frame = readFrame(vid);

if useGray
    frameGray = rgb2gray(frame);
else
    frameGray = frame;
end

figure; imshow(frameGray);
title('Z dvema klikoma označi igralca');
[x, y] = ginput(2);

x = round(x); 
y = round(y);

x0 = min(x); 
y0 = min(y);
w  = abs(x(2) - x(1));
h  = abs(y(2) - y(1));

template = frameGray(y0:y0+h, x0:x0+w);
refHist = compute_hist(template, numBins);

pos = [x0 y0];

frameOut = insertShape(frame, 'Rectangle', [pos w h], ...
    'Color', 'red', 'LineWidth', 2);
writeVideo(writer, frameOut);

while hasFrame(vid)

    frame = readFrame(vid);

    if useGray
        frameGray = rgb2gray(frame);
    else
        frameGray = frame;
    end

    bestDist = inf;
    bestPos  = pos;

    for dx = -epsilon:epsilon
        for dy = -epsilon:epsilon

            xTest = pos(1) + dx;
            yTest = pos(2) + dy;

            if xTest < 1 || yTest < 1 || ...
               xTest+w > size(frameGray,2) || ...
               yTest+h > size(frameGray,1)
                continue;
            end

            patch = frameGray(yTest:yTest+h, xTest:xTest+w);
            patchHist = compute_hist(patch, numBins);

            dist = chi2_distance(refHist, patchHist);

            if dist < bestDist
                bestDist = dist;
                bestPos = [xTest yTest];
            end
        end
    end

    pos = bestPos;

    frameOut = insertShape(frame, 'Rectangle', ...
        [pos w h], 'Color', 'red', 'LineWidth', 2);
    writeVideo(writer, frameOut);
end

close(writer);
disp('Sledenje končano.');


function h = compute_hist(img, numBins)
    img = double(img);
    h = histcounts(img(:), numBins, 'Normalization', 'probability');
end

function d = chi2_distance(h1, h2)
    eps = 1e-10;
    d = sum(((h1 - h2).^2) ./ (h1 + h2 + eps));
end
==== END Azra Bulić | Azra Bulić_26676_assignsubmission_file | naloga22.m ====

==== BEGIN Azra Bulić | Azra Bulić_26676_assignsubmission_file | naloga3.m ====
clear; clc; close all;


videoFile = 'squash.avi';
outFile   = 'squash_tracking_3.avi';

numBins = 32;      % število binov histograma
epsilon = 20;      % velikost lokalnega iskanja
alpha   = 0.05;    % faktor učenja (ONLINE LEARNING)
useGray = true;    % sivinski prostor


vid = VideoReader(videoFile);
writer = VideoWriter(outFile);
open(writer);


frame = readFrame(vid);

if useGray
    frameGray = rgb2gray(frame);
else
    frameGray = frame;
end

figure; imshow(frameGray);
title('Z dvema klikoma označi igralca');
[x, y] = ginput(2);

x = round(x);
y = round(y);

x0 = min(x);
y0 = min(y);
w  = abs(x(2) - x(1));
h  = abs(y(2) - y(1));

template = frameGray(y0:y0+h, x0:x0+w);
refHist = compute_hist(template, numBins);

pos = [x0 y0];

frameOut = insertShape(frame, 'Rectangle', [pos w h], ...
    'Color', 'red', 'LineWidth', 2);
writeVideo(writer, frameOut);


while hasFrame(vid)

    frame = readFrame(vid);

    if useGray
        frameGray = rgb2gray(frame);
    else
        frameGray = frame;
    end

    bestDist = inf;
    bestPos  = pos;

   
    for dx = -epsilon:epsilon
        for dy = -epsilon:epsilon

            xTest = pos(1) + dx;
            yTest = pos(2) + dy;

            if xTest < 1 || yTest < 1 || ...
               xTest+w > size(frameGray,2) || ...
               yTest+h > size(frameGray,1)
                continue;
            end

            patch = frameGray(yTest:yTest+h, xTest:xTest+w);
            patchHist = compute_hist(patch, numBins);

            dist = chi2_distance(refHist, patchHist);

            if dist < bestDist
                bestDist = dist;
                bestPos = [xTest yTest];
            end
        end
    end

   
    pos = bestPos;

   
    patch = frameGray(pos(2):pos(2)+h, pos(1):pos(1)+w);
    currentHist = compute_hist(patch, numBins);

    refHist = (1 - alpha) * refHist + alpha * currentHist;
   
    frameOut = insertShape(frame, 'Rectangle', ...
        [pos w h], 'Color', 'green', 'LineWidth', 2);
    writeVideo(writer, frameOut);
end

close(writer);
disp('Sledenje s sprotnim učenjem končano.');



function h = compute_hist(img, numBins)
    img = double(img);
    h = histcounts(img(:), numBins, 'Normalization', 'probability');
end

function d = chi2_distance(h1, h2)
    eps = 1e-10;
    d = sum(((h1 - h2).^2) ./ (h1 + h2 + eps));
end
==== END Azra Bulić | Azra Bulić_26676_assignsubmission_file | naloga3.m ====

==== BEGIN Azra Bulić | Azra Bulić_26676_assignsubmission_file | naloga_2_1.m ====
vid = VideoReader('squash.avi');

% Prvi frame i ručno biranje pravougaonika
firstFrame = readFrame(vid);
figure; 
imshow(firstFrame); 
title('Klikni 2 ugla pravougaonika oko igraca');

[x, y] = ginput(2);
x = round(x); 
y = round(y);

x1 = max(1, min(x)); 
x2 = min(size(firstFrame,2), max(x));
y1 = max(1, min(y)); 
y2 = min(size(firstFrame,1), max(y));

w = x2 - x1 + 1;
h = y2 - y1 + 1;

% Pretvori u sivu i uzmi template
if size(firstFrame,3) == 3
    firstGray = rgb2gray(firstFrame);
else
    firstGray = firstFrame;
end
templ = double(firstGray(y1:y2, x1:x2));

% Parametar lokalne pretrage (epsilon)
eps = 6;  % podesi eksperimentalno

% Izlazni video
outFile = 'squash_track_L2.avi';
vw = VideoWriter(outFile);
vw.FrameRate = vid.FrameRate;
open(vw);

% Trenutna procjena pozicije (gornji lijevi ugao)
px = x1;
py = y1;

% Vrati video na početak i obradi sve frameove
vid.CurrentTime = 0;

while hasFrame(vid)
    frame = readFrame(vid);

    % siva slika
    if size(frame,3) == 3
        gray = rgb2gray(frame);
    else
        gray = frame;
    end
    grayD = double(gray);

    % Lokalno područje pretrage oko (px,py)
    xs = max(1, px - eps);
    ys = max(1, py - eps); %lijeva i gornja granica pretrage
    xe = min(size(gray,2) - w + 1, px + eps);
    ye = min(size(gray,1) - h + 1, py + eps); %desna i donja granica pretrage

    bestD = inf; %najveca moguca udaljenost
    bestX = px; 
    bestY = py;

    % Traži minimum L2 udaljenosti
    for yy = ys:ye
        for xx = xs:xe %xx i yy gdje bi igrac mogao biti u trenutnom frameu
            patch = grayD(yy:yy+h-1, xx:xx+w-1); %patch je istih dimenzija kao moj odabrani templ
            d = sum((patch(:) - templ(:)).^2);   % L2^2 (dovoljno, sqrt ne treba)
            if d < bestD %trazenje najmanjeg d
                bestD = d;
                bestX = xx;
                bestY = yy;
            end
        end
    end

    % Update pozicije
    px = bestX;
    py = bestY;

    % Ucrtavanje pravougaonika
    frameOut = insertShape(frame, 'Rectangle', [px py w h], 'LineWidth', 3);

    writeVideo(vw, frameOut);
end

close(vw);
==== END Azra Bulić | Azra Bulić_26676_assignsubmission_file | naloga_2_1.m ====

