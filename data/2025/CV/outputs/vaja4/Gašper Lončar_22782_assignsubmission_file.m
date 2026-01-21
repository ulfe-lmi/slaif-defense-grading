==== BEGIN Gašper Lončar | Gašper Lončar_22782_assignsubmission_file | drawLines.m ====
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
==== END Gašper Lončar | Gašper Lončar_22782_assignsubmission_file | drawLines.m ====

==== BEGIN Gašper Lončar | Gašper Lončar_22782_assignsubmission_file | RVlab4.m ====
%% 4. vaja 1. naloga
hotel = imread("hotel.jpg");
hotel_siv = rgb2gray(hotel);
hotel_siv = im2double(hotel_siv);

sobelX = [1 0 -1; 2 0 -2; 1 0 -1];
sobelY = [1 2 1; 0 0 0; -1 -2 -1];

gradX = conv2(hotel_siv, sobelX,'same');
gradY = conv2(hotel_siv, sobelY, 'same');

grad = sqrt(gradX.^2 + gradY.^2);
binarn = graythresh(grad);  % prag od 0 do 1
sobel = grad >= binarn;

canny = edge(hotel_siv,"canny", [0.05 0.15], 1.2);  % sigma na koncu

figure; 
subplot(1,2,1); imshow(sobel);
subplot(1,2,2); imshow(canny);

%% hough transform
hotel2d_canny = canny;
hotel2d_sobel = sobel;

k = -2:0.01:2;
n = -200:1:200;
Nk = length(k);
Nn = length(n);

H_prostor = zeros(Nk,Nn);
[visina, sirina] = size(hotel2d_canny);

[x, y] = meshgrid(1:sirina, 1:visina);
stolpci = x(hotel2d_canny);
vrstice = y(hotel2d_canny);

robovi = 0.5:1:(Nn+0.5);
for i = 1:Nk
    stevecN = vrstice - k(i).*stolpci;      % n = y 'kx
    indexN = round(stevecN - n(1) + 1);     % od 1 do Nn
    maska = (indexN >= 1) & (indexN <= Nn);
    stevec = histcounts(indexN(maska), robovi);
    H_prostor(i, :) = H_prostor(i, :) + stevec;
end

figure; imagesc(n, k, H_prostor); axis xy; xlabel('n'); ylabel('k'); colorbar;


N = 5; % number of lines we want to draw
%H_prostor = HoughTransform(hotel);
drawLines(hotel,H_prostor,N,'Canny');
==== END Gašper Lončar | Gašper Lončar_22782_assignsubmission_file | RVlab4.m ====

==== BEGIN Gašper Lončar | Gašper Lončar_22782_assignsubmission_file | RVlab4_video.m ====
%% RV4_video
C=VideoReader('squash.avi');
orig_okvirji=read(C,[1 Inf]);
video_size=size(orig_okvirji);
st_frameov=video_size(4);
korak = 10;
index = 1:korak:st_frameov;
N = numel(index);


% prazna tabelca velikosti videa za število frameov
okvirji = orig_okvirji(:,:,:, index); 
ozadje = zeros(video_size(1), video_size(2), 3, 'uint8');

for i =1:3
    M = reshape(okvirji(:,:,i,:), video_size(1)*video_size(2),N);
    m = mode(M, 2);     % najbolj pogosti
    ozadje(:,:,i) = reshape(uint8(m), video_size(1), video_size(2));
end

imshow(ozadje); imwrite(ozadje,'ozadje.png');

%% 4. naloga

[visina, sirina, ~, st_frameov] = size(orig_okvirji);

% slika razlike od ozadja
prvi_frame = orig_okvirji(:,:,:,1);
evklidska_razlika = sqrt(sum((double(prvi_frame) - double(ozadje)).^2, 3));
prag = max(30, 0.35 * max(evklidska_razlika(:)));

figure; imshow(prvi_frame); impixelinfo;

figure; imagesc(evklidska_razlika); colormap gray; axis image; colorbar;

% video z označenima igralcema (kvadratki)
vid_id = VideoWriter('squash_identiteta.avi');
vid_id.FrameRate = C.FrameRate;
open(vid_id);

r = 5;  % polmer kvadrata

% ignoriramo območje na levi strani igrišča z navijači
rob = round(0.1*sirina);
roiMaska = true(visina, sirina);
roiMaska(:,1:rob) = false;

% identiteta
ident = false;
rdec = [255 0 0];
bel = [255 255 255];

for i = 1:st_frameov
    okvir = orig_okvirji(:,:,:,i);                          % RGB uint8 okvir

    % slika evklidske razlike 
    evd_raz = sqrt(sum((double(okvir) - double(ozadje)).^2, 3));

    % morfologije
    BW = evd_raz > prag;
    BW = bwmorph(BW, 'clean');        % odstrani osamljene piksle (sol)
    BW = bwmorph(BW, 'majority');     % večinsko glasovanje (gladi šum)
    BW = bwmorph(BW, 'close');        % morfološko zapiranje (zapre reže)
    BW = bwmorph(BW, 'fill');         % zapolni luknje znotraj objektov
    BW = bwmorph(BW, 'spur', 2);      % odstrani kratke "resice" (2 iteraciji)

    BW = BW & roiMaska;

    % 2 največji razliki za detekcijo
    [L, num] = bwlabel(BW, 8);
    Fout = okvir;

    if num > 0
        S = regionprops(L, 'Area', 'Centroid', 'PixelIdxList');

        % vzemi največji 2 področji
        [~, idx] = maxk([S.Area], min(2,num));

        R_delta = 85;   % R mora biti toliko večji od G in B za rdeče
        R_min = 140;    % minimalna R 
        B_min = 120;    % minimalna svetlost za belo
        B_max = 30;

        R = double(okvir(:,:,1));
        G = double(okvir(:,:,2));
        B = double(okvir(:,:,3));

        for k = 1:numel(idx)
            c = round(S(idx(k)).Centroid);  % [x y]
            cx = max(1, min(sirina, c(1)));
            cy = max(1, min(visina, c(2)));

            % majhen kvadratek v težišču
            x1 = max(1, cx - r); x2 = min(sirina, cx + r);
            y1 = max(1, cy - r); y2 = min(visina, cy + r);

            piksel = S(idx(k)).PixelIdxList;
            Rm = mean(R(piksel));
            Gm = mean(G(piksel));
            Bm = mean(B(piksel));
            I = (Rm+Gm+Bm)/3;
            razl = max([Rm,Gm,Bm]) - min([Rm,Gm,Bm]);

            jeRdec = (Rm > Gm + R_delta) && (Rm > Bm + R_delta) && (Rm > R_min);
            jeBel = (I > B_min) && (razl < B_max);

            if isRed
                barva = rdec;   
            elseif isWhite
                barva = bel; 
            else
                % po večjem R ali po svetlosti
                if (Rm - max(Gm,Bm)) > 15
                    barva = rdec;
                else
                barva = bel;
                end
            end

            Fout(y1:y2, x1:x2, 1) = barva(1);          
            Fout(y1:y2, x1:x2, 2) = barva(2);
            Fout(y1:y2, x1:x2, 3) = barva(3);
        end
    end
    
    writeVideo(vid_id, Fout);

end

close(vid_id);
==== END Gašper Lončar | Gašper Lončar_22782_assignsubmission_file | RVlab4_video.m ====

