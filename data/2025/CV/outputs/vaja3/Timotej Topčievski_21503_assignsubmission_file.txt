==== BEGIN Timotej Topčievski | Timotej Topčievski_21503_assignsubmission_file | vaja3.m ====
% vaja3.m

close all; clear; clc;

% Testne datoteke
img1_url = 'http://vision.fe.uni-lj.si/classes/RV/vaje/vaja3/yosemite_meadows.jpg';
img2_url = 'http://vision.fe.uni-lj.si/classes/RV/vaje/vaja3/coloured_pencils.jpg';
video_url = 'http://vision.fe.uni-lj.si/classes/RV/vaje/vaja3/ladja.avi';

% Izhodna mapa
outdir = 'rezultati';
if ~exist(outdir,'dir'), mkdir(outdir); end

%% Naloga 1: Pretvorba v HSV in Lab, prikaz komponent
fprintf('Naloga 1: nalaganje in pretvorbe (HSV, Lab)...\n');
I1 = im2double(imread(img1_url));
I2 = im2double(imread(img2_url));

sivinske_komponente(I1,'yosemite',outdir);
sivinske_komponente(I2,'pencils',outdir);

%% Naloga 2: Učinek izločanja posameznih komponent (HSV in Lab)
fprintf('Naloga 2: vpliv posameznih komponent (HSV in Lab)...\n');

komponente(I1,'yosemite',outdir);
komponente(I2,'pencils',outdir);

%% Naloga 3: Ročna segmentacija na podlagi barve (RGB in HSV)
fprintf('Naloga 3: ročna segmentacija (RGB in HSV) na videu ladja.avi ...\n');

try
    vfile = websave(fullfile(outdir,'ladja.avi'), video_url);
catch
    vfile = video_url;
end
manual_color_segmentation(vfile, outdir);

%% Naloga 4: Avtomatska segmentacija s 3D RGB histogramom
fprintf('Naloga 4: avtomatska segmentacija z 3D RGB histogramom ...\n');
auto_hist_segmentation(vfile, outdir);

%% Naloga 5: Segmentacija na podlagi preseka histogramov (4x4x4) po blokih 8x8
fprintf('Naloga 5: segmentacija na podlagi razdalje med histogrami (block 8x8) ...\n');
hist_intersection_block_segmentation(vfile, outdir);

fprintf('Vse izvedeno. Rezultati so v mapi "%s".\n', outdir);

%% Lokalne funkcije
function sivinske_komponente(I,basename,outdir)
    % I: double RGB [0..1]
    hsv = rgb2hsv(I);
    lab = rgb2lab(I); % L in [0..100], a,b approx [-128..127]
    figure('Name',['Components: ' basename],'Visible','off');
    
    % Sive HSV komponente
    subplot(2,3,1), imagesc(hsv(:,:,1)); axis image off; colormap gray; title('H');
    subplot(2,3,2), imagesc(hsv(:,:,2)); axis image off; colormap gray; title('S');
    subplot(2,3,3), imagesc(hsv(:,:,3)); axis image off; colormap gray; title('V');
    
    % Sive Lab komponente
    subplot(2,3,4), imagesc(lab(:,:,1)/100); axis image off; colormap gray; title('L');
    subplot(2,3,5), imagesc((lab(:,:,2)+128)/256); axis image off; colormap gray; title('a');
    subplot(2,3,6), imagesc((lab(:,:,3)+128)/256); axis image off; colormap gray; title('b');
    
    saveas(gcf, fullfile(outdir,[basename '_components.png']));
    close;
end

function komponente(I,basename,outdir)
    % Prikaže vpliv nastavitve komponente na konstanto za HSV in Lab
    hsv = rgb2hsv(I);
    lab = rgb2lab(I);
    % HSV: za vsako komponento privzemi sredinsko vrednost in rekonstruiraj
    mids_hsv = [0.5, 0.5, 0.5];
    for k=1:3
        tmp = hsv;
        tmp(:,:,k) = mids_hsv(k);
        recon = hsv2rgb(tmp);
        imwrite(recon, fullfile(outdir, sprintf('%s_hsv_fix_%d.png',basename,k)));
    end
    % Lab: nastavimo L, a, b na srednje vrednosti
    % L = 50, a,b = 0
    mids_lab = [50, 0, 0];
    for k=1:3
        tmp = lab;
        tmp(:,:,k) = mids_lab(k);
        recon = lab2rgb(tmp,'OutputType','double');
        recon = min(max(recon,0),1);
        imwrite(recon, fullfile(outdir, sprintf('%s_lab_fix_%d.png',basename,k)));
    end
end

function manual_color_segmentation(vfile,outdir)
    % Ročna segmentacija 
    vr = VideoReader(vfile);
    frame = readFrame(vr);
    % Shrani vzorčni frame
    imwrite(frame, fullfile(outdir,'ladja_sample_frame.png'));
    
    R = frame(:,:,1); G = frame(:,:,2); B = frame(:,:,3);
    % RGB Vrednosti
    Rmin=50; Rmax=120;
    Gmin=75; Gmax=165;
    Bmin=50; Bmax=95;

    % Binarna maska
    mask_rgb = (R>=Rmin & R<=Rmax) & (G>=Gmin & G<=Gmax) & (B>=Bmin & B<=Bmax);
    % Shrani vzorčno masko
    imwrite(mask_rgb, fullfile(outdir,'ladja_manual_mask_sample_rgb.png'));
    % Izgradnja videa
    vr.CurrentTime = 0;
    vw = VideoWriter(fullfile(outdir,'ladja_manual_rgb.avi'));
    open(vw);

    while hasFrame(vr)
        f = readFrame(vr);
        R = f(:,:,1); G=f(:,:,2); B=f(:,:,3);
        mask = (R>=Rmin & R<=Rmax) & (G>=Gmin & G<=Gmax) & (B>=Bmin & B<=Bmax);
        writeVideo(vw,uint8(mask*255));
    end

    close(vw);

    % HSV prostor
    vr = VideoReader(vfile); hsvvr=VideoWriter(fullfile(outdir,'ladja_manual_hsv.avi'));
    open(hsvvr);

    while hasFrame(vr)
        f = im2double(readFrame(vr));
        hsi = rgb2hsv(f);
        H = hsi(:,:,1); S = hsi(:,:,2); V = hsi(:,:,3);
        % HSV vrednosti
        mask_hsv = (H>0.3 & H<0.5) & (S>0.1 & S<1) & (V);
        writeVideo(hsvvr,uint8(mask_hsv*255));
    end

    close(hsvvr);
end

function auto_hist_segmentation(vfile,outdir)
    vr = VideoReader(vfile);
    
    frame = readFrame(vr);
    [h,w,~] = size(frame);

    % ROI
    cx = round(w/2); cy = round(h*0.65); s = min(round(min(h,w)/12),50);
    roi = frame(cy-s:cy+s, cx-s:cx+s, :);
    imwrite(roi, fullfile(outdir,'ladja_hist_roi.png'));

    % Zgradimo 8x8x8 histogram
    bins = 8;

    % Diskretiziraj 0..255 v bin številke 1..bins
    R = double(roi(:,:,1)); G = double(roi(:,:,2)); B = double(roi(:,:,3));
    edges = linspace(0,255,bins+1);
    rbin = discretize(R,edges);
    gbin = discretize(G,edges);
    bbin = discretize(B,edges);
    idx = sub2ind([bins,bins,bins], rbin(:), gbin(:), bbin(:));
    H = accumarray(idx,1,[bins^3,1]);
    H = reshape(H, [bins,bins,bins]);

    % Normaliziraj tako, da je najbolj poln bin = 255
    H = double(H);
    if max(H(:))>0
        H = H / max(H(:)) * 255;
    end

    % Shrani histogram
    save(fullfile(outdir,'ladja_rgb_hist_8x8x8.mat'),'H','edges');
    
    vr.CurrentTime = 0;
    vw = VideoWriter(fullfile(outdir,'ladja_histmap_8x8x8.avi'));
    open(vw);

    while hasFrame(vr)
        f = readFrame(vr);
        R = double(f(:,:,1)); G = double(f(:,:,2)); B = double(f(:,:,3));
        rbin = discretize(R,edges); gbin = discretize(G,edges); bbin = discretize(B,edges);
        % za robne piksle, kjer discretize vrne NaN, nastavimo 1
        rbin(isnan(rbin)) = 1; gbin(isnan(gbin)) = 1; bbin(isnan(bbin)) = 1;
        idx = sub2ind([bins,bins,bins], rbin(:), gbin(:), bbin(:));
        val = H(idx); % vektor dolžine numPix
        imgray = reshape(uint8(val), size(R));
        writeVideo(vw, imgray);
    end
    close(vw);
end

function hist_intersection_block_segmentation(vfile,outdir)
    vr = VideoReader(vfile);
    frame = readFrame(vr);
    [h,w,~] = size(frame);

    % ROI
    cx = round(w/2); cy = round(h*0.65); s = min(round(min(h,w)/12),40);
    roi = frame(cy-s:cy+s, cx-s:cx+s,:);
    imwrite(roi, fullfile(outdir,'ladja_hist4x4x4_roi.png'));
    
    % Histogram 4x4x4
    bins = 4;
    edges = linspace(0,255,bins+1);

    % Histogram iz ROI
    R = double(roi(:,:,1)); G = double(roi(:,:,2)); B = double(roi(:,:,3));
    rbin = discretize(R,edges); gbin = discretize(G,edges); bbin = discretize(B,edges);
    idx = sub2ind([bins,bins,bins], rbin(:), gbin(:), bbin(:));
    Hmodel = accumarray(idx,1,[bins^3,1]);
    Hmodel = double(Hmodel) / sum(Hmodel(:)); % normaliziramo na sum=1

    % Obdelava videa po blokih 8x8
    block = 8;
    vr.CurrentTime = 0;
    vw = VideoWriter(fullfile(outdir,'ladja_hist_intersection_blocks.avi'));
    open(vw);
    while hasFrame(vr)
        f = readFrame(vr);
        [h,w,~] = size(f);
        outFrame = zeros(h,w,'uint8');
        % blok po blok
        nbh = floor(h/block); 
        nbw = floor(w/block);
        
        for by = 1:nbh
            for bx = 1:nbw
                ys = (by-1)*block+1; ye = by*block;
                xs = (bx-1)*block+1; xe = bx*block;
                
                patch = f(ys:ye, xs:xe, :);
                R = double(patch(:,:,1)); G = double(patch(:,:,2)); B = double(patch(:,:,3));
                
                rbin = discretize(R,edges); gbin = discretize(G,edges); bbin = discretize(B,edges);
                rbin(isnan(rbin)) = 1; gbin(isnan(gbin)) = 1; bbin(isnan(bbin)) = 1;
                idx = sub2ind([bins,bins,bins], rbin(:), gbin(:), bbin(:));
                
                Hpatch = accumarray(idx,1,[bins^3,1]);
                Hpatch = double(Hpatch) / sum(Hpatch(:)); % normaliziraj

                % Histogram intersection
                inter = sum(min(Hmodel, Hpatch)) / sum(Hmodel); % normalizirana vrednost med 0 in 1
                val = uint8(inter * 255); % razpon 0..255
                outFrame(ys:ye, xs:xe) = val;

            end
        end
        writeVideo(vw, outFrame);
    end
    close(vw);
end
==== END Timotej Topčievski | Timotej Topčievski_21503_assignsubmission_file | vaja3.m ====

