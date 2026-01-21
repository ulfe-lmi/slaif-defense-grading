==== BEGIN Gregor Turk | Gregor Turk_21511_assignsubmission_file | vaja3.m ====
clear all

%% 1. RGB, HSV, LAB

yosemite=imread('yosemite_meadows.jpg');
yosemite_HSV = rgb2hsv(yosemite);
yosemite_H = yosemite_HSV(:,:,1);
yosemite_S = yosemite_HSV(:,:,2);
yosemite_V = yosemite_HSV(:,:,3);

figure;
tiledlayout(2,2);
nexttile;
imshow(yosemite);
title("Original")
nexttile;
imagesc(yosemite_H);
colormap(gray); 
title("H");
nexttile;
imagesc(yosemite_S);
colormap(gray); 
title("S")
nexttile;
imagesc(yosemite_V);
colormap(gray); 
title("V")


yosemite_LAB = rgb2lab(yosemite);
yosemite_L = yosemite_LAB(:,:,1);
yosemite_A = yosemite_LAB(:,:,2);
yosemite_B = yosemite_LAB(:,:,3);

figure;
tiledlayout(2,2);
nexttile;
imshow(yosemite);
title("Original")
nexttile;
imagesc(yosemite_L);
colormap(gray); 
title("L");
nexttile;
imagesc(yosemite_A);
colormap(gray); 
title("A")
nexttile;
imagesc(yosemite_B);
colormap(gray); 
title("B")


%% 2. 

barvice = imread("coloured_pencils.jpg");

% HSV

barvice_HSV = rgb2hsv(barvice);
barvice_H = barvice_HSV(:,:,1);
barvice_S = barvice_HSV(:,:,2);
barvice_V = barvice_HSV(:,:,3);

max_H = max(barvice_H(:));
barvice_H_const = barvice_H; 
barvice_H_const(:) = max_H/2;

max_S = max(barvice_S(:));
barvice_S_const = barvice_S; 
barvice_S_const(:) = max_S/2;

max_V = max(barvice_V(:));
barvice_V_const = barvice_V; 
barvice_V_const(:) = max_V/2;

barvice_HSV_constH = cat(3, barvice_H_const, barvice_S, barvice_V);
barvice_HSV_constS = cat(3, barvice_H, barvice_S_const, barvice_V);
barvice_HSV_constV = cat(3, barvice_H, barvice_S, barvice_V_const);

RGB_constH = hsv2rgb(barvice_HSV_constH);
RGB_constS = hsv2rgb(barvice_HSV_constS);
RGB_constV = hsv2rgb(barvice_HSV_constV);


figure;
tiledlayout(2,2);
nexttile;
imshow(barvice);
title("Original");
nexttile;
imshow(RGB_constH);
title("H konstanten");
nexttile;
imshow(RGB_constS);
title("S konstanten");
nexttile;
imshow(RGB_constV);
title("V konstanten");

% LAB

barvice_LAB = rgb2lab(barvice);
barvice_L = barvice_LAB(:,:,1);
barvice_A = barvice_LAB(:,:,2);
barvice_B = barvice_LAB(:,:,3);

% intensity: od 0 do 100
max_L = max(barvice_L(:));
barvice_L_const = barvice_L;
barvice_L_const(:) = max_L/2;

% A: -100:zelena, 100:rdeca
max_A = max(barvice_A(:));
barvice_A_const = barvice_A;
barvice_A_const(:) = 0; % ce damo na 0 izlocimo zeleno in rdeco

% B: -100:rumena, 100:modra
max_B = max(barvice_B(:));
barvice_B_const = barvice_B;
barvice_B_const(:) = 0; % ce damo na 0 izlocimo modro in rumeno

barvice_LAB_constL = cat(3, barvice_L_const, barvice_A, barvice_B);
barvice_LAB_constA = cat(3, barvice_L, barvice_A_const, barvice_B);
barvice_LAB_constB = cat(3, barvice_L, barvice_A, barvice_B_const);

RGB_constL = lab2rgb(barvice_LAB_constL);
RGB_constA = lab2rgb(barvice_LAB_constA);
RGB_constB = lab2rgb(barvice_LAB_constB);

figure;
tiledlayout(2,2);

nexttile;
imshow(barvice);
title("Original");
nexttile;
imshow(RGB_constL);
title("L konstanten");
nexttile;
imshow(RGB_constA);
title("A konstanten");
nexttile;
imshow(RGB_constB);
title("B konstanten");


%% 3.

% segmentacija z RGB
ladja = VideoReader("ladja.avi");
frame = read(ladja, 5);
%figure;
%imshow(frame);
%impixelinfo;  % doda informacije o pikslih

%52, 79, 51
%95 115, 107

Rmin = 52;  Rmax = 95;
Gmin = 79;  Gmax = 115;
Bmin = 51;  Bmax = 107;

maskRGB = VideoWriter("ladja_mask_RGB.avi");
maskRGB.FrameRate = ladja.FrameRate;   % enak fps kot original
open(maskRGB);


while hasFrame(ladja)
    frame = readFrame(ladja);

    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);

    % piksel je znotraj RGB intervalov - znotraj = 1, zunaj = 0
    mask = (R >= Rmin & R <= Rmax) & ...
           (G >= Gmin & G <= Gmax) & ...
           (B >= Bmin & B <= Bmax);

    % znotraj =  255, zunaj = 0
    gray = uint8(mask) * 255;

    % 3 kanali
    grayRGB = cat(3, gray, gray, gray);

    writeVideo(maskRGB, grayRGB);
end

close(maskRGB);

% segmentacija z HSV
ladja = VideoReader("ladja.avi");
frame = read(ladja, 5);
frame_HSV = rgb2hsv(frame);
%figure;
%imshow(frame_HSV);
%impixelinfo;  % doda informacije o pikslih

%52, 79, 51
%95 115, 107

Hmin = 0.32;  Hmax = 0.45;
Smin = 0;  Smax = 1;
Vmin = 0;  Vmax = 0.5;

maskHSV = VideoWriter("ladja_mask_HSV.avi");
maskHSV.FrameRate = ladja.FrameRate;   % enak fps kot original
open(maskHSV);


while hasFrame(ladja)
    frame = readFrame(ladja);
    frame_HSV = rgb2hsv(frame);
    H = frame_HSV(:,:,1);
    S = frame_HSV(:,:,2);
    V = frame_HSV(:,:,3);

    % piksel je znotraj HSV intervalov - znotraj = 1, zunaj = 0
    mask = (H >= Hmin & H <= Hmax) & ...
           (S >= Smin & S <= Smax) & ...
           (V >= Vmin & V <= Vmax);

    % znotraj =  255, zunaj = 0
    gray = uint8(mask) * 255;

    % 3 kanali
    grayRGB = cat(3, gray, gray, gray);

    writeVideo(maskHSV, grayRGB);
end

close(maskHSV);

%% 4. 3D histogram

ladja = VideoReader("ladja.avi");
frame = read(ladja, 5);

% morje
% x: 0 -> do konca
% y: 285 -> do konca

morje = frame(320:height(frame), 1:width(frame),:);
%figure;
%imshow(morje);

locljivost = 8;
histogram3d = zeros(locljivost,locljivost,locljivost);

n_na_bin = 256/locljivost;

morje = double(morje);
for col = 1:height(morje)
    for row = 1:width(morje)
        
        R = morje(col,row,1);
        G = morje(col,row,2);
        B = morje(col,row,3);
        
        binR = floor(R / n_na_bin) + 1;
        binG = floor(G / n_na_bin) + 1;
        binB = floor(B / n_na_bin) + 1;
        
        histogram3d(binR, binG, binB) = histogram3d(binR, binG, binB)+1; % dodamo na pravo mesto
    end
end

maxValue = max(histogram3d(:));
% vrednost najmocnejsega bina == 255
hist_norm = uint8( (double(histogram3d) / double(maxValue)) * 255 );


hist_segmentacija = VideoWriter("ladja_mask_hist.avi");
hist_segmentacija.FrameRate = ladja.FrameRate;   % enak fps kot original
open(hist_segmentacija);


while hasFrame(ladja)
    frame = double(readFrame(ladja));

    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);
    % matrike, kje ima vsak piksel vrednost v kater bin pade v kanalu
    binR = floor(R / n_na_bin) + 1;
    binG = floor(G / n_na_bin) + 1;
    binB = floor(B / n_na_bin) + 1;

        
    [h, w] = size(R);
    gray = zeros(h, w, 'uint8');
    % piksel v rezultatu (sivinska slika) je vrednost iz histograma 
    for i = 1:h
        for j = 1:w
            gray(i,j) = hist_norm( binR(i,j), binG(i,j), binB(i,j) );
        end
    end

    % 3 kanali
    grayRGB = cat(3, gray, gray, gray);

    writeVideo(hist_segmentacija, grayRGB);
end

close(hist_segmentacija);


%% 5. 3D histogram

ladja = VideoReader("ladja.avi");
frame = read(ladja, 5);

% morje
% x: 0 -> do konca
% y: 285 -> do konca

morje = frame(320:height(frame), 1:width(frame),:);
%figure;
%imshow(morje);

locljivost = 4;
histogram3d = zeros(locljivost,locljivost,locljivost);

n_na_bin = 256/locljivost;

morje = double(morje);
for col = 1:height(morje)
    for row = 1:width(morje)
        
        R = morje(col,row,1);
        G = morje(col,row,2);
        B = morje(col,row,3);
        
        binR = floor(R / n_na_bin) + 1;
        binG = floor(G / n_na_bin) + 1;
        binB = floor(B / n_na_bin) + 1;
        
        histogram3d(binR, binG, binB) = histogram3d(binR, binG, binB)+1; % dodamo na pravo mesto
    end
end

maxValue = max(histogram3d(:));
% vrednost najmocnejsega bina == 255
hist_norm = uint8( (double(histogram3d) / double(maxValue)) * 255 );


hist_presek = VideoWriter("ladja_hist_presek.avi");
hist_presek.FrameRate = ladja.FrameRate;   % enak fps kot original
open(hist_presek);


while hasFrame(ladja)
    frame = double(readFrame(ladja));
    
    [H, W, ~] = size(frame);
    gray = zeros(H, W, 'uint8');
    for c = 1:8:H-7
        for r = 1:8:W-7
            
            hist = zeros(locljivost,locljivost,locljivost); % histogram za 8x8 kvadrat v sliki
            for i = 0:7
                for j = 0:7
                    R = frame(c+i,r+j,1);
                    G = frame(c+i,r+j,2);
                    B = frame(c+i,r+j,3);
                    
                    binR = floor(R / n_na_bin) + 1;
                    binG = floor(G / n_na_bin) + 1;
                    binB = floor(B / n_na_bin) + 1;

                    hist(binR, binG, binB) = hist(binR, binG, binB) + 1;
                end
            end
            maxValue_obmocje8x8 = max(hist(:));
            % vrednost najmocnejsega bina == 255
            hist_obmocje8x8_norm = uint8( (double(hist) / double(maxValue_obmocje8x8)) * 255 );
      
            % formula za normaliziran presek : sum( min(histogram_morja,  hist8x8) ) / sum(histogram_morja) -> normirani histogrami
            % cez vse bine - manjsa vrednost je presek

            % presek vrednost med 0 in 1
            presek = sum( min(hist_norm(:), hist_obmocje8x8_norm(:)) ) / sum(hist_norm(:));
            val = presek * 256;
            

            gray(c:c+7, r:r+7) = val;  % celo obmocje 8x8 dobi vrednost preseka

        end
    end

    % 3 kanali
    grayRGB = cat(3, gray, gray, gray);

    writeVideo(hist_presek, grayRGB);
end

close(hist_presek);


==== END Gregor Turk | Gregor Turk_21511_assignsubmission_file | vaja3.m ====

