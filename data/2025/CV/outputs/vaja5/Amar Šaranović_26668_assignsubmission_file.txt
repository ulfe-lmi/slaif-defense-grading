==== BEGIN Amar Šaranović | Amar Šaranović_26668_assignsubmission_file | vaja5.m ====
%% Naloga 1
videoDatoteka = 'Holywood.avi';
vhodniVideo = VideoReader(videoDatoteka);
okvirjiStevilo = vhodniVideo.NumFrames;

% Inicializacija matrik za zmanjšane videe
videoNN = cell(3, 1);
videoBL_Brez = cell(3, 1);
videoBL_Za = cell(3, 1);

% Faktorji pomanjšanja
manjsanje = [0.5, 0.25, 0.125];

% Obdelava posameznih okvirjev
for okvir = 1:okvirjiStevilo
    trenutniOkvir = read(vhodniVideo, okvir);

    % Najbližji sosed
    for indeks = 1:length(manjsanje)
        videoNN{indeks}(:,:,:,okvir) = imresize(trenutniOkvir, manjsanje(indeks), 'nearest');
    end

    % Bilinearno brez filtriranja
    for indeks = 1:length(manjsanje)
        videoBL_Brez{indeks}(:,:,:,okvir) = imresize(trenutniOkvir, manjsanje(indeks), 'bilinear', 'Antialiasing', false);
    end

    % Bilinearno s filtriranjem
    for indeks = 1:length(manjsanje)
        videoBL_Za{indeks}(:,:,:,okvir) = imresize(trenutniOkvir, manjsanje(indeks), 'bilinear', 'Antialiasing', true);
    end
end

% Funkcija za shranjevanje videoposnetkov
shranjevanjeVideov = @(okvirji, imeDatoteke) shraniVideo(okvirji, imeDatoteke, vhodniVideo.FrameRate);

% Shranjevanje vseh pomanjšanih videoposnetkov
imenDatotek = {'_Polovica', '_Cetrtina', '_Osmina'};
for i = 1:3
    shranjevanjeVideov(videoNN{i}, ['Video_NN', imenDatotek{i}, '.avi']);
    shranjevanjeVideov(videoBL_Brez{i}, ['Video_BL_Brez', imenDatotek{i}, '.avi']);
    shranjevanjeVideov(videoBL_Za{i}, ['Video_BL_Za', imenDatotek{i}, '.avi']);
end

% Funkcija za shranjevanje 
function shraniVideo(okvirji, imeIzhoda, fps)
    pisec = VideoWriter(imeIzhoda);
    pisec.FrameRate = fps;
    open(pisec);
    writeVideo(pisec, uint8(okvirji));
    close(pisec);
end
%% Naloga2.1
video = VideoReader('squash.avi');
allFrames = read(video, [1 Inf]);

prviFrame = allFrames(:,:,:,1);
figure;
imshow(prviFrame);
title('Kliknite 2 točki znotraj igralca (zgoraj levo, spodaj desno');

[xKliki, yKliki] = ginput(2);
% koordinate 
% xKliki =
% 
%   109.8216
%   120.8172
% 
% 
% yKliki =
% 
%   121.2401
%   128.4295


% Izračun središč 
xRdeci = xKliki(1) + (xKliki(2) - xKliki(1)) / 2;
yRdeci = yKliki(1) + (yKliki(2) - yKliki(1)) / 2;

% xBeli = xKliki(3) + (xKliki(4) - xKliki(3)) / 2;
% yBeli = yKliki(3) + (yKliki(4) - yKliki(3)) / 2;

% % Dimenzije izseka
dxRdeci = floor(xKliki(2) - xKliki(1));
dyRdeci = floor(yKliki(2) - yKliki(1));
% 
% dxBeli = floor(xKliki(4) - xKliki(3));
% dyBeli = floor(yKliki(4) - yKliki(3));

% Izsek igralca rdeči
rdeciIgralec = prviFrame(yKliki(1):yKliki(1)+dyRdeci, xKliki(1):xKliki(1)+dxRdeci, :);

% Izsek igralca beli
%beliIgralec = prviFrame(yKliki(3):yKliki(3)+dyBeli, xKliki(3):xKliki(3)+dxBeli, :);

% Območje iskanja
epsilon = 20;

oznaceniOkvirji = zeros(size(allFrames), 'uint8');

for okvir = 2:size(allFrames, 4) %st okvirjev
    trenutniFrame = allFrames(:,:,:,okvir);

    % R- območje iskanja 
    yMinR = max(1, round(yRdeci - epsilon));
    yMaxR = min(size(trenutniFrame, 1), round(yRdeci + epsilon));
    xMinR = max(1, round(xRdeci - epsilon));
    xMaxR = min(size(trenutniFrame, 2), round(xRdeci + epsilon));

    okolicaRdeci = trenutniFrame(yMinR:yMaxR, xMinR:xMaxR, :);
    minDistanceR = inf;
    %noviR = [1, 1];
    for y = 1:size(okolicaRdeci, 1) - size(rdeciIgralec, 1) + 1 %število možnih premikov izseka
        for x = 1:size(okolicaRdeci, 2) - size(rdeciIgralec, 2) + 1

            izsek = okolicaRdeci(y:y+size(rdeciIgralec, 1)-1, x:x+size(rdeciIgralec, 2)-1, :);
            distance = sum((double(izsek) - double(rdeciIgralec)).^2, 'all'); % Evklidska razdalja
            
            if distance < minDistanceR
                minDistanceR = distance;
                noviR = [x, y];
            end
        end
    end
    xRdeci = xMinR + noviR(1) - 1;
    yRdeci = yMinR + noviR(2) - 1;

    % % B- območje iskanja 
    % yMinB = max(1, round(yBeli - epsilon));
    % yMaxB = min(size(trenutniFrame, 1), round(yBeli + epsilon));
    % xMinB = max(1, round(xBeli - epsilon));
    % xMaxB = min(size(trenutniFrame, 2), round(xBeli + epsilon));
    % 
    % okolicaBeli = trenutniFrame(yMinB:yMaxB, xMinB:xMaxB, :);
    % minDistanceB = inf;
    % noviB = [1, 1];
    % for y = 1:size(okolicaBeli, 1) - size(beliIgralec, 1) + 1
    %     for x = 1:size(okolicaBeli, 2) - size(beliIgralec, 2) + 1
    %         izsek = okolicaBeli(y:y+size(beliIgralec, 1)-1, x:x+size(beliIgralec, 2)-1, :);
    %         distance = sum((double(izsek) - double(beliIgralec)).^2, 'all'); % Evklidska razdalja
    %         if distance < minDistanceB
    %             minDistanceB = distance;
    %             noviB = [x, y];
    %         end
    %     end
    % end
    % xBeli = xMinB + noviB(1) - 1;
    % yBeli = yMinB + noviB(2) - 1;

    % Posodobitev izseka igralca beli
    %beliIgralec = trenutniFrame(yBeli:yBeli+dyBeli, xBeli:xBeli+dxBeli, :);

    % Označevanje obeh igralcev
    oznaceniOkvirji(:,:,:,okvir) = insertShape(trenutniFrame, 'Circle', [xRdeci yRdeci 14], 'Color', {'red'});
    %oznaceniOkvirji(:,:,:,okvir) = insertShape(oznaceniOkvirji(:,:,:,okvir), 'Circle',[xBeli yBeli 14], 'Color', {'white'});
end

% Shranjevanje označenega videa
izhodniVideo = VideoWriter('video_sledenje_evk.avi');
izhodniVideo.FrameRate = video.FrameRate;
open(izhodniVideo);
writeVideo(izhodniVideo, oznaceniOkvirji);
close(izhodniVideo);

%% Naloga2.2
video = VideoReader('squash.avi');
allFrames = read(video, [1 Inf]);
frameSize = size(allFrames);

imshow(allFrames(:,:,:,1));
title('Kliknite 2 točki znotraj igralca (zgoraj levo, spodaj desno');

[xKliki, yKliki] = ginput(2);
% koordinate
% xKliki =
% 
%   108.1300
%   119.1256
% 
% 
% yKliki =
% 
%   122.0859
%   127.5837

% Izračun središča igralca
xRdeci = xKliki(1) + (xKliki(2) - xKliki(1)) / 2;
yRdeci = yKliki(1) + (yKliki(2) - yKliki(1)) / 2;

% Velikost izseka igralca
dxRdeci = floor(xKliki(2) - xKliki(1));
dyRdeci = floor(yKliki(2) - yKliki(1));

% Izsek igralca- znacilka 
znacilka = allFrames(yKliki(1):yKliki(2), xKliki(1):xKliki(2), :, 1);
znacilka_gray = rgb2gray(znacilka);

% Histogram značilke igralca
igracHist = zeros(1, 9);
for i = 1:size(znacilka_gray, 1)
    for j = 1:size(znacilka_gray, 2)
        bin = floor(znacilka_gray(i, j) / 32) + 1;
        igracHist(bin) = igracHist(bin) + 1;
    end
end
igracHist = igracHist / sum(igracHist);  % Normaliziran histogram

% Parametri iskanja
epsilon = 25;
windowSize = [dyRdeci, dxRdeci];  % Velikost okna za iskanje
trackedFrames = zeros(size(allFrames), 'uint8');

% Sledenje skozi vse okvire
for f = 1:size(allFrames, 4)
    % Središče igralca in parametri iskanja
    x1 = floor(xRdeci - epsilon / 2);
    x2 = floor(xRdeci + epsilon / 2);
    y1 = floor(yRdeci - epsilon / 2);
    y2 = floor(yRdeci + epsilon / 2);
    
    % Preverjanje meja slike
    x1 = max(1, x1);
    x2 = min(frameSize(2), x2);
    y1 = max(1, y1);
    y2 = min(frameSize(1), y2);

    % Sivi okvir trenutnega okvira
    frames_gray = rgb2gray(allFrames(:,:,:,f));

    % Iskanje najboljše ujemanje s histogrami
    minDistance = inf;  % Začetna razdalja je zelo velika
    
    % Preiskovanje območja za najboljše ujemanje histogramov
    for y = y1 : y2 - windowSize(1) + 1
        for x = x1 : x2 - windowSize(2) + 1
            patch = frames_gray(y:y+windowSize(1)-1, x:x+windowSize(2)-1);
            
            % Izračun histograma za trenutni izsek
            trenutniHist = zeros(1, 9);
            for i = 1:size(patch, 1)
                for j = 1:size(patch, 2)
                    bin = floor(patch(i, j) / 32) + 1;
                    trenutniHist(bin) = trenutniHist(bin) + 1;
                end
            end
            trenutniHist = trenutniHist / sum(trenutniHist);  % Normalizacija histogramu
            
            % Izračun kvadratne razdalje med histogramom igralca in trenutnim histogramom
            distance = sum((igracHist - trenutniHist).^2);
            
            % Posodobitev najboljše točke
            if distance < minDistance
                minDistance = distance;
                novi = [x, y];
            end
        end
    end
    
    % Posodobitev središča igralca
    xRdeci = novi(1) + floor(dxRdeci / 2);
    yRdeci = novi(2) + floor(dyRdeci / 2);

    % Označevanje igralca z rdečim krogom
    trackedFrames(:,:,:,f) = insertShape(allFrames(:,:,:,f), 'Circle', [xRdeci, yRdeci, 16], 'Color', 'red', 'LineWidth', 1);
end

% Shranjevanje rezultata
outputVideo = VideoWriter('video_sledenje_hi.avi');
outputVideo.FrameRate = video.FrameRate;
open(outputVideo);
writeVideo(outputVideo, trackedFrames);
close(outputVideo);
%% naloga 3
clear all
video = VideoReader('squash.avi');
allFrames = read(video, [1 Inf]);

% Prikaz prvega okvirja in označitev igralcev
prviFrame = allFrames(:,:,:,1);
figure;
imshow(prviFrame);
title('Kliknite 2 točki znotraj igralca (zgoraj levo, spodaj desno');

[xKliki, yKliki] = ginput(2);

% Izračun središč za igralca rdeči
xRdeci = xKliki(1) + (xKliki(2) - xKliki(1)) / 2;
yRdeci = yKliki(1) + (yKliki(2) - yKliki(1)) / 2;

% Dimenzije izseka igralca rdeči
dxRdeci = floor(xKliki(2) - xKliki(1));
dyRdeci = floor(yKliki(2) - yKliki(1));

% Izsek igralca rdeči
znacilka = prviFrame(yKliki(1):yKliki(1)+dyRdeci, xKliki(1):xKliki(1)+dxRdeci, :);

% Območje iskanja
epsilon = 20;

oznaceniOkvirji = zeros(size(allFrames), 'uint8');

for okvir = 2:size(allFrames, 4)
    trenutniFrame = allFrames(:,:,:,okvir);

    % R- območje iskanja
    yMinR = max(1, round(yRdeci - epsilon));
    yMaxR = min(size(trenutniFrame, 1), round(yRdeci + epsilon)); 
    xMinR = max(1, round(xRdeci - epsilon));
    xMaxR = min(size(trenutniFrame, 2), round(xRdeci + epsilon));

    okolicaRdeci = trenutniFrame(yMinR:yMaxR, xMinR:xMaxR, :);
    minDistance = inf;
    for y = 1:size(okolicaRdeci, 1) - size(znacilka, 1) + 1
        for x = 1:size(okolicaRdeci, 2) - size(znacilka, 2) + 1
            izsek = okolicaRdeci(y:y+size(znacilka, 1)-1, x:x+size(znacilka, 2)-1, :);
            diff = double(izsek) - double(znacilka);
            distance = sum(diff(:).^2); % Evklidska razdalja

            if distance < minDistance
                minDistance = distance;
                novi = [x, y];
            end
        end
    end
    xRdeci = xMinR + novi(1) - 1;
    yRdeci = yMinR + novi(2) - 1;

    % spreminjanje znacilke
    znacilka = trenutniFrame(yRdeci:yRdeci+dyRdeci, xRdeci:xRdeci+dxRdeci, :);

    % Označevanje igralca
    oznaceniOkvirji(:,:,:,okvir) = insertShape(trenutniFrame, 'Circle', ...
        [xRdeci yRdeci 14], 'Color', {'red'});
end

% Shranjevanje označenega videa
izhodniVideo = VideoWriter('video_znacilka_evk.avi');
izhodniVideo.FrameRate = video.FrameRate;
open(izhodniVideo);
writeVideo(izhodniVideo, oznaceniOkvirji);
close(izhodniVideo);
==== END Amar Šaranović | Amar Šaranović_26668_assignsubmission_file | vaja5.m ====

