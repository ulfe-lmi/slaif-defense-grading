==== BEGIN Lovro Perme | Lovro Perme_21519_assignsubmission_file | CV_Vaja3.m ====
%% Naloga 1:
close all;
clear all;
clc;

pencils = imread('01-Input\coloured_pencils.jpg');
yosemite = imread('01-Input\yosemite_meadows.jpg');
pencils_hsv = rgb2hsv(pencils);
yosemite_hsv = rgb2hsv(yosemite);

f1 = figure;
image(repmat(pencils_hsv(:,:,1),[1,1,3]));

f2 = figure;
image(repmat(pencils_hsv(:,:,2),[1,1,3]));

f3 = figure;
image(repmat(pencils_hsv(:,:,3),[1,1,3]));

f4 = figure;
image(repmat(yosemite_hsv(:,:,1),[1,1,3]));

f5 = figure;
image(repmat(yosemite_hsv(:,:,2),[1,1,3]));

f6 = figure;
image(repmat(yosemite_hsv(:,:,3),[1,1,3]));

pause;

%% Naloga 2:
close all;
clear all;
clc;

pencils = imread('01-Input\coloured_pencils.jpg');
yosemite = imread('01-Input\yosemite_meadows.jpg');
pencils_hsv = rgb2hsv(pencils);
yosemite_hsv = rgb2hsv(yosemite);
pencils_lab = rgb2lab(pencils);
yosemite_lab = rgb2lab(yosemite);

pencils_max_hue = pencils_hsv;
pencils_max_hue(:,:,1) = 0.5;
f1 = figure;
image(hsv2rgb(pencils_max_hue));

pencils_max_sat = pencils_hsv;
pencils_max_sat(:,:,2) = 0.5;
f2 = figure;
image(hsv2rgb(pencils_max_sat));

pencils_max_val = pencils_hsv;
pencils_max_val(:,:,3) = 0.5;
f3 = figure;
image(hsv2rgb(pencils_max_val));

yosemite_max_hue = yosemite_hsv;
yosemite_max_hue(:,:,1) = 0.5;
f4 = figure;
image(hsv2rgb(yosemite_max_hue));

yosemite_max_sat = yosemite_hsv;
yosemite_max_sat(:,:,2) = 0.5;
f5 = figure;
image(hsv2rgb(yosemite_max_sat));

yosemite_max_val = yosemite_hsv;
yosemite_max_val(:,:,3) = 0.5;
f6 = figure;
image(hsv2rgb(yosemite_max_val));


pencils_max_lum = pencils_lab;
pencils_max_lum(:,:,1) = 50;
f7 = figure;
image(lab2rgb(pencils_max_lum));

pencils_max_a = pencils_lab;
pencils_max_a(:,:,2) = 0;
f8 = figure;
image(lab2rgb(pencils_max_a));

pencils_max_b = pencils_lab;
pencils_max_b(:,:,3) = 0;
f9 = figure;
image(lab2rgb(pencils_max_b));

yosemite_max_lum = yosemite_lab;
yosemite_max_lum(:,:,1) = 50;
f10 = figure;
image(lab2rgb(yosemite_max_lum));

yosemite_max_a = yosemite_lab;
yosemite_max_a(:,:,2) = 0;
f11 = figure;
image(lab2rgb(yosemite_max_a));

yosemite_max_b = yosemite_lab;
yosemite_max_b(:,:,3) = 0;
f12 = figure;
image(lab2rgb(yosemite_max_b));

pause;

%% Naloga 3:
close all;
clear all;
clc;

video_obj = VideoReader('01-Input\ladja.avi');
video = read(video_obj);
video_hsv = zeros(size(video), 'double');
for i = 1:size(video, 4)
    video_hsv(:,:,:,i) = rgb2hsv(video(:,:,:,i));
end


% za ročno ugotavljanje mej
% image(repmat(video(:,:,1,30),[1 1 3]));
treshold_r = video(:,:,1,30) < 85 & video(:,:,1,30) > 20;
f2 = figure;
image(repmat(treshold_r,[1 1 3]));

treshold_g = video(:,:,2,30) < 100 & video(:,:,2,30) > 20;
f3 = figure;
image(repmat(treshold_g,[1 1 3]));

treshold_b = video(:,:,3,30) < 100 & video(:,:,3,30) > 20;
f4 = figure;
image(repmat(treshold_b,[1 1 3]));

treshold_rgb = treshold_r & treshold_g & treshold_b;
f5 = figure;
image(repmat(treshold_rgb,[1 1 3]));

video_tresh_rgb = zeros(size(video), 'double');
for i = 1:size(video, 4)
    video_tresh_rgb(:,:,1,i) = video(:,:,1,i) < 85 & video(:,:,1,i) > 20;
    video_tresh_rgb(:,:,2,i) = video(:,:,2,i) < 100 & video(:,:,2,i) > 20;
    video_tresh_rgb(:,:,3,i) = video(:,:,3,i) < 100 & video(:,:,3,i) > 20;
end
video_mask = video_tresh_rgb(:,:,1,:) & video_tresh_rgb(:,:,2,:) & video_tresh_rgb(:,:,3,:);
writer_object = VideoWriter('02-Output\ladja_treshold_rgb.avi');
writer_object.FrameRate = video_obj.FrameRate;
writer_object.Quality = 100;
open(writer_object)
writeVideo(writer_object, uint8(video_mask * 255))
close(writer_object)

%za ročno ugotavljanje
% image(repmat(video_hsv(:,:,1,30),[1 1 3]));
treshold_hue = video_hsv(:,:,1,30) < 0.50 & video_hsv(:,:,1,30) > 0.3;
f6 = figure;
image(repmat(treshold_hue,[1 1 3]));

treshold_val = video_hsv(:,:,3,30) < 0.50 & video_hsv(:,:,3,30) > 0.2;
f7 = figure;
image(repmat(treshold_val,[1 1 3]));

treshold_hsv = treshold_hue & treshold_val;
f8 = figure;
image(repmat(treshold_hsv,[1 1 3]));

video_tresh_hsv = zeros(size(video), 'double');
for i = 1:size(video, 4)
    video_tresh_hsv(:,:,1,i) = video_hsv(:,:,1,i) < 0.50 & video_hsv(:,:,1,i) > 0.3;
    video_tresh_hsv(:,:,3,i) = video_hsv(:,:,3,i) < 0.50 & video_hsv(:,:,3,i) > 0.2;
end

video_mask = video_tresh_hsv(:,:,1,:) & video_tresh_hsv(:,:,3,:);
writer_object = VideoWriter('02-Output\ladja_treshold_hsv.avi');
writer_object.FrameRate = video_obj.FrameRate;
writer_object.Quality = 100;
open(writer_object)
writeVideo(writer_object, uint8(video_mask * 255))
close(writer_object)

pause;
%% Naloga 4:
close all;
clear all;
clc;

video_obj = VideoReader('01-Input\ladja.avi');
video = read(video_obj);
video = double(video);
sea_section = video(300:449, 1:399,:,30);

num_bins = 8;
step = 256/num_bins;

R_idx = floor(sea_section(:,:,1) / step) + 1;
G_idx = floor(sea_section(:,:,2) / step) + 1;
B_idx = floor(sea_section(:,:,3) / step) + 1;

rgb_bins = accumarray([R_idx(:), G_idx(:), B_idx(:)], 1, [num_bins num_bins num_bins]);

hist_section = round(rgb_bins / (max(rgb_bins(:))/255));

f2 = figure;
[x,y,z] = ndgrid(1:num_bins,1:num_bins,1:num_bins);
scatter3(x(:), y(:), z(:), 100, hist_section(:), 'filled');
xlabel('R'); ylabel('G'); zlabel('B');
colormap(sky);
colorbar;
axis equal;

video_gray = zeros(size(video, 1), size(video, 2), 1, size(video, 4));


for n = 1:size(video, 4)
    R_idx = floor(video(:,:,1,n) / step) + 1;
    G_idx = floor(video(:,:,2,n) / step) + 1;
    B_idx = floor(video(:,:,3,n) / step) + 1;

    for i = 1:size(video, 1)
        for j = 1:size(video, 2)
            video_gray(i, j, 1, n) = hist_section(R_idx(i,j), G_idx(i,j), B_idx(i,j));
        end
    end
end

video_gray = repmat(video_gray, [1, 1, 3, 1]);

writer_object = VideoWriter('02-Output\video_gray_histogram.avi');
writer_object.FrameRate = video_obj.FrameRate;
writer_object.Quality = 100;
open(writer_object)
writeVideo(writer_object, uint8(video_gray))
close(writer_object)


%% Naloga 5:
close all;
clear all;
clc;

video_obj = VideoReader('01-Input\ladja.avi');
video = read(video_obj);
sea_section = video(300:449, 1:399,:,30);
f1 = image(sea_section);
video = double(video);
sea_section = double(sea_section);

num_bins = 4;
step = 256/num_bins;

R_idx = floor(sea_section(:,:,1) / step) + 1;
G_idx = floor(sea_section(:,:,2) / step) + 1;
B_idx = floor(sea_section(:,:,3) / step) + 1;

rgb_bins = accumarray([R_idx(:), G_idx(:), B_idx(:)], 1, [num_bins num_bins num_bins]);

hist_section = rgb_bins / sum(rgb_bins(:));

f2 = figure;
[x,y,z] = ndgrid(1:num_bins,1:num_bins,1:num_bins);
scatter3(x(:), y(:), z(:), 100, hist_section(:), 'filled');
xlabel('R'); ylabel('G'); zlabel('B');
colormap(sky);
colorbar;
axis equal;



video_razlika_hist = zeros(size(video, 1), size(video, 2), 1, size(video, 4));


for n = 1:size(video, 4)
    section_count = 0;  
    section_x = 8;
    while section_x <= size(video, 1)
        section_y = 8;
        while section_y <= size(video, 2)
            section8 = video((section_x - 7):section_x,(section_y - 7):section_y,:,n);
            section_count = section_count + 1;     
            
            R_idx = floor(section8(:,:,1) / step) + 1;
            G_idx = floor(section8(:,:,2) / step) + 1;
            B_idx = floor(section8(:,:,3) / step) + 1;
    
            rgb_bins = accumarray([R_idx(:), G_idx(:), B_idx(:)], 1, [num_bins num_bins num_bins]);
            rgb_bins = rgb_bins / sum(rgb_bins(:));
            presek = hist_presek(rgb_bins, hist_section);
    
            video_razlika_hist((section_x - 7):section_x, (section_y - 7):section_y, 1, n) = presek;

            section_y = section_y + 8;
            
        end
        section_x = section_x + 8;
    end
end

video_razlika_hist = repmat(video_razlika_hist, [1, 1, 3, 1]);

writer_object = VideoWriter('02-Output\video_razlika_histogram.avi');
writer_object.FrameRate = video_obj.FrameRate;
writer_object.Quality = 100;
open(writer_object)
writeVideo(writer_object, uint8(video_razlika_hist))
close(writer_object)

function presek = hist_presek(hist, ref_hist)
    presek = sum(min(hist(:), ref_hist(:)));
    presek = presek * 255;
end
==== END Lovro Perme | Lovro Perme_21519_assignsubmission_file | CV_Vaja3.m ====

