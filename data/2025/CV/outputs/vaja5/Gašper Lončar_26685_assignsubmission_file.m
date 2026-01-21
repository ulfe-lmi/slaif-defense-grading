==== BEGIN Gašper Lončar | Gašper Lončar_26685_assignsubmission_file | RVlab5.m ====
%% 5 vaja 1. naloga
% anti aliansing

C=VideoReader('Holywood.avi');
orig_okvirji=read(C,[1 Inf]);
video_size=size(orig_okvirji);
st_frameov=video_size(4);
prvi_frame=orig_okvirji(:,:,:,1);

skala=[0.5, 0.25, 0.125];
visina = round(video_size(1)*skala(3));
sirina = round(video_size(2)*skala(3));

% prazna tabelca velikosti videa za število frameov
skaliran_okvir = zeros(visina,sirina,3,st_frameov,'uint8'); 


for i = 1:st_frameov
   okvir = orig_okvirji(:,:,:,i);
   %okvir = imresize(okvir,skala(1),'nearest',Antialiasing=false);
   %okvir=imresize(okvir, skala(3),"bilinear",Antialiasing=false);
   okvir=imresize(okvir,skala(3),"bilinear",Antialiasing=true);

   skaliran_okvir(:,:,:,i) = okvir;
end

skaliran_video=VideoWriter('skaliran_video_AA3');
skaliran_video.FrameRate = 25;
open(skaliran_video);
writeVideo(skaliran_video, skaliran_okvir);
close(skaliran_video);

%% 2. naloga - sledenje igralcema
D=VideoReader('squash.avi');
orig_okvirji=read(D,[1 Inf]);
video_size=size(orig_okvirji);
st_frameov=video_size(4);
prvi_frame=orig_okvirji(:,:,:,1);

% pogledaš vrednosti RGB na okvirju
%figure; imshow(prvi_frame); impixelinfo; 

figure; imshow(prvi_frame);
[x,y] = ginput(2);


x1 = round(min(x)); x2 = round(max(x));
y1 = round(min(y)); y2 = round(max(y));

znacilnica = prvi_frame(y1:y2, x1:x2, :);
znacilnica_hsv = rgb2hsv(znacilnica);
znacilnica_V = znacilnica_hsv(:,:,3);

center_x = round((x1+x2)/2);
center_y = round((y1+y2)/2);

velikost_okolice = 12;   % velikost okolice
%%Evklidska razdalja
sivinska_znacilnica = rgb2gray(znacilnica);
[visina_zna, sirina_zna] = size(sivinska_znacilnica);

% figure;
% imshow(znacilnica, []);

evk_video = VideoWriter('sledenje_evk.avi');
evk_video.FrameRate = 25;
open(evk_video);

for i = 1:st_frameov
    okvir = orig_okvirji(:,:,:,i);
    siv_okvir = rgb2gray(okvir);

    opt_razdalja = Inf;
    pozicija = [center_x center_y];

    for razdalja_y = -velikost_okolice:velikost_okolice
        for razdalja_x = -velikost_okolice:velikost_okolice
            x0 = center_x + razdalja_x;
            y0 = center_y + razdalja_y;

            if x0 < 1 || y0 < 1 || x0+sirina_zna-1 > video_size(2) || y0+visina_zna-1 > video_size(1)
                continue;
            end

            
            kandidat = okvir(y0:y0+visina_zna-1, x0:x0+sirina_zna-1, :);
            kandidat_hsv = rgb2hsv(kandidat);
            kandidat_V = kandidat_hsv(:,:,3);
            razlika = sum((double(kandidat_V(:)) - double(znacilnica_V(:))).^2);

            if razlika < opt_razdalja
                opt_razdalja = razlika;
                pozicija = [x0 y0];
            end
        end
    end

    %posodobimo pozicijo
    center_x = pozicija(1);
    center_y = pozicija(2);

    % označimo
    okvir(center_y:center_y+visina_zna-1, center_x:center_x+visina_zna-1, :) = 255;

    writeVideo(evk_video, okvir);
end

close(evk_video);

% reset pozicije za 2. nacin
center_x = round((x1+x2)/2);
center_y = round((y1+y2)/2);

%% kvadrat

% sivinska značilnica
znacilnica_siv = rgb2gray(znacilnica);

nBin = 20;                      % dovolj, ni treba komplicirat
ref_hist = imhist(znacilnica_siv, nBin);
ref_hist = ref_hist / sum(ref_hist);   % normalizacija


kvad_video = VideoWriter('sledenje_kvad.avi');
kvad_video.FrameRate = 25;
open(kvad_video);


for i = 1:st_frameov
    okvir = orig_okvirji(:,:,:,i);
    siv_okvir = rgb2gray(okvir);

    najboljsa_razdalja = Inf;
    pozicija = [center_x center_y];

    for dy = -velikost_okolice:velikost_okolice
        for dx = -velikost_okolice:velikost_okolice

            x0 = center_x + dx;
            y0 = center_y + dy;

            if x0 < 1 || y0 < 1 || ...
               x0+sirina_zna-1 > video_size(2) || ...
               y0+visina_zna-1 > video_size(1)
                continue;
            end

            kandidat = siv_okvir(y0:y0+visina_zna-1, ...
                                 x0:x0+sirina_zna-1);

            % histogram kandidata
            hist_kand = imhist(kandidat, nBin);
            if sum(hist_kand) == 0
                  continue;
            end
            hist_kand = hist_kand / sum(hist_kand);

            % χ² razdalja
            chi2 = sum( (hist_kand - ref_hist).^2 ./ ...
                        (hist_kand + ref_hist + 1e-6) );

            if chi2 < najboljsa_razdalja
                najboljsa_razdalja = chi2;
                pozicija = [x0 y0];
            end
        end
    end

    center_x = pozicija(1);
    center_y = pozicija(2);


    okvir(center_y:center_y+visina_zna-1, ...
          center_x:center_x+sirina_zna-1, :) = 255;

    writeVideo(kvad_video, okvir);
end

close(kvad_video);

%% 3. NE DELA KOT BI MORALO, RAZMISLI ZAKAJ NE
==== END Gašper Lončar | Gašper Lončar_26685_assignsubmission_file | RVlab5.m ====

