==== BEGIN Boris Jovanović | Boris Jovanović_23622_assignsubmission_file | drawLines.m ====
% Function: drawLines
% Author: Marija Ivanovska
% Description: This function draws N lines with maximum number of votes,
% defined by Hough transformation.
% Usage example:
% hotelRGB=imread('hotel.jpg'); % input image
% N = 5; % number of lines we want to draw
% HoughSpace = HoughTransform(BinaryImage)
% drawLines(hotelRGB,HoughSpace,N,'Sobel');
function []=drawLines(image,HoughSpace,N,Operator)
k=-2:0.01:2;
n=-200:1:200;
maximum=zeros(N,2);
for p=1:N % (k,n)
[max1,index]=max(HoughSpace);
[max2,columnId]=max(max1);
rowId=index(columnId);
maximum(p,1)=k(rowId);
maximum(p,2)=n(columnId);
HoughSpace(rowId,columnId)=0;
for i=1:481
    j=round(k(rowId)*i+n(columnId));
    for widthVar=1:size(j)
        image(j,i,1)=255;
        image(j,i,2)=0;
        image(j,i,3)=0;
    end
end
end
figure('Name',Operator);imshow(image);
==== END Boris Jovanović | Boris Jovanović_23622_assignsubmission_file | drawLines.m ====

==== BEGIN Boris Jovanović | Boris Jovanović_23622_assignsubmission_file | RV_LV_4.m ====
%% Naloga 1:
slika = imread('hotel.jpg');       
sivinska = rgb2gray(slika);     
%imshow(sivinska);

% Sobelov operator
Sx = [1 0 -1; 2 0 -2; 1 0 -1];     % Horizontalni filter
Sy = [1 2 1; 0 0 0; -1 -2 -1];     % Vertikalni filter

% Konvolucija 
Gx = conv2(double(sivinska), Sx); % Horizontalni gradient
Gy = conv2(double(sivinska), Sy); % Vertikalni gradient

% Magnituda gradientov
G = sqrt(Gx .^ 2 + Gy .^ 2);         

% Upragovljenje 
threshold = 200;                   
G_sobel = G > threshold;

% Cannyjev detektor
G_canny = edge(sivinska, 'Canny'); 

% Prikaz rezultatov
figure;
subplot(1, 3, 1);
imshow(sivinska);
title('Originalna sivinska slika');

subplot(1, 3, 2);
imshow(G_sobel);
title('Sobelov operator ');

subplot(1, 3, 3);
imshow(G_canny);
title('Cannyjev detektor');

 
%% Naloga 2:
% Sobel
N = 3;  % Število premic
st_delov = 401; 

k = linspace(-2, 2, st_delov); 
n = linspace(-200, 200, st_delov);  

% Inicializacija akumulatorja
akumulator_sobel = zeros(size(k,2), size(n,2));

% Glasovanje v Houghovem prostoru za Sobel
for i = 10:size(G_sobel, 1)-10
    for j = 10:size(G_sobel, 2)-10
        if G_sobel(i, j) == 1 %piksel je del roba
            for l = 1:401
                for m = 1:401
                    % y = k * j + n 
                    y_pred = round(k(l) * j + n(m));
                    if y_pred == i
                        akumulator_sobel(l, m) = akumulator_sobel(l, m) + 1;
                    end
                end
            end
        end
    end
end

figure;
imshow(akumulator_sobel / max(max(akumulator_sobel))); %največja vrednost v matriki
title('Houghov prostor (Sobel)');

% Izris premic 
drawLines(slika, akumulator_sobel, N, 'Sobel');

%% Canny
akumulator_canny = zeros(size(k,2), size(n,2));
N=5;
k = linspace(-2, 2, 401);
n = linspace(-200, 200, 401);

for i = 10:size(G_canny, 1)-10
    for j = 10:size(G_canny, 2)-10
        if G_canny(i, j) == 1
            for l = 1:401
                for m = 1:401
                    % Izračunaj vrednost y = k * j(x) + n za vsako točko
                    y_pred = round(k(l) * j + n(m));
                    if y_pred == i
                        akumulator_canny(l, m) = akumulator_canny(l, m) + 1;
                    end
                end
            end
        end
    end
end

figure;
imshow(akumulator_canny / max(max(akumulator_canny))); %največja vrednost v matriki
title('Houghov prostor (Canny)');

% Izris premic na izvirno sliko
drawLines(slika, akumulator_canny, N, 'Canny');

%% Naloga 3:
video = VideoReader('squash.avi');

% Parametri za izbiro slik
n = 10; % vsaka 10 slika
frames = 80; % skupno število slik 

% dimenzije
vidHeight = video.Height;
vidWidth = video.Width;

% 4D matika
frame_stack = zeros(vidHeight, vidWidth, 3, frames, 'uint8');

frame_idx = 1;
for i = 1:n:frames*n
    video.CurrentTime = (i-1) / video.FrameRate; %dobis s, kdaj se slika nahaja v videu
    frame = readFrame(video);
    frame_stack(:,:,:,frame_idx) = frame;
    frame_idx = frame_idx + 1;
end

% Izračun mediane po dimenziji-4.
ozadje = median(frame_stack, 4);

ozadje = uint8(ozadje);
figure;
imshow(ozadje);
title('Izračunano ozadje z median filtrom');
imwrite(ozadje, 'ozadje.png');

%% Naloga 4:
video = VideoReader('squash.avi');
ozadje = imread('ozadje.png');

% Parametri
threshold = 60; 
outputVideo = VideoWriter('igralci.avi');
open(outputVideo);

while hasFrame(video)
    frame = readFrame(video);
    
    % Izračun evklidske razdalje med sliko in ozadjem
    diff = sqrt(sum((double(frame) - double(ozadje)).^2, 3));

    % Binarizacija s pragom
    binaryImage = diff > threshold;
    
    % morfološke operacije
    binaryImage = bwmorph(binaryImage, 'open'); % odstrani manjše povezane komponente, erozija+dilacija
    binaryImage = bwmorph(binaryImage, 'clean'); % odstrani 'izoliran piksel'
    binaryImage = bwmorph(binaryImage, 'majority'); % piksli se nastavijo glede na večino sosednjih vrednosti.
    
    % Iskanje povezanih komponent
    labeledImage = bwlabel(binaryImage);
    stats = regionprops(labeledImage, 'Centroid', 'Area'); %geometrijske lastnosti povezanih komponent
    
    % Preverimo, če imamo vsaj dve komponenti
    if numel(stats) >= 2
        % Iskanje dveh največjih področij (igralcev)
        [~, idx] = maxk([stats.Area], 2); % % dve največji področji
        centroid1 = stats(idx(1)).Centroid;
        centroid2 = stats(idx(2)).Centroid;
        
        circles = [centroid1, 20; centroid2, 20]; % Središče in radij kroga
        
        % Dodaj sliko v izhodni video z označenimi krogi
        frameWithCircles = insertShape(frame, 'Circle', circles, ...
                                       'Color', 'red', 'LineWidth', 3);
    else
        % Če ni dovolj komponent, samo prikažemo trenutni okvir brez sprememb
        frameWithCircles = frame;
    end
    
    % Zapis v izhodni video
    writeVideo(outputVideo, frameWithCircles);
end

close(outputVideo);

%% Naloga 5:
video = VideoReader('squash.avi');
ozadje = imread('ozadje.png'); 

threshold = 40; 
outputVideo = VideoWriter('igralci_barva.avi'); 
open(outputVideo);

frame = readFrame(video);
imshow(frame);
title('Kliknite na dve točki za barvo majic');
[x, y] = ginput(2); % dve točki na sliki

% RGB vrednosti 
selectedColorA = reshape(frame(round(y(1)), round(x(1)), :), 1, 3); 
selectedColorB = reshape(frame(round(y(2)), round(x(2)), :), 1, 3);

disp('Barve za igralca A (rdeči):');
disp(['R: ', num2str(selectedColorA(1)), ', G: ', num2str(selectedColorA(2)), ', B: ', num2str(selectedColorA(3))]);

disp('Barve za igralca B (beli):');
disp(['R: ', num2str(selectedColorB(1)), ', G: ', num2str(selectedColorB(2)), ', B: ', num2str(selectedColorB(3))]);

while hasFrame(video)
    frame = readFrame(video);
    
    % Izračun evklidske razdalje med sliko in ozadjem
    diff = sqrt(sum((double(frame) - double(background)).^2, 3));
    binaryImage = diff > threshold;
    
    % Morfološke operacije 
    binaryImage = bwmorph(binaryImage, 'open'); % odstrani manjše povezane komponente, erozija+dilacija
    binaryImage = bwmorph(binaryImage, 'clean'); % odstrani 'izoliran piksel'
    binaryImage = bwmorph(binaryImage, 'majority'); % Piksli se nastavijo glede na večino sosednjih vrednosti.
    
    % Igralec A
    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);
    
    tolerance = 35; % Toleranca za barve
    binaryA = (R >= (selectedColorA(1) - tolerance) & R <= (selectedColorA(1) + tolerance)) & ...
              (G >= (selectedColorA(2) - tolerance) & G <= (selectedColorA(2) + tolerance)) & ...
              (B >= (selectedColorA(3) - tolerance) & B <= (selectedColorA(3) + tolerance));
    binaryA = uint8(binaryA) * 255;
    
    % Igralec B
    binaryB = (R >= (selectedColorB(1) - tolerance) & R <= (selectedColorB(1) + tolerance)) & ...
              (G >= (selectedColorB(2) - tolerance) & G <= (selectedColorB(2) + tolerance)) & ...
              (B >= (selectedColorB(3) - tolerance) & B <= (selectedColorB(3) + tolerance));
    binaryB = uint8(binaryB) * 255;
    
    % Morfološke operacije 
    binaryA = bwmorph(binaryA, 'open'); % odstrani manjše povezane komponente, erozija+dilacija
    binaryB = bwmorph(binaryB, 'open'); % odstrani manjše povezane komponente, erozija+dilacija

    % Iskanje povezanih komponent za igralca A in B
    labeledA = bwlabel(binaryA);
    labeledB = bwlabel(binaryB);
    
    %geometrijske lastnosti povezanih komponent
    statsA = regionprops(labeledA, 'Centroid', 'Area');
    statsB = regionprops(labeledB, 'Centroid', 'Area');
    
    if ~isempty(statsA) && ~isempty(statsB) %da nista prazna
        % Iskanje dveh največjih področij 
        [~, idxA] = max([statsA.Area]);
        [~, idxB] = max([statsB.Area]);
        
        centroidA = statsA(idxA).Centroid;
        centroidB = statsB(idxB).Centroid;
        
        % oznaci igralca
        frameWithCircles = insertShape(frame, 'Circle', [centroidA, 30], ...
                                       'Color', 'red', 'LineWidth', 3);
        frameWithCircles = insertShape(frameWithCircles, 'Circle', [centroidB, 30], ...
                                       'Color', 'white', 'LineWidth', 3);
        
        frameWithCircles = insertText(frameWithCircles, centroidA, 'A', 'FontSize', 18, 'TextColor', 'red');
        frameWithCircles = insertText(frameWithCircles, centroidB, 'B', 'FontSize', 18, 'TextColor', 'white');
    else
        % Če ni dovolj komponent, samo prikažemo trenutni okvir brez sprememb
        frameWithCircles = frame;
    end
    
    writeVideo(outputVideo, frameWithCircles);
end

close(outputVideo);
==== END Boris Jovanović | Boris Jovanović_23622_assignsubmission_file | RV_LV_4.m ====

