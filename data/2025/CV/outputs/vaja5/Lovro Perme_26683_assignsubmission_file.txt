==== BEGIN Lovro Perme | Lovro Perme_26683_assignsubmission_file | CV_Vaja5.m ====
%% ====== Naloga 1 =========================================
clc;
close;

video = VideoReader('01-Input\holywood.avi');
holywood = read(video);

methods = ["nearest", "bilinear", "bilinear"];
antialiasings = [false, false, true];

holywood_half = zeros(size(holywood,1)*0.5, size(holywood,2)*0.5, size(holywood,3), size(holywood,4));
holywood_quarter = zeros(size(holywood,1)*0.25, size(holywood,2)*0.25, size(holywood,3), size(holywood,4));
holywood_eighth = zeros(size(holywood,1)*0.125, size(holywood,2)*0.125, size(holywood,3), size(holywood,4));

for j = 1 : length(methods)
    method = methods(j);
    antialiasing = antialiasings(j);

    for i = 1 : size(holywood, 4)
        holywood_half(:,:,:,i) = imresize(holywood(:,:,:,i), 0.5, method,"Antialiasing",antialiasing);
        holywood_quarter(:,:,:,i) = imresize(holywood(:,:,:,i), 0.25, method,"Antialiasing",antialiasing);
        holywood_eighth(:,:,:,i) = imresize(holywood(:,:,:,i), 0.125, method,"Antialiasing",antialiasing);
    end
    out_filename = sprintf('02-Output\\holywood_half_%s_antialising_%d.avi', method, antialiasing);
    writer_object = VideoWriter(out_filename);
    writer_object.FrameRate = holywood_obj.FrameRate;
    writer_object.Quality = 100;
    open(writer_object);
    writeVideo(writer_object, uint8(holywood_half))
    close(writer_object)

    out_filename = sprintf('02-Output\\holywood_quarter_%s_antialising_%d.avi', method, antialiasing);
    writer_object = VideoWriter(out_filename);
    writer_object.FrameRate = holywood_obj.FrameRate;
    writer_object.Quality = 100;
    open(writer_object);
    writeVideo(writer_object, uint8(holywood_quarter))
    close(writer_object)

    out_filename = sprintf('02-Output\\holywood_eighth_%s_antialising_%d.avi', method, antialiasing);
    writer_object = VideoWriter(out_filename);
    writer_object.FrameRate = holywood_obj.FrameRate;
    writer_object.Quality = 100;
    open(writer_object);
    writeVideo(writer_object, uint8(holywood_eighth))
    close(writer_object)
end

%% ====== Naloga 2_1 =========================================
clc;
close;

video = VideoReader('01-Input\squash.avi');
squash = read(video);

imshow(squash(:,:,:,1));
title('Z 2 točkama pravokotnika označi igralca');
hold on;
[box_x, box_y] = ginput(2);
box_x = round(box_x);
box_y = round(box_y);

location = [round((box_x(1) + box_x(2))/2), round((box_y(1) + box_y(2))/2)];

okolica = 25;   %kvadratna okolica, na kateri iščemo poizicjo igralca

znacilka  = squash(box_y(1):box_y(2),box_x(1):box_x(2),:,1);
znacilka_velikost = size(znacilka);

razdalja = inf(size(squash, 1), size(squash, 2));

writer_object = VideoWriter('02-Output\squash_evklidska.avi');
writer_object.FrameRate = video.FrameRate;
writer_object.Quality = 100;
open(writer_object);

min_x = ceil(znacilka_velikost(2)/2);
max_x = floor(size(squash, 2) - znacilka_velikost(2)/2);
min_y = ceil(znacilka_velikost(1)/2);
max_y = floor(size(squash, 1) - znacilka_velikost(1)/2);

for frame = 1 : size(squash, 4)
    % da negremo čez robove slike
    start_x = max(location(1) - okolica, min_x) + 1; 
    end_x   = min(location(1) + okolica, max_x) + 1;
    
    start_y = max(location(2) - okolica, min_y) + 1;
    end_y   = min(location(2) + okolica, max_y) + 1;

    for x = start_x : end_x
        for y = start_y : end_y
            izsek = squash(y - floor(znacilka_velikost(1)/2) : y + ceil(znacilka_velikost(1)/2) - 1, x - floor(znacilka_velikost(2)/2) : x + ceil(znacilka_velikost(2)/2) - 1, :, frame);
        
            razlika = double(izsek) - double(znacilka);
            razdalja(y,x) = sum(razlika(:).^2);            
        end
    end

    [min_val, idx] = min(razdalja(:));
    [y_idx, x_idx] = ind2sub(size(razdalja), idx);
    location = [x_idx, y_idx];
    razdalja = inf(size(squash, 1), size(squash, 2));
    
    new_frame = insertShape(squash(:,:,:,frame), 'circle',[location 20], 'Color', 'red','LineWidth', 2);
    writeVideo(writer_object, new_frame);
end

close(writer_object);


%% ====== Naloga 2_2 =========================================
clc;
close;

video = VideoReader('01-Input\squash.avi');
squash = read(video);

imshow(squash(:,:,:,1));
title('Z 2 točkama pravokotnika označi igralca');
hold on;
[box_x, box_y] = ginput(2);
box_x = round(box_x);
box_y = round(box_y);

location = [round((box_x(1) + box_x(2))/2), round((box_y(1) + box_y(2))/2)];

okolica = 25;   %kvadratna okolica, na kateri iščemo poizicjo igralca
hist_bins = 8;

znacilka  = squash(box_y(1):box_y(2),box_x(1):box_x(2),:,1);
znacilka_velikost = size(znacilka);
znacilka_hist = get_histogram(znacilka, hist_bins);

razdalja = inf(size(squash, 1), size(squash, 2));

writer_object = VideoWriter('02-Output\squash_chi_squared.avi');
writer_object.FrameRate = video.FrameRate;
writer_object.Quality = 100;
open(writer_object);

min_x = ceil(znacilka_velikost(2)/2);
max_x = floor(size(squash, 2) - znacilka_velikost(2)/2);
min_y = ceil(znacilka_velikost(1)/2);
max_y = floor(size(squash, 1) - znacilka_velikost(1)/2);

for frame = 1 : size(squash, 4)
    % da negremo čez robove slike
    start_x = max(location(1) - okolica, min_x) + 1; 
    end_x   = min(location(1) + okolica, max_x) + 1;
    
    start_y = max(location(2) - okolica, min_y) + 1;
    end_y   = min(location(2) + okolica, max_y) + 1;

    for x = start_x : end_x
        for y = start_y : end_y
            izsek = squash(y - floor(znacilka_velikost(1)/2) : y + ceil(znacilka_velikost(1)/2) - 1, x - floor(znacilka_velikost(2)/2) : x + ceil(znacilka_velikost(2)/2) - 1, :, frame);
            izsek_hist = get_histogram(izsek, hist_bins);

            h1 = double(znacilka_hist(:));
            h2 = double(izsek_hist(:));
            
            varnost = 1e-10;    %da preprečimo deljenje z 0
            razlika = 0.5 * sum((h1 - h2).^2 ./ (h1 + h2 + varnost));            
            razdalja(y,x) = razlika;         
        end
    end

    [min_val, idx] = min(razdalja(:));
    [y_idx, x_idx] = ind2sub(size(razdalja), idx);
    location = [x_idx, y_idx];
    razdalja = inf(size(squash, 1), size(squash, 2));
    
    new_frame = insertShape(squash(:,:,:,frame), 'circle',[location 20], 'Color', 'red','LineWidth', 2);
    writeVideo(writer_object, new_frame);
end

close(writer_object);


%% ====== Naloga 3 =========================================
clc;
close;

video = VideoReader('01-Input\squash.avi');
squash = read(video);

imshow(squash(:,:,:,1));
title('Z 2 točkama pravokotnika označi igralca');
hold on;
[box_x, box_y] = ginput(2);
box_x = round(box_x);
box_y = round(box_y);

location = [round((box_x(1) + box_x(2))/2), round((box_y(1) + box_y(2))/2)];

okolica = 25;   %kvadratna okolica, na kateri iščemo poizicjo igralca
hist_bins = 8;
learning_rate = 0.1;     % x*100% se vzame novega histograma - da omejimo drift  

znacilka  = squash(box_y(1):box_y(2),box_x(1):box_x(2),:,1);
znacilka_velikost = size(znacilka);
znacilka_hist = get_histogram(znacilka, hist_bins);

razdalja = inf(size(squash, 1), size(squash, 2));

writer_object = VideoWriter('02-Output\squash_chi_squared_learn.avi');
writer_object.FrameRate = video.FrameRate;
writer_object.Quality = 100;
open(writer_object);

min_x = ceil(znacilka_velikost(2)/2);
max_x = floor(size(squash, 2) - znacilka_velikost(2)/2);
min_y = ceil(znacilka_velikost(1)/2);
max_y = floor(size(squash, 1) - znacilka_velikost(1)/2);

for frame = 1 : size(squash, 4)
    % da negremo čez robove slike
    start_x = max(location(1) - okolica, min_x) + 1; 
    end_x   = min(location(1) + okolica, max_x) + 1;
    
    start_y = max(location(2) - okolica, min_y) + 1;
    end_y   = min(location(2) + okolica, max_y) + 1;

    for x = start_x : end_x
        for y = start_y : end_y
            izsek = squash(y - floor(znacilka_velikost(1)/2) : y + ceil(znacilka_velikost(1)/2) - 1, x - floor(znacilka_velikost(2)/2) : x + ceil(znacilka_velikost(2)/2) - 1, :, frame);
            izsek_hist = get_histogram(izsek, hist_bins);

            h1 = double(znacilka_hist(:));
            h2 = double(izsek_hist(:));
            
            varnost = 1e-10;    %da preprečimo deljenje z 0
            razlika = 0.5 * sum((h1 - h2).^2 ./ (h1 + h2 + varnost));            
            razdalja(y,x) = razlika;         
        end
    end

    [min_val, idx] = min(razdalja(:));
    [y_idx, x_idx] = ind2sub(size(razdalja), idx);
    location = [x_idx, y_idx];
    razdalja = inf(size(squash, 1), size(squash, 2));

    znacilka_new  = squash((location(2) - floor(znacilka_velikost(1)/2)):(location(2) + ceil(znacilka_velikost(1)/2) - 1), (location(1) - floor(znacilka_velikost(2)/2)):(location(1) + ceil(znacilka_velikost(2)/2) - 1),:,frame);
    znacilka_hist_new = get_histogram(znacilka_new, hist_bins);
    znacilka_hist = (1 - learning_rate) * znacilka_hist + learning_rate * znacilka_hist_new;
    
    new_frame = insertShape(squash(:,:,:,frame), 'circle',[location 20], 'Color', 'red','LineWidth', 2);
    writeVideo(writer_object, new_frame);
end

close(writer_object);



function histogram = get_histogram(image, num_bins)
    step = 256/num_bins;
    
    R_idx = min(floor(image(:,:,1) / step) + 1, num_bins);
    G_idx = min(floor(image(:,:,2) / step) + 1, num_bins);
    B_idx = min(floor(image(:,:,3) / step) + 1, num_bins);
    
    rgb_bins = accumarray([R_idx(:), G_idx(:), B_idx(:)], 1, [num_bins num_bins num_bins]);

    % histogram = round(rgb_bins / (max(rgb_bins(:))/255));
    histogram = rgb_bins / sum(rgb_bins(:));
end
==== END Lovro Perme | Lovro Perme_26683_assignsubmission_file | CV_Vaja5.m ====

