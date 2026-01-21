==== BEGIN Lina Josifovska | Lina Josifovska_21506_assignsubmission_file | naloga1.m ====
coloured_pencils = imread('coloured_pencils.jpg');
yosemite_meadows = imread('yosemite_meadows.jpg');

coloured_pencils_HSV = rgb2hsv(coloured_pencils);
yosemite_meadows_HSV = rgb2hsv(yosemite_meadows);

figure; imshow(coloured_pencils); title('Original - Pencils');
figure; imshow(yosemite_meadows); title('Original - Yosemite');

figure; imagesc(coloured_pencils_HSV(:,:,1)); title('Pencils - H (Hue)'), colorbar; colormap(gray);
figure; imagesc(coloured_pencils_HSV(:,:,2)); title('Pencils - S (Saturation)'), colorbar; colormap(gray);
figure; imagesc(coloured_pencils_HSV(:,:,3)); title('Pencils - V (Value)'), colorbar; colormap(gray);
%%
figure; imagesc(yosemite_meadows_HSV(:,:,1)); title('Yosemite - H'), colorbar; colormap(gray);
figure; imagesc(yosemite_meadows_HSV(:,:,2)); title('Yosemite - S'), colorbar; colormap(gray);
figure; imagesc(yosemite_meadows_HSV(:,:,3)); title('Yosemite - V'), colorbar; colormap(gray);

coloured_pencils_LAB = rgb2lab(coloured_pencils);
yosemite_meadows_LAB = rgb2lab(yosemite_meadows);

figure; imagesc(coloured_pencils_LAB(:,:,1)); title('Pencils - L'), colorbar; colormap(gray);
figure; imagesc(coloured_pencils_LAB(:,:,2)); title('Pencils - a'), colorbar; colormap(gray);
figure; imagesc(coloured_pencils_LAB(:,:,3)); title('Pencils - b'), colorbar; colormap(gray);

figure; imagesc(yosemite_meadows_LAB(:,:,1)); title('Yosemite - L'), colorbar; colormap(gray);
figure; imagesc(yosemite_meadows_LAB(:,:,2)); title('Yosemite - a'), colorbar; colormap(gray);
figure; imagesc(yosemite_meadows_LAB(:,:,3)); title('Yosemite - b'), colorbar; colormap(gray);
==== END Lina Josifovska | Lina Josifovska_21506_assignsubmission_file | naloga1.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_21506_assignsubmission_file | naloga2.m ====
coloured_pencils2=imread('coloured_pencils.jpg');

%HSV

coloured_pencils2_HSV=rgb2hsv(coloured_pencils2);
coloured_pencils_HSV_H=coloured_pencils2_HSV;
coloured_pencils_HSV_S=coloured_pencils2_HSV;
coloured_pencils_HSV_V=coloured_pencils2_HSV;

spremeni_H=coloured_pencils2_HSV(:,:,1);
spremeni_S=coloured_pencils2_HSV(:,:,2);
spremeni_V=coloured_pencils2_HSV(:,:,3);

spremeni_H(:,:)=0.5;
spremeni_S(:,:)=0.5;
spremeni_V(:,:)=0.5;

coloured_pencils_HSV_H(:,:,1)=spremeni_H;
coloured_pencils_HSV_S(:,:,2)=spremeni_S;
coloured_pencils_HSV_V(:,:,3)=spremeni_V;

coloured_pencils_H_RGB=hsv2rgb(coloured_pencils_HSV_H);
coloured_pencils_S_RGB=hsv2rgb(coloured_pencils_HSV_S);
coloured_pencils_V_RGB=hsv2rgb(coloured_pencils_HSV_V);
figure; imshow(coloured_pencils_H_RGB);
title('H Fixed');
figure; imshow(coloured_pencils_S_RGB);
title('S Fixed');
figure; imshow(coloured_pencils_V_RGB);
title('V Fixed');

%%
%LAB
coloured_pencils2=imread('coloured_pencils.jpg');
coloured_pencils2_LAB=rgb2lab(coloured_pencils2);
coloured_pencils_LAB_L=coloured_pencils_LAB;
coloured_pencils_LAB_A=coloured_pencils_LAB;
coloured_pencils_LAB_B=coloured_pencils_LAB;

spremeni_L=coloured_pencils2_LAB(:,:,1);
spremeni_A=coloured_pencils2_LAB(:,:,2);
spremeni_B=coloured_pencils2_LAB(:,:,3);

spremeni_L(:,:)=50;
spremeni_A(:,:)=0;
spremeni_B(:,:)=0;

coloured_pencils_LAB_L(:,:,1)=spremeni_L;
coloured_pencils_LAB_A(:,:,2)=spremeni_A;
coloured_pencils_LAB_B(:,:,3)=spremeni_B;

coloured_pencils_L_RGB=lab2rgb(coloured_pencils_LAB_L);
coloured_pencils_A_RGB=lab2rgb(coloured_pencils_LAB_A);
coloured_pencils_B_RGB=lab2rgb(coloured_pencils_LAB_B);
figure; imshow(coloured_pencils_L_RGB)
title('L fixed');
figure; imshow(coloured_pencils_A_RGB)
title('a fixed');
figure; imshow(coloured_pencils_B_RGB)
title('b fixed');
==== END Lina Josifovska | Lina Josifovska_21506_assignsubmission_file | naloga2.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_21506_assignsubmission_file | naloga3.m ====
vidObj = VideoReader('ladja.avi');  
nFrames = vidObj.NumFrames;         
frameExample = read(vidObj,1);      
imshow(frameExample);               
title('Select a ROI that contains the sea');

h = imrect;             
position = round(wait(h)); 
x1 = position(1); y1 = position(2);
w = position(3); hgt = position(4);
roi = frameExample(y1:y1+hgt, x1:x1+w, :);  

roi = im2double(roi);  
R = roi(:,:,1);
G = roi(:,:,2);
B = roi(:,:,3);

Rmin = min(R(:)); Rmax = max(R(:));
Gmin = min(G(:)); Gmax = max(G(:));
Bmin = min(B(:)); Bmax = max(B(:));

fprintf('R range: %.2f - %.2f\n', Rmin, Rmax);
fprintf('G range: %.2f - %.2f\n', Gmin, Gmax);
fprintf('B range: %.2f - %.2f\n', Bmin, Bmax);


outputRGB = VideoWriter('morje_RGB.avi'); 
outputRGB.FrameRate = vidObj.FrameRate;
open(outputRGB);

for k = 1:nFrames
    frame = im2double(read(vidObj,k));
    
    mask = frame(:,:,1) >= Rmin & frame(:,:,1) <= Rmax & ...
           frame(:,:,2) >= Gmin & frame(:,:,2) <= Gmax & ...
           frame(:,:,3) >= Bmin & frame(:,:,3) <= Bmax;
    
    maskRGB = repmat(uint8(mask*255), [1 1 3]);
    
    writeVideo(outputRGB, maskRGB);
end
close(outputRGB);
disp('RGB segmentation finished!');


hsvROI = rgb2hsv(roi);
Hmin = min(hsvROI(:,:,1),[],'all'); Hmax = max(hsvROI(:,:,1),[],'all');
Smin = min(hsvROI(:,:,2),[],'all'); Smax = max(hsvROI(:,:,2),[],'all');

outputHSV = VideoWriter('morje_HSV.avi'); 
outputHSV.FrameRate = vidObj.FrameRate;
open(outputHSV);

for k = 1:nFrames
    frame = im2double(read(vidObj,k));
    hsvFrame = rgb2hsv(frame);
    
    mask = hsvFrame(:,:,1) >= Hmin & hsvFrame(:,:,1) <= Hmax & ...
           hsvFrame(:,:,2) >= Smin & hsvFrame(:,:,2) <= Smax;
       
    maskHSV = repmat(uint8(mask*255), [1 1 3]);
    writeVideo(outputHSV, maskHSV);
end
close(outputHSV);
disp('Konec');
==== END Lina Josifovska | Lina Josifovska_21506_assignsubmission_file | naloga3.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_21506_assignsubmission_file | naloga4.m ====
close all; clc;

vidObj = VideoReader('ladja.avi');
frame1 = im2double(read(vidObj,1));
imshow(frame1); 
title('Izberi ROI za morje');

h = drawrectangle('Color','r');  

disp('Ko končaš z izbiro, pritisni Enter v Command Window');
pause;  

position = round(h.Position); 

roi = frame1(position(2):position(2)+position(4), ...
             position(1):position(1)+position(3), :);

figure; imshow(roi); title('Izbrano območje morja');


nBins = 8; 

R_roi = roi(:,:,1); G_roi = roi(:,:,2); B_roi = roi(:,:,3);

edges = linspace(0,1,nBins+1);

hist3D = zeros(nBins,nBins,nBins);

for i = 1:numel(R_roi)
    rBin = find(R_roi(i) >= edges,1,'last'); rBin = min(rBin,nBins);
    gBin = find(G_roi(i) >= edges,1,'last'); gBin = min(gBin,nBins);
    bBin = find(B_roi(i) >= edges,1,'last'); bBin = min(bBin,nBins);
    hist3D(rBin,gBin,bBin) = hist3D(rBin,gBin,bBin) + 1;
end

hist3D = hist3D / max(hist3D(:)) * 255;

outputHist = VideoWriter('morje_histogram.avi');
open(outputHist);

for k = 1:nFrames
    frame = im2double(read(vidObj,k));
    [rows, cols, ~] = size(frame);
    grayFrame = zeros(rows,cols);
    
    Rf = frame(:,:,1); Gf = frame(:,:,2); Bf = frame(:,:,3);
    
    for i = 1:rows
        for j = 1:cols
            rBin = find(Rf(i,j) >= edges,1,'last'); rBin = min(rBin,nBins);
            gBin = find(Gf(i,j) >= edges,1,'last'); gBin = min(gBin,nBins);
            bBin = find(Bf(i,j) >= edges,1,'last'); bBin = min(bBin,nBins);
            
            grayFrame(i,j) = hist3D(rBin,gBin,bBin); 
        end
    end
    
    grayFrame_uint8 = uint8(grayFrame);
    
    writeVideo(outputHist, grayFrame_uint8);
end

close(outputHist);
disp('Histogram segmentacija končana in shranjena kot morje_histogram.avi');
==== END Lina Josifovska | Lina Josifovska_21506_assignsubmission_file | naloga4.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_21506_assignsubmission_file | naloga5.m ====
close all; clc;

vidObj = VideoReader('ladja.avi');
nFrames = vidObj.NumFrames;

frame1 = im2double(read(vidObj,1));
imshow(frame1); title('Izberi ROI za morje'); 
h = drawrectangle('Color','r'); 
disp('Ko končaš z izbiro, pritisni Enter v Command Window'); pause;
position = round(h.Position);
roi = frame1(position(2):position(2)+position(4), position(1):position(1)+position(3), :);
delete(h);

nBins = 4;
edges = linspace(0,1,nBins+1);
R_roi = roi(:,:,1); G_roi = roi(:,:,2); B_roi = roi(:,:,3);
histROI = zeros(nBins,nBins,nBins);

for i = 1:numel(R_roi)
    rBin = find(R_roi(i) >= edges,1,'last'); rBin = min(rBin,nBins);
    gBin = find(G_roi(i) >= edges,1,'last'); gBin = min(gBin,nBins);
    bBin = find(B_roi(i) >= edges,1,'last'); bBin = min(bBin,nBins);
    histROI(rBin,gBin,bBin) = histROI(rBin,gBin,bBin) + 1;
end

histROI = histROI / sum(histROI(:)); 

blockSize = 8; 
outputHist = VideoWriter('morje_hist_intersection.avi');
open(outputHist);

for k = 1:nFrames
    frame = im2double(read(vidObj,k));
    [rows, cols, ~] = size(frame);
    
    grayFrame = zeros(rows,cols);
    
    for i = 1:blockSize:rows-blockSize+1
        for j = 1:blockSize:cols-blockSize+1
            block = frame(i:i+blockSize-1, j:j+blockSize-1, :);
            
            Rb = block(:,:,1); Gb = block(:,:,2); Bb = block(:,:,3);
            histBlock = zeros(nBins,nBins,nBins);
            
            for p = 1:numel(Rb)
                rBin = find(Rb(p) >= edges,1,'last'); rBin = min(rBin,nBins);
                gBin = find(Gb(p) >= edges,1,'last'); gBin = min(gBin,nBins);
                bBin = find(Bb(p) >= edges,1,'last'); bBin = min(bBin,nBins);
                histBlock(rBin,gBin,bBin) = histBlock(rBin,gBin,bBin) + 1;
            end
            
            histBlock = histBlock / sum(histBlock(:)); 
            
            intersection = sum(min(histROI(:), histBlock(:))); 
            intensity = uint8(intersection * 256); 
            
            grayFrame(i:i+blockSize-1, j:j+blockSize-1) = intensity;
        end
    end
    
    writeVideo(outputHist, uint8(grayFrame));
end

close(outputHist);
disp('Segmentacija po histogram intersection končana, shranjeno kot morje_hist_intersection.avi');
==== END Lina Josifovska | Lina Josifovska_21506_assignsubmission_file | naloga5.m ====

