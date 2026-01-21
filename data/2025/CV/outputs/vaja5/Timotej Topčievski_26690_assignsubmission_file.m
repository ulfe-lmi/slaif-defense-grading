==== BEGIN Timotej Topčievski | Timotej Topčievski_26690_assignsubmission_file | vaja5_3.m ====
%% Naloga 1
clear; clc; close all;

inFile = 'Holywood.avi';  
outDir = 'Naloga1';
if ~exist(outDir, 'dir'), mkdir(outDir); end

coeff = [0.5, 0.25, 0.125];
s
configs = {
    % name,      method,     antialias
    'nearest',   'nearest',   [];    
    'bilinear', 'bilinear',  false;
    'bilinear_AA', 'bilinear',  true;
};

for si = 1:numel(coeff)
    s = coeff(si);

    for ci = 1:size(configs,1)
        tag   = configs{ci,1};
        meth  = configs{ci,2};
        AA    = configs{ci,3};

        outFile = fullfile(outDir, sprintf('Holywood_scale_%g_%s.avi', s, tag));
        fprintf('Making: %s\n', outFile);

        make_resized_video(inFile, outFile, s, meth, AA);
    end
end

disp('Done!');

%% Naloga 2
clear; clc; close all;

v  = VideoReader("squash.avi");
V0 = read(v, [1 Inf]);                 
H = size(V0,1); W = size(V0,2); N = size(V0,4);

imshow(V0(:,:,:,1)); title("Klikni igralca (1x)");
p = ginput(1); close;

half = 4;                               
w0 = 2*half;  h0 = 2*half;
x0 = round(p(1) - half);
y0 = round(p(2) - half);

x0 = min(max(x0,1), W-w0);
y0 = min(max(y0,1), H-h0);

epsilon = 16;                           
marker  = 8;                            

nbins = 8;                              
binw  = 256/nbins;

%% 2.1
V = V0;

x = x0; y = y0; w = w0; h = h0;
tmpl = double(V(y:y+h, x:x+w, :, 1));    

for i = 1:N
    frame = double(V(:,:,:,i));

    bestD = inf; bestx = x; besty = y;

    x1 = max(1, x - epsilon); x2 = min(W-w, x + epsilon);
    y1 = max(1, y - epsilon); y2 = min(H-h, y + epsilon);

    for xx = x1:x2
        for yy = y1:y2
            patch = frame(yy:yy+h, xx:xx+w, :);
            d = sum((patch(:) - tmpl(:)).^2);   
            if d < bestD
                bestD = d; bestx = xx; besty = yy;
            end
        end
    end

    x = bestx; y = besty;

    % marker (moder)
    cx = round(x + w/2); cy = round(y + h/2);
    r1 = max(1, cy-floor(marker/2)); r2 = min(H, cy+floor(marker/2));
    c1 = max(1, cx-floor(marker/2)); c2 = min(W, cx+floor(marker/2));
    V(r1:r2, c1:c2, 1, i) = 0;
    V(r1:r2, c1:c2, 2, i) = 0;
    V(r1:r2, c1:c2, 3, i) = 255;
end

wrt = VideoWriter("naloga2_1.avi");
open(wrt); writeVideo(wrt, V); close(wrt);

%% 2.2
V = V0;

x = x0; y = y0; w = w0; h = h0;

refPatch = V(y:y+h, x:x+w, :, 1);
R = floor(double(refPatch(:,:,1))/binw);
G = floor(double(refPatch(:,:,2))/binw);
B = floor(double(refPatch(:,:,3))/binw);
R = min(max(R,0),nbins-1);
G = min(max(G,0),nbins-1);
B = min(max(B,0),nbins-1);
idx = R*nbins*nbins + G*nbins + B;                 
histRef = histcounts(idx(:), 0:(nbins^3));         
histRef = histRef / (sum(histRef) + eps);

for i = 1:N
    frame = V(:,:,:,i);

    bestD = inf; bestx = x; besty = y;

    x1 = max(1, x - epsilon); x2 = min(W-w, x + epsilon);
    y1 = max(1, y - epsilon); y2 = min(H-h, y + epsilon);

    for xx = x1:x2
        for yy = y1:y2
            patch = frame(yy:yy+h, xx:xx+w, :);

            R = floor(double(patch(:,:,1))/binw);
            G = floor(double(patch(:,:,2))/binw);
            B = floor(double(patch(:,:,3))/binw);
            R = min(max(R,0),nbins-1);
            G = min(max(G,0),nbins-1);
            B = min(max(B,0),nbins-1);

            idx = R*nbins*nbins + G*nbins + B;
            h2  = histcounts(idx(:), 0:(nbins^3));
            h2  = h2 / (sum(h2) + eps);

            d = sum((h2 - histRef).^2);

            if d < bestD
                bestD = d; bestx = xx; besty = yy;
            end
        end
    end

    x = bestx; y = besty;

    % marker (zelen)
    cx = round(x + w/2); cy = round(y + h/2);
    r1 = max(1, cy-floor(marker/2)); r2 = min(H, cy+floor(marker/2));
    c1 = max(1, cx-floor(marker/2)); c2 = min(W, cx+floor(marker/2));
    V(r1:r2, c1:c2, 1, i) = 0;
    V(r1:r2, c1:c2, 2, i) = 255;
    V(r1:r2, c1:c2, 3, i) = 0;
end

wrt = VideoWriter("naloga2_2.avi");
open(wrt); writeVideo(wrt, V); close(wrt);


%% Naloga 3
clear; clc; close all;

v  = VideoReader("squash.avi");
V0 = read(v, [1 Inf]);                 
H = size(V0,1); W = size(V0,2); N = size(V0,4);

imshow(V0(:,:,:,1)); title("Klikni igralca (1x)");
p = ginput(1); close;

half = 4;                               
w0 = 2*half;  h0 = 2*half;
x0 = round(p(1) - half);
y0 = round(p(2) - half);

x0 = min(max(x0,1), W-w0);
y0 = min(max(y0,1), H-h0);

epsilon = 16;
marker  = 8;

nbins = 8;
binw  = 256/nbins;

%% 3.1
V = V0;

x = x0; y = y0; w = w0; h = h0;
tmpl = double(V(y:y+h, x:x+w, :, 1));

for i = 1:N
    frame = double(V(:,:,:,i));

    bestD = inf; bestx = x; besty = y;

    x1 = max(1, x - epsilon); x2 = min(W-w, x + epsilon);
    y1 = max(1, y - epsilon); y2 = min(H-h, y + epsilon);

    for xx = x1:x2
        for yy = y1:y2
            patch = frame(yy:yy+h, xx:xx+w, :);
            d = sum((patch(:) - tmpl(:)).^2);     
            if d < bestD
                bestD = d; bestx = xx; besty = yy;
            end
        end
    end

    x = bestx; y = besty;

    tmpl = frame(y:y+h, x:x+w, :);

    % marker (moder)
    cx = round(x + w/2); cy = round(y + h/2);
    r1 = max(1, cy-floor(marker/2)); r2 = min(H, cy+floor(marker/2));
    c1 = max(1, cx-floor(marker/2)); c2 = min(W, cx+floor(marker/2));
    V(r1:r2, c1:c2, 1, i) = 0;
    V(r1:r2, c1:c2, 2, i) = 0;
    V(r1:r2, c1:c2, 3, i) = 255;
end

wrt = VideoWriter("naloga3_sprotno.avi");
open(wrt); writeVideo(wrt, V); close(wrt);


%% 3.2
V = V0;

x = x0; y = y0; w = w0; h = h0;

refPatch = V(y:y+h, x:x+w, :, 1);
R = floor(double(refPatch(:,:,1))/binw);
G = floor(double(refPatch(:,:,2))/binw);
B = floor(double(refPatch(:,:,3))/binw);
R = min(max(R,0),nbins-1);
G = min(max(G,0),nbins-1);
B = min(max(B,0),nbins-1);
idx = R*nbins*nbins + G*nbins + B;
histRef = histcounts(idx(:), 0:(nbins^3));
histRef = histRef / (sum(histRef) + eps);

for i = 1:N
    frameU8 = V(:,:,:,i);              

    bestD = inf; bestx = x; besty = y;
    bestHist = histRef;

    x1 = max(1, x - epsilon); x2 = min(W-w, x + epsilon);
    y1 = max(1, y - epsilon); y2 = min(H-h, y + epsilon);

    for xx = x1:x2
        for yy = y1:y2
            patch = frameU8(yy:yy+h, xx:xx+w, :);

            R = floor(double(patch(:,:,1))/binw);
            G = floor(double(patch(:,:,2))/binw);
            B = floor(double(patch(:,:,3))/binw);
            R = min(max(R,0),nbins-1);
            G = min(max(G,0),nbins-1);
            B = min(max(B,0),nbins-1);

            idx = R*nbins*nbins + G*nbins + B;
            h2  = histcounts(idx(:), 0:(nbins^3));
            h2  = h2 / (sum(h2) + eps);

            d = sum((h2 - histRef).^2);

            if d < bestD
                bestD = d; bestx = xx; besty = yy;
                bestHist = h2;          
            end
        end
    end

    x = bestx; y = besty;

  
    histRef = bestHist;

    % marker (zelen)
    cx = round(x + w/2); cy = round(y + h/2);
    r1 = max(1, cy-floor(marker/2)); r2 = min(H, cy+floor(marker/2));
    c1 = max(1, cx-floor(marker/2)); c2 = min(W, cx+floor(marker/2));
    V(r1:r2, c1:c2, 1, i) = 0;
    V(r1:r2, c1:c2, 2, i) = 255;
    V(r1:r2, c1:c2, 3, i) = 0;
end

wrt = VideoWriter("naloga3_hist_sprotno.avi");
open(wrt); writeVideo(wrt, V); close(wrt);

%% Funkcije
     
function make_resized_video(inFile, outFile, scale, method, antialiasFlag)
    vr = VideoReader(inFile);

    vw = VideoWriter(outFile, 'Motion JPEG AVI');
    vw.FrameRate = vr.FrameRate;
    open(vw);

    while hasFrame(vr)
        frame = readFrame(vr);

        
        if isempty(antialiasFlag)
            frameSmall = imresize(frame, scale, method);
        else
            frameSmall = imresize(frame, scale, method, 'Antialiasing', antialiasFlag);
        end

        writeVideo(vw, frameSmall);
    end

    close(vw);
end

==== END Timotej Topčievski | Timotej Topčievski_26690_assignsubmission_file | vaja5_3.m ====

