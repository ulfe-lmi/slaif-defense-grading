==== BEGIN Teodora Tanurkova | Teodora Tanurkova_21498_assignsubmission_file | Vaja3.m ====

% Nalaganje slik
img1 = imread('yosemite_meadows.jpg');
img2 = imread('coloured_pencils.jpg');

figure; 
subplot(1,2,1); imshow(img1); title('Yosemite');
subplot(1,2,2); imshow(img2); title('Coloured pencils');

% Naloga 1 pretvorba v HSV
imagesHSV = {img1, img2};
for j=1:length(imagesHSV)

    ImageHSV = imagesHSV{j};
    hsv = rgb2hsv(ImageHSV);
    H = hsv(:,:,1);
    S = hsv(:,:,2);
    V = hsv(:,:,3);

    figure;
    subplot(2,2,1); imagesc(H); colormap("gray"); title('Hue (H)');
    subplot(2,2,2); imagesc(S); colormap("gray"); title('Saturation (S)');
    subplot(2,2,3); imagesc(V); colormap("gray"); title('Value (V)');
end


% Naloga 1 pretvorba v Lab

imagesLAB = {img1, img2};
for i=1:length(imagesLAB)

    ImageLAB = imagesLAB{i};
    Lab = rgb2lab(ImageLAB);
    L = Lab(:,:,1);
    a = Lab(:,:,2);
    b = Lab(:,:,3);

    figure;
    subplot(2,2,1); imagesc(L); colormap("gray"); title('L');
    subplot(2,2,2); imagesc(a); colormap("gray"); title('a');
    subplot(2,2,3); imagesc(b); colormap("gray"); title('b');
end

%% Naloga 2

img1 = imread('yosemite_meadows.jpg');
img2 = imread('coloured_pencils.jpg');

images = {img1, img2};
for i=1:length(images)

    Image = images{i};               

    Orighsv = rgb2hsv(Image);

    for k = 1:3
          % vedno začnemo iz originalne HSV slike
        Sprhsv = Orighsv;

        % komponento k nastavimo na njeno povprečje
        Sprhsv(:,:,k) = 0.5;
    
        % nazaj v RGB
        Slikargb = hsv2rgb(Sprhsv);
    
        % prikaz
        figure;
        subplot(1,2,1); imshow(Image); title('Original');
        if k == 1
            title2 = 'H = konstanta';
        elseif k == 2
            title2 = 'S = konstanta';
        else
            title2 = 'V = konstanta';
        end
        subplot(1,2,2); imshow(Slikargb); title(title2);
    end
end

for j=1:length(images)

    Image = images{j};               

    Origlab = rgb2lab(Image);

    for n = 1:3
          % vedno začnemo iz originalne HSV slike
        Sprlab = Origlab;

        % komponento n nastavimo na njeno povprečje
        if n==1
            Sprlab(:,:,n) = 50;
        elseif n==2
            Sprlab(:,:,n) = 0;
        else 
            Sprlab(:,:,n) = 0;
        end
        
        % nazaj v RGB
        Slikargb2 = lab2rgb(Sprlab);
    
        % prikaz
        figure;
        subplot(1,2,1); imshow(Image); title('Original');
        if n == 1
            title2 = 'L = konstanta';
        elseif n == 2
            title2 = 'a = konstanta';
        else
            title2 = 'b = konstanta';
        end
        subplot(1,2,2); imshow(Slikargb2); title(title2);
    end
end
%% Naloga 3

Video=VideoReader('ladja.avi');
okvirSlike=50;
Okvir=read(Video,okvirSlike);

figure;
imshow(Okvir);
title('Izbrana slika za dolocanje RGB komponente barve morja');

%dolocanje obmocje kjer je morje
[visina, sirina, ~]=size(Okvir);
y_start = round(5*visina/6);
y_end = visina;
x_end = round(sirina/2);

obmocjeMorja = Okvir(y_start:y_end, 1:x_end, :);
R_obMorja = obmocjeMorja(:,:,1);
G_obMorja = obmocjeMorja(:,:,2);
B_obMorja = obmocjeMorja(:,:,3);

%min max vrednosti po vsakem kanalu

R_obMorjaMin = min(R_obMorja(:)); %R_obMorja(:) - da mi pretstavi celotno matriko v en stoplcec, ker brez tega po vrnil vektor od vsaki stolpec min vrednost
R_obMorjaMax = max(R_obMorja(:));

G_obMorjaMin = min(G_obMorja(:));
G_obMorjaMax = max(G_obMorja(:));

B_obMorjaMin = min(B_obMorja(:));
B_obMorjaMax = max(B_obMorja(:));

fprintf('RGB intervali:\n');
fprintf('R: [%d, %d]\n', R_obMorjaMin, R_obMorjaMax);
fprintf('G: [%d, %d]\n', G_obMorjaMin, G_obMorjaMax);
fprintf('B: [%d, %d]\n', B_obMorjaMin, B_obMorjaMax);

%obdelava videa za RGB prostor

vid = VideoReader('ladja.avi');
rezVideo=VideoWriter('ladja_morjeRGBNaloga3.avi');
open(rezVideo);


while hasFrame(vid)
    frame = readFrame(vid);

    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);

   maskRGB = (R >= R_obMorjaMin & R <= R_obMorjaMax) & ...
              (G >= G_obMorjaMin & G <= G_obMorjaMax) & ...
              (B >= B_obMorjaMin & B <= B_obMorjaMax);

   RGBframe = uint8(maskRGB)*255; %ce ni morje = 0 crno, ce je morje = 255 belo
   writeVideo(rezVideo,RGBframe);

end

close(rezVideo);

% HSV prostor

ObmocjeMHSV = rgb2hsv(obmocjeMorja);

H_obmocje = ObmocjeMHSV(:,:,1);
S_obmocje = ObmocjeMHSV(:,:,2);
V_obmocje = ObmocjeMHSV(:,:,3);

H_min = min(H_obmocje(:));
H_max = max(H_obmocje(:));

S_min = min(S_obmocje(:));
S_max = max(S_obmocje(:));

V_min = min(V_obmocje(:));
V_max = max(V_obmocje(:));

fprintf('HSV intervali:\n');
fprintf('H: [%.3f, %.3f]\n', H_min, H_max);
fprintf('S: [%.3f, %.3f]\n', S_min, S_max);
fprintf('V: [%.3f, %.3f]\n', V_min, V_max);

%obdelava videa za HSV prostor

vidHSV = VideoReader('ladja.avi');
rezVideoHSV=VideoWriter('ladja_morjeHSVNaloga3.avi');
open(rezVideoHSV);


while hasFrame(vidHSV)
    Frame = readFrame(vidHSV);
    FrameHSV = rgb2hsv(Frame);

    H = FrameHSV(:,:,1);
    S = FrameHSV(:,:,2);
    V = FrameHSV(:,:,3);

   maskHSV = (H >= H_min & H <= H_max)& ...
             (V >= V_min & V <= V_max);

   HSVframe = uint8(maskHSV)*255; %ce ni morje = 0 crno, ce je morje = 255 belo
   writeVideo(rezVideoHSV,HSVframe);

end

close(rezVideoHSV);

%% Naloga 4 – Segmentacija na podlagi barve (3D RGB histogram)

Video = VideoReader('ladja.avi');
okvirSlike = 50;                    % isti okvir kot v nalogi 3
Okvir = read(Video, okvirSlike);

figure;
imshow(Okvir);
title('Izbrana slika za dolocanje obmocja morja (RGB)');

% Izberemo obmocje, kjer je samo morje
[visina, sirina, ~] = size(Okvir);
y_start = round(5*visina/6);
y_end   = visina;
x_end   = round(sirina/2);

obmocjeMorja = Okvir(y_start:y_end, 1:x_end, :);

% Izracun 3D histograma iz obmocja morja

bine   = 8;               % 8 binov na vsaki barvni osi
binSize = 256 / bine;     % = 32

% posamezni barvni kanali
R = obmocjeMorja(:,:,1);
G = obmocjeMorja(:,:,2);
B = obmocjeMorja(:,:,3);

% vektorji (1D) vseh pikslov
Rv = R(:);
Gv = G(:);
Bv = B(:);

% indeksi binov za vsak piksel
rBin = floor(Rv / binSize) + 1;
gBin = floor(Gv / binSize) + 1;
bBin = floor(Bv / binSize) + 1;

% pazimo, da ne gremo preko st binov (zaradi vrednosti 255)
rBin(rBin > bine) = bine;
gBin(gBin > bine) = bine;
bBin(bBin > bine) = bine;

% inicializacija 3D histograma
H3D = zeros(bine, bine, bine);

% napolnimo 3D histogram: stevilo pikslov v vsakem 3D binu
for i = 1:length(Rv)
    H3D(rBin(i), gBin(i), bBin(i)) = H3D(rBin(i), gBin(i), bBin(i)) + 1;
end

% 4) Normalizacija histograma na [0, 255]

maxVal = max(H3D(:));
H3D_norm = H3D * (255 / maxVal);  % skaliramo da bi imelli max vrednost 255(kolko krat se pojavi vrednost ene celice)
H3D_norm = uint8(H3D_norm);          % da dobimo svetlost 0–255

% Obdelava celotnega videa z uporabo 3D histograma

vid = VideoReader('ladja.avi');
genVid = VideoWriter('ladja_morjeHistogramNaloga4.avi');
open(genVid);

while hasFrame(vid)
    frame = readFrame(vid);        % originalni RGB frame

    Rf = frame(:,:,1);
    Gf = frame(:,:,2);
    Bf = frame(:,:,3);

    % bin indeksi za vsak piksel v trenutnem framu
    rBinF = floor(Rf / binSize) + 1;
    gBinF = floor(Gf / binSize) + 1;
    bBinF = floor(Bf / binSize) + 1;

    rBinF(rBinF > bine) = bine;
    gBinF(gBinF > bine) = bine;
    bBinF(bBinF > bine) = bine;

    [h, w, ~] = size(frame);
    grayFrame = zeros(h, w);       % tukaj bomo shranili sivinsko sliko

    % za vsak piksel vzamemo vrednost iz normiranega 3D histograma
    for y = 1:h
        for x = 1:w
            grayFrame(y,x) = H3D_norm( rBinF(y,x), gBinF(y,x), bBinF(y,x) ); % npr. grayFrame(y,x) = 230, oz. vzamemo vrednost klk norm. pixlov so na poziciji H3D_norm(3,5,4)_ kje je tud pixel in mu prepisemo vrendnost na tega piksla v frameu
        end
    end

    grayFrame = uint8(grayFrame);  % 0–255 sivinska slika
    writeVideo(genVid, grayFrame);
end

close(genVid);

%% Naloga 5

Video = VideoReader('ladja.avi');
okvirSlike = 50;                    % isti okvir
Okvir = read(Video, okvirSlike);

figure;
imshow(Okvir);
title('Izbrana slika za dolocanje obmocja morja (RGB)');

% Izberemo obmocje, kjer je samo morje
[visina, sirina, ~] = size(Okvir);
y_start = round(5*visina/6);
y_end   = visina;
x_end   = round(sirina/2);

obmocjeMorja = Okvir(y_start:y_end, 1:x_end, :);

% Izracun 3D histograma iz obmocja morja

bine = 4;               % 4 binov na vsaki barvni osi
binSize = 256 / bine;     

% posamezni barvni kanali v double
R = obmocjeMorja(:,:,1);
G = obmocjeMorja(:,:,2);
B = obmocjeMorja(:,:,3);

% vektorji (1D) vseh pikslov
Rv = R(:);
Gv = G(:);
Bv = B(:);

% indeksi binov za vsak piksel
rBins = floor(Rv / binSize) + 1;
gBins = floor(Gv / binSize) + 1;
bBins = floor(Bv / binSize) + 1;

% pazimo, da ne gremo preko nbins (zaradi vrednosti 255)
rBins(rBins > bine) = bine;
gBins(gBins > bine) = bine;
bBins(bBins > bine) = bine;

H_model = zeros(bine,bine,bine);

for i = 1:length(Rv)
    H_model(rBins(i), gBins(i), bBins(i)) = H_model(rBins(i), gBins(i), bBins(i)) + 1;
end

H_modelNorm = H_model / sum(H_model(:));

vid = VideoReader('ladja.avi');
out = VideoWriter('ladja_morjeNaloga5HistRazd.avi');
open(out);

blockSize = 8;

while hasFrame(vid)
    frame = readFrame(vid);
    [H, W, ~] = size(frame);
    grayOut = zeros(H, W);

    % blokovi 8×8
    for y = 1:blockSize:H-blockSize+1
        for x = 1:blockSize:W-blockSize+1

            block = frame(y:y+blockSize-1, x:x+blockSize-1, :);

            % histogram bloka
            Hb = zeros(bine,bine,bine);

            Rb = block(:,:,1); Gb = block(:,:,2); Bb = block(:,:,3);
            Rbv = Rb(:); Gbv = Gb(:); Bbv = Bb(:);

            rB = floor(Rbv/binSize)+1; rB(rB>bine)=bine;
            gB = floor(Gbv/binSize)+1; gB(gB>bine)=bine;
            bB = floor(Bbv/binSize)+1; bB(bB>bine)=bine;

            for k = 1:length(Rbv)
                Hb(rB(k), gB(k), bB(k)) = Hb(rB(k), gB(k), bB(k)) + 1;
            end

            Hb_norm = Hb / sum(Hb(:));

            % histogram intersection
            HI = sum(min(H_modelNorm(:), Hb_norm(:)))/sum(H_modelNorm(:));

            % pretvorimo v 0–255 območje
            value = uint8(256 * HI);

            % napolnimo cel blok s to vrednostjo
            grayOut(y:y+blockSize-1, x:x+blockSize-1) = value;

        end
    end

    grayOut = uint8(grayOut);
    writeVideo(out, grayOut);
end

close(out);





























==== END Teodora Tanurkova | Teodora Tanurkova_21498_assignsubmission_file | Vaja3.m ====

