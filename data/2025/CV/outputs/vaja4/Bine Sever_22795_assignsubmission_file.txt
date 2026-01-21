==== BEGIN Bine Sever | Bine Sever_22795_assignsubmission_file | drawLines.m ====
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
==== END Bine Sever | Bine Sever_22795_assignsubmission_file | drawLines.m ====

==== BEGIN Bine Sever | Bine Sever_22795_assignsubmission_file | Vaja4.m ====
websave('hotel.jpg', 'https://vision.fe.uni-lj.si/classes/RV/vaje/vaja4/hotel.jpg');
websave('squash.avi', 'http://vision.fe.uni-lj.si/classes/RV/vaje/vaja4/squash.avi');

%%
%Naloga 1
Sx = [1 0 -1;
     2 0 -2;
     1 0 -1];

Sy = [1 2 1;
     0 0 0;
     -1 -2 -1];

hotelRGB = imread('hotel.jpg');
hotelGray = rgb2gray(hotelRGB);
figure
imshow(hotelGray);

Gx = conv2(hotelGray,Sx,"valid");
Gy = conv2(hotelGray,Sy,"valid");
G = sqrt(Gx.^2 + Gy.^2);
t = 200;
mask = G > t;
soble_blackwhite = uint8(mask)*255;
figure
subplot(1,2,1)
imshow(soble_blackwhite);
title('Sobel')

subplot(1,2,2)
cannyHotel = edge(hotelGray,'canny');
imshow(cannyHotel);
title('Canny')

%%
%Naloga 2 Sobel
k = -2:0.01:2;
n = -200:1:200;

sizeK = numel(k);
sizeN = numel(n);

akumulator_sobel = zeros(sizeK, sizeN);

[rows, cols] = size(soble_blackwhite);

for ik = 1:sizeK
    for in = 1:sizeN
        for x = 1:cols
            for y = 1:rows
                if soble_blackwhite(y,x) == 255
                    y_premica = k(ik)*x + n(in);

                    if y == round(y_premica)
                        akumulator_sobel(ik, in) = akumulator_sobel(ik, in) + 1;
                    end
                end
            end
        end
    end
end


akumluator_sobel_norm = akumulator_sobel/max(akumulator_sobel,[],'All');
akumulator_sivinski_sobel = uint8(ceil(akumluator_sobel_norm*255));
figure
imshow(akumulator_sivinski_sobel)
impixelinfo;
%%
hotelRGB=imread('hotel.jpg');
N = 5; % number of lines we want to draw
HoughSpace = akumulator_sobel;
drawLines(hotelRGB,HoughSpace,N,'Sobel');

%%
%Naloga 2 Canny
k = -2:0.01:2;
n = -200:1:200;

sizeK = numel(k);
sizeN = numel(n);

akumulator = zeros(sizeK, sizeN);

[rows, cols] = size(cannyHotel);

for ik = 1:sizeK
    for in = 1:sizeN
        for x = 1:cols
            for y = 1:rows
                if cannyHotel(y,x) == 1
                    y_premica = k(ik)*x + n(in);
                    if y == round(y_premica)
                        akumulator(ik,in) = akumulator(ik,in) + 1; 
                    end
                end
            end
        end
    end
end

%%
akumluator_norm = akumulator/max(akumulator,[],'All');
akumulator_sivinsko = uint8(ceil(akumluator_norm*255));
figure
imshow(akumulator_sivinsko)
impixelinfo;
title("Canny akumulator")
%%
hotelRGB=imread('hotel.jpg');
N = 5; % number of lines we want to draw
HoughSpace = akumulator;
drawLines(hotelRGB,HoughSpace,N,'Canny');


%%%%%%%%%%%%%%%%%%
%% 3.naloga

video = VideoReader('squash.avi');
frame_idx = round(linspace(1,video.NumFrames,80));
numberofframes = numel(frame_idx);
[rows,cols,colour] = size(read(video,1));
frames = zeros(rows,cols,colour,numberofframes);
%frames = uint8(frames);

for i = 1:numberofframes
    frame = double(read(video,frame_idx(i)));
    frames(:,:,:,i) = frame;
end

ozadje = mode(frames,4);
ozadje = uint8(ozadje);


imshow(ozadje)
%%
% Naloga 4
video = VideoReader('squash.avi');
x0 = 52.51;
y0 = 39.51;
width = 296.98;
height = 208.98;
ROI = [x0 y0 width height];
Offset = [x0,y0];

ozadje_crop = imcrop(ozadje,ROI);
R_ozadje = ozadje_crop(:,:,1);
G_ozadje = ozadje_crop(:,:,2);
B_ozadje = ozadje_crop(:,:,3);


out_dist = VideoWriter('Distance.avi');


open(out_dist);
for t = 1:video.NumFrames
    frame = read(video,t);
    frameCrop = imcrop(frame,ROI);
    R = frameCrop(:,:,1);
    G = frameCrop(:,:,2);
    B = frameCrop(:,:,3);
    
    r = sqrt((double(R_ozadje-R)).^2 + (double(G_ozadje-G)).^2 + (double(B_ozadje-B)).^2);
    T = 18;
    mask = r > T;
    mask = bwmorph(mask,'clean');
    mask = bwmorph(mask,'open');
    mask = bwmorph(mask,'close');
    mask = bwmorph(mask,'open');
    mask = bwmorph(mask,'close');
    [L, num] = bwlabel(mask, 8);
    Lvis = zeros(size(L),'uint8');
    Lvis(L == 1) = 100;
    Lvis(L == 2) = 255;
    
    
    stats = regionprops(L, 'Centroid','Area','BoundingBox');% en vnos v stats na vsak label > 0
    areas = [stats.Area];                          % 1×N double
    [AreaSize, Stat_indx] = sort(areas, 'descend');
    if  numel(Stat_indx) >= 2
        igralca = [stats(Stat_indx(1)),stats(Stat_indx(2))];
    else
        igralca = [stats(Stat_indx(1))];
    end

   
   
    r = 25;                        % isti polmer za vse
    imshow(frame)
    hold on
    for k = 1:numel(igralca)
        c = igralca(k).Centroid + Offset(1:2);
        if k ==1
            viscircles(c, r, 'Color','r','LineWidth',1.5);
        elseif k == 2
            viscircles(c, r, 'Color','w','LineWidth',1.5);
        end
    end
    
    frame_tracked = getframe(gca);
    hold off;
    writeVideo(out_dist,frame_tracked.cdata)
end
close(out_dist);


%%
% Naloga 5
video = VideoReader('squash.avi');
x0 = 52.51;
y0 = 39.51;
width = 296.98;
height = 208.98;
ROI = [x0 y0 width height];
Offset = [x0,y0];

ozadje_crop = imcrop(ozadje,ROI);
R_ozadje = ozadje_crop(:,:,1);
G_ozadje = ozadje_crop(:,:,2);
B_ozadje = ozadje_crop(:,:,3);


R2_min = 115;
G2_min = 34;
B2_min = 44;
R2_max = 190;
G2_max = 80;
B2_max = 90;


out = VideoWriter('Squash_Segment.avi');

open(out);
for t = 1:video.NumFrames
    frame = read(video,t);
    frameCrop = imcrop(frame,ROI);
    R = frameCrop(:,:,1);
    G = frameCrop(:,:,2);
    B = frameCrop(:,:,3);
    
    r = sqrt((double(R_ozadje-R)).^2 + (double(G_ozadje-G)).^2 + (double(B_ozadje-B)).^2);
    T = 10;
    mask = r > T;
    mask = bwmorph(mask,'clean');
    mask = bwmorph(mask,'open');
    mask = bwmorph(mask,'close');
    mask = bwmorph(mask,'open');
    mask = bwmorph(mask,'close');

    R = double(frameCrop(:,:,1));
    G = double(frameCrop(:,:,2));
    B = double(frameCrop(:,:,3));


   maskB_color = (R >= R2_min & R <= R2_max) & ...
           (G >= G2_min & G <= G2_max) & ...
             (B >= B2_min & B <= B2_max);
    

   maskaB_final = mask & maskB_color;
   %maskA = mask &~ maskB_color;
   %subplot(1,3,1)
   %imshow(maskA);
   %subplot(1,3,2)
   %imshow(maskB_color);
   %subplot(1,3,3)
   %imshow(mask);



    [L, numA] = bwlabel(mask, 8);
    [LB, numB] = bwlabel(maskaB_final, 8);
    
    
    
    stats = regionprops(L, 'Centroid','Area');   % en vnos v stats na vsak label > 0
    areas = [stats.Area];                          % 1×N double
    [AreaSize, Stat_indx] = sort(areas, 'descend');

    statsB = regionprops(LB, 'Centroid','Area');   % en vnos v stats na vsak label > 0
    areasB = [statsB.Area];                          % 1×N double
    [AreaSizeB, Stat_indxB] = sort(areasB, 'descend');

    cRed = statsB(Stat_indxB(1)).Centroid;

   
    
    if numel(Stat_indx) < 2
        cA = stats(Stat_indx(1)).Centroid + Offset;
        cB = cA;
    else
         % centroida dveh največjih globalnih objektov
        c1 = stats(Stat_indx(1)).Centroid;
        c2 = stats(Stat_indx(2)).Centroid;
        
        % razdalji do rdečega
        dst1 = norm(c1 - cRed);
        dst2 = norm(c2 - cRed); 
         if dst1 > dst2
            cA = stats(Stat_indx(1)).Centroid + Offset;
            cB = stats(Stat_indx(2)).Centroid + Offset;
        elseif dst1 < dst2
            cA = stats(Stat_indx(2)).Centroid + Offset;
            cB = stats(Stat_indx(1)).Centroid + Offset; 
        end

    end




   
    r = 25;                        % isti polmer za vse
    imshow(frame)
    hold on
        
    viscircles(cA, r, 'Color','w','LineWidth',1.5);
    viscircles(cB, r, 'Color','r','LineWidth',1.5);
    
    frame_tracked = getframe(gca);
    hold off;
    writeVideo(out,frame_tracked.cdata)
end
close(out);



==== END Bine Sever | Bine Sever_22795_assignsubmission_file | Vaja4.m ====

