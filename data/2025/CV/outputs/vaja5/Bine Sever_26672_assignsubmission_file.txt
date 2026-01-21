==== BEGIN Bine Sever | Bine Sever_26672_assignsubmission_file | Vaja5.m ====
websave('Hollywood2.avi', 'http://vision.fe.uni-lj.si/classes/RV/vaje/vaja1/Holywood2-t00427-rgb.avi');
websave('squash.avi', 'http://vision.fe.uni-lj.si/classes/RV/vaje/vaja4/squash.avi');
%%
%Histogram
function H = hist(slika,nBins)
    slika = double(slika) / 255;
    R = slika(:,:,1);
    G = slika(:,:,2);
    B = slika(:,:,3);
    
    r_idx = ceil(R * nBins);
    g_idx = ceil(G * nBins);
    b_idx = ceil(B * nBins);
    
    r_idx(r_idx==0) = 1;
    g_idx(g_idx==0) = 1;
    b_idx(b_idx==0) = 1;
    
    H = zeros(nBins, nBins, nBins);
    for i = 1:numel(R)
        r = r_idx(i);
        g = g_idx(i);
        b = b_idx(i);
        H(r,g,b) = H(r,g,b) + 1;
    end
    H = H/sum(H(:));
end



%%
%%Naloga 1

video_H = VideoReader("Hollywood2.avi");
out_H2_nn = VideoWriter('Hollywood_2nn.avi');
out_H4_nn = VideoWriter('Hollywood_4nn.avi');
out_H8_nn = VideoWriter('Hollywood_8nn.avi');

out_H2_B_On = VideoWriter('Hollywood_2B_On.avi');
out_H4_B_On = VideoWriter('Hollywood_4B_On.avi');
out_H8_B_On = VideoWriter('Hollywood_8B_On.avi');

out_H2_B_Off = VideoWriter('Hollywood_2B_Off.avi');
out_H4_B_Off = VideoWriter('Hollywood_4B_Off.avi');
out_H8_B_Off = VideoWriter('Hollywood_8B_Off.avi');

open(out_H2_nn);
open(out_H4_nn);
open(out_H8_nn);

open(out_H2_B_On);
open(out_H4_B_On);
open(out_H8_B_On);

open(out_H2_B_Off);
open(out_H4_B_Off);
open(out_H8_B_Off);


for t = 1:video_H.NumFrames
    frame = read(video_H,t);

    frame_2_nn = imresize(frame,1/2,'nearest');
    writeVideo(out_H2_nn,frame_2_nn);
    frame_4_nn = imresize(frame,1/4,'nearest');
    writeVideo(out_H4_nn,frame_4_nn);
    frame_8_nn = imresize(frame,1/8,'nearest');
    writeVideo(out_H8_nn,frame_8_nn);

    frame_2_B_On = imresize(frame,1/2,'bilinear',"Antialiasing",true);
    writeVideo(out_H2_B_On,frame_2_B_On);
    frame_4_B_On = imresize(frame,1/4,'bilinear',"Antialiasing",true);
    writeVideo(out_H4_B_On,frame_4_B_On);
    frame_8_B_On = imresize(frame,1/8,'bilinear',"Antialiasing",true);
    writeVideo(out_H8_B_On,frame_8_B_On);

    frame_2_B_Off = imresize(frame,1/2,'bilinear',"Antialiasing",false);
    writeVideo(out_H2_B_Off,frame_2_B_Off);
    frame_4_B_Off = imresize(frame,1/4,'bilinear',"Antialiasing",false);
    writeVideo(out_H4_B_Off,frame_4_B_Off);
    frame_8_B_Off = imresize(frame,1/8,'bilinear',"Antialiasing",false);
    writeVideo(out_H8_B_Off,frame_8_B_Off);
end
close(out_H2_nn)
close(out_H4_nn)
close(out_H8_nn)

close(out_H2_B_On)
close(out_H4_B_On)
close(out_H8_B_On)

close(out_H2_B_Off)
close(out_H4_B_Off)
close(out_H8_B_Off)

%%
%Naloga 2
video = VideoReader("squash.avi");
out = VideoWriter("squash_sledenje.avi");
%sizeX = 8;
%sizeY = 8;
%x0 = 109;
%y0 = 121;
sizeX = 13;
sizeY = 12;
x0 = 105;
y0 = 120;
rect = [x0,y0, sizeX,sizeY];
frame = read(video,1);
izsek = imcrop(frame,rect);
%subplot(1,2,1)
%imshow(frame)
%hold on
%rectangle('Position', rect, 'EdgeColor', 'b', 'LineWidth', 1);
%subplot(1,2,2)
%imshow(izsek);
%impixelinfo;
R_izsek = izsek(:,:,1);
G_izsek = izsek(:,:,2);
B_izsek = izsek(:,:,3);
x_size_izsek = size(izsek,2);
y_size_izsek = size(izsek,1);

rx = 20;
ry = 20;
%size_epsilonX = 40;
%size_epsilonY = 40;
size_epsilonX = 36;
size_epsilonY = 36;
%rectE = [84.5100  103.5100   99   99];
%rectE = [rx+x0 ry+y0 size_epsilonY size_epsilonX];

open(out);
 x0_trenutni = x0;
 y0_trenutni = y0;
 
for  t = 1:video.NumFrames
    frame = read(video,t);
    offset_x = x0_trenutni-rx;
    offset_y = y0_trenutni-ry;
    rectE = [offset_x offset_y size_epsilonY size_epsilonX];
    if numel(rectE) ~= 4
        continue;   % skip this frame
    end
    epsilon = imcrop(frame,rectE);
    R_epsilon = epsilon(:,:,1);
    G_epsilon = epsilon(:,:,2);
    B_epsilon = epsilon(:,:,3);

    x_size_epsilon = size(epsilon,2);
    y_size_epsilon = size(epsilon,1);
    
    %x_blocks = 1:x_size_izsek:x_size_epsilon;
    %y_blocks = 1:y_size_izsek:y_size_epsilon;
    x_blocks = 1:(x_size_epsilon - x_size_izsek + 1);
    y_blocks = 1:(y_size_epsilon - y_size_izsek + 1);
    
    nx = numel(x_blocks);
    ny = numel(y_blocks);

    
    dist = zeros(nx, ny);
        for i = 1:nx
            for j =  1:ny
                xb = x_blocks(i);
                yb = y_blocks(j);

                R_block = R_epsilon(yb:yb+y_size_izsek-1,xb:xb+x_size_izsek-1);
                G_block = G_epsilon(yb:yb+y_size_izsek-1,xb:xb+x_size_izsek-1);
                B_block = B_epsilon(yb:yb+y_size_izsek-1,xb:xb+x_size_izsek-1);
                
                d = (double((R_block-R_izsek).^2 + (G_block-G_izsek).^2 + (B_block-B_izsek).^2));
                dist(i,j) = sqrt(sum(d(:)));
            end
        end
     [minVal,index] = min(dist,[],"All");
     [ix, iy] = ind2sub(size(dist), index);
     x0_trenutni = x_blocks(ix) + offset_x;
     y0_trenutni = y_blocks(iy) + offset_y;

     
     
     %izsek_najden = epsilon(y0_najden:y0_najden+y_size_izsek-1,x0_najden:x0_najden+x_size_izsek-1,:);
     tezisce = [x0_trenutni+x_size_izsek/2 y0_trenutni+y_size_izsek/2];
     imshow(frame)
     r = 25;                        % isti polmer za vse
     imshow(frame)
     hold on
     viscircles(tezisce, r, 'Color','r','LineWidth',1.5);
     %hold on
     %rectangle('Position', rectE, 'EdgeColor', 'b', 'LineWidth', 1);
    
     frame_tracked = getframe(gca);
     hold off;
     writeVideo(out,frame_tracked.cdata)    
end
close(out)


%%
%Naloga 3
video = VideoReader("squash.avi");
out = VideoWriter("squash_sledenje_hist.avi");
sizeX = 13;
sizeY = 12;
x0 = 105;
y0 = 120;
rect = [x0,y0, sizeX,sizeY];
frame = read(video,1);
izsek = imcrop(frame,rect);
%subplot(1,2,1)
%imshow(frame)
%hold on
%rectangle('Position', rect, 'EdgeColor', 'b', 'LineWidth', 1);
%subplot(1,2,2)
%imshow(izsek);
%impixelinfo;
%R_izsek = izsek(:,:,1);
%G_izsek = izsek(:,:,2);
%B_izsek = izsek(:,:,3);
x_size_izsek = size(izsek,2);
y_size_izsek = size(izsek,1);


nbins = 8;
hist_izsek = hist(izsek,nbins);
%hist_izesk_norm = hist_izsek/sum(hist_izsek(:));
rx = 20;
ry = 20;
size_epsilonX = 50;
size_epsilonY = 50;
%rectE = [84.5100  103.5100   99   99];
%rectE = [rx+x0 ry+y0 size_epsilonY size_epsilonX];

open(out);
 x0_trenutni = x0;
 y0_trenutni = y0;
 
for  t = 1:video.NumFrames
    frame = read(video,t);
    offset_x = x0_trenutni-rx;
    offset_y = y0_trenutni-ry;
    rectE = [offset_x offset_y size_epsilonY size_epsilonX];
    if numel(rectE) ~= 4
        continue;   % skip this frame
    end
    epsilon = imcrop(frame,rectE);
    %R_epsilon = epsilon(:,:,1);
    %G_epsilon = epsilon(:,:,2);
    %B_epsilon = epsilon(:,:,3);

    x_size_epsilon = size(epsilon,2);
    y_size_epsilon = size(epsilon,1);
    
    %x_blocks = 1:x_size_izsek:x_size_epsilon;
    %y_blocks = 1:y_size_izsek:y_size_epsilon;
    x_blocks = 1:(x_size_epsilon - x_size_izsek + 1);
    y_blocks = 1:(y_size_epsilon - y_size_izsek + 1);
    
    

     nx = numel(x_blocks);
     ny = numel(y_blocks);
 
    
    dist = zeros(nx, ny);
        for i = 1:nx
            for j =  1:ny
                xb = x_blocks(i);
                yb = y_blocks(j);
                block = epsilon(yb:yb+y_size_izsek-1,xb:xb+x_size_izsek-1,:);
                hist_block = hist(block,nbins);
                hi2 = ((hist_block - hist_izsek).^2)./(hist_izsek+0.00001);
                dist(i,j) = sum(hi2(:));
            end
        end
     [minVal,index] = min(dist(:));
     [ix, iy] = ind2sub(size(dist), index);
     x0_trenutni = x_blocks(ix) + offset_x;
     y0_trenutni = y_blocks(iy) + offset_y;
     
     %izsek_najden = epsilon(y0_najden:y0_najden+y_size_izsek-1,x0_najden:x0_najden+x_size_izsek-1,:);
     tezisce = [x0_trenutni+x_size_izsek/2 y0_trenutni+y_size_izsek/2];
     r = 25;                        % isti polmer za vse
     imshow(frame)
     hold on
     viscircles(tezisce, r, 'Color','r','LineWidth',1.5);
     %hold on
     %rectangle('Position', rectE, 'EdgeColor', 'b', 'LineWidth', 1);
    
     frame_tracked = getframe(gca);
     hold off;
     writeVideo(out,frame_tracked.cdata)    
end
close(out)


%%
%Naloga 4a
video = VideoReader("squash.avi");
out = VideoWriter("squash_sledenje_evklid_ucenje.avi");
sizeX = 8;
sizeY = 8;
x0 = 109;
y0 = 121;
rect = [x0,y0, sizeX,sizeY];
frame = read(video,1);
izsek = imcrop(frame,rect);
%subplot(1,2,1)
%imshow(frame)
%hold on
%rectangle('Position', rect, 'EdgeColor', 'b', 'LineWidth', 1);
%subplot(1,2,2)
%imshow(izsek);
%impixelinfo;
R_izsek = izsek(:,:,1);
G_izsek = izsek(:,:,2);
B_izsek = izsek(:,:,3);
x_size_izsek = size(izsek,2);
y_size_izsek = size(izsek,1);

rx = 20;
ry = 20;
size_epsilonX = 50;
size_epsilonY = 50;
%rectE = [84.5100  103.5100   99   99];
%rectE = [rx+x0 ry+y0 size_epsilonY size_epsilonX];

open(out);
 x0_trenutni = x0;
 y0_trenutni = y0;
 
for  t = 1:video.NumFrames
    frame = read(video,t);
    offset_x = x0_trenutni-rx;
    offset_y = y0_trenutni-ry;

    rect_trenutni = [x0_trenutni,y0_trenutni,sizeX,sizeY];
   
    rectE = [offset_x offset_y size_epsilonY size_epsilonX];
    if (numel(rectE) ~= 4) || (numel(rect_trenutni)  ~= 4)
        continue;   % skip this frame
    end
    
    izsek_trenutni = imcrop(frame,rect_trenutni);
    x_size_izsek = size(izsek_trenutni,2);
    y_size_izsek = size(izsek_trenutni,1);


    R_trenutni = izsek_trenutni(:,:,1);
    G_trenutni = izsek_trenutni(:,:,2);
    B_trenutni = izsek_trenutni(:,:,3);


    epsilon = imcrop(frame,rectE);
    R_epsilon = epsilon(:,:,1);
    G_epsilon = epsilon(:,:,2);
    B_epsilon = epsilon(:,:,3);

    x_size_epsilon = size(epsilon,2);
    y_size_epsilon = size(epsilon,1);
    
    %x_blocks = 1:x_size_izsek:x_size_epsilon;
    %y_blocks = 1:y_size_izsek:y_size_epsilon;
    x_blocks = 1:(x_size_epsilon - x_size_izsek + 1);
    y_blocks = 1:(y_size_epsilon - y_size_izsek + 1);
    
    nx = numel(x_blocks);
    ny = numel(y_blocks);

    
    dist = zeros(nx, ny);
        for i = 1:nx
            for j =  1:ny
                xb = x_blocks(i);
                yb = y_blocks(j);

                R_block = R_epsilon(yb:yb+y_size_izsek-1,xb:xb+x_size_izsek-1);
                G_block = G_epsilon(yb:yb+y_size_izsek-1,xb:xb+x_size_izsek-1);
                B_block = B_epsilon(yb:yb+y_size_izsek-1,xb:xb+x_size_izsek-1);
                
                d = (double((R_block-R_trenutni).^2 + (G_block-G_trenutni).^2 + (B_block-B_trenutni).^2));
                dist(i,j) = sqrt(sum(d(:)));
            end
        end
     [minVal,index] = min(dist,[],"All");
     [ix, iy] = ind2sub(size(dist), index);
     x0_trenutni = x_blocks(ix) + offset_x;
     y0_trenutni = y_blocks(iy) + offset_y;

     
     
     %izsek_najden = epsilon(y0_najden:y0_najden+y_size_izsek-1,x0_najden:x0_najden+x_size_izsek-1,:);
     tezisce = [x0_trenutni+x_size_izsek/2 y0_trenutni+y_size_izsek/2];
     imshow(frame)
     r = 25;                        % isti polmer za vse
     imshow(frame)
     hold on
     viscircles(tezisce, r, 'Color','r','LineWidth',1.5);
     %hold on
     %rectangle('Position', rectE, 'EdgeColor', 'b', 'LineWidth', 1);
    
     frame_tracked = getframe(gca);
     hold off;
     writeVideo(out,frame_tracked.cdata)    
end
close(out)


%%
%Naloga 4b
video = VideoReader("squash.avi");
out = VideoWriter("squash_sledenje_hist_ucenje.avi");
sizeX = 13;
sizeY = 12;
x0 = 105;
y0 = 120;
rect = [x0,y0, sizeX,sizeY];
frame = read(video,1);
izsek = imcrop(frame,rect);
%subplot(1,2,1)
%imshow(frame)
%hold on
%rectangle('Position', rect, 'EdgeColor', 'b', 'LineWidth', 1);
%subplot(1,2,2)
%imshow(izsek);
impixelinfo;
%R_izsek = izsek(:,:,1);
%G_izsek = izsek(:,:,2);
%B_izsek = izsek(:,:,3);
x_size_izsek = size(izsek,2);
y_size_izsek = size(izsek,1);


nbins = 8;
hist_izsek = hist(izsek,nbins);
%hist_izesk_norm = hist_izsek/sum(hist_izsek(:));
rx = 20;
ry = 20;
size_epsilonX = 50;
size_epsilonY = 50;
%rectE = [84.5100  103.5100   99   99];
%rectE = [rx+x0 ry+y0 size_epsilonY size_epsilonX];

open(out);
 x0_trenutni = x0;
 y0_trenutni = y0;
 
for  t = 1:video.NumFrames
    frame = read(video,t);
    offset_x = x0_trenutni-rx;
    offset_y = y0_trenutni-ry;
    rect_trenutni = [x0_trenutni,y0_trenutni,sizeX,sizeY];
   
    rectE = [offset_x offset_y size_epsilonY size_epsilonX];
    if (numel(rectE) ~= 4) || (numel(rect_trenutni)  ~= 4)
        continue;   % skip this frame
    end
    
    izsek_trenutni = imcrop(frame,rect_trenutni);
    x_size_izsek = size(izsek_trenutni,2);
    y_size_izsek = size(izsek_trenutni,1);
    hist_izsek = hist(izsek_trenutni,nbins);

    epsilon = imcrop(frame,rectE);
    %R_epsilon = epsilon(:,:,1);
    %G_epsilon = epsilon(:,:,2);
    %B_epsilon = epsilon(:,:,3);

    x_size_epsilon = size(epsilon,2);
    y_size_epsilon = size(epsilon,1);
    
    %x_blocks = 1:x_size_izsek:x_size_epsilon;
    %y_blocks = 1:y_size_izsek:y_size_epsilon;
    x_blocks = 1:(x_size_epsilon - x_size_izsek + 1);
    y_blocks = 1:(y_size_epsilon - y_size_izsek + 1);
    
    

    nx = numel(x_blocks);
    ny = numel(y_blocks);
 
    
    dist = zeros(nx, ny);
        for i = 1:nx
            for j =  1:ny
                xb = x_blocks(i);
                yb = y_blocks(j);
                block = epsilon(yb:yb+y_size_izsek-1,xb:xb+x_size_izsek-1,:);
                hist_block = hist(block,nbins);
                hi2 = ((hist_block - hist_izsek).^2)./(hist_izsek+0.00001);
                dist(i,j) = sum(hi2(:));
            end
        end
     [minVal,index] = min(dist(:));
     [ix, iy] = ind2sub(size(dist), index);
     x0_trenutni = x_blocks(ix) + offset_x;
     y0_trenutni = y_blocks(iy) + offset_y;
     
     %izsek_najden = epsilon(y0_najden:y0_najden+y_size_izsek-1,x0_najden:x0_najden+x_size_izsek-1,:);
     tezisce = [x0_trenutni+x_size_izsek/2 y0_trenutni+y_size_izsek/2];
     r = 25;                        % isti polmer za vse
     imshow(frame)
     hold on
     viscircles(tezisce, r, 'Color','r','LineWidth',1.5);
     %hold on
     %rectangle('Position', rectE, 'EdgeColor', 'b', 'LineWidth', 1);
    
     frame_tracked = getframe(gca);
     hold off;
     writeVideo(out,frame_tracked.cdata)    
end
close(out)








==== END Bine Sever | Bine Sever_26672_assignsubmission_file | Vaja5.m ====

