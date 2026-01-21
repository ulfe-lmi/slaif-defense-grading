==== BEGIN Tina Gutnik | Tina Gutnik_22794_assignsubmission_file | lab_vaja_4.m ====
% 1. Naloga

S_x = [1 0 -1; 2 0 -2; 1 0 -1];
S_y = [1 2 1; 0 0 0; -1 -2 -1];

I = imread('hotel.jpg');
I = rgb2gray(I);
image(I); colormap gray;

G_x = conv2(S_x, I);
G_y = conv2(S_y, I);
G = sqrt(G_x.^2 + G_y.^2);

prag = 400;
robovi = G > prag;        % ker je to logična slika z vrednostmi 0 in 1, pride s colormap gray 0 = črna in 1 = zelo temno siva, 
                          % zato potrebujemo drugačen colormap (črna in bela)
                          % v colormap(gray(2)) 0 = črno, 1 = belo
C = edge(I, 'canny');


figure;

subplot(1,2,1);
image(robovi); colormap(gray(2)); axis image off; title('Sobel z upragovljanjem');

subplot(1,2,2);
image(C); colormap(gray(2)); axis image off; title('Canny');

% 2. Naloga

k_min = -2; k_max =  2;
n_min = -200; n_max =  200;

k_vrednosti = linspace(k_min, k_max, 401);  % imamo 400 delov, ampak +1, ker so deli določeni s točkami na robu
n_vrednosti = linspace(n_min, n_max, 401);  % s tema dvema vrsticama razdelimo k in n na točke

dk = k_vrednosti(2) - k_vrednosti(1);
dn = n_vrednosti(2) - n_vrednosti(1);                 % definiramo korak med točkama

H = zeros(length(k_vrednosti),length(n_vrednosti));   % definiramo prazno akumulatorsko matriko 401x401: toliko vrstic, kot je vrednosti k (različnih naklonov) in toliko stolpcev, kot je vrednosti n (različnih odsekov)
                                                      % vsaka celica H(i,j) predstavlja konkretno premico y = k_i * x + n_j
                                                      % vrednost te celice H(i,j) pove, koliko robnih pikslov v sliki verjame, da ležijo na tej premici, 
                                                      % torej akumulator je števec glasov za vsako možno celico

[vrstice, stolpci] = find(C);      % funckija find najde neničelne elemente, vrne v katerih vrsticah in stolpcih so - najde torej vse robne piksle
st_tock = length(vrstice);         % pove koliko robnih pikslov je

for t = 1:st_tock                      % po vseh robnih pikslih
    x = stolpci(t);                    % stolpec je x koordinata piksla
    y = vrstice(t);                    % vrstica je y koordinata piksla
    
    for i_k = 1:length(k_vrednosti)    % po vseh možnih k vrednostih
        k = k_vrednosti(i_k);          % določimo k
        n = y - k * x;                 % določimo n iz enačbe premice

        if n < n_min || n > n_max
            continue;
        end

        j_n = round((n - n_min)/dn) + 1;   % pretvorimo n v indeks j po n_vrednosti

        H(i_k, j_n) = H(i_k, j_n) + 1;     % povečamo števec glasov
    end
end

N = 5;                    % zdaj iščemo N največjih elementov

H_stolp_vektor = H(:);    % matriko spremenimo v stolpični vektor, ki vsak stolpec posebej doda na konec stolp. vektorja (matriko zravnamo v seznam)

[H_vrednosti, indeksi] = sort(H_stolp_vektor, 'descend');  % elemente razvrstimo v padajočem vrstnem redu
                                                           % prvi izhod so razvrščene H vrednosti, drugi izhod pa indeksi teh vrednosti, kat mi potrebujemo
N_indeksi = indeksi(1:N);  % dobimo indekse največjih N elementov

[k_indeksi, n_indeksi] = ind2sub(size(H), N_indeksi);

k_N = k_vrednosti(k_indeksi);
n_N = n_vrednosti(n_indeksi);        % to dvoje sta vektorja dolžine N


% izris premic
figure;
H = imread('hotel.jpg');
image(H); hold on;

[visina, sirina] = size(C);

x = 1:sirina;

for i = 1:N

    k = k_N(i);
    n = n_N(i);
    y = k * x + n;
    plot(x,y,'LineWidth',2);
end

%% 3. naloga

video = VideoReader('squash.avi');

korak = 10;
vsi_okvirji = 1:korak:video.NumFrames;
N = length(vsi_okvirji);              % št. slik, ki jih uporabimo

prvi_frame = read(video, vsi_okvirji(1));
[H, W, C] = size(prvi_frame);         % height, width, colour (C = 3)

matrika = zeros(H, W, C, N, 'uint8'); % pripravimo 4D matriko

for i = 1:N
    f = read(video, vsi_okvirji(i));   % preberemo i-ti frame
    matrika(:,:,:,i) = f;              % ga damo v matriko
end

ozadje = median(matrika, 4);           % funkcija median po 4. dimenziji, torej po času - po frame-ih

figure;
image(ozadje);
title('Slika ozadja');


% 4. naloga

ozadje = im2double(ozadje);  % slika iz prejšnje naloge

novi_video = VideoWriter('squash_igralci.avi');
novi_video.FrameRate = video.FrameRate;
open(novi_video)

prag = 0.2;

for i = 1:video.NumFrames

    frame = read(video, i);         % v uint8
    frame_d = im2double(frame);       % v double

    razlika = frame_d - ozadje;   % razlika v RGB

    D = sqrt(razlika(:,:,1).^2 + razlika(:,:,2).^2 + razlika(:,:,3).^2);  % evklidska razdalja = koren(dR^2+dG^2+dB^2)

    slika = D > prag;  % upragovljanje: igralec = 1, ozadje = 0

    slika2 = bwmorph(slika, 'clean');       % odstrani osamljene pikice
    slika2 = bwmorph(slika2, 'open');       % odstrani majhne objekte
    slika2 = bwmorph(slika2, 'fill');       % zapolni luknje znotraj objektov
    slika2 = bwmorph(slika2, 'majority');   % večina v okolici
    
    [L, st_objektov] = bwlabel(slika2);
    lastnosti = regionprops(L, 'Area', 'Centroid', 'BoundingBox');  % površina, težišče, pravokotnik

     if st_objektov > 0
        povrsine = [lastnosti.Area];
        [~, indeks] = sort(povrsine, 'descend');
        kolicina = min(2, st_objektov);   % največ 2 objekta

        for k = 1:kolicina
            s = lastnosti(indeks(k));
            frame = insertShape(frame, 'Rectangle', s.BoundingBox);
            frame = insertMarker(frame, s.Centroid);
        end
     end

    writeVideo(novi_video, frame);
end

close(novi_video);

figure;
imagesc(D);        % prikaže D z avtomatskim raztegovanjem dinamičnega obsega
colormap gray;     % sivinski prikaz
colorbar;          % barvna lestvica
title('Slika evklidskih razdalj');

figure;
imagesc(slika);      % tukaj morda raje NE colormap gray, da bolje vidiš
colormap(gray(2));  % črno-belo
title('Binarna slika (igralca ≈ 1, ozadje ≈ 0)');


figure;
imagesc(slika2);
colormap(gray(2));
title('Binarna slika po morfoloških operacijah');

% 5. naloga
% ko se pojavi figure 6, je potrebnih nekaj klikov na rdečo majico nato enter, potem pa še nekaj klikov na belo majico in enter, da zajamemo piksle

poljuben_frame = read(video, 50);
figure; imshow(poljuben_frame);
rdeci = impixel;   % Nx3 matrika [R G B] v uint8   

figure; imshow(poljuben_frame);
beli = impixel;

rdeci = rdeci/255;
beli = beli/255;

povp_rdeci = mean(rdeci, 1);
povp_beli = mean(beli, 1);


novi_video_barva = VideoWriter('squash_igralci_barva.avi');
novi_video_barva.FrameRate = video.FrameRate;
open(novi_video_barva);

prag = 0.2;

for i = 1:video.NumFrames

    frame = read(video, i);         % v uint8
    frame_d = im2double(frame);       % v double

    razlika = frame_d - ozadje;   % razlika v RGB

    D = sqrt(razlika(:,:,1).^2 + razlika(:,:,2).^2 + razlika(:,:,3).^2);  % evklidska razdalja = koren(dR^2+dG^2+dB^2)

    slika = D > prag;  % upragovljanje: igralec = 1, ozadje = 0

    slika2 = bwmorph(slika, 'clean');       % odstrani osamljene pikice
    slika2 = bwmorph(slika2, 'open');       % odstrani majhne objekte
    slika2 = bwmorph(slika2, 'fill');       % zapolni luknje znotraj objektov
    slika2 = bwmorph(slika2, 'majority');   % večina v okolici
    
    [L, st_objektov] = bwlabel(slika2);
    lastnosti = regionprops(L, 'Area', 'Centroid', 'BoundingBox');  % površina, težišče, pravokotnik

     if st_objektov > 0
        povrsine = [lastnosti.Area];
        [~, indeks] = sort(povrsine, 'descend');
        kolicina = min(2, st_objektov);   % največ 2 objekta

        R = frame(:,:,1);   % pripravimo kanale
        G = frame_d(:,:,2);
        B = frame_d(:,:,3);
        meanR = zeros(1,kolicina);
        meanG = zeros(1, kolicina);
        meanB = zeros(1, kolicina);

        for k = 1:kolicina
            s = lastnosti(indeks(k));
            komponenta_L = indeks(k);

            maska = (L == komponenta_L);  % maska trenutnega igralca
            meanR(k) = mean(R(maska));
            meanG(k) = mean(G(maska));
            meanB(k) = mean(B(maska));
            rdeca_barva = meanR - max(meanG, meanB);

            [~, idx_rdec] = max(rdeca_barva); 

            if k ==  idx_rdec
                oznaka = 'rdeci';         
            else 
                oznaka = 'beli';    
            end

            frame = insertShape(frame, 'Rectangle', s.BoundingBox);
            frame = insertMarker(frame, s.Centroid);
            
            pozicija_teksta = [s.Centroid(1)+10, s.Centroid(2)-10];
            frame = insertText(frame, pozicija_teksta, oznaka);

            end
    end

    writeVideo(novi_video_barva, frame);
end

close(novi_video_barva);
==== END Tina Gutnik | Tina Gutnik_22794_assignsubmission_file | lab_vaja_4.m ====

