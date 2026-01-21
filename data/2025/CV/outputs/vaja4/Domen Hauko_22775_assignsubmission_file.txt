==== BEGIN Domen Hauko | Domen Hauko_22775_assignsubmission_file | drawLines.m ====
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
    for widthVar=1:numel(j)
        image(j,i,1)=255;
        image(j,i,2)=0;
        image(j,i,3)=0;
    end
end
end
figure('Name',Operator);imshow(image);
==== END Domen Hauko | Domen Hauko_22775_assignsubmission_file | drawLines.m ====

==== BEGIN Domen Hauko | Domen Hauko_22775_assignsubmission_file | vaja4_Turk_Hauko.m ====
%% 1. sobel, canny

hotel = imread("hotel.jpg");
hotelRGB = hotel;
hotel = rgb2gray(hotel);
hotel = double(hotel);

Sx = [1 0 -1;
      2 0 -2;
      1 0 -1];
Sy = [1 2 1;
      0 0 0;
      -1 -2 -1];


Gx = conv2(hotel,Sx, 'valid'); % 'same' ohrani velikost slike
Gy = conv2(hotel,Sy, 'valid');
G = sqrt(Gx.^2 + Gy.^2);
th = 200;
G_bin = (G > th);

figure;
subplot(2,2,1);
imshow(Gx, []); % [] normalizira
title('Sobel X');

subplot(2,2,2);
imshow(Gy, []);
title('Sobel Y');

subplot(2,2,3);
imshow(G, []);
title('G');

subplot(2,2,4);
imshow(G_bin);
title('G binarna');

% primerjava sobel in canny
canny = edge(hotel, "Canny");

figure;
subplot(1,2,1);
imshow(G_bin);
title("Sobel");

subplot(1,2,2);
imshow(canny);
title("Canny");


%% 2. Hough

sobel = G_bin;
akumulator_sobel = my_hough(sobel);
akumulator_canny = my_hough(canny);


figure;
subplot(1,2,1);
imshow(akumulator_sobel,[]);
title("Akumulator Sobel");

subplot(1,2,2);
imshow(akumulator_canny,[]);
title("Akumulator Canny");

N = 5;
drawLines(hotelRGB, akumulator_sobel, N,'Sobel');
drawLines(hotelRGB, akumulator_canny, N,'Canny');


%% 3. pridobivanje ozadja

squash = VideoReader("squash.avi");
num_frames = squash.NumFrames;

oneFrame = read(squash, 1);
[h, w, c] = size(oneFrame);

frames = zeros(h, w, c, numel(1:20:num_frames), 'uint8');
i = 1;

for i_frame = 1:20:num_frames
    frames(:,:,:,i) = read(squash, i_frame);
    i = i + 1;
end

% mode ali mediana oba delata
background = mode(frames,4); % modus - najbolj pogost piksel
figure;
imshow(background);


%% 4. detekcija podrocij in morfoloske operacije

squash = VideoReader("squash.avi");

squash_res = VideoWriter("squash_res.avi");
squash_res.FrameRate = squash.FrameRate;   % enak fps kot original
open(squash_res);

bg_double = double(background);

%figure;
%hImg = imagesc(zeros(size(bg_double,1), size(bg_double,2))); % empty image
%colormap gray;
%colorbar;
%title('Slika razlike (evklidska razdalja)');

while hasFrame(squash)
    frameRGB = readFrame(squash);
    frame    = double(frameRGB);  
    
    diff = frame - bg_double; % (H x W x 3)
    razlika = sqrt(sum(diff.^2, 3)); 

    %set(hImg, 'CData', razlika);
    %drawnow;   % refresh figure
    
    mask = (razlika >= 60);
    
    mask = bwmorph(mask, 'open'); % remove specks
    mask = bwmorph(mask, 'majority'); % denoise / smooth
    mask = bwmorph(mask, 'close'); % connect nearby pixels
    mask = bwmorph(mask, 'fill'); % fill small holes
    mask = bwmorph(mask, 'clean'); % remove isolated pixels again


    [label, num] = bwlabel(mask, 8);
    if num > 0
        % label - binarna slika obmocij, area - koliko pikslov v vsaki regiji, bounding box - x,y,w,h
        stats  = regionprops(label, 'Area', 'BoundingBox'); 
        areas  = [stats.Area];
        [~, order] = sort(areas, 'descend');

        % iscemo dve najvecji regiji - dva igralca
        % ce ni naslo dveh igralcev narisemo samo enega
        K = min(2, num);   
        boxes = cat(1, stats(order(1:K)).BoundingBox); 

        for k = 1:K
            frameRGB = insertShape(frameRGB, ...
                'Rectangle', boxes(k,:), ...
                'Color', 'red', ...
                'LineWidth', 3);
        end
    end

    % zapis z markerji
    writeVideo(squash_res, frameRGB);
end
close(squash_res);


%% detekcija na podlagi barve


squash = VideoReader("squash.avi");

squash_res_barve = VideoWriter("squash_res_barve.avi");
squash_res_barve.FrameRate = squash.FrameRate;   % enak fps kot original
open(squash_res_barve);

bg_double = double(background);


while hasFrame(squash)
    frameRGB = readFrame(squash);
    frame    = double(frameRGB);  
    
    diff = frame - bg_double; % (H x W x 3)
    razlika = sqrt(sum(diff.^2, 3)); 

    
    mask = (razlika >= 60);
    
    mask = bwmorph(mask, 'open');
    mask = bwmorph(mask, 'majority');
    mask = bwmorph(mask, 'close');
    mask = bwmorph(mask, 'fill');
    mask = bwmorph(mask, 'clean');

    % RGB mask ima vrednost 0 za ozadje in vrednost RGB kjer so igralci
    RGB_mask = frameRGB;
    for c = 1:3
        RGB_mask(:,:,c) = frameRGB(:,:,c) .* uint8(mask);
    end

    [label, num] = bwlabel(mask, 8);
    if num >= 2
        % label - binarna slika obmocij, area - koliko pikslov v vsaki regiji, bounding box - x,y,w,h
        stats  = regionprops(label, 'Area', 'BoundingBox'); 
        areas  = [stats.Area];
        [~, order] = sort(areas, 'descend');

        % iscemo dve najvecji regiji - dva igralca
        % ce ni naslo dveh igralcev narisemo samo enega
        K = 2;   
        boxes = cat(1, stats(order(1:K)).BoundingBox); 

        scores = zeros(K,1);
        for k = 1:K
            x1 = round(boxes(k,1));
            y1 = round(boxes(k,2));
            w = round(boxes(k,3));
            h = round(boxes(k,4));
            
            x2 = min(size(frameRGB,2), x1 + w);
            y2 = min(size(frameRGB,1), y1 + h);
            x1 = max(1, x1);
            y1 = max(1, y1);
        
            % zanima nas regija znotraj bounding boxa
            % znotraj bounding boxa je ozadje izloceno (RGB_mask)
            roi = RGB_mask(y1:y2, x1:x2, :);
        
            % sum of RGB values inside the box
            R = sum(roi(:,:,1), 'all');
            G = sum(roi(:,:,2), 'all');
            B = sum(roi(:,:,3), 'all');

            scores(k) = R / (R+G+B);
        end

        % rdec bo imel visje razmerje rdecega kanala z vsemi piksli
        [~, idx] = sort(scores, 'descend');
        idx_red   = idx(1);
        idx_white = idx(2);

        frameRGB = insertShape(frameRGB, ...
            'Rectangle', boxes(idx_white,:), ...
            'Color', 'white', ...
            'LineWidth', 3);
        
        frameRGB = insertText(frameRGB, ...
            boxes(idx_white,1:2), 'Player A', ...
            'TextColor', 'white', 'BoxOpacity', 0);
        
        frameRGB = insertShape(frameRGB, ...
            'Rectangle', boxes(idx_red,:), ...
            'Color', 'red', ...
            'LineWidth', 3);
        
        frameRGB = insertText(frameRGB, ...
            boxes(idx_red,1:2), 'Player B', ...
            'TextColor', 'red', 'BoxOpacity', 0);
    end

    writeVideo(squash_res_barve, frameRGB);
end
close(squash_res_barve);


%%

function akumulator = my_hough(edges)

    k = linspace(-2, 2, 401);

    akumulator = zeros(401, 401); % 401 x 401
    
    
    for y=1:size(edges,1)
        for x=1:size(edges,2)
    
            if edges(y,x) ~= 0
                for i_k = 1:length(k)
                    n = -x* k(i_k) + y;
                    if n > 200 || n < -200
                        continue
                    end
                    i_n = round(n + 201);
                    akumulator(i_k, i_n) = akumulator(i_k, i_n) + 1;
                end
                
            end
        end
    end

end
==== END Domen Hauko | Domen Hauko_22775_assignsubmission_file | vaja4_Turk_Hauko.m ====

