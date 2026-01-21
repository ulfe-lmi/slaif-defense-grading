==== BEGIN Lovro Perme | Lovro Perme_22774_assignsubmission_file | CV_Vaja4.m ====
%% ====== Naloga 1 =========================================
close all;
clear all;
clc;

hotel = imread('01-Input\hotel.jpg');
hotel_g = double(rgb2gray(hotel));

s_x = [1 0 -1; 2 0 -2; 1 0 -1];     %sobelov konvolucijski filter za x smer
s_y = s_x';                         %sobelov konvolucijski filter za y smer

g_x = imfilter(hotel_g, s_x);
g_y = imfilter(hotel_g, s_y);
g_sobel = sqrt(g_x.^2 + g_y.^2);
f1 = figure;
imshow(uint8(g_sobel));
title('sobelova konvolucija - brez upragovaljanja');

%upragovljanje
g_sobel_t = g_sobel > 200;
g_sobel_t = boolean(g_sobel_t);
f2 = figure;
subplot(1,2,1);
imshow(g_sobel_t);
title('sobelova konvolucija - upragovljena')

g_canny = edge(hotel_g,"canny");
subplot(1,2,2);
imshow(g_canny);
title('Cannyev detektor')

%% ====== Naloga 2 =========================================
clc;

k_acc = -2:(4/400):2;
n_acc = -200:(400/400):200;

%sobel
acc = hough_trans(g_sobel_t, k_acc, n_acc);
f2_2 = figure;
imshow(uint8(acc));
title('akumulator houghove trans. za canny');
n = 10;
[acc_sorted, sorted_idx] = sort(acc(:),"descend");
n_maxes = acc_sorted(1:n);
n_maxes_idx = sorted_idx(1:n);

[max_k_idx, max_n_idx] = ind2sub(size(acc), n_maxes_idx);

f3 = figure;
imshow(g_sobel_t);
title('houghova transformacija na sobelovi sliki');
hold on;

for i = 1:length(max_k_idx)
    fplot(@(x) k_acc(max_k_idx(i))*x + n_acc(max_n_idx(i)), [0, size(g_sobel_t,2)],'LineWidth',1.5);
    ylim([0, size(g_sobel_t,1)]);
end
hold off;

%canny
acc = hough_trans(g_canny, k_acc, n_acc);
f3_2 = figure;
imshow(uint8(acc));
title('akumulator houghove trans. za canny');
n = 10;
[acc_sorted, sorted_idx] = sort(acc(:),"descend");
n_maxes = acc_sorted(1:n);
n_maxes_idx = sorted_idx(1:n);

[max_k_idx, max_n_idx] = ind2sub(size(acc), n_maxes_idx);

f4 = figure;
imshow(g_canny);
title('houghova transformacija na cannyevi sliki');
hold on;

for i = 1:length(max_k_idx)
    fplot(@(x) k_acc(max_k_idx(i))*x + n_acc(max_n_idx(i)), [0, size(g_canny,2)],'LineWidth',1.5);
    ylim([0, size(g_canny,1)]);
end
hold off;

function acc = hough_trans(bin_pic, k_vector, n_vector)
    acc = zeros(length(k_vector), length(n_vector));
    for i = 1 : size(bin_pic,2)
        for j = 1 : size(bin_pic,1)
            if bin_pic(j,i)
                for k_idx = 1 : length(k_vector)
                    n = -i * k_vector(k_idx) + j;
                    n = round(n);
                    if n >= -200 && n <= 200
                        n_idx = (n + 200) * 400/400 + 1;
                        acc(k_idx, n_idx) = acc(k_idx, n_idx) + 1;
                    end
                end
            end
        end
    end
end

%% ====== Naloga 3,4,5 =========================================
clc;


squash_obj = VideoReader('01-Input\squash.avi');
squash = read(squash_obj);

squash_fps = squash(:,:,:,1:10:end);

background = mode(squash_fps,4);
f5 = figure;
imshow(background);
title('izločeno ozadje videa');
hold on;
[border_x, border_y] = ginput(2);   %da območja okrog igrišča ne bomo računali -> eliminiramo premikanje gledalcev
border_x = round(border_x);
border_y = round(border_y);
plot([border_x(1), border_x(2), border_x(2), border_x(1), border_x(1)], [border_y(1), border_y(1), border_y(2), border_y(2), border_y(1)], '-r'); % izris pravokotnika

diff = zeros(size(squash_fps,1), size(squash_fps,2), size(squash_fps,4));

for i = 1 : size(squash, 4)
    diff(border_y(1):border_y(2),border_x(1):border_x(2),i) = sqrt(sum((squash(border_y(1):border_y(2),border_x(1):border_x(2),:,i) - background(border_y(1):border_y(2),border_x(1):border_x(2),:)).^2, 3));
end

f6 = figure;
imagesc(diff(:,:,1));
colorbar;

diff_t = diff > 15;

diff_morph = zeros(size(diff_t));
for i = 1 : size(squash, 4)
    diff_morph(:,:,i) = bwmorph(diff_t(:,:,i),'erode',1); 
    diff_morph(:,:,i) = bwmorph(diff_morph(:,:,i),'open',1);       
    diff_morph(:,:,i) = bwmorph(diff_morph(:,:,i),'dilate',5);
    diff_morph(:,:,i) = bwmorph(diff_morph(:,:,i),'close',1);
end

diff_morph = boolean(diff_morph);


writer_object = VideoWriter('02-Output\squash_tracked.avi');
writer_object.FrameRate = squash_obj.FrameRate;
writer_object.Quality = 100;
open(writer_object);


diff_labeled = zeros(size(diff_morph));
player1_centroid = zeros(2,size(squash, 4));
player2_centroid = zeros(2,size(squash, 4));
for i = 1 : size(squash, 4)
    diff_labeled(:,:,i) = bwlabel(diff_morph(:,:,i));
    region_data = regionprops(diff_labeled(:,:,i),'Centroid', 'Area');
    
    if size(region_data,1) >= 2
        [~, idx] = maxk([region_data.Area], 2);
        player1_centroid(:,i) = region_data(idx(1)).Centroid;
        player2_centroid(:,i) = region_data(idx(2)).Centroid;
    else
        player1_centroid(:,i) = region_data(1).Centroid;
        player2_centroid(:,i) = player1_centroid(:,i);
    end
    
    centers = [
    player1_centroid(:,i).'
    player2_centroid(:,i).'
    ];   
    radii = [20; 20];
    new_frame = insertShape(squash(:,:,:,i), 'circle',[centers radii], 'Color', 'red','LineWidth', 2);
    

    player1_centroid(:,i) = round(player1_centroid(:,i));
    player2_centroid(:,i) = round(player2_centroid(:,i));
    region1 = rgb2hsv(squash(player1_centroid(2,i)-10:player1_centroid(2,i)+10, player1_centroid(1,i)-10:player1_centroid(1,i)+10,:,i));
    region2 = rgb2hsv(squash(player2_centroid(2,i)-10:player2_centroid(2,i)+10, player2_centroid(1,i)-10:player2_centroid(1,i)+10,:,i));
    
    meanHue1 = mean(region1(:, :, 1), 'all');
    meanSaturation1 = mean(region1(:, :, 2), 'all');
    meanValue1 = mean(region1(:, :, 3), 'all');

    meanHue2 = mean(region2(:, :, 1), 'all');
    meanSaturation2 = mean(region2(:, :, 2), 'all');
    meanValue2 = mean(region2(:, :, 3), 'all');
    
    if meanSaturation1 > meanSaturation2
        new_frame = insertText(new_frame(:,:,:), centers(1,:) + [0 -40; 0 -40],'RDEČ IGRALEC','TextColor', 'red', 'FontSize', 10, 'BoxOpacity', 0);
        new_frame = insertText(new_frame(:,:,:), centers(2,:) + [0 -40; 0 -40],'BEL IGRALEC','TextColor', 'red', 'FontSize', 10, 'BoxOpacity', 0);
    elseif meanSaturation2 > meanSaturation1
        new_frame = insertText(new_frame(:,:,:), centers(2,:) + [0 -40; 0 -40],'RDEČ IGRALEC','TextColor', 'red', 'FontSize', 10, 'BoxOpacity', 0);
        new_frame = insertText(new_frame(:,:,:), centers(1,:) + [0 -40; 0 -40],'BEL IGRALEC','TextColor', 'red', 'FontSize', 10, 'BoxOpacity', 0);
    else
        new_frame = insertText(new_frame(:,:,:), centers(1,:) + [0 -40; 0 -40],'NERAZLOČNO','TextColor', 'red', 'FontSize', 10, 'BoxOpacity', 0);
        new_frame = insertText(new_frame(:,:,:), centers(2,:) + [0 -40; 0 -40],'NERAZLOČNO','TextColor', 'red', 'FontSize', 10, 'BoxOpacity', 0);
    end  
    writeVideo(writer_object, new_frame);
end

close(writer_object);




==== END Lovro Perme | Lovro Perme_22774_assignsubmission_file | CV_Vaja4.m ====

