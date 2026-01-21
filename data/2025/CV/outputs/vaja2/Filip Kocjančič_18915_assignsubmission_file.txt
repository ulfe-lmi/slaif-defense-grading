==== BEGIN Filip Kocjančič | Filip Kocjančič_18915_assignsubmission_file | Calib_ResultsTxt.txt ====
% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 658.592421038404950 ; 659.070101266950587 ];

%-- Principal point:
cc = [ 304.080973232697602 ; 245.541549019833241 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ -0.260921389328254 ; 0.166781762670592 ; 0.000290515210686 ; 0.000099339777463 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 0.801476409004065 ; 0.881492270191822 ];

%-- Principal point uncertainty:
cc_error = [ 1.631439809468477 ; 1.492764606501436 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.007486498549234 ; 0.039035609762126 ; 0.000324626803103 ; 0.000317495714724 ; 0.000000000000000 ];

%-- Image size:
nx = 640;
ny = 480;


%-- Various other variables (may be ignored if you do not use the Matlab Calibration Toolbox):
%-- Those variables are used to control which intrinsic parameters should be optimized

n_ima = 20;						% Number of calibration images
est_fc = [ 1 ; 1 ];					% Estimation indicator of the two focal variables
est_aspect_ratio = 1;				% Estimation indicator of the aspect ratio fc(2)/fc(1)
center_optim = 1;					% Estimation indicator of the principal point
est_alpha = 0;						% Estimation indicator of the skew coefficient
est_dist = [ 1 ; 1 ; 1 ; 1 ; 0 ];	% Estimation indicator of the distortion coefficients


%-- Extrinsic parameters:
%-- The rotation (omc_kk) and the translation (Tc_kk) vectors for every calibration image and their uncertainties

%-- Image #1:
omc_1 = [ NaN ; NaN ; NaN ];
Tc_1  = [ NaN ; NaN ; NaN ];
omc_error_1 = [ NaN ; NaN ; NaN ];
Tc_error_1  = [ NaN ; NaN ; NaN ];

%-- Image #2:
omc_2 = [ 1.851507e+00 ; 1.901574e+00 ; -3.921291e-01 ];
Tc_2  = [ -1.562495e+02 ; -1.626963e+02 ; 7.578978e+02 ];
omc_error_2 = [ 1.570284e-03 ; 2.023119e-03 ; 3.298541e-03 ];
Tc_error_2  = [ 1.888288e+00 ; 1.717889e+00 ; 9.493000e-01 ];

%-- Image #3:
omc_3 = [ NaN ; NaN ; NaN ];
Tc_3  = [ NaN ; NaN ; NaN ];
omc_error_3 = [ NaN ; NaN ; NaN ];
Tc_error_3  = [ NaN ; NaN ; NaN ];

%-- Image #4:
omc_4 = [ NaN ; NaN ; NaN ];
Tc_4  = [ NaN ; NaN ; NaN ];
omc_error_4 = [ NaN ; NaN ; NaN ];
Tc_error_4  = [ NaN ; NaN ; NaN ];

%-- Image #5:
omc_5 = [ 2.183293e+00 ; 6.108591e-01 ; 6.210168e-01 ];
Tc_5  = [ -1.671708e+02 ; -3.831985e+01 ; 4.801200e+02 ];
omc_error_5 = [ 2.298925e-03 ; 1.468490e-03 ; 2.857660e-03 ];
Tc_error_5  = [ 1.213329e+00 ; 1.104469e+00 ; 8.330233e-01 ];

%-- Image #6:
omc_6 = [ NaN ; NaN ; NaN ];
Tc_6  = [ NaN ; NaN ; NaN ];
omc_error_6 = [ NaN ; NaN ; NaN ];
Tc_error_6  = [ NaN ; NaN ; NaN ];

%-- Image #7:
omc_7 = [ NaN ; NaN ; NaN ];
Tc_7  = [ NaN ; NaN ; NaN ];
omc_error_7 = [ NaN ; NaN ; NaN ];
Tc_error_7  = [ NaN ; NaN ; NaN ];

%-- Image #8:
omc_8 = [ 1.962159e+00 ; 1.822679e+00 ; 1.332168e+00 ];
Tc_8  = [ -1.709870e+02 ; -1.057271e+02 ; 4.627411e+02 ];
omc_error_8 = [ 2.542593e-03 ; 1.262625e-03 ; 3.261078e-03 ];
Tc_error_8  = [ 1.210141e+00 ; 1.096330e+00 ; 9.041564e-01 ];

%-- Image #9:
omc_9 = [ NaN ; NaN ; NaN ];
Tc_9  = [ NaN ; NaN ; NaN ];
omc_error_9 = [ NaN ; NaN ; NaN ];
Tc_error_9  = [ NaN ; NaN ; NaN ];

%-- Image #10:
omc_10 = [ -1.511758e+00 ; -2.087089e+00 ; 1.828971e-01 ];
Tc_10  = [ -3.108539e+01 ; -3.042686e+02 ; 8.604086e+02 ];
omc_error_10 = [ 1.688982e-03 ; 1.954466e-03 ; 3.256826e-03 ];
Tc_error_10  = [ 2.188161e+00 ; 1.963458e+00 ; 1.232804e+00 ];

%-- Image #11:
omc_11 = [ NaN ; NaN ; NaN ];
Tc_11  = [ NaN ; NaN ; NaN ];
omc_error_11 = [ NaN ; NaN ; NaN ];
Tc_error_11  = [ NaN ; NaN ; NaN ];

%-- Image #12:
omc_12 = [ -1.836951e+00 ; -2.085521e+00 ; -5.215656e-01 ];
Tc_12  = [ -1.345078e+02 ; -1.799430e+02 ; 6.051837e+02 ];
omc_error_12 = [ 1.326989e-03 ; 2.065236e-03 ; 3.602692e-03 ];
Tc_error_12  = [ 1.528926e+00 ; 1.398213e+00 ; 9.347775e-01 ];

%-- Image #13:
omc_13 = [ NaN ; NaN ; NaN ];
Tc_13  = [ NaN ; NaN ; NaN ];
omc_error_13 = [ NaN ; NaN ; NaN ];
Tc_error_13  = [ NaN ; NaN ; NaN ];

%-- Image #14:
omc_14 = [ NaN ; NaN ; NaN ];
Tc_14  = [ NaN ; NaN ; NaN ];
omc_error_14 = [ NaN ; NaN ; NaN ];
Tc_error_14  = [ NaN ; NaN ; NaN ];

%-- Image #15:
omc_15 = [ NaN ; NaN ; NaN ];
Tc_15  = [ NaN ; NaN ; NaN ];
omc_error_15 = [ NaN ; NaN ; NaN ];
Tc_error_15  = [ NaN ; NaN ; NaN ];

%-- Image #16:
omc_16 = [ NaN ; NaN ; NaN ];
Tc_16  = [ NaN ; NaN ; NaN ];
omc_error_16 = [ NaN ; NaN ; NaN ];
Tc_error_16  = [ NaN ; NaN ; NaN ];

%-- Image #17:
omc_17 = [ NaN ; NaN ; NaN ];
Tc_17  = [ NaN ; NaN ; NaN ];
omc_error_17 = [ NaN ; NaN ; NaN ];
Tc_error_17  = [ NaN ; NaN ; NaN ];

%-- Image #18:
omc_18 = [ NaN ; NaN ; NaN ];
Tc_18  = [ NaN ; NaN ; NaN ];
omc_error_18 = [ NaN ; NaN ; NaN ];
Tc_error_18  = [ NaN ; NaN ; NaN ];

%-- Image #19:
omc_19 = [ NaN ; NaN ; NaN ];
Tc_19  = [ NaN ; NaN ; NaN ];
omc_error_19 = [ NaN ; NaN ; NaN ];
Tc_error_19  = [ NaN ; NaN ; NaN ];

%-- Image #20:
omc_20 = [ NaN ; NaN ; NaN ];
Tc_20  = [ NaN ; NaN ; NaN ];
omc_error_20 = [ NaN ; NaN ; NaN ];
Tc_error_20  = [ NaN ; NaN ; NaN ];

==== END Filip Kocjančič | Filip Kocjančič_18915_assignsubmission_file | Calib_ResultsTxt.txt ====

==== BEGIN Filip Kocjančič | Filip Kocjančič_18915_assignsubmission_file | rv2_vse_naloge.m ====
%% RV2_VSE_NALOGE
close all; clear; clc;

%% ---- nastavitve slik ----
projImgName = 'Image_rect6.tif';   % 2. naloga -> prilagodi po potrebi
radImgName  = 'Image15.tif';   % 3. in 4. naloga

%% ---- središče distorzije iz Calib_Results.mat ----
R = load('Calib_Results.mat');

cx = R.cc(1); cy = R.cc(2);

%% ===================== 2. NALOGA: PROJEKTIVNA =====================
Ip = imread(projImgName);

figure; imshow(Ip,[]); axis image;
title({'2. naloga: klikni 4 vogale šahovnice v zaporedju:', ...
       '1: levo zgoraj, 2: desno zgoraj, 3: desno spodaj, 4: levo spodaj'});
[xv, yv] = ginput(4);
moving = [xv yv];

% prilagodi glede na svojo šahovnico:
numSquaresX = 12;
numSquaresY = 11;
squareSize  = 30;
W = numSquaresX * squareSize;
H = numSquaresY * squareSize;

fixed = [0 0; W 0; W H; 0 H];

T = maketform('projective', moving, fixed);
[J, ~, ~] = imtransform(Ip, T, 'XData',[0 W], 'YData',[0 H]);

figure; imshow(J,[]); axis image;
title('2. naloga: korigirana (projektivna) slika');

% oglišča v idealni mreži + preslikava nazaj na original
[Xg, Yg] = meshgrid(0:squareSize:W, 0:squareSize:H);
ideal_pts = [Xg(:) Yg(:)];
invT = maketform('projective', fixed, moving);
[xg, yg] = tformfwd(invT, ideal_pts(:,1), ideal_pts(:,2));

figure; imshow(Ip,[]); axis image; hold on;
plot(xg, yg, 'r.', 'MarkerSize', 6);
title('2. naloga: oglišča šahovnice na originalni sliki');


%% ========== 3. & 4. NALOGA: RADIALNA DISTORZIJA (Image15) ==========

Ir = imread(radImgName);

figure; imshow(Ir,[]); axis image;
title({'3./4. naloga:', ...
       'Najprej klikni ROBNO vertikalno vrsto oglišč (Enter za konec),', ...
       'nato SREDINSKO vertikalno vrsto (Enter za konec).'});

disp('3./4. naloga: robna vrsta, Enter za konec.');
[x1, y1] = ginput;
disp('3./4. naloga: sredinska vrsta, Enter za konec.');
[x2, y2] = ginput;
close;

%% ---- 3. naloga: diskretno iskanje f v [400:20:800] ----

f_vals = 400:20:800;
E_vals = zeros(size(f_vals));

for k = 1:length(f_vals)
    E_vals(k) = radial_error(f_vals(k), x1,y1,x2,y2, cx,cy);
end

[Emin, idxMin] = min(E_vals);
f_best_grid = f_vals(idxMin);

fprintf('3. naloga: najboljši f (diskretno) = %.4f, napaka = %.4f\n', ...
        f_best_grid, Emin);

figure;
plot(f_vals, E_vals, '-o'); grid on;
xlabel('f'); ylabel('Vsota kvadratov razdalj');
title('3. naloga: napaka glede na f (diskretno)');
    


%% ---- 4. naloga: nelinearno iskanje f z fminsearch ----

f0 = f_best_grid;                 % začnemo pri diskretnem minimumu
opts = optimset('Display','off'); % minimalno, brez spama v konzoli

[f_best_cont, E_best_cont] = fminsearch( ...
    @(f) radial_error(f, x1,y1,x2,y2, cx,cy), f0, opts);

fprintf('4. naloga: optimalni f (fminsearch) = %.6f, napaka = %.6f\n', ...
        f_best_cont, E_best_cont);

% (neobvezno, a pregledno) lokalni prikaz okoli optimuma
f_loc = linspace(max(100, f_best_cont-200), min(1000, f_best_cont+200), 30);
E_loc = arrayfun(@(f) radial_error(f, x1,y1,x2,y2, cx,cy), f_loc);

figure;
plot(f_loc, E_loc, '-o'); grid on;
xlabel('f'); ylabel('Vsota kvadratov razdalj');
title('4. naloga: napaka okoli optimalnega f');


%% ===== LOKALNE FUNKCIJE (OSTANEJO V ISTEM .m, TO JE ŠE VEDNO SKRIPTA) =====

function E = radial_error(f, x1,y1,x2,y2, cx,cy)
    % Napaka za dano f: vsota kvadratov razdalj obeh stolpcev do svojih premic
    if f <= 0
        E = 1e12;
        return;
    end

    [xu1, yu1] = undistort_points(x1, y1, cx, cy, f);
    [xu2, yu2] = undistort_points(x2, y2, cx, cy, f);

    [~, d1] = fitline([xu1.'; yu1.']);   % 2xN
    [~, d2] = fitline([xu2.'; yu2.']);

    E = sum(d1.^2) + sum(d2.^2);
end


function [xu, yu] = undistort_points(x, y, cx, cy, f)
    % Inverz radialne distorzije:
    % r' -> r_l = f * sinh(r'/f)

    dx = x - cx;
    dy = y - cy;

    rp = sqrt(dx.^2 + dy.^2);       % popačen radij
    rl = f .* sinh(rp ./ f);        % nepopačen radij

    scale = ones(size(rp));
    mask = (rp > 0);
    scale(mask) = rl(mask) ./ rp(mask);

    xu = cx + dx .* scale;
    yu = cy + dy .* scale;
end
==== END Filip Kocjančič | Filip Kocjančič_18915_assignsubmission_file | rv2_vse_naloge.m ====

