==== BEGIN Jakob Melkić Sitar | Jakob Melkić Sitar_21504_assignsubmission_file | vaja3.m ====
%% 1 – prikaz komponent HSV in Lab

pencils = imread('coloured_pencils.jpg');
yosemite = imread('yosemite_meadows.jpg');

p_hsv = rgb2hsv(pencils);
H1 = uint8(255*p_hsv(:,:,1));
S1 = uint8(255*p_hsv(:,:,2));
V1 = uint8(255*p_hsv(:,:,3));

figure;
subplot(2,2,1); imshow(pencils); title('Original coloured pencils');
subplot(2,2,2); imshow(H1); title('H');
subplot(2,2,3); imshow(S1); title('S');
subplot(2,2,4); imshow(V1); title('V');

y_hsv = rgb2hsv(yosemite);
H2 = uint8(255*y_hsv(:,:,1));
S2 = uint8(255*y_hsv(:,:,2));
V2 = uint8(255*y_hsv(:,:,3));

figure;
subplot(2,2,1); imshow(yosemite); title('Original yosemite');
subplot(2,2,2); imshow(H2); title('H');
subplot(2,2,3); imshow(S2); title('S');
subplot(2,2,4); imshow(V2); title('V');

p_lab = rgb2lab(pencils);
L1 = uint8(255*mat2gray(p_lab(:,:,1)));
a1 = uint8(255*mat2gray(p_lab(:,:,2)));
b1 = uint8(255*mat2gray(p_lab(:,:,3)));

figure;
subplot(2,2,1); imshow(pencils); title('Original coloured pencils');
subplot(2,2,2); imshow(L1); title('L');
subplot(2,2,3); imshow(a1); title('a');
subplot(2,2,4); imshow(b1); title('b');

y_lab = rgb2lab(yosemite);
L2 = uint8(255*mat2gray(y_lab(:,:,1)));
a2 = uint8(255*mat2gray(y_lab(:,:,2)));
b2 = uint8(255*mat2gray(y_lab(:,:,3)));

figure;
subplot(2,2,1); imshow(yosemite); title('Original yosemite');
subplot(2,2,2); imshow(L2); title('L');
subplot(2,2,3); imshow(a2); title('a');
subplot(2,2,4); imshow(b2); title('b');


%% 2 – vpliv odstranitve posamezne komponente

%HSV – vpliv coloured pencils
hsv_mod = p_hsv;

hsv_mod(:,:,1) = 0.5;
H_removed = hsv2rgb(hsv_mod);

hsv_mod = p_hsv;
hsv_mod(:,:,2) = 0.5;
S_removed = hsv2rgb(hsv_mod);

hsv_mod = p_hsv;
hsv_mod(:,:,3) = 0.5;
V_removed = hsv2rgb(hsv_mod);

figure('Name','HSV influence');
subplot(2,2,1); imshow(pencils); title('Original');
subplot(2,2,2); imshow(H_removed); title('H = 0.5');
subplot(2,2,3); imshow(S_removed); title('S = 0.5');
subplot(2,2,4); imshow(V_removed); title('V = 0.5');

%Lab – vpliv coloured pencils
lab_mod = p_lab;

lab_mod(:,:,1) = 50;      
L_removed = lab2rgb(lab_mod);

lab_mod = p_lab;
lab_mod(:,:,2) = 0;       
A_removed = lab2rgb(lab_mod);

lab_mod = p_lab;
lab_mod(:,:,3) = 0;       
B_removed = lab2rgb(lab_mod);

figure('Name','Lab influence');
subplot(2,2,1); imshow(pencils); title('Original');
subplot(2,2,2); imshow(L_removed); title('L = 50');
subplot(2,2,3); imshow(A_removed); title('a = 0');
subplot(2,2,4); imshow(B_removed); title('b = 0');

%HSV – vpliv yosemite
hsv_mod = y_hsv;

hsv_mod(:,:,1) = 0.5;
H_removed = hsv2rgb(hsv_mod);

hsv_mod = y_hsv;
hsv_mod(:,:,2) = 0.5;
S_removed = hsv2rgb(hsv_mod);

hsv_mod = y_hsv;
hsv_mod(:,:,3) = 0.5;
V_removed = hsv2rgb(hsv_mod);

figure('Name','HSV influence');
subplot(2,2,1); imshow(yosemite); title('Original');
subplot(2,2,2); imshow(H_removed); title('H = 0.5');
subplot(2,2,3); imshow(S_removed); title('S = 0.5');
subplot(2,2,4); imshow(V_removed); title('V = 0.5');

%Lab – vpliv yosemite
lab_mod = y_lab;

lab_mod(:,:,1) = 50;      
L_removed = lab2rgb(lab_mod);

lab_mod = y_lab;
lab_mod(:,:,2) = 0;       
A_removed = lab2rgb(lab_mod);

lab_mod = y_lab;
lab_mod(:,:,3) = 0;       
B_removed = lab2rgb(lab_mod);

figure('Name','Lab influence');
subplot(2,2,1); imshow(yosemite); title('Original');
subplot(2,2,2); imshow(L_removed); title('L = 50');
subplot(2,2,3); imshow(A_removed); title('a = 0');
subplot(2,2,4); imshow(B_removed); title('b = 0');

%% 3
vid = VideoReader('ladja.avi');
vid.CurrentTime = 0;
frame = readFrame(vid);
imshow(frame);
disp('klikni dve točki na morju, tako da bosta predstavljali ogljišči pravokotnika');
[x, y] = ginput(2);
close;

min_x = round(min(x));
max_x = round(max(x));
min_y = round(min(y));
max_y = round(max(y));

sea_region = frame(min_x:max_x, min_y:max_y, :);
sea_region_hsv = rgb2hsv(sea_region);

mean_r = mean(sea_region(:,:,1), 'all');
mean_g = mean(sea_region(:,:,2), 'all');
mean_b = mean(sea_region(:,:,3), 'all');
mean_h = mean(sea_region_hsv(:,:,1), 'all');
mean_s = mean(sea_region_hsv(:,:,2), 'all');

tol_rgb = 15;
tol_h = 0.1;
tol_s = 0.1;

%rgb
vid.CurrentTime = 0;
rgb_video = VideoWriter('segmentacija_rgb.avi', 'Uncompressed AVI');
open(rgb_video);

while hasFrame(vid)
    frame_current = readFrame(vid);
    red_mask   = abs(frame_current(:,:,1) - mean_r) <= tol_rgb;
    green_mask = abs(frame_current(:,:,2) - mean_g) <= tol_rgb;
    blue_mask  = abs(frame_current(:,:,3) - mean_b) <= tol_rgb;
    
    combined_mask = red_mask & green_mask & blue_mask;
    binary_frame = uint8(repmat(combined_mask*255, [1,1,3]));
    
    writeVideo(rgb_video, binary_frame);
end

close(rgb_video);

%hsv
vid = VideoReader('ladja.avi');
hsv_video = VideoWriter('segmentacija_hsv.avi', 'Uncompressed AVI');
open(hsv_video);

while hasFrame(vid)
    frame_rgb = readFrame(vid);
    frame_hsv = rgb2hsv(frame_rgb);
    
    hue_mask = abs(frame_hsv(:,:,1) - mean_h) <= tol_h;
    sat_mask = abs(frame_hsv(:,:,2) - mean_s) <= tol_s;
    
    combined_mask = hue_mask & sat_mask;
    binary_frame = uint8(repmat(combined_mask*255, [1,1,3]));
    
    writeVideo(hsv_video, binary_frame);
end

close(hsv_video);


%% 4
vid = VideoReader('ladja.avi');
vid.CurrentTime = 0;
frame = readFrame(vid);
imshow(frame);
disp('klikni dve točki na morju, tako da bosta predstavljali ogljišči pravokotnika');
[x, y] = ginput(2);
close;

x1 = round(min(y)); 
x2 = round(max(y));
y1 = round(min(x)); 
y2 = round(max(x));

sea_sample = frame(x1:x2, y1:y2, :);

num_bins = 8;
bin_edges = linspace(0,1,num_bins+1);

r = double(sea_sample(:,:,1))/255;
g = double(sea_sample(:,:,2))/255;
b = double(sea_sample(:,:,3))/255;

ri = min(floor(r(:)*num_bins)+1, num_bins);
gi = min(floor(g(:)*num_bins)+1, num_bins);
bi = min(floor(b(:)*num_bins)+1, num_bins);

hist3d = zeros(num_bins,num_bins,num_bins);
for k = 1:length(ri)
    hist3d(ri(k), gi(k), bi(k)) = hist3d(ri(k), gi(k), bi(k)) + 1;
end
hist3d = hist3d / max(hist3d(:)) * 255;

seg_video = VideoWriter('ladja_hist_seg.avi','Uncompressed AVI');
open(seg_video);
vid.CurrentTime = 0;

while hasFrame(vid)
    f = double(readFrame(vid))/255;
    ri = min(floor(f(:,:,1)*num_bins)+1, num_bins);
    gi = min(floor(f(:,:,2)*num_bins)+1, num_bins);
    bi = min(floor(f(:,:,3)*num_bins)+1, num_bins);
    
    idx = sub2ind([num_bins,num_bins,num_bins], ri, gi, bi);
    gray_frame = reshape(hist3d(idx), size(f,1), size(f,2));
    
    gray_uint8 = uint8(repmat(gray_frame,[1 1 3]));
    writeVideo(seg_video, gray_uint8);
end

close(seg_video);


%% 5
vid = VideoReader("ladja.avi");

vid.CurrentTime = 0;
F0 = readFrame(vid);
imshow(F0);
disp('klikni dve točki na morju, tako da bosta predstavljali ogljišči pravokotnika');
[x, y] = ginput(2);
close;

r1 = round(min(y)); 
r2 = round(max(y));
c1 = round(min(x)); 
c2 = round(max(x));

roi = F0(r1:r2, c1:c2, :);

bini = 4;
binEdges = linspace(0, 256, bini+1);

binR = discretize(double(roi(:,:,1)), binEdges);
binG = discretize(double(roi(:,:,2)), binEdges);
binB = discretize(double(roi(:,:,3)), binEdges);

refHist = accumarray([binR(:), binG(:), binB(:)], 1, [bini bini bini]);
refHist = refHist / (sum(refHist(:)) + eps);

writer = VideoWriter("ladja_dis_hist.avi");
open(writer);

block = 8;
vid.CurrentTime = 0;

while hasFrame(vid)
    F = readFrame(vid);
    [H, W, ~] = size(F);
    H2 = floor(H/block)*block;
    W2 = floor(W/block)*block;
    F = F(1:H2, 1:W2, :);
    numR = H2/block;
    numC = W2/block;
    inters = zeros(numR, numC);

    for i = 1:numR
        for j = 1:numC
            rA = (i-1)*block + 1;  rB = i*block;
            cA = (j-1)*block + 1;  cB = j*block;
            B = F(rA:rB, cA:cB, :);

            bR = discretize(double(B(:,:,1)), binEdges);
            bG = discretize(double(B(:,:,2)), binEdges);
            bB = discretize(double(B(:,:,3)), binEdges);

            Hblk = accumarray([bR(:), bG(:), bB(:)], 1, [bini bini bini]);
            Hblk = Hblk / (sum(Hblk(:)) + eps);

            inters(i,j) = sum(min(Hblk(:), refHist(:)));
        end
    end

    outFrame = kron(inters, ones(block));
    outFrame = uint8(outFrame * 256);
    outFrame = repmat(outFrame, 1,1,3);
    writeVideo(writer, outFrame);
end

close(writer);

==== END Jakob Melkić Sitar | Jakob Melkić Sitar_21504_assignsubmission_file | vaja3.m ====

