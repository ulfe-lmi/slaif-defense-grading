==== BEGIN Tina Gutnik | Tina Gutnik_21495_assignsubmission_file | konstantne_komponente.m ====
function konstantne_komponente(datoteka)
% vhod datoteke mora biti v obliki 'slika.jpg'
% funkcija vrne 6 rgb slik - v primeru konstantne vsake izmed komponent HSV in Lab

I_int = imread(datoteka);
I_double = im2double(I_int);

% HSV prostor

I_hsv = rgb2hsv(I_double);  % pretvorimo v HSV prostor

I_hsv_H = I_hsv;
I_hsv_H(:,:,1) = 0.5;  % H je konstanten, torej imajo vsi piksli isti odtenek barve

I_hsv_S = I_hsv; 
I_hsv_S(:,:,2) = 0.5;  % S kje konstanten, torej so vse barve enako žive

I_hsv_V = I_hsv; 
I_hsv_V(:,:,3) = 0.5;  % V je konstanten, torej so vsi piksli enako svetli


I_rgb_H = hsv2rgb(I_hsv_H);  % pretvorimo nazaj v RGB prostorž
figure;
imshow(I_rgb_H);
title('HSV: konstanten H');

I_rgb_S = hsv2rgb(I_hsv_S);
figure;
imshow(I_rgb_S);
title('HSV: konstanten S');

I_rgb_V = hsv2rgb(I_hsv_V);
figure;
imshow(I_rgb_V);
title('HSV: konstanten V');

% Lab prostor

I_lab = rgb2lab(I_double);

I_lab_L = I_lab;
I_lab_L(:,:,1) = 50;  % L je konstanten, torej 

I_lab_a = I_lab; 
I_lab_a(:,:,2) = 0;  % a kje konstanten, torej 

I_lab_b = I_lab; 
I_lab_b(:,:,3) = 0;  % b je konstanten, torej


I_rgb_L = lab2rgb(I_lab_L);  % pretvorimo nazaj v RGB prostor
figure;
imshow(I_rgb_L);
title('Lab: konstanten L');

I_rgb_a = lab2rgb(I_lab_a);
figure;
imshow(I_rgb_a);
title('Lab: konstanten a');

I_rgb_b = lab2rgb(I_lab_b);
figure;
imshow(I_rgb_b);
title('Lab: konstanten b');

end
==== END Tina Gutnik | Tina Gutnik_21495_assignsubmission_file | konstantne_komponente.m ====

==== BEGIN Tina Gutnik | Tina Gutnik_21495_assignsubmission_file | lab_vaja_3.m ====
%% 1. naloga

sivinska_slika_komponent('coloured_pencils.jpg');
sivinska_slika_komponent('yosemite_meadows.jpg');

%% 2. naloga

konstantne_komponente('coloured_pencils.jpg');
konstantne_komponente('yosemite_meadows.jpg');

%% 3. naloga

% RGB segmentacija

V = VideoReader('ladja.avi');
frame = read(V, 20);    % izberemo en frame
%imshow(frame);

R_min = 30; % dobimo s klikanjem pixlov s funkcijo impixel()
R_max = 110;
G_min = 60;
G_max = 130;
B_min = 40;
B_max = 130;

seg_V = VideoWriter('ladja_segmentacija_rgb.avi');
seg_V.FrameRate = V.FrameRate;
open(seg_V);

while hasFrame(V)
    I = readFrame(V);         % en frame gledamo kot sliko uint
    I_double = im2double(I);  

    R = I(:,:,1);
    G = I(:,:,2);
    B = I(:,:,3);

   
    maska =  R >= R_min & R <= R_max & G >= G_min & G <= G_max & B >= B_min & B <= B_max;

    % črnobela slika; morje je belo, vse ostalo je črno; zato predelamo nazaj v uint
    
    frame = uint8(maska) * 255;
    writeVideo(seg_V, frame);
end

close(seg_V);
implay('ladja_segmentacija_rgb.avi');

% HSV segmentacija

video = VideoReader('ladja.avi');
frame = read(video, 20);
frame_double = im2double(frame);
frame_hsv = rgb2hsv(frame_double);
%imshow(frame_hsv);

H = frame_hsv(:,:,1);
S = frame_hsv(:,:,2);
V = frame_hsv(:,:,3);

H_min = 0.28; 
H_max = 0.47;   
S_min = 0.09;  
S_max = 0.5;    
V_min = 0.26;  
V_max = 0.51;    


seg_video = VideoWriter('ladja_segmentacija_hsv.avi');
seg_video.FrameRate = video.FrameRate;
open(seg_video);

while hasFrame(video)
    I = readFrame(video);        
    I_double = im2double(I);
    I_hsv = rgb2hsv(I_double);

    H = I_hsv(:,:,1);
    S = I_hsv(:,:,2);
    V = I_hsv(:,:,3);

    % lahko bi uporabili samo H ali pa H in S
    maska =  H >= H_min & H <= H_max & S >= S_min & S <= S_max & V >= V_min & V <= V_max;

    frame = uint8(maska) * 255;
    writeVideo(seg_video, frame);
end

close(seg_video);
implay('ladja_segmentacija_hsv.avi');

%% 4. naloga

video = VideoReader('ladja.avi');
frame = read(video, 20);         
imshow(frame);

izrez = imcrop(frame);      % z miško povlečemo pravokotnik in dvakrat kliknemo znotraj pravokotnika
imshow(izrez);

R = izrez(:,:,1);
G = izrez(:,:,2);
B = izrez(:,:,3);

st_binov = 8;             % število binov na vsaki osi
sirina_bina = 256 / st_binov;  % širina enega bina je 32

H = zeros(st_binov, st_binov, st_binov);  % inicializiramo histogram

[vrstice, stolpci, ~] = size(izrez);

for i = 1:vrstice                % gremo čez vse vrstice in stolpce (torej čez vse piksle) in polnimo histogram
    for j = 1:stolpci
        
        r = double(R(i,j));   % spotoma pretvorimo v double
        g = double(G(i,j));
        b = double(B(i,j));

        r_bin = floor(r / sirina_bina) + 1;  % izračunamo indeks bina za vsak kanal od 1 do 8
        g_bin = floor(g / sirina_bina) + 1;
        b_bin = floor(b / sirina_bina) + 1;

        H(r_bin, g_bin, b_bin) = H(r_bin, g_bin, b_bin) + 1;  % povečamo števec v tem binu
    end
end

maks = max(H(:));   % normalizacija: največji vrednosti pripišemo 255
H = H * (255 / maks); 

% pretvorba videa v sivinski posnetek

video = VideoReader('ladja.avi');

video_siv = VideoWriter('sivinska_ladja_histogram.avi');
video_siv.FrameRate = video.FrameRate;
open(video_siv);

while hasFrame(video)   % gremo čez vse frameje
    frame = readFrame(video);              
    [vrstice_frame, stolpci_frame, ~] = size(frame);
    
    frame_siv = zeros(vrstice_frame, stolpci_frame, 'uint8'); % pripravimo siv frame
    
    R_f = double(frame(:,:,1));
    G_f = double(frame(:,:,2));
    B_f = double(frame(:,:,3));
    
    for i = 1:vrstice_frame          % gremo čez vse piksle znotraj enega frameja 
        for j = 1:stolpci_frame
            
            r = R_f(i,j);
            g = G_f(i,j);
            b = B_f(i,j);
            
            r_bin = floor(r / sirina_bina) + 1;
            g_bin = floor(g / sirina_bina) + 1;
            b_bin = floor(b / sirina_bina) + 1;
            
            siv_H = H(r_bin, g_bin, b_bin);  % preberemo sivinsko vrednost iz norm. histograma
            
            frame_siv(i,j) = siv_H;          % zapišemo v sivinsko sliko
        end
    end
   
    writeVideo(video_siv, frame_siv);           % zapišemo sivinski frame v video
end

close(video_siv);
implay('sivinska_ladja_histogram.avi');

%% 5. naloga

video = VideoReader('ladja.avi');
frame = read(video, 20);         
imshow(frame);

izrez = imcrop(frame);      % z miško povlečemo pravokotnik in dvakrat kliknemo znotraj pravokotnika
imshow(izrez);

R = izrez(:,:,1);
G = izrez(:,:,2);
B = izrez(:,:,3);

st_binov = 4;            
sirina_bina = 256 / st_binov;  % širina enega bina je 64

H = zeros(st_binov, st_binov, st_binov);  

[vrstice, stolpci, ~] = size(izrez);

for i = 1:vrstice                
    for j = 1:stolpci
        
        r = double(R(i,j));   
        g = double(G(i,j));
        b = double(B(i,j));

        r_bin = floor(r / sirina_bina) + 1;  
        g_bin = floor(g / sirina_bina) + 1;
        b_bin = floor(b / sirina_bina) + 1;

        H(r_bin, g_bin, b_bin) = H(r_bin, g_bin, b_bin) + 1;  
    end
end

H_ref = H(:);   % normalizacija: da je vsota 1
vsota_ref = sum(H_ref);
H_ref = H_ref / vsota_ref;

% pripravimo video

video = VideoReader('ladja.avi');

video_izhod = VideoWriter('ladja_intersection.avi');
video_izhod.FrameRate = video.FrameRate;
open(video_izhod);

velikost_bloka = 8; % 8x8

while hasFrame(video)   % obdelamo vse frameje
    frame = readFrame(video);          
    [vrstice_frame, stolpci_frame, ~] = size(frame);

    bloki_vrstica = floor(vrstice_frame / velikost_bloka);   % poračunamo koliko celih blokov gre v sliko
    bloki_stolpec = floor(stolpci_frame / velikost_bloka);   % tukaj s floor zagotovimo, da ignoriramo rob

    bloki_vrstica_1 = bloki_vrstica * velikost_bloka;         % poračunamo koliko dejanskih blokov je celih notri
    bloki_stolpec_1 = bloki_stolpec * velikost_bloka;
    
    frame_siv = zeros(bloki_vrstica_1, bloki_stolpec_1, 'uint8');  % pripravi siv frame

    R_f = double(frame(:,:,1));
    G_f = double(frame(:,:,2));
    B_f = double(frame(:,:,3));

    for v = 1:bloki_vrstica
        for s = 1:bloki_stolpec

            vrstica_zac = (v - 1) * velikost_bloka + 1;
            vrstica_kon = v * velikost_bloka;
            stolpec_zac = (s - 1) * velikost_bloka + 1;
            stolpec_kon = s * velikost_bloka;

            blok_R = R_f(vrstica_zac:vrstica_kon, stolpec_zac:stolpec_kon); % za vsak kanal izrežemo 8x8 blok
            blok_G = G_f(vrstica_zac:vrstica_kon, stolpec_zac:stolpec_kon);
            blok_B = B_f(vrstica_zac:vrstica_kon, stolpec_zac:stolpec_kon);

            H_blok = zeros(st_binov, st_binov, st_binov);

            for i = 1:velikost_bloka
                for j = 1:velikost_bloka
                    
                    r = blok_R(i,j);
                    g = blok_G(i,j);
                    b = blok_B(i,j);
                    
                    r_bin = floor(r / sirina_bina) + 1;
                    g_bin = floor(g / sirina_bina) + 1;
                    b_bin = floor(b / sirina_bina) + 1;

                    H_blok(r_bin, g_bin, b_bin) = H_blok(r_bin, g_bin, b_bin) + 1;
                end
            end

            H_blok_ref = H_blok(:);  % normalizacija
            vsota_blok_ref = sum(H_blok_ref);
            H_blok_ref = H_blok_ref / vsota_blok_ref;

            % intersekcija/presek

            presek = 0;  
            for k = 1:length(H_ref)
                presek = presek + min(H_ref(k), H_blok_ref(k));
            end
            
            siv_vrednost = uint8(255 * presek);   % 255 namesto 256, da ne pride do preliva 
            
            % vsem pikslom v bloku pripišemo isto sivinsko vrednost
            siv_frame(vrstica_zac:vrstica_kon, stolpec_zac:stolpec_kon) = siv_vrednost;
        end
    end

    writeVideo(video_izhod, siv_frame);
end

close(video_izhod);
implay('ladja_intersection.avi');








==== END Tina Gutnik | Tina Gutnik_21495_assignsubmission_file | lab_vaja_3.m ====

==== BEGIN Tina Gutnik | Tina Gutnik_21495_assignsubmission_file | sivinska_slika_komponent.m ====
function sivinska_slika_komponent(datoteka)
% vhod datoteke mora biti v obliki 'slika.jpg'
% funkcija vrne 6 sivinskih slik - vsako izmed HSV in Lab komponent


I_int = imread(datoteka);
I_double = im2double(I_int);

% HSV prostor

I_hsv = rgb2hsv(I_double);   % pretvorimo v HSV prostor

H = I_hsv(:,:,1); 
S = I_hsv(:,:,2); 
V = I_hsv(:,:,3);

figure;                  
imagesc(H);
colormap(gray);
title('HSV: H');

figure;                  
imagesc(S);
colormap(gray);
title('HSV: S');

figure;                  
imagesc(V);
colormap(gray);
title('HSV: V');

% Lab prostor

I_lab = rgb2lab(I_double);

L = I_lab(:,:,1); 
a = I_lab(:,:,2);   
b = I_lab(:,:,3);  

figure;                  
imagesc(L);
colormap(gray);
title('Lab: L');

figure;                  
imagesc(a);
colormap(gray);
title('Lab: a');

figure;                  
imagesc(b);
colormap(gray);
title('Lab: b');

end
==== END Tina Gutnik | Tina Gutnik_21495_assignsubmission_file | sivinska_slika_komponent.m ====

