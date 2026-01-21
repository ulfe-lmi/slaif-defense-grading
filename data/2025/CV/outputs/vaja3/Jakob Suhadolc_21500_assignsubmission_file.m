==== BEGIN Jakob Suhadolc | Jakob Suhadolc_21500_assignsubmission_file | Naloga1in2_Vaja3 (1).m ====
% Naloga 1 Koncept barv in barvni prostori RGB, HSV ter Lab
% Jakob Suhadolc & Mihaela Temelkova

slike = { 'yosemite_meadows.jpg', ...
          'coloured_pencils.jpg' };

%PRETVORBA V HSV PROSTORU
for i = 1:numel(slike)
    
    % Preberi RGB sliko
    I = imread(slike{i});
    I_d = im2double(I); %vrednosti pikslov preslika iz [0,255] v [0,1]

    %Pretvori RGB sliko v HSV in dobimo tri kanale slike
    I_hsv = rgb2hsv(I_d);
    H = I_hsv(:,:,1);
    S = I_hsv(:,:,2);
    V = I_hsv(:,:,3);

    figure('Name',['HSV - ' slike{i}]);

    subplot(2,2,1);
    imshow(I);
    title(['Original: ' slike{i}], 'Interpreter','none');

    subplot(2,2,2);
    imagesc(H);
    axis image off;
    title('H komponenta');
    colormap(gray); colorbar;

    subplot(2,2,3);
    imagesc(S);
    axis image off;
    title('S komponenta');
    colormap(gray); colorbar;

    subplot(2,2,4);
    imagesc(V);
    axis image off;
    title('V komponenta');
    colormap(gray); colorbar;

% PRETVORBA V Lab PROSTORU
    I_lab = rgb2lab(I_d);
    L = I_lab(:,:,1);   
    a = I_lab(:,:,2);   
    b = I_lab(:,:,3);  

    figure('Name',['Lab - ' slike{i}]);

    subplot(2,2,1);
    imshow(I);
    title(['Original: ' slike{i}], 'Interpreter','none');

    subplot(2,2,2);
    imagesc(L, [0 100]);
    axis image off;
    title('L komponenta');
    colormap(gray); colorbar;

    subplot(2,2,3);
    imagesc(a, [-128 127]);
    axis image off;
    title('a komponenta');
    colormap(gray); colorbar;

    subplot(2,2,4);
    imagesc(b, [-128 127]);
    axis image off;
    title('b komponenta');
    colormap(gray); colorbar;

end

%% Naloga 2 Vpliv posameznih komponent na rekonstruirano RGB sliko
close all; clear; clc;

slike = {'yosemite_meadows.jpg', 'coloured_pencils.jpg' };

% Izkloplenje HSV komponent
for i = 1:numel(slike)

    I = im2double(imread(slike{i}));
    HSV = rgb2hsv(I);
    % Ena komponenta je konstanta, z namenom da jo izklopimo in vidimo
    % njeneno delovanje 
    H = HSV;
    H(:,:,1) = 0.5;
    S = HSV;
    S(:,:,2) = 0.5;
    V = HSV;
    V(:,:,3) = 0.5;

    I_H = hsv2rgb(H);
    I_S = hsv2rgb(S);
    I_V = hsv2rgb(V);

    figure('Name', slike{i});
    subplot(2,2,1); imshow(I); title('Original');
    subplot(2,2,2); imshow(I_H); title('H = 0.5');
    subplot(2,2,3); imshow(I_S); title('S = 0.5');
    subplot(2,2,4); imshow(I_V); title('V = 0.5');
end

%% Naloga 2
close all; clear; clc;

slike = {'yosemite_meadows.jpg', 'coloured_pencils.jpg' };

%Izkloplenje Lab komponent

for i = 1:numel(slike)
    I = im2double(imread(slike{i}));
    Lab = rgb2lab(I);

    L = Lab;
    L(:,:,1) = 50; % Od 0 do 100
    a = Lab;
    a(:,:,2) = 0;  %Od -127 do 128
    b = Lab;
    b(:,:,3) = 0; %Od -127 do 128

    I_L = lab2rgb(L);
    I_a = lab2rgb(a);
    I_b = lab2rgb(b);

    figure('Name', slike{i});
    subplot(2,2,1); imshow(I); title('Original');
    subplot(2,2,2); imshow(I_L); title('L = 50');
    subplot(2,2,3); imshow(I_a); title('a = 0');
    subplot(2,2,4); imshow(I_b); title('b = 0');
end





==== END Jakob Suhadolc | Jakob Suhadolc_21500_assignsubmission_file | Naloga1in2_Vaja3 (1).m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_21500_assignsubmission_file | Naloga1in2_Vaja3.m ====
% Naloga 1 Koncept barv in barvni prostori RGB, HSV ter Lab
% Jakob Suhadolc & Mihaela Temelkova

slike = { 'yosemite_meadows.jpg', ...
          'coloured_pencils.jpg' };

%PRETVORBA V HSV PROSTORU
for i = 1:numel(slike)
    
    % Preberi RGB sliko
    I = imread(slike{i});
    I_d = im2double(I); %vrednosti pikslov preslika iz [0,255] v [0,1]

    %Pretvori RGB sliko v HSV in dobimo tri kanale slike
    I_hsv = rgb2hsv(I_d);
    H = I_hsv(:,:,1);
    S = I_hsv(:,:,2);
    V = I_hsv(:,:,3);

    figure('Name',['HSV - ' slike{i}]);

    subplot(2,2,1);
    imshow(I);
    title(['Original: ' slike{i}], 'Interpreter','none');

    subplot(2,2,2);
    imagesc(H);
    axis image off;
    title('H komponenta');
    colormap(gray); colorbar;

    subplot(2,2,3);
    imagesc(S);
    axis image off;
    title('S komponenta');
    colormap(gray); colorbar;

    subplot(2,2,4);
    imagesc(V);
    axis image off;
    title('V komponenta');
    colormap(gray); colorbar;

% PRETVORBA V Lab PROSTORU
    I_lab = rgb2lab(I_d);
    L = I_lab(:,:,1);   
    a = I_lab(:,:,2);   
    b = I_lab(:,:,3);  

    figure('Name',['Lab - ' slike{i}]);

    subplot(2,2,1);
    imshow(I);
    title(['Original: ' slike{i}], 'Interpreter','none');

    subplot(2,2,2);
    imagesc(L, [0 100]);
    axis image off;
    title('L komponenta');
    colormap(gray); colorbar;

    subplot(2,2,3);
    imagesc(a, [-128 127]);
    axis image off;
    title('a komponenta');
    colormap(gray); colorbar;

    subplot(2,2,4);
    imagesc(b, [-128 127]);
    axis image off;
    title('b komponenta');
    colormap(gray); colorbar;

end

%% Naloga 2 Vpliv posameznih komponent na rekonstruirano RGB sliko
close all; clear; clc;

slike = {'yosemite_meadows.jpg', 'coloured_pencils.jpg' };

% Izkloplenje HSV komponent
for i = 1:numel(slike)

    I = im2double(imread(slike{i}));
    HSV = rgb2hsv(I);
    % Ena komponenta je konstanta, z namenom da jo izklopimo in vidimo
    % njeneno delovanje 
    H = HSV;
    H(:,:,1) = 0.5;
    S = HSV;
    S(:,:,2) = 0.5;
    V = HSV;
    V(:,:,3) = 0.5;

    I_H = hsv2rgb(H);
    I_S = hsv2rgb(S);
    I_V = hsv2rgb(V);

    figure('Name', slike{i});
    subplot(2,2,1); imshow(I); title('Original');
    subplot(2,2,2); imshow(I_H); title('H = 0.5');
    subplot(2,2,3); imshow(I_S); title('S = 0.5');
    subplot(2,2,4); imshow(I_V); title('V = 0.5');
end

%% Naloga 2
close all; clear; clc;

slike = {'yosemite_meadows.jpg', 'coloured_pencils.jpg' };

%Izkloplenje Lab komponent

for i = 1:numel(slike)
    I = im2double(imread(slike{i}));
    Lab = rgb2lab(I);

    L = Lab;
    L(:,:,1) = 50; % Od 0 do 100
    a = Lab;
    a(:,:,2) = 0;  %Od -127 do 128
    b = Lab;
    b(:,:,3) = 0; %Od -127 do 128

    I_L = lab2rgb(L);
    I_a = lab2rgb(a);
    I_b = lab2rgb(b);

    figure('Name', slike{i});
    subplot(2,2,1); imshow(I); title('Original');
    subplot(2,2,2); imshow(I_L); title('L = 50');
    subplot(2,2,3); imshow(I_a); title('a = 0');
    subplot(2,2,4); imshow(I_b); title('b = 0');
end





==== END Jakob Suhadolc | Jakob Suhadolc_21500_assignsubmission_file | Naloga1in2_Vaja3.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_21500_assignsubmission_file | Naloga3_Vaja3.m ====
%% Naloga 3 – segmentacija morja v RGB in HSV
close all; clear; clc;

% Preberemo prvi frame iz videa
v = VideoReader('ladja.avi');
frame = readFrame(v);
framed = im2double(frame); 

% Uporabnik klikne točko na morju (za določitev patcha)
figure; imshow(framed); title('Klikni na morje');
[x, y] = ginput(1);
x = round(x); y = round(y);
close;

% Izrežemo manjšo zaplato (patch) okoli klika
r = 50;
[H_img, W_img, ~] = size(framed);
x1 = max(1, x-r); x2 = min(W_img, x+r);
y1 = max(1, y-r); y2 = min(H_img, y+r);

%% RGB segmentacija 

% Patch nad morjem v RGB, ki ga naredimo iz okolice tocke ki smo jo
% kliknili
patchRGB = framed(y1:y2, x1:x2, :);

% Povprečne RGB vrednosti patcha (tipična barva morja)
mRGB = squeeze(mean(mean(patchRGB,1),2));

% Dovoljen odmik okoli povprečij 
dR = 0.10; dG = 0.10; dB = 0.10;

% Intervali za R, G, B in definicija barve morja
Rmin = max(0, mRGB(1)-dR); Rmax = min(1, mRGB(1)+dR);
Gmin = max(0, mRGB(2)-dG); Gmax = min(1, mRGB(2)+dG);
Bmin = max(0, mRGB(3)-dB); Bmax = min(1, mRGB(3)+dB);

% Ponovno odpremo video in pripravimo izhodni RGB video
v = VideoReader('ladja.avi');
outRGB = VideoWriter('ladja_morje_RGB.avi');
outRGB.FrameRate = v.FrameRate;
open(outRGB);

% Za vsak frame preverimo, kateri piksli so znotraj RGB intervalov
while hasFrame(v)
    frm = im2double(readFrame(v));
    R = frm(:,:,1); G = frm(:,:,2); B = frm(:,:,3);

    % Maska: 1 - barva podobna morju, 0 - ni 
    mask = (R>=Rmin & R<=Rmax) & ...
           (G>=Gmin & G<=Gmax) & ...
           (B>=Bmin & B<=Bmax);

    % Pretvorba maske v binarno (0/255) in v 3-kanalno sliko za video
    BW = uint8(mask)*255;
    BW_rgb = cat(3,BW,BW,BW);
    writeVideo(outRGB, BW_rgb);
end

close(outRGB);

%%  HSV segmentacija

% Patch nad morjem pretvorimo v HSV
patchHSV = rgb2hsv(patchRGB);

% Povprečne HSV vrednosti patcha
mHSV = squeeze(mean(mean(patchHSV,1),2));

% Dovoljen odmik za H in S (V ignoriramo)
dH = 0.10; dS = 0.25;        

% Intervali za H in S in definicija barve morja v HSV
Hmin = max(0, mHSV(1)-dH); Hmax = min(1, mHSV(1)+dH);
Smin = max(0, mHSV(2)-dS); Smax = min(1, mHSV(2)+dS);

% Ponovno odpremo video in pripravimo izhodni binarni video (HSV prag)
v = VideoReader('ladja.avi');
outHSV = VideoWriter('ladja_morje_HSV.avi');
outHSV.FrameRate = v.FrameRate;
open(outHSV);

% Za vsak frame naredimo vpragovljenje v HSV prostoru
while hasFrame(v)
    frm = im2double(readFrame(v));
    hsv = rgb2hsv(frm);
    Hc = hsv(:,:,1); Sc = hsv(:,:,2);

    % Maska: 1 - piksel ima H,S podobna morju
    mask = (Hc>=Hmin & Hc<=Hmax) & ...
           (Sc>=Smin & Sc<=Smax);  

    % Pretvorimo masko v binarno sliko in zapišemo v video
    BW = uint8(mask)*255;
    BW_rgb = cat(3,BW,BW,BW);
    writeVideo(outHSV, BW_rgb);
end

close(outHSV);
==== END Jakob Suhadolc | Jakob Suhadolc_21500_assignsubmission_file | Naloga3_Vaja3.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_21500_assignsubmission_file | Naloga4_Vaja3.m ====
%% Naloga 4
close all; clear; clc;

% Preberemo prvi frame videa
v = VideoReader('ladja.avi');
frame = readFrame(v);
framed = im2double(frame);

% Kliknemo točko na morju
figure; imshow(framed); title('Klikni na morje');
[x, y] = ginput(1);
x = round(x); y = round(y);
close;

% Izrežemo patch okoli klika (morje)
r = 50;
[H_img, W_img, ~] = size(framed);
x1 = max(1, x-r); x2 = min(W_img, x+r);
y1 = max(1, y-r); y2 = min(H_img, y+r);

% učenje barv morja
patch = framed(y1:y2, x1:x2, :);  

% Razdelimo vsak kanal R,G,B na 8 delov ali 8x8x8
bins = 8;
%Definiramo robove bina oziroma bin 1 je na intervalu [0,0.125], bin 2 na [0.125,0.25]
edges = linspace(0,1,bins+1);
% Dolocimo 8x8x8 matrika H oziroma histograma ki ima 0
H = zeros(bins,bins,bins);

% 3D RGB histogram patcha
R = patch(:,:,1); G = patch(:,:,2); B = patch(:,:,3);
% Pove v katerem binu se nahaja piksel iz patcha glede na edges
ri = discretize(R,edges);
gi = discretize(G,edges);
bi = discretize(B,edges);

%Steje piksle, koliko pikslov se pojavijo v posamezen bin
sz = size(patch,1)*size(patch,2);
for i=1:sz
    H(ri(i), gi(i), bi(i)) = H(ri(i), gi(i), bi(i)) + 1;
end

% Normalizacija histograma na [0,255]
H = H / max(H(:));
H = H * 255;

% Gremo čez cel video in vsako točko preslikamo skozi histogram
v = VideoReader('ladja.avi');
writer = VideoWriter('ladja_Naloga4.avi');  
open(writer);

while hasFrame(v)
    f = im2double(readFrame(v));
    R = f(:,:,1); G = f(:,:,2); B = f(:,:,3);

    ri = discretize(R,edges);
    gi = discretize(G,edges);
    bi = discretize(B,edges);

    M = zeros(size(R));          % izhodna sivinska slika
    for i=1:numel(R)
        M(i) = H(ri(i), gi(i), bi(i));   % vrednost iz histograma
    end

    M = uint8(M);
    writeVideo(writer, M);       % zapišemo frame
end

close(writer);
==== END Jakob Suhadolc | Jakob Suhadolc_21500_assignsubmission_file | Naloga4_Vaja3.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_21500_assignsubmission_file | Naloga5_Vaja3.m ====
%% Naloga 5 - Segmentacija z uporabo histogram intersection

close all; clear; clc;

% Preberemo prvi frame iz videa
v = VideoReader('ladja.avi');
frame = readFrame(v);
framed = im2double(frame);

%Izbere pravokotnik nad morjem (nas patch)
figure; imshow(framed);
title('Selektiraj pravokotnik cez morja');
patch_rect = round(getrect); % [x, y, width, height]

% Koordinate pravokotnika
px = patch_rect(1);  
py = patch_rect(2);
pw = patch_rect(3);  
ph = patch_rect(4);

% Izrežemo patch morja iz slike
patch = framed(py:py+ph, px:px+pw, :);

% Razdelimo R,G,B kanale na 4 delov, kar bo nas referencni histogram
bins = 4;                                   
edges = linspace(0,1,bins+1); 
% prazen 3D histogram 4x4x4
H_ref = zeros(bins,bins,bins);           

% Kanali patcha (morje)
R = patch(:,:,1); G = patch(:,:,2); B = patch(:,:,3);

% Za vsak piksel določimo, v kateri bin
ri = discretize(R, edges);
gi = discretize(G, edges);
bi = discretize(B, edges);

% Polnimo 3D histogram: štejemo, kolikokrat se pojavi kombinacija (ri,gi,bi)
for i = 1:numel(R)
    H_ref(ri(i), gi(i), bi(i)) = H_ref(ri(i), gi(i), bi(i)) + 1;
end

% Normaliziramo referenčni histogram
H_ref = H_ref / sum(H_ref(:));

% Priprava videa
v = VideoReader('ladja.avi');
writer = VideoWriter('ladja_morje_Naloga5.avi');
open(writer);

block = 8;   % velikost bloka: 8×8 pikslov

% Gremo čez vse frame-e videa
while hasFrame(v)
    frame = im2double(readFrame(v));
    [h, w, ~] = size(frame);

    % izhodna sivinska mapa podobnosti z morjem
    M = zeros(h, w);  

    % Premikamo se po sliki v korakih 8 px po y in x
    for y = 1:block:(h - mod(h,block))
        for x = 1:block:(w - mod(w,block))

            % Izrežemo trenutni blok velikosti 8x8
            blk = frame(y:y+block-1, x:x+block-1, :);

            %Izračun histograma za ta blok (Hb) 
            Hb = zeros(bins,bins,bins);    

            Rb = blk(:,:,1);
            Gb = blk(:,:,2);
            Bb = blk(:,:,3);

            % Določimo indekse binov za kanal R,G,B v bloku
            rbi = discretize(Rb, edges);
            gbi = discretize(Gb, edges);
            bbi = discretize(Bb, edges);

            % Polnimo histogram bloka: štejemo pojavitve kombinacij (rbi,gbi,bbi)
            for i = 1:numel(Rb)
                Hb(rbi(i), gbi(i), bbi(i)) = Hb(rbi(i), gbi(i), bbi(i)) + 1;
            end

            % Normaliziramo histogram bloka, če ni prazen (vsota = 1)
            if sum(Hb(:)) > 0
                Hb = Hb / sum(Hb(:));
            end

            % Histogram intersection (Swain & Ballard)
             % HI meri podobnost med histogramom morja (H_ref) in histogramom trenutnega bloka (Hb)
            HI = sum( min(H_ref(:), Hb(:)) );

            % Preslikamo HI v interval 0–255 za sivinsko sliko
            HI_val = uint8(HI * 256);

            % Celoten blok dobi isto sivinsko vrednost (HI_val)
            % Svetel blok - barve podobne morju, temen blok - drugačne barve
            M(y:y+block-1, x:x+block-1) = HI_val;
        end
    end

    % Zapišemo sivinski frame v video
    writeVideo(writer, uint8(M));
end

close(writer);

disp('konec');
==== END Jakob Suhadolc | Jakob Suhadolc_21500_assignsubmission_file | Naloga5_Vaja3.m ====

