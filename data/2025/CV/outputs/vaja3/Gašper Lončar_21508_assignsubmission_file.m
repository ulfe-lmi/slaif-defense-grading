==== BEGIN Gašper Lončar | Gašper Lončar_21508_assignsubmission_file | RVlab3_1.m ====
%%% LAB vaja 3 RV
%% HSV
barvice = imread("coloured_pencils.jpg");
barvice_hsv = im2double(barvice);
gore = imread("yosemite_meadows.jpg");
gore_hsv = im2double(gore);

barvice_hsv = rgb2hsv(barvice_hsv);
gore_hsv = rgb2hsv(gore_hsv);

H_bar = barvice_hsv(:,:,1);
S_bar = barvice_hsv(:,:,2);
V_bar = barvice_hsv(:,:,3);

H_gor = gore_hsv(:,:,1);
S_gor = gore_hsv(:,:,2);
V_gor = gore_hsv(:,:,3);

figure("Name","HSV barvice");
subplot(1,3,1);imagesc(H_bar); axis image off; colormap(gray), colorbar;
subplot(1,3,2);imagesc(S_bar); axis image off; colormap(gray), colorbar;
subplot(1,3,3);imagesc(V_bar); axis image off; colormap(gray), colorbar;

figure("Name","HSV gore");
subplot(1,3,1);imagesc(H_gor); axis image off; colormap(gray), colorbar;
subplot(1,3,2);imagesc(S_gor); axis image off; colormap(gray), colorbar;
subplot(1,3,3);imagesc(V_gor); axis image off; colormap(gray), colorbar;

%% LAB
barvice_lab = rgb2lab(barvice);
gore_lab = rgb2lab(gore);

L_bar = barvice_lab(:,:,1);
A_bar = barvice_lab(:,:,2);
B_bar = barvice_lab(:,:,3);

L_gor = gore_lab(:,:,1);
A_gor = gore_lab(:,:,2);
B_gor = gore_lab(:,:,3);

figure("Name","Lab barvice");
subplot(1,3,1);imagesc(L_bar); axis image off; colormap(gray), colorbar;
subplot(1,3,2);imagesc(A_bar); axis image off; colormap(gray), colorbar;
subplot(1,3,3);imagesc(B_bar); axis image off; colormap(gray), colorbar;

figure("Name","Lab gore");
subplot(1,3,1);imagesc(L_gor,[0 100]); axis image off; colormap(gray), colorbar;
subplot(1,3,2);imagesc(A_gor,[-100 100]); axis image off; colormap(gray), colorbar;
subplot(1,3,3);imagesc(B_gor, [-100 100]); axis image off; colormap(gray), colorbar;

%% 2. naloga HSV
Hs = 0.3;
Ss = 0.70;
Vs = 1.50;

H_bar_fix = barvice_hsv;
S_bar_fix = barvice_hsv;
V_bar_fix = barvice_hsv;

H_bar_fix(:,:,1) = Hs;
S_bar_fix(:,:,2) = Ss;
V_bar_fix(:,:,3) = Vs;

H_gor_fix = gore_hsv;
S_gor_fix = gore_hsv;
V_gor_fix = gore_hsv;

H_gor_fix(:,:,1) = Hs;
S_gor_fix(:,:,2) = Ss;
V_gor_fix(:,:,3) = Vs;

H_bar_rgb = hsv2rgb(H_bar_fix);
S_bar_rgb = hsv2rgb(S_bar_fix);
V_bar_rgb = hsv2rgb(V_bar_fix);

H_gor_rgb = hsv2rgb(H_gor_fix);
S_gor_rgb = hsv2rgb(S_gor_fix);
V_gor_rgb = hsv2rgb(V_gor_fix);

figure('Name','HSV: vpliv različnih komponent - barvice');
subplot(2,2,1); imshow(barvice);      title('Original');
subplot(2,2,2); imshow(H_bar_rgb); title(sprintf('H = %.2f (S,V izvirna)', Hs));
subplot(2,2,3); imshow(S_bar_rgb); title(sprintf('S = %.2f (H,V izvirna)', Ss));
subplot(2,2,4); imshow(V_bar_rgb); title(sprintf('V = %.2f (H,S izvirna)', Vs));

figure('Name','HSV: vpliv različnih komponent - gore');
subplot(2,2,1); imshow(gore);      title('Original');
subplot(2,2,2); imshow(H_gor_rgb); title(sprintf('H = %.2f (S,V izvirna)', Hs));
subplot(2,2,3); imshow(S_gor_rgb); title(sprintf('S = %.2f (H,V izvirna)', Ss));
subplot(2,2,4); imshow(V_gor_rgb); title(sprintf('V = %.2f (H,S izvirna)', Vs));

%% 2. naloga Lab
Ls = 0.2;
As = 0.5;
Bs = 0.5;

L_bar_fix = barvice_lab;
A_bar_fix = barvice_lab;
B_bar_fix = barvice_lab;

L_bar_fix(:,:,1) = Ls;
A_bar_fix(:,:,2) = As;
B_bar_fix(:,:,3) = Bs;

L_gor_fix = gore_lab;
A_gor_fix = gore_lab;
B_gor_fix = gore_lab;

L_gor_fix(:,:,1) = Ls;
A_gor_fix(:,:,2) = As;
B_gor_fix(:,:,3) = Bs;

L_bar_rgb = lab2rgb(L_bar_fix);
A_bar_rgb = lab2rgb(A_bar_fix);
B_bar_rgb = lab2rgb(B_bar_fix);

L_gor_rgb = lab2rgb(L_gor_fix);
A_gor_rgb = lab2rgb(A_gor_fix);
B_gor_rgb = lab2rgb(B_gor_fix);

figure('Name','LAB: vpliv različnih komponent - barvice');
subplot(2,2,1); imshow(barvice);      title('Original');
subplot(2,2,2); imshow(L_bar_rgb); title(sprintf('L = %.2f (A,B izvirna)', Ls));
subplot(2,2,3); imshow(A_bar_rgb); title(sprintf('A = %.2f (L,B izvirna)', As));
subplot(2,2,4); imshow(B_bar_rgb); title(sprintf('B = %.2f (L,A izvirna)', Bs));

figure('Name','LAB: vpliv različnih komponent - gore');
subplot(2,2,1); imshow(gore);      title('Original');
subplot(2,2,2); imshow(L_gor_rgb); title(sprintf('L = %.2f (A,B izvirna)', Ls));
subplot(2,2,3); imshow(A_gor_rgb); title(sprintf('A = %.2f (L,B izvirna)', As));
subplot(2,2,4); imshow(B_gor_rgb); title(sprintf('B = %.2f (L,A izvirna)', Bs));

%% 3. naloga
C=VideoReader('ladja.avi');
orig_okvirji=read(C,[1 Inf]);
video_size=size(orig_okvirji);
st_frameov=video_size(4);
prvi_frame=orig_okvirji(:,:,:,1);

% pogledaš vrednosti RGB na okvirju
figure; imshow(prvi_frame); impixelinfo;            

Rmin = 0;     Rmax=90;
Gmin = 65;    Gmax=110;
Bmin = 40;    Bmax=120;

Hmin = 0.3;   Hmax=0.5;
Smin = 0;  Smax=0.7;
Vmin = 0;     Vmax=0.6;

rgb_bin_video = VideoWriter('morje_rgb.avi');
rgb_bin_video.FrameRate = 2;
open(rgb_bin_video);

hsv_bin_video = VideoWriter('morje_hsv.avi');
hsv_bin_video.FrameRate = 2;
open(hsv_bin_video);

for i = 1:st_frameov
    R = orig_okvirji(:,:,1,i);
    G = orig_okvirji(:,:,2,i);
    B = orig_okvirji(:,:,3,i);

    maska_rgb = (R>=Rmin & R<=Rmax) & (G>=Gmin & G<=Gmax) & (B>=Bmin & B<=Bmax);
    okvir_rgb = uint8(repmat(maska_rgb, [1 1 3]))*255;     % dobimo 3x matrico
    writeVideo(rgb_bin_video, okvir_rgb);

    I = im2double(orig_okvirji(:,:,:,i));
    okvir_hsv = rgb2hsv(I);
    H = okvir_hsv(:,:,1);   S = okvir_hsv(:,:,2);   V = okvir_hsv(:,:,3);
    maska_hsv = (H>=Hmin & H<=Hmax) & (S>=Smin & S<=Smax) & (V>=Vmin & V<=Vmax);
    okvir_bin_hsv = uint8(repmat(maska_hsv, [1 1 3]))*255;
    writeVideo(hsv_bin_video,okvir_bin_hsv);
end

close(rgb_bin_video);
close(hsv_bin_video);

%% 4. naloga - avtomtska segmentacija
[visina, sirina,~,st_frameov] = size(orig_okvirji);
n_frame=orig_okvirji(:,:,:,20);

% izberi regijo s morjem
figure; imshow(n_frame); title('Izberi regijo z morjem po istem zaporedju kot pri 2. nalogi')
[x2,y2] = ginput(2); close;
x1 =round(min(x2)); y1 = round(min(y2));
x2 =round(max(x2)); y2 = round(max(y2));
regija_interesa = prvi_frame(y1:y2, x1:x2, :);

% narediš tri 1D histograme 0-255               normalizacija
Rh = histcounts(regija_interesa(:,:,1), 0:256); Rh = Rh / max(1, max(Rh));
Gh = histcounts(regija_interesa(:,:,2), 0:256); Gh = Gh / max(1, max(Gh));
Bh = histcounts(regija_interesa(:,:,3), 0:256); Bh = Bh / max(1, max(Bh));

LookUpTabela = @(R,G,B) uint8(255 * ((Rh(R+1) * Gh(G+1) * Bh(B+1))^(1/3)));

auto_hist = VideoWriter('morje_auto_hist.avi');
auto_hist.FrameRate=50;
open(auto_hist);

for i=1:st_frameov
    okvir = orig_okvirji(:,:,:,i);
    R = double(okvir(:,:,1));
    G = double(okvir(:,:,2));
    B = double(okvir(:,:,3));
    
    % vektorsko v sivinski prostor
    Rsiv = double(R)+1;
    Gsiv = double(G)+1;
    Bsiv = double(B)+1;
    
    Y = uint8(255 *  ((Rh(Rsiv).*Gh(Gsiv).*Bh(Bsiv)).^(1/3)));
    
    okvir = repmat(Y,[1 1 3]);
    writeVideo(auto_hist, okvir);
end
close(auto_hist);

%% 5. naloga - segmentacija na podlagi razdalje med histogrami
rob_visina = floor(visina/8)*8; rob_sirina = floor(sirina/8)*8;
n_binov = 4;

vBin = @(C) min(max(floor(double(C)/64) + 1, 1),n_binov);

% 4x4x4 histogram za učenje
Rkvant = vBin(regija_interesa(:,:,1));
Gkvant = vBin(regija_interesa(:,:,2));
Bkvant = vBin(regija_interesa(:,:,3));
bin64 = (Rkvant-1)*16 + (Gkvant-1)*4 + Bkvant;
ref_hist = histcounts(bin64(:), 0.5:1:64.5);
% ref_hist = ref_hist + 1e-9;
% ref_hist= ref_hist / sum(ref_hist);

morje_hist_presek = VideoWriter('morje_hist_presek');
morje_hist_presek.FrameRate = 5;
open(morje_hist_presek);

for i=1:st_frameov
    Rkvant = vBin(orig_okvirji(:,:,1,i));
    Gkvant = vBin(orig_okvirji(:,:,2,i));
    Bkvant = vBin(orig_okvirji(:,:,3,i));

    skupni_bin64 = (Rkvant-1)*16 + (Gkvant-1)*4 + Bkvant;

    Y = zeros(visina,sirina,'uint8');

    % 8x8
    for y=1:8:rob_visina
        for x=1:8:rob_sirina
            
            bin8 = skupni_bin64(y:y+7, x:x+7);

            hist_bin = histcounts(bin8(:), 0.5:1:64.5);
           
            vsota = sum(hist_bin);
            presek  = sum(min(ref_hist, hist_bin));   % Swain Ballord
            presek = presek / vsota;           

            Y(y:y+7, x:x+7) = uint8(max(0, min(255, round(256*presek))));
        end
    end

    okvir = repmat(Y,[1 1 3]);
    writeVideo(morje_hist_presek, okvir);
end
close(morje_hist_presek);
==== END Gašper Lončar | Gašper Lončar_21508_assignsubmission_file | RVlab3_1.m ====

