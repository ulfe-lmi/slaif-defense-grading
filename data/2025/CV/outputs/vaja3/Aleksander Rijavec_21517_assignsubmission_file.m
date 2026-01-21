==== BEGIN Aleksander Rijavec | Aleksander Rijavec_21517_assignsubmission_file | naloga3-aleksanderrijavec.m ====
%% Naloga 1 
slika1 = imread('coloured_pencils.jpg');
slika2 = imread('yosemite_meadows.jpg');

% Slika1 - hsv
slika1_hsv = rgb2hsv(slika1);
H1 = slika1_hsv(:, :, 1); % H komponenta
S1 = slika1_hsv(:, :, 2); % S komponenta
V1 = slika1_hsv(:, :, 3); % V komponenta

% Prikaz H, S, V 
figure;
subplot(1, 3, 1);
imagesc(H1);
colormap(gray);
colorbar;
title('Prva slika - H komponenta');

subplot(1, 3, 2);
imagesc(S1);
colormap(gray);
colorbar;
title('Prva slika - S komponenta');

subplot(1, 3, 3);
imagesc(V1);
colormap(gray);
colorbar;
title('Prva slika - V komponenta');

% slika2 - hsv
slika2_hsv = rgb2hsv(slika2);
H2 = slika2_hsv(:, :, 1); % H komponenta
S2 = slika2_hsv(:, :, 2); % S komponenta
V2 = slika2_hsv(:, :, 3); % V komponenta

% Prikaz H, S, V
figure;
subplot(1, 3, 1);
imagesc(H2);
colormap(gray);
colorbar;
title('Druga slika - H komponenta');

subplot(1, 3, 2);
imagesc(S2);
colormap(gray);
colorbar;
title('Druga slika - S komponenta');

subplot(1, 3, 3);
imagesc(V2);
colormap(gray);
colorbar;
title('Druga slika - V komponenta');

% slika1 - Lab
slika1_lab = rgb2lab(slika1);
L1 = slika1_lab(:, :, 1); % L komponenta
a1 = slika1_lab(:, :, 2); % a komponenta
b1 = slika1_lab(:, :, 3); % b komponenta

% Prikaz L, a, b
figure;
subplot(1, 3, 1);
imagesc(L1);
colormap(gray);
colorbar;
title('Prva slika - L komponenta');

subplot(1, 3, 2);
imagesc(a1);
colormap(gray);
colorbar;
title('Prva slika - a komponenta');

subplot(1, 3, 3);
imagesc(b1);
colormap(gray);
colorbar;
title('Prva slika - b komponenta');

% slika2 - Lab
slika2_lab = rgb2lab(slika2);
L2 = slika2_lab(:, :, 1); % L komponenta
a2 = slika2_lab(:, :, 2); % a komponenta
b2 = slika2_lab(:, :, 3); % b komponenta

% Prikaz L, a, b
figure;
subplot(1, 3, 1);
imagesc(L2);
colormap(gray);
colorbar;
title('Druga slika - L komponenta');

subplot(1, 3, 2);
imagesc(a2);
colormap(gray);
colorbar;
title('Druga slika - a komponenta');

subplot(1, 3, 3);
imagesc(b2);
colormap(gray);
colorbar;
title('Druga slika - b komponenta');

%% Naloga 2
slika1 = imread('coloured_pencils.jpg');

% HSV
slika_hsv = rgb2hsv(slika1);

% H
slika_H_constant = slika_hsv;
slika_H_constant(:, :, 1) = 0.5; % 0.5 je 180 stopin
slika_H_rgb = hsv2rgb(slika_H_constant);

% S
slika_S_constant = slika_hsv;
slika_S_constant(:, :, 2) = 0.5;
slika_S_rgb = hsv2rgb(slika_S_constant);

% V
slika_V_constant = slika_hsv;
slika_V_constant(:, :, 3) = 0.5;
slika_V_rgb = hsv2rgb(slika_V_constant);

% Prikaz
figure
subplot(1, 4, 1);
imshow(slika1);
title('Originalna slika');

subplot(1, 4, 2);
imshow(slika_H_rgb);
title('H komponenta na polovici');

subplot(1, 4, 3);
imshow(slika_S_rgb);
title('S komponenta na polovici');

subplot(1, 4, 4);
imshow(slika_V_rgb);
title('V komponenta na polovici');

% Lab
slika_lab = rgb2lab(slika1);

% L
slika_L_constant = slika_lab;
slika_L_constant(:, :, 1) = 50;
slika_L_rgb = lab2rgb(slika_L_constant);

% S
slika_a_constant = slika_lab;
slika_a_constant(:, :, 2) = 0;
slika_a_rgb = lab2rgb(slika_a_constant);

% V
slika_b_constant = slika_lab;
slika_b_constant(:, :, 3) = 0;
slika_b_rgb = lab2rgb(slika_b_constant);

% Prikaz
figure
subplot(1, 4, 1);
imshow(slika1);
title('Originalna slika');

subplot(1, 4, 2);
imshow(slika_L_rgb);
title('L komponenta na polovici');

subplot(1, 4, 3);
imshow(slika_a_rgb);
title('a komponenta na polovici');

subplot(1, 4, 4);
imshow(slika_b_rgb);
title('b komponenta na polovici');

%% Naloga 3
video = VideoReader('ladja.avi');
outputRGB = VideoWriter('segmented_rgb.avi'); 
outputHSV = VideoWriter('segmented_hsv.avi'); 
open(outputRGB);
open(outputHSV);

% Prikaz prvega okvirja za določanje intervalov
frame = readFrame(video);
imshow(frame);
title('Kliknite na eno točko morja za določitev barvnih intervalov');

% Izbira točke
[x, y] = ginput(1);
x = round(x);
y = round(y);

selectedColor = reshape(frame(y, x, :), 1, 3);

% Določanje intervalov 
tolerance = 30;
minR = max(0, selectedColor(1) - tolerance);
maxR = min(255, selectedColor(1) + tolerance);
minG = max(0, selectedColor(2) - tolerance);
maxG = min(255, selectedColor(2) + tolerance);
minB = max(0, selectedColor(3) - tolerance);
maxB = min(255, selectedColor(3) + tolerance);

disp('Intervali RGB določeni:');
disp(['R: [', num2str(minR), ', ', num2str(maxR), ']']);
disp(['G: [', num2str(minG), ', ', num2str(maxG), ']']);
disp(['B: [', num2str(minB), ', ', num2str(maxB), ']']);

% Pretvorba RGB v HSV in določanje HSV intervalov
selectedColorHSV = rgb2hsv(double(selectedColor) / 255);

minH = max(0, selectedColorHSV(1) - 0.05); 
maxH = min(1, selectedColorHSV(1) + 0.05);
minS = max(0, selectedColorHSV(2) - 0.2); 
maxS = min(1, selectedColorHSV(2) + 0.2);
minV = 0;
maxV = 1;  

disp('Intervali HSV določeni:');
disp(['H: [', num2str(minH), ', ', num2str(maxH), ']']);
disp(['S: [', num2str(minS), ', ', num2str(maxS), ']']);
disp(['V: [', num2str(minV), ', ', num2str(maxV), ']']);

video.CurrentTime = 0;

% Segmentacija videa v RGB prostoru
while hasFrame(video)
    frame = readFrame(video);
    
    % RGB segmentacija
    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);
    binaryRGB = (R >= minR & R <= maxR) & ...
                (G >= minG & G <= maxG) & ...
                (B >= minB & B <= maxB);
    
    binaryRGB = uint8(binaryRGB) * 255;
    writeVideo(outputRGB, binaryRGB);
end

video.CurrentTime = 0;

% Segmentacija videa v HSV prostoru
while hasFrame(video)
    frame = readFrame(video);
    hsvFrame = rgb2hsv(frame);

    H = hsvFrame(:,:,1);
    S = hsvFrame(:,:,2);
    V = hsvFrame(:,:,3);

    binaryHSV = (H >= minH & H <= maxH) & ...
                (S >= minS & S <= maxS) & ...
                (V >= minV & V <= maxV);

    binaryHSV = uint8(binaryHSV) * 255;
    writeVideo(outputHSV, binaryHSV);
end

close(outputRGB);
close(outputHSV);

%% Naloga 4
videoReader = VideoReader('ladja.avi');
frameSample = readFrame(videoReader);
imshow(frameSample);
title('Izberite območje, ki predstavlja tipično barvo morja');

% pravokotno območje
position = round(getrect);
close;

seaRegion = imcrop(frameSample, position);

numBins = 8; % Uporabimo 8x8x8 histogram
binSize = 256 / numBins; % Velikost posameznega intervala

% histogram
hist3D = zeros(numBins, numBins, numBins); % Inicializacija 3D histograma

R = seaRegion(:,:,1);
G = seaRegion(:,:,2);
B = seaRegion(:,:,3);
binR = max(ceil(double(R) / binSize), 1); 
binG = max(ceil(double(G) / binSize), 1);
binB = max(ceil(double(B) / binSize), 1);

for i = 1:numel(R)
    hist3D(binR(i), binG(i), binB(i)) = hist3D(binR(i), binG(i), binB(i)) + 1;
end

hist3D = hist3D * (255 / max(hist3D(:)));

outputVideo = VideoWriter('morje_sivinska_hist.avi');
open(outputVideo);

videoReader.CurrentTime = 0;

% Procesiramo vsak okvir in ga pretvorimo v sivinsko sliko
while hasFrame(videoReader)
    frame = readFrame(videoReader); % Preberemo trenutni okvir
    
    grayFrame = zeros(size(frame, 1), size(frame, 2), 'uint8');
    
    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);
    
    binR = max(min(ceil(double(R) / binSize), numBins), 1);
    binG = max(min(ceil(double(G) / binSize), numBins), 1);
    binB = max(min(ceil(double(B) / binSize), numBins), 1);
    
    for i = 1:size(frame, 1)
        for j = 1:size(frame, 2)
            grayFrame(i, j) = hist3D(binR(i, j), binG(i, j), binB(i, j));
        end
    end
    
    writeVideo(outputVideo, grayFrame);
end

close(outputVideo);

%% Naloga 5
videoReader = VideoReader('ladja.avi');

frameSample = readFrame(videoReader);
imshow(frameSample);
title('Izberite območje, ki predstavlja tipično barvo morja');

position = round(getrect);
close; 
seaRegion = imcrop(frameSample, position);

numBins = 4; % 4x4x4 histogram
binSize = 256 / numBins;

seaHist = zeros(numBins, numBins, numBins); % Inicializacija 3D histograma za morje

R = seaRegion(:,:,1);
G = seaRegion(:,:,2);
B = seaRegion(:,:,3);
binR = max(ceil(double(R) / binSize), 1); 
binG = max(ceil(double(G) / binSize), 1);
binB = max(ceil(double(B) / binSize), 1);

for i = 1:numel(R)
    seaHist(binR(i), binG(i), binB(i)) = seaHist(binR(i), binG(i), binB(i)) + 1;
end

seaHist = seaHist / sum(seaHist(:));

outputVideo = VideoWriter('morje_histogram_intersection.avi');
open(outputVideo);

videoReader.CurrentTime = 0;


blockSize = 8;

while hasFrame(videoReader)
    frame = readFrame(videoReader); 
    
    grayFrame = zeros(size(frame, 1), size(frame, 2), 'uint8');
    
    for row = 1:blockSize:size(frame, 1) - blockSize + 1
        for col = 1:blockSize:size(frame, 2) - blockSize + 1
           
            block = frame(row:row+blockSize-1, col:col+blockSize-1, :);
            
          
            blockHist = zeros(numBins, numBins, numBins);
            
      
            R = block(:,:,1);
            G = block(:,:,2);
            B = block(:,:,3);
            
            binR = max(ceil(double(R) / binSize), 1); 
            binG = max(ceil(double(G) / binSize), 1);
            binB = max(ceil(double(B) / binSize), 1);
            
      
            for i = 1:numel(R)
                blockHist(binR(i), binG(i), binB(i)) = blockHist(binR(i), binG(i), binB(i)) + 1;
            end
            
      
            blockHist = blockHist / sum(blockHist(:));
            

            intersectionValue = sum(min(blockHist(:), seaHist(:))) * 256; 
            
   
            grayFrame(row:row+blockSize-1, col:col+blockSize-1) = uint8(intersectionValue);
        end
    end
    
 
    writeVideo(outputVideo, grayFrame);
end

close(outputVideo);
==== END Aleksander Rijavec | Aleksander Rijavec_21517_assignsubmission_file | naloga3-aleksanderrijavec.m ====

