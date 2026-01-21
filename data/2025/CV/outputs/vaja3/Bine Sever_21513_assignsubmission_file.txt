==== BEGIN Bine Sever | Bine Sever_21513_assignsubmission_file | vaja3.m ====
websave('yosemite_meadow.jpg', 'https://vision.fe.uni-lj.si/classes/RV/vaje/vaja3/yosemite_meadows.jpg');
websave('coloured_pencils.jpg', 'https://vision.fe.uni-lj.si/classes/RV/vaje/vaja3/coloured_pencils.jpg');
websave('ladja.avi','http://vision.fe.uni-lj.si/classes/RV/vaje/vaja3/ladja.avi');

Slika1RGB = imread('yosemite_meadow.jpg');
figure
imshow(Slika1RGB)
title('Medow RGB')

Slika2RGB = imread('coloured_pencils.jpg');
figure
imshow(Slika2RGB)
title('Pencils RGB')

slikeRGB = {Slika1RGB, Slika2RGB};

%HSV
for i = 1:numel(slikeRGB)
    Slika_HSV = rgb2hsv(slikeRGB{i});

    H = Slika_HSV(:,:,1);
    S = Slika_HSV(:,:,2);
    V = Slika_HSV(:,:,3);

    figure
    imagesc(H);
    colormap(gray);
    title('H')
    figure
    imagesc(S);
    colormap(gray)
    title('S')
    figure
    imagesc(V);
    colormap(gray)
    title('V')


    %LAB
    Slika_LAB = rgb2lab(slikeRGB{i});
    
    L = Slika_LAB(:,:,1);
    A = Slika_LAB(:,:,2);
    B = Slika_LAB(:,:,3);
    
    figure
    imagesc(L);
    colormap(gray)
    title('L')
    figure
    imagesc(A)
    colormap(gray)
    title('A')
    figure
    imagesc(B)
    colormap(gray)
    title('B')
end
%%
%Naloga 2

for i = 1:numel(slikeRGB)
  figure
  for j = 1:3
    HSV_Original = rgb2hsv(slikeRGB{i});
    HSV_Original(:,:,j) = 0.5;
    HSV_Changed = HSV_Original;
    RGB_HSVChanged = hsv2rgb(HSV_Changed);
    subplot(2,3,j)
    image(RGB_HSVChanged);
    if j == 1
        title("HSV H = 0.5")
    elseif j == 2
        title("HSV S = 0.5")
    else
        title("HSV V = 0.5")
    end
  end
  figure
  for j = 1:3
    LAB_Original = rgb2lab(slikeRGB{i});
    if j == 1
        LAB_Original(:,:,j) = 50;
    else
        LAB_Original(:,:,j) = 0;
    end
    LAB_Changed = LAB_Original;
    RGB_LABChanged = lab2rgb(LAB_Changed);
    subplot(2,3,j)
    image(RGB_LABChanged);
    if j == 1
        title("LAB L = 50")
    elseif j == 2
        title("LAB A = 0")
    else
        title("LAB B = 0")
    end
  end
end   


%% 
%Naloga 3
video = VideoReader('ladja.avi');
out_RGB = VideoWriter('RGB_Segmentacija.avi');

frame = read(video, 1);
%imshow(frame);
%title('Izberi značilne točke morja')
pixels_RGB = impixel(frame);

Rmax = max(pixels_RGB(:,1));
Gmax = max(pixels_RGB(:,2));
Bmax = max(pixels_RGB(:,3));

Rmin = min(pixels_RGB(:,1));
Gmin = min(pixels_RGB(:,2));
Bmin = min(pixels_RGB(:,3));

 
open(out_RGB)
for t = 1:video.NumFrames
    frame = read(video,t);
    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);

    mask = R >= Rmin & R <= Rmax & ...
           G >= Gmin & G <= Gmax & ...
           B >= Bmin & B <= Bmax;
    BW = uint8(mask) * 255;   % črno-bela slika
    writeVideo(out_RGB, BW);

end

close(out_RGB);


%% 

frame = read(video, 1);
%imshow(frame)
%title('Prvi okvir videa')
%title('izberi nekaj značilnih točk morja')
frameHSV = rgb2hsv(frame);
pixels_HSV = impixel(frameHSV);

Hmax = max(pixels_HSV(:,1));
Smax = max(pixels_HSV(:,2));
Vmax = max(pixels_HSV(:,3));

Hmin = min(pixels_HSV(:,1));
Smin = min(pixels_HSV(:,2));
Vmin = min(pixels_HSV(:,3));


out_HSV = VideoWriter('HSV_Segmentacija.avi');
open(out_HSV)

for t = 1:video.NumFrames
    frame = read(video,t);
    frame = rgb2hsv(frame);
    H = frame(:,:,1);
    S = frame(:,:,2);
    

    mask = H >= Hmin & H <= Hmax & ...
           S >= Smin & S <= Smax;
    BW_HSV = uint8(mask) * 255;   % črno-bela slika
    writeVideo(out_HSV, BW_HSV);

end

close(out_HSV);

%%
%Naloga 3
video = VideoReader('ladja.avi');
frame = read(video, video.NumFrames);  % uporabi zadnji okvir
%imshow(frame)
%title('Izberi območje morja')
out_H = VideoWriter('MorjeHistogram.avi');
%title("izberi odsek morja")
crop = imcrop(frame);

nBins = 8;
crop = im2double(crop); % [0,1]
R = crop(:,:,1);
G = crop(:,:,2);
B = crop(:,:,3);

% Indeksi binov za ROI
r_idx = ceil(R * nBins);
g_idx = ceil(G * nBins);
b_idx = ceil(B * nBins);

r_idx(r_idx==0) = 1;
g_idx(g_idx==0) = 1;
b_idx(b_idx==0) = 1;

hist3D = zeros(nBins, nBins, nBins);
for i = 1:numel(R)
    r = r_idx(i);
    g = g_idx(i);
    b = b_idx(i);
    hist3D(r,g,b) = hist3D(r,g,b) + 1;
end

% normalizacija: max bin -> 255
hist = hist3D / max(hist3D(:)) * 255;   % double, [0,255]

open(out_H);

for t = 1:video.NumFrames
    frame = read(video,t);
    frame = im2double(frame);

    % Indeksi binov za CEL frame
    r_indx = ceil(frame(:,:,1) * nBins);
    g_indx = ceil(frame(:,:,2) * nBins);
    b_indx = ceil(frame(:,:,3) * nBins);

    r_indx(r_indx == 0) = 1;
    g_indx(g_indx == 0) = 1;
    b_indx(b_indx == 0) = 1;

    outFrame = zeros(size(frame,1), size(frame,2));

    % za vsak piksel: vzemi vrednost pripadajočega bina
    for i = 1:numel(outFrame)
        outFrame(i) = hist(r_indx(i), g_indx(i), b_indx(i));
    end

    % v video zapišemo uint8 sivinsko sliko
    writeVideo(out_H, uint8(outFrame));
end

close(out_H);
%%
video = VideoReader('ladja.avi');
frame = read(video, video.NumFrames);  % uporabi zadnji okvir
imshow(frame)
title('Izberi območje morja')
out_H = VideoWriter('MorjeHistogram.avi');

crop = imcrop(frame);
title("izberi odsek morja")
nBins = 4;
crop = im2double(crop); % [0,1]
R = crop(:,:,1);
G = crop(:,:,2);
B = crop(:,:,3);

% Indeksi binov za ROI
r_idx = ceil(R * nBins);
g_idx = ceil(G * nBins);
b_idx = ceil(B * nBins);

r_idx(r_idx==0) = 1;
g_idx(g_idx==0) = 1;
b_idx(b_idx==0) = 1;

hist3D = zeros(nBins, nBins, nBins);
for i = 1:numel(R)
    r = r_idx(i);
    g = g_idx(i);
    b = b_idx(i);
    hist3D(r,g,b) = hist3D(r,g,b) + 1;
end

% normalizacija: max bin -> 255
hist = hist3D / max(hist3D(:)) * 255;   % double, [0,255]
histSea = hist/sum(hist(:));

blockSize = 8;

out_Hintersection = VideoWriter('Morje_HistIntersection.avi');
open(out_Hintersection);

for t = 1:video.NumFrames
    frame = read(video, t);
    frame = im2double(frame);
    [rows, cols, ~] = size(frame);
    
    outFrame = zeros(rows, cols); % rezultat (svetlost glede na podobnost)
    
    for r = 1:blockSize:rows - mod(rows, blockSize)
        for c = 1:blockSize:cols - mod(cols, blockSize)
            
            % Izreži blok 8×8
            block = frame(r:r+blockSize-1, c:c+blockSize-1, :);
            R = block(:,:,1); G = block(:,:,2); B = block(:,:,3);

            % Histogram bloka
            r_idx = ceil(R * nBins);
            g_idx = ceil(G * nBins);
            b_idx = ceil(B * nBins);

            r_idx(r_idx < 1) = 1; r_idx(r_idx > nBins) = nBins;
            g_idx(g_idx < 1) = 1; g_idx(g_idx > nBins) = nBins;
            b_idx(b_idx < 1) = 1; b_idx(b_idx > nBins) = nBins;

            histBlock = zeros(nBins, nBins, nBins);
            for i = 1:numel(R)
                histBlock(r_idx(i), g_idx(i), b_idx(i)) = histBlock(r_idx(i), g_idx(i), b_idx(i)) + 1;
            end
            %histBlock = histBlock / sum(histSea(:));

            % Izračun preseka histogramov (histogram intersection)
            Presek = sum(min(hist(:), histBlock(:)))/sum(histBlock(:));

            % Pretvori podobnost v 0–255 in shrani v izhodni okvir
            outFrame(r:r+blockSize-1, c:c+blockSize-1) = Presek * 256;
        end
    end
    
    % Pretvori v uint8 in zapiši
    outFrame = uint8(outFrame);
    writeVideo(out_Hintersection, outFrame);
end

close(out_Hintersection);
==== END Bine Sever | Bine Sever_21513_assignsubmission_file | vaja3.m ====

