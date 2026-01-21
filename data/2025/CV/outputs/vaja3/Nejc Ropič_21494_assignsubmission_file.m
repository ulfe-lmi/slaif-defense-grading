==== BEGIN Nejc Ropič | Nejc Ropič_21494_assignsubmission_file | izracun_histograma.m ====
function [N,edgesR,edgesG,edgesB] = izracun_histograma(bins, R, G, B)

    R_norm = double(R(:)) / 255;
    G_norm = double(G(:)) / 255;
    B_norm = double(B(:)) / 255;

    edges = linspace(0,1,bins+1);

    idxR = discretize(R_norm, edges);
    idxG = discretize(G_norm, edges);
    idxB = discretize(B_norm, edges);

    valid = ~isnan(idxR) & ~isnan(idxG) & ~isnan(idxB);

    N = accumarray([idxR(valid), idxG(valid), idxB(valid)], 1, [bins bins bins]);

    edgesR = edges;
    edgesG = edges;
    edgesB = edges;
end
==== END Nejc Ropič | Nejc Ropič_21494_assignsubmission_file | izracun_histograma.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_21494_assignsubmission_file | vaja1.m ====
A = imread('yosemite_meadows.jpg');
hsv = rgb2hsv(A);
imshow(hsv)
%%
h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);

izrisi_sliko(h, 'H')
izrisi_sliko(s, 'S')
izrisi_sliko(v, 'V')

A = imread('yosemite_meadows.jpg');
lab = rgb2lab(A);

l = lab(:,:,1);
a = lab(:,:,2);
b = lab(:,:,3);

izrisi_sliko(l, 'L')
izrisi_sliko(a, 'A')
izrisi_sliko(b, 'B')


function izrisi_sliko(vrednost, naslov)
    figure;
    imagesc(vrednost);
    colormap(gray);
    colorbar;
    axis image;
    title(naslov);
end
==== END Nejc Ropič | Nejc Ropič_21494_assignsubmission_file | vaja1.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_21494_assignsubmission_file | vaja2.m ====
pretvori_hsv('yosemite_meadows.jpg', 1, 0.5)
pretvori_hsv('yosemite_meadows.jpg', 2, 0.5)
pretvori_hsv('yosemite_meadows.jpg', 3, 0.5);

pretvori_hsv('coloured_pencils.jpg', 1, 0.5)
pretvori_hsv('coloured_pencils.jpg', 2, 0.5)
pretvori_hsv('coloured_pencils.jpg', 3, 0.5);

function pretvori_hsv(slika, komponenta, vrednost)
    figure
    A = imread(slika);
    lab = rgb2hsv(A);
    lab(:,:,komponenta) = vrednost;
    rgb = hsv2rgb(lab);
    imshow(rgb)
end
%%
pretvori_lab('yosemite_meadows.jpg', 1, 50);
pretvori_lab('yosemite_meadows.jpg', 2, 0);
pretvori_lab('yosemite_meadows.jpg', 3, 0);

pretvori_lab('coloured_pencils.jpg', 1, 50);
pretvori_lab('coloured_pencils.jpg', 2, 0);
pretvori_lab('coloured_pencils.jpg', 3, 0);

function pretvori_lab(slika, komponenta, vrednost)
    figure
    A = imread(slika);
    lab = rgb2lab(A);
    lab(:,:,komponenta) = vrednost;
    rgb = lab2rgb(lab);
    imshow(rgb)
end
==== END Nejc Ropič | Nejc Ropič_21494_assignsubmission_file | vaja2.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_21494_assignsubmission_file | vaja3.m ====
video = VideoReader('ladja.avi');
frames = read(video,[1, Inf]); 

frame = 1;
slika = frames(:,:,:,frame);
imshow(slika);          
impixelinfo;
%% RGB
video = VideoReader('ladja.avi');
frames = read(video,[1, Inf]);
[~, ~, ~, num_frames] = size(frames);

minR = 50;
maxR = 105;
minG = 75;
maxG = 115;
minB = 50;     
maxB = 100;

for k = 1:num_frames
    frame = frames(:,:,:,k);
    R = frame(:,:,1);
    G = frame(:,:,2);
    B = frame(:,:,3);

    mask = (R >= minR & R <= maxR & G >= minG & ...
        G <= maxG & B >= minB & B <= maxB);

    imshow(mask);
    colormap(gray);
end
%%
video = VideoReader('ladja.avi');
frames = read(video,[1, Inf]); 

frame = 1;
slika = frames(:,:,:,frame);
hsv = rgb2hsv(slika);
H = hsv(:,:,1);
imshow(H);
colormap(gray);
impixelinfo;

%% HSV
video = VideoReader('ladja.avi');
frames = read(video,[1, Inf]);
[~, ~, ~, num_frames] = size(frames);

minH = 0.3;
maxH = 0.45;
minS = 0.25;
maxS = 0.99;


for k = 1:num_frames
    frame = frames(:,:,:,k);
    hsv = rgb2hsv(frame);
    H = hsv(:,:,1); 

    mask = (H >= minH & H <= maxH) & ...
       (S >= minS & S <= maxS) ;


    imshow(mask);
    colormap(gray);
end
==== END Nejc Ropič | Nejc Ropič_21494_assignsubmission_file | vaja3.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_21494_assignsubmission_file | vaja4.m ====
clc, clear;
video = VideoReader('ladja.avi');
frames = read(video,[1, Inf]); 
[height, width, channels, num_of_frames] =size(frames);

% okvir za učenje barve morja
frame = 40;
slika = frames(275,:,:,frame); 

R = slika(:,:,1);
G = slika(:,:,2);
B = slika(:,:,3);

% izracun histograma
[N,edgesR,edgesG,edgesB] = izracun_histograma(8,R,G,B);

% Normalizacija histograma na 0,255
max_bin = max(N(:));
N_norm = uint8( (N / max_bin) * 255 );

% iskanje najbolj polnega bina po normalizaciji
[max_val, idx] = max(N(:));
[iR, iG, iB] = ind2sub(size(N_norm), idx);

% meje bina
R_min = edgesR(iR);
R_max = edgesR(iR+1);

G_min = edgesG(iG);
G_max = edgesG(iG+1);

B_min = edgesB(iB);
B_max = edgesB(iB+1);

% segmentacija slike po barvi
R_all = double(frames(:,:,1,frame))/255;
G_all = double(frames(:,:,2,frame))/255;
B_all = double(frames(:,:,3,frame))/255;

mask = (R_all >= R_min & R_all < R_max & ...
        G_all >= G_min & G_all < G_max & ...
        B_all >= B_min & B_all < B_max);

% prikaz segmentacije
figure;
subplot(1,2,1); imshow(frames(:,:,:,frame)); title('Izvirni frame');
subplot(1,2,2); imshow(mask); title('Segmentacija morja');

%% drugi del
writer = VideoWriter('ladja_sivinska_8bit.avi');
open(writer);

for f = 1:num_of_frames
    
    frameRGB = frames(:,:,:,f);
    
    % normalizerani kanali
    R_all = double(frameRGB(:,:,1)) / 255;
    G_all = double(frameRGB(:,:,2)) / 255;
    B_all = double(frameRGB(:,:,3)) / 255;
    
    % piksli v vektorjih
    R_vec = R_all(:);
    G_vec = G_all(:);
    B_vec = B_all(:);
    
    % ugotavljanje binov
    idxR = discretize(R_vec, edgesR);
    idxG = discretize(G_vec, edgesG);
    idxB = discretize(B_vec, edgesB);
    
    % veljavni piksli
    valid = ~isnan(idxR) & ~isnan(idxG) & ~isnan(idxB);
    
    % vektor za izhodno sivinsko sliko
    gray_vec = zeros(size(R_vec), 'uint8');
    
    % vrednosti iz histograma v vektor
    gray_vec(valid) = N_norm(sub2ind(size(N_norm), idxR(valid), idxG(valid), idxB(valid)));
    
    % pretvorba v 2d sliko
    gray_img = reshape(gray_vec, height, width);
    
    % zapis v video
    writeVideo(writer, gray_img);
end

close(writer);

%% nov video
video_rgb = VideoReader('ladja.avi');
video_gray = VideoReader('ladja_sivinska_8bit.avi');

figure;
while hasFrame(video_gray) && hasFrame(video_rgb)
    frame_rgb = readFrame(video_rgb);
    frame_gray = readFrame(video_gray);

    subplot(1,2,1); imshow(frame_rgb); title('Originalni video');
    subplot(1,2,2); imshow(frame_gray, []); title('Sivinski video (histogram)');
    
    pause(1/video_rgb.FrameRate);
end
==== END Nejc Ropič | Nejc Ropič_21494_assignsubmission_file | vaja4.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_21494_assignsubmission_file | vaja5.m ====
clc; clear;

video = VideoReader('ladja.avi');
frames = read(video,[1, Inf]); 
[height, width, ~, num_frames] = size(frames);

% okvir za učenje barve morja
frame = 40;
slika = frames(275:end,:,:,frame);

% model histograma morja 4×4×4
[H_model, edgesR, edgesG, edgesB] = izracun_histograma(4, slika(:,:,1), slika(:,:,2), slika(:,:,3));

% model normaliziramo na verjetnostno porazdelitev
H_model = double(H_model);
H_model = H_model / sum(H_model(:));

writer = VideoWriter('ladja_sivinska_4bit.avi');
open(writer);

block = 8;

for f = 1:num_frames
    
    frameRGB = frames(:,:,:,f);
    out = zeros(height, width, 'uint8');

    for i = 1:block:height-block+1
        for j = 1:block:width-block+1

            blok = frameRGB(i:i+block-1, j:j+block-1, :);

            % histogram bloka
            [H_block, ~, ~, ~] = izracun_histograma(4, blok(:,:,1), blok(:,:,2), blok(:,:,3));
            H_block = double(H_block);
            
            if sum(H_block(:)) == 0
                s = 0;
            else
                % normalizacija
                s = sum(min(H_model(:), H_block(:)));
            end
            
            % preslikava na [0,255]
            s_norm = uint8(round(255 * s));


            % zapis enake vrednosti za cel blok
            out(i:i+block-1, j:j+block-1) = s_norm;
        end
    end

    writeVideo(writer, out);
end

close(writer);

%% nov video
video_rgb = VideoReader('ladja.avi');
video_gray = VideoReader('ladja_sivinska_4bit.avi');

figure;
while hasFrame(video_gray) && hasFrame(video_rgb)
    frame_rgb = readFrame(video_rgb);
    frame_gray = readFrame(video_gray);

    subplot(1,2,1); imshow(frame_rgb); title('Originalni video');
    subplot(1,2,2); imshow(frame_gray, []); title('Sivinski video (histogram)');
    
    pause(1/video_rgb.FrameRate);
end
==== END Nejc Ropič | Nejc Ropič_21494_assignsubmission_file | vaja5.m ====

