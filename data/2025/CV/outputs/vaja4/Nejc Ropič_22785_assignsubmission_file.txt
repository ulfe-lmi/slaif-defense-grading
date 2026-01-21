==== BEGIN Nejc Ropič | Nejc Ropič_22785_assignsubmission_file | drawLines.m ====
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
==== END Nejc Ropič | Nejc Ropič_22785_assignsubmission_file | drawLines.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_22785_assignsubmission_file | vaja1.m ====
% Branje sivinske slike
img = imread('hotel.jpg');
img = rgb2gray(img);

Sx = [1 0 -1; 2 0 -2; 1 0 -1];
Sy = [1 2 1; 0 0 0; -1 -2 -1];

img_d = double(img);

% Sobel gradienti
Gx = conv2(img_d, Sx, 'same');
Gy = conv2(img_d, Sy, 'same');
G = sqrt(Gx.^2 + Gy.^2);
Gnorm = mat2gray(G); % normalizacija

% prag
T = 0.25;
edges_sobel = Gnorm > T;

% canny
edges_canny = edge(img, 'canny');   

% prikaz
figure;

subplot(1,2,1);
imshow(edges_sobel);
title('Sobelov detektor (prag = 0.25)');

subplot(1,2,2);
imshow(edges_canny);
title('Cannyjev detektor (MATLAB edge)');

==== END Nejc Ropič | Nejc Ropič_22785_assignsubmission_file | vaja1.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_22785_assignsubmission_file | vaja2.m ====
img = imread('hotel.jpg');
gray = rgb2gray(img);

%------------------ SOBEL ---------------------%
Sx = [1 0 -1; 2 0 -2; 1 0 -1];
Sy = [1 2 1; 0 0 0; -1 -2 -1];


img_d = double(gray);
Gx = conv2(img_d, Sx, 'same');
Gy = conv2(img_d, Sy, 'same');
G = sqrt(Gx.^2 + Gy.^2);
Gnorm = mat2gray(G);

T = 0.25; % threshold / prag
edges_sobel = Gnorm > T; % robovi glede na threshold
% odstranim robove 
edges_sobel(1,:) = 0;
edges_sobel(end,:) = 0;
edges_sobel(:,1) = 0;
edges_sobel(:,end) = 0;


% canny
edges_canny = edge(gray, 'canny');

% houghova transformacija
H_sobel = HoughTransform(edges_sobel);
H_canny = HoughTransform(edges_canny);

% izris k in n parametrov
A_normirana = mat2gray(H_sobel);
figure;
imshow(A_normirana, []);
colormap('gray');
colorbar;
xlabel('n');
ylabel('k');
%%
%------------------ DRAW LINES ----------------%
N = 5;

drawLines(img, H_sobel, N, 'Sobel');
drawLines(img, H_canny, N, 'Canny');


function A = HoughTransform(edges)

    [H, W] = size(edges);

    % diskretizacija k in n parametrov
    k_vals = -2:0.01:2;       
    n_vals = -200:1:200;      % 401 values

    num_k = length(k_vals);
    num_n = length(n_vals);

    %  priprava Houghovega prostora
    A = zeros(num_k, num_n);
    
    [y_idxs, x_idxs] = find(edges);

    % zanka čez vse robove
    for idx = 1:length(x_idxs)
        x = x_idxs(idx);
        y = y_idxs(idx);

        for ik = 1:num_k
            k = k_vals(ik);

            n = y - k*x;

            if n < -200 || n > 200
                continue;
            end

            % index for n = round((n - n_min) / step) + 1
            in = round(n - (-200)) + 1;    % step = 1 → easy

            A(ik, in) = A(ik, in) + 1;
        end
    end
end
==== END Nejc Ropič | Nejc Ropič_22785_assignsubmission_file | vaja2.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_22785_assignsubmission_file | vaja3.m ====
video = VideoReader('squash.avi');
frames = read(video,[1, Inf]); 
[height, width, c, num_frames] = size(frames);

step = 40;
frames_len = floor(num_frames / step);
frames4D = zeros(height,width,c, frames_len);

frame_counter = 0;
for f = 1:step:num_frames
    
    frame_counter = frame_counter + 1;
    frame = frames(:,:,:,f);
    frames4D(:,:,:,frame_counter) = frame;

end

% mediana, ker je nelinearen robusten filter, ki odstrani objekte, ki 
% ne zavzemajo istega piksla več kot polovico časa. Za vsak piksle pogledaš
% njegovo vrednost na vseh frameih
frames4D = frames4D(:,:,:,1:frame_counter);
mode_double = mode(frames4D,4);
modus = uint8(mode_double);

% 5. Prikaz slike ozadja
imshow(modus);
title('Ocenjeno ozadje (mediana po času)');
==== END Nejc Ropič | Nejc Ropič_22785_assignsubmission_file | vaja3.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_22785_assignsubmission_file | vaja4.m ====
%% ozadje iz 3. naloge
video = VideoReader('squash.avi');
frames = read(video,[1, Inf]); 
[height, width, c, num_frames] = size(frames);

step = 40;
frames_len = floor(num_frames / step);
frames4D = zeros(height,width,c, frames_len);

frame_counter = 0;
for f = 1:step:num_frames
    
    frame_counter = frame_counter + 1;
    frame = frames(:,:,:,f);
    frames4D(:,:,:,frame_counter) = frame;
end

frames4D = frames4D(:,:,:,1:frame_counter);
mode_double = mode(frames4D,4);
modus = uint8(mode_double);
%%
vse_slike_razlike = zeros(height,width,num_frames);
for f = 1:num_frames
    frame = frames(:,:,:,f);
    razlika = double(frame) - double(modus);
    slika_razlike = sqrt( razlika(:,:,1).^2 + ...
                          razlika(:,:,2).^2 + ...
                          razlika(:,:,3).^2 );

    vse_slike_razlike(:,:,f) = slika_razlike;
    
end
imagesc(vse_slike_razlike(:,:,1));
colormap gray;
colorbar;
title('Razlika med sliko in ozadjem');
%% dolocanje praga s histogramom
%figure;
%histogram(slika_razlike(:), 200);
frame = frames(:,:,:,1);
    razlika = double(frame) - double(modus);
    slika_razlike = sqrt( razlika(:,:,1).^2 + ...
                          razlika(:,:,2).^2 + ...
                          razlika(:,:,3).^2 );

    vse_slike_razlike(:,:,1) = slika_razlike;
    prag = 30;
    
    binary = slika_razlike > prag;
    binary = bwmorph(binary, 'clean');      % odstrani samotne piksele
    binary = bwmorph(binary, 'close');      % zapolni luknje
    binary = bwmorph(binary, 'majority');   % popravlja male artefakte



figure;
imagesc(binary);
colormap gray;
colorbar;
title("Binarna slika (threshold)");
%%
writer = VideoWriter('oznaceni_igralci.avi');
open(writer);
for f = 1:num_frames
    frame = frames(:,:,:,f);     % izvirni frame
    
    % izračun slike razlike
    razlika = double(frame) - double(modus);
    slika_razlike = sqrt( razlika(:,:,1).^2 + ...
                          razlika(:,:,2).^2 + ...
                          razlika(:,:,3).^2 );

    prag = 30;
    binary = slika_razlike > prag;

    % morfološke operacije
    binary = bwmorph(binary, 'clean');
    binary = bwmorph(binary, 'close');
    binary = bwmorph(binary, 'majority');

    % najdi igralca (centroid + bounding box)
    [c1, c2, bb1, bb2] = najdi_igralca(binary);

    % izris
    figure(1); clf;
    imshow(frame);
    hold on;

    % težišča
    plot(c1(1), c1(2), 'r+', 'LineWidth', 2, 'MarkerSize', 12);
    plot(c2(1), c2(2), 'r+', 'LineWidth', 2, 'MarkerSize', 12);

    % pravokotnika
    rectangle('Position', bb1, 'EdgeColor', 'g', 'LineWidth', 2);
    rectangle('Position', bb2, 'EdgeColor', 'g', 'LineWidth', 2);

    hold off;
    drawnow;

    % zapis v video
    F = getframe(gca);         % zajame sliko iz figure
    writeVideo(writer, F);

end

close(writer);



function [cent1, cent2, bb1, bb2] = najdi_igralca(binary_image)

    [labeled, ~] = bwlabel(binary_image);
    props = regionprops(labeled, 'Area', 'Centroid', 'BoundingBox');

    % indeks dveh največjih komponent
    [~, idx] = maxk([props.Area], 2);

    p1 = props(idx(1));
    p2 = props(idx(2));

    % vrni težišča
    cent1 = p1.Centroid;
    cent2 = p2.Centroid;

    % vrni bounding box-a
    bb1 = p1.BoundingBox;
    bb2 = p2.BoundingBox;
end
==== END Nejc Ropič | Nejc Ropič_22785_assignsubmission_file | vaja4.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_22785_assignsubmission_file | vaja5.m ====
%% ozadje iz 3. naloge
video = VideoReader('squash.avi');
frames = read(video,[1, Inf]); 
[height, width, c, num_frames] = size(frames);

step = 40;
frames_len = floor(num_frames / step);
frames4D = zeros(height,width,c, frames_len);

frame_counter = 0;
for f = 1:step:num_frames
    
    frame_counter = frame_counter + 1;
    frame = frames(:,:,:,f);
    frames4D(:,:,:,frame_counter) = frame;
end

frames4D = frames4D(:,:,:,1:frame_counter);
mode_double = mode(frames4D,4);
modus = uint8(mode_double);

%% meje
P1_R_min = 110; P1_R_max = 170; 
P1_G_min = 50; P1_G_max = 70; 
P1_B_min = 60; P1_B_max = 110; 

P2_R_min = 100; P2_R_max = 180; 
P2_G_min = 170; P2_G_max = 190; 
P2_B_min = 170; P2_B_max = 210; 
%%
video = VideoReader('squash.avi');
frames = read(video,[1 Inf]);
[H,W,~,num_frames] = size(frames);

step = 40;
cnt = 0;
for f = 1:step:num_frames
    cnt = cnt + 1;
    frames4D(:,:,:,cnt) = frames(:,:,:,f);
end
modus = uint8(mode(frames4D,4));
%%
writer = VideoWriter('squash_vaja5_kombinirano.avi');
open(writer);

prag = 70;

for f = 1:num_frames
    frame = frames(:,:,:,f);

    % slika razlike
    razlika = double(frame) - double(modus);
    slika_razlike = sqrt(razlika(:,:,1).^2 + ...
                         razlika(:,:,2).^2 + ...
                         razlika(:,:,3).^2);

    binary = slika_razlike > prag;
    binary = bwmorph(binary,'clean');
    binary = bwmorph(binary,'close');
    binary = bwmorph(binary,'majority');

    [labeled, ~] = bwlabel(binary);
    props = regionprops(labeled,'Area','Centroid','BoundingBox');

    if numel(props) < 2
        continue
    end

    [~, idx] = maxk([props.Area],2);
    p1 = props(idx(1));
    p2 = props(idx(2));
    % doloci igralca
    [type1, col1] = doloci_igralca(frame, p1.BoundingBox);
    [type2, col2] = doloci_igralca(frame, p2.BoundingBox);

    % izris
    figure(1); clf; imshow(frame); hold on;

    rectangle('Position',p1.BoundingBox,'EdgeColor',col1,'LineWidth',2);
    plot(p1.Centroid(1),p1.Centroid(2),[col1 '+'],'LineWidth',2);
    text(p1.Centroid(1),p1.Centroid(2)-20,type1,'Color',col1,...
        'FontSize',12,'FontWeight','bold');

    rectangle('Position',p2.BoundingBox,'EdgeColor',col2,'LineWidth',2);
    plot(p2.Centroid(1),p2.Centroid(2),[col2 '+'],'LineWidth',2);
    text(p2.Centroid(1),p2.Centroid(2)-20,type2,'Color',col2,...
        'FontSize',12,'FontWeight','bold');

    hold off;

    F = getframe(gca);
    writeVideo(writer,F);
end

close(writer);

function [label, color] = doloci_igralca(frame, bb)

    % pragovi
    P1_R_min = 110; P1_R_max = 170;
    P1_G_min = 50;  P1_G_max = 70;
    P1_B_min = 60;  P1_B_max = 110;

    bb = round(bb);

    roi = frame(bb(2):bb(2)+bb(4)-1, ...
                bb(1):bb(1)+bb(3)-1, :);

    R = roi(:,:,1);
    G = roi(:,:,2);
    B = roi(:,:,3);

    % maska rdečega znotraj ROI
    red_mask = (R >= P1_R_min & R <= P1_R_max & ...
                G >= P1_G_min & G <= P1_G_max & ...
                B >= P1_B_min & B <= P1_B_max);

    % delež rdečih pikslov
    red_ratio = sum(red_mask(:)) / numel(red_mask);

    % prag – dovolj že majhen delež
    if red_ratio > 0.03
        label = 'Rdeci igralec';
        color = 'r';
    else
        label = 'Beli igralec';
        color = 'b';
    end
end

function [cent1, cent2, bb1, bb2] = najdi_igralca(binary_image)

    [labeled, ~] = bwlabel(binary_image);
    props = regionprops(labeled, 'Area', 'Centroid', 'BoundingBox');

    % indeks dveh največjih komponent
    [~, idx] = maxk([props.Area], 2);

    p1 = props(idx(1));
    p2 = props(idx(2));

    % vrni težišča
    cent1 = p1.Centroid;
    cent2 = p2.Centroid;

    % vrni bounding box-a
    bb1 = p1.BoundingBox;
    bb2 = p2.BoundingBox;
end
==== END Nejc Ropič | Nejc Ropič_22785_assignsubmission_file | vaja5.m ====

