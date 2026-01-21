==== BEGIN VALENTIN NEMANIČ | VALENTIN NEMANIČ_26682_assignsubmission_file | Vaja5_min_rgb_sp.m ====
%% RV_Vaja5
%% 1) Podvzorcenje
clear;

v = VideoReader("Holywood.avi");
V = read(v, [1 Inf]);

scales = [1/2 1/4 1/8];

% 1) nearest
for s = scales
    Vout = zeros(max(1,round(size(V,1)*s)), max(1,round(size(V,2)*s)), 3, size(V,4), "like", V);
    for i = 1:size(V,4)
        Vout(:,:,:,i) = imresize(V(:,:,:,i), s, "nearest");
    end
    w = VideoWriter(sprintf("nearest_%g.avi", s));
    open(w); writeVideo(w, Vout); close(w);
end

% 2) bilinear (antialiasing off)
for s = scales
    Vout = zeros(max(1,round(size(V,1)*s)), max(1,round(size(V,2)*s)), 3, size(V,4), "like", V);
    for i = 1:size(V,4)
        Vout(:,:,:,i) = imresize(V(:,:,:,i), s, "bilinear", "Antialiasing", false);
    end
    w = VideoWriter(sprintf("bilinear_noAA_%g.avi", s));
    open(w); writeVideo(w, Vout); close(w);
end

% 3) bilinear (antialiasing on)
for s = scales
    Vout = zeros(max(1,round(size(V,1)*s)), max(1,round(size(V,2)*s)), 3, size(V,4), "like", V);
    for i = 1:size(V,4)
        Vout(:,:,:,i) = imresize(V(:,:,:,i), s, "bilinear", "Antialiasing", true);
    end
    w = VideoWriter(sprintf("bilinear_AA_%g.avi", s));
    open(w); writeVideo(w, Vout); close(w);
end


%% Skupna izbira obmocja (1x) z eno tocko:
clear;

v = VideoReader("squash.avi");
V0 = read(v, [1 Inf]);

H = size(V0,1); W = size(V0,2); N = size(V0,4);

first = V0(:,:,:,1);
imshow(first);
p = ginput(1);
close;

half = 4;                 % okolica (če je 2 dela tudi sprotno sledenje)
w0 = 2*half; h0 = 2*half; 
x0 = round(p(1) - half);
y0 = round(p(2) - half);

x0 = min(max(x0,1), W-w0);
y0 = min(max(y0,1), H-h0);

epsilon = 16;
marker = 8;

nbins = 8;
binw = 256/nbins;


%% 2.1) Predloga + Evklidska razdalja (L2) na RGB
V = V0;

x = x0; y = y0; w = w0; h = h0;
tmpl = double(V( y:y+h, x:x+w, :, 1));

for i = 1:N
    frame = V(:,:,:,i);

    bestD = inf;
    bestx = x;
    besty = y;

    x1 = max(1, x - epsilon); x2 = min(W-w, x + epsilon);
    y1 = max(1, y - epsilon); y2 = min(H-h, y + epsilon);

    for xx = x1:x2
        for yy = y1:y2
            patch = double(frame(yy:yy+h, xx:xx+w, :));
            d = sqrt(sum((patch(:) - tmpl(:)).^2));
            if d < bestD
                bestD = d;
                bestx = xx;
                besty = yy;
            end
        end
    end

    x = bestx; y = besty;

    cx = round(x + w/2);
    cy = round(y + h/2);

    r1 = max(1, cy-floor(marker/2)); r2 = min(H, cy+floor(marker/2));
    c1 = max(1, cx-floor(marker/2)); c2 = min(W, cx+floor(marker/2));

    V(r1:r2, c1:c2, 1, i) = 0;
    V(r1:r2, c1:c2, 2, i) = 0;
    V(r1:r2, c1:c2, 3, i) = 255;
end

wrt = VideoWriter("evklidska_razdalja.avi");
open(wrt); writeVideo(wrt, V); close(wrt);


%% 2.2) RGB histogram (3D) + vsota kvadratov razlik binov
V = V0;

x = x0; y = y0; w = w0; h = h0;

tmplPatch = double(V(y:y+h, x:x+w, :, 1));
histRef = zeros(nbins, nbins, nbins);

for a = 1:size(tmplPatch,1)
    for b = 1:size(tmplPatch,2)
        rr = floor(tmplPatch(a,b,1)/binw) + 1;
        gg = floor(tmplPatch(a,b,2)/binw) + 1;
        bb = floor(tmplPatch(a,b,3)/binw) + 1;
        rr = min(max(rr,1),nbins);
        gg = min(max(gg,1),nbins);
        bb = min(max(bb,1),nbins);
        histRef(rr,gg,bb) = histRef(rr,gg,bb) + 1;
    end
end

for i = 1:N
    frame = double(V(:,:,:,i));

    bestD = inf;
    bestx = x;
    besty = y;

    x1 = max(1, x - epsilon); x2 = min(W-w, x + epsilon);
    y1 = max(1, y - epsilon); y2 = min(H-h, y + epsilon);

    for xx = x1:x2
        for yy = y1:y2
            patch = frame(yy:yy+h, xx:xx+w, :);

            h2 = zeros(nbins, nbins, nbins);
            for a = 1:size(patch,1)
                for b = 1:size(patch,2)
                    rr = floor(patch(a,b,1)/binw) + 1;
                    gg = floor(patch(a,b,2)/binw) + 1;
                    bb = floor(patch(a,b,3)/binw) + 1;
                    rr = min(max(rr,1),nbins);
                    gg = min(max(gg,1),nbins);
                    bb = min(max(bb,1),nbins);
                    h2(rr,gg,bb) = h2(rr,gg,bb) + 1;
                end
            end

            d = sum((h2(:) - histRef(:)).^2);

            if d < bestD
                bestD = d;
                bestx = xx;
                besty = yy;
            end
        end
    end

    x = bestx; y = besty;

    cx = round(x + w/2);
    cy = round(y + h/2);

    r1 = max(1, cy-floor(marker/2)); r2 = min(H, cy+floor(marker/2));
    c1 = max(1, cx-floor(marker/2)); c2 = min(W, cx+floor(marker/2));

    V(r1:r2, c1:c2, 1, i) = 0;
    V(r1:r2, c1:c2, 2, i) = 255;
    V(r1:r2, c1:c2, 3, i) = 0;
end

wrt = VideoWriter("mera_podobnosti.avi");
open(wrt); writeVideo(wrt, V); close(wrt);


%% 3.1) Sprotno ucenje: predloga (RGB) se posodobi na vsaki sliki
V = V0;

x = x0; y = y0; w = w0; h = h0;
tmpl = double(V( y:y+h, x:x+w, :, 1));

for i = 1:N
    frame = V(:,:,:,i);

    bestD = inf;
    bestx = x;
    besty = y;

    x1 = max(1, x - epsilon); x2 = min(W-w, x + epsilon);
    y1 = max(1, y - epsilon); y2 = min(H-h, y + epsilon);

    for xx = x1:x2
        for yy = y1:y2
            patch = double(frame(yy:yy+h, xx:xx+w, :));
            d = sqrt(sum((patch(:) - tmpl(:)).^2));
            if d < bestD
                bestD = d;
                bestx = xx;
                besty = yy;
            end
        end
    end

    x = bestx; y = besty;

    tmpl = double(frame(y:y+h, x:x+w, :));

    cx = round(x + w/2);
    cy = round(y + h/2);

    r1 = max(1, cy-floor(marker/2)); r2 = min(H, cy+floor(marker/2));
    c1 = max(1, cx-floor(marker/2)); c2 = min(W, cx+floor(marker/2));

    V(r1:r2, c1:c2, 1, i) = 0;
    V(r1:r2, c1:c2, 2, i) = 0;
    V(r1:r2, c1:c2, 3, i) = 255;
end

wrt = VideoWriter("evklidska_razdalja_sprotno_ucenje.avi");
open(wrt); writeVideo(wrt, V); close(wrt);


%% 3.2) Sprotno ucenje: RGB histogram se posodobi na vsaki sliki
V = V0;

x = x0; y = y0; w = w0; h = h0;

tmplPatch = double(V(y:y+h, x:x+w, :, 1));
histRef = zeros(nbins, nbins, nbins);
for a = 1:size(tmplPatch,1)
    for b = 1:size(tmplPatch,2)
        rr = floor(tmplPatch(a,b,1)/binw) + 1;
        gg = floor(tmplPatch(a,b,2)/binw) + 1;
        bb = floor(tmplPatch(a,b,3)/binw) + 1;
        rr = min(max(rr,1),nbins);
        gg = min(max(gg,1),nbins);
        bb = min(max(bb,1),nbins);
        histRef(rr,gg,bb) = histRef(rr,gg,bb) + 1;
    end
end

for i = 1:N
    frame = double(V(:,:,:,i));

    bestD = inf;
    bestx = x;
    besty = y;
    bestHist = histRef;

    x1 = max(1, x - epsilon); x2 = min(W-w, x + epsilon);
    y1 = max(1, y - epsilon); y2 = min(H-h, y + epsilon);

    for xx = x1:x2
        for yy = y1:y2
            patch = frame(yy:yy+h, xx:xx+w, :);

            h2 = zeros(nbins, nbins, nbins);
            for a = 1:size(patch,1)
                for b = 1:size(patch,2)
                    rr = floor(patch(a,b,1)/binw) + 1;
                    gg = floor(patch(a,b,2)/binw) + 1;
                    bb = floor(patch(a,b,3)/binw) + 1;
                    rr = min(max(rr,1),nbins);
                    gg = min(max(gg,1),nbins);
                    bb = min(max(bb,1),nbins);
                    h2(rr,gg,bb) = h2(rr,gg,bb) + 1;
                end
            end

            d = sum((h2(:) - histRef(:)).^2);

            if d < bestD
                bestD = d;
                bestx = xx;
                besty = yy;
                bestHist = h2;
            end
        end
    end

    x = bestx; y = besty;

    histRef = bestHist;

    cx = round(x + w/2);
    cy = round(y + h/2);

    r1 = max(1, cy-floor(marker/2)); r2 = min(H, cy+floor(marker/2));
    c1 = max(1, cx-floor(marker/2)); c2 = min(W, cx+floor(marker/2));

    V(r1:r2, c1:c2, 1, i) = 0;
    V(r1:r2, c1:c2, 2, i) = 255;
    V(r1:r2, c1:c2, 3, i) = 0;
end

wrt = VideoWriter("mera_podobnosti_sprotno_ucenje.avi");
open(wrt); writeVideo(wrt, V); close(wrt);
==== END VALENTIN NEMANIČ | VALENTIN NEMANIČ_26682_assignsubmission_file | Vaja5_min_rgb_sp.m ====

