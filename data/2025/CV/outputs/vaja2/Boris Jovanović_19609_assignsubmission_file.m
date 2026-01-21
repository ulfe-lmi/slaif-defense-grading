==== BEGIN Boris Jovanović | Boris Jovanović_19609_assignsubmission_file | Calib_Results.m ====
% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 657.453175445359875 ; 658.137763319905275 ];

%-- Principal point:
cc = [ 303.895457971947508 ; 243.148190633409371 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ -0.259868440258877 ; 0.149982959551292 ; -0.000175643518561 ; 0.000161206278902 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 0.687675459393088 ; 0.841665238010820 ];

%-- Principal point uncertainty:
cc_error = [ 1.599052776163214 ; 1.337220319371903 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.006355147452469 ; 0.027288269606693 ; 0.000308398798660 ; 0.000333504419788 ; 0.000000000000000 ];

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
omc_2 = [ 1.849050e+00 ; 1.899768e+00 ; -3.958709e-01 ];
Tc_2  = [ -1.560270e+02 ; -1.599115e+02 ; 7.574126e+02 ];
omc_error_2 = [ 1.510634e-03 ; 2.082767e-03 ; 3.048229e-03 ];
Tc_error_2  = [ 1.851173e+00 ; 1.536760e+00 ; 9.355543e-01 ];

%-- Image #3:
omc_3 = [ NaN ; NaN ; NaN ];
Tc_3  = [ NaN ; NaN ; NaN ];
omc_error_3 = [ NaN ; NaN ; NaN ];
Tc_error_3  = [ NaN ; NaN ; NaN ];

%-- Image #4:
omc_4 = [ 1.828132e+00 ; 2.116401e+00 ; -1.101009e+00 ];
Tc_4  = [ -6.552472e+01 ; -1.554527e+02 ; 7.789827e+02 ];
omc_error_4 = [ 1.239792e-03 ; 2.379591e-03 ; 3.103293e-03 ];
Tc_error_4  = [ 1.906508e+00 ; 1.568718e+00 ; 7.539772e-01 ];

%-- Image #5:
omc_5 = [ NaN ; NaN ; NaN ];
Tc_5  = [ NaN ; NaN ; NaN ];
omc_error_5 = [ NaN ; NaN ; NaN ];
Tc_error_5  = [ NaN ; NaN ; NaN ];

%-- Image #6:
omc_6 = [ -1.700934e+00 ; -1.929378e+00 ; -7.938686e-01 ];
Tc_6  = [ -1.495206e+02 ; -7.998263e+01 ; 4.446337e+02 ];
omc_error_6 = [ 1.306607e-03 ; 2.442212e-03 ; 2.908863e-03 ];
Tc_error_6  = [ 1.083711e+00 ; 9.199644e-01 ; 7.284896e-01 ];

%-- Image #7:
omc_7 = [ NaN ; NaN ; NaN ];
Tc_7  = [ NaN ; NaN ; NaN ];
omc_error_7 = [ NaN ; NaN ; NaN ];
Tc_error_7  = [ NaN ; NaN ; NaN ];

%-- Image #8:
omc_8 = [ 1.960734e+00 ; 1.823866e+00 ; 1.328207e+00 ];
Tc_8  = [ -1.708364e+02 ; -1.039293e+02 ; 4.619777e+02 ];
omc_error_8 = [ 2.735092e-03 ; 1.241001e-03 ; 2.777801e-03 ];
Tc_error_8  = [ 1.169357e+00 ; 9.821592e-01 ; 9.287919e-01 ];

%-- Image #9:
omc_9 = [ -1.364030e+00 ; -1.981796e+00 ; 3.189586e-01 ];
Tc_9  = [ -2.906223e+00 ; -2.257365e+02 ; 7.286411e+02 ];
omc_error_9 = [ 1.584587e-03 ; 2.033593e-03 ; 2.527327e-03 ];
Tc_error_9  = [ 1.786141e+00 ; 1.485933e+00 ; 9.163574e-01 ];

%-- Image #10:
omc_10 = [ NaN ; NaN ; NaN ];
Tc_10  = [ NaN ; NaN ; NaN ];
omc_error_10 = [ NaN ; NaN ; NaN ];
Tc_error_10  = [ NaN ; NaN ; NaN ];

%-- Image #11:
omc_11 = [ NaN ; NaN ; NaN ];
Tc_11  = [ NaN ; NaN ; NaN ];
omc_error_11 = [ NaN ; NaN ; NaN ];
Tc_error_11  = [ NaN ; NaN ; NaN ];

%-- Image #12:
omc_12 = [ NaN ; NaN ; NaN ];
Tc_12  = [ NaN ; NaN ; NaN ];
omc_error_12 = [ NaN ; NaN ; NaN ];
Tc_error_12  = [ NaN ; NaN ; NaN ];

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

==== END Boris Jovanović | Boris Jovanović_19609_assignsubmission_file | Calib_Results.m ====

==== BEGIN Boris Jovanović | Boris Jovanović_19609_assignsubmission_file | RV_LV_2.m ====
clear all;
close all;

%% Druga naloga:
A = imread('Image_rect2.tif');
A = repmat(A,[1,1,3]);

figure;
image(A);                  % prikaz slike
%axis image;               % ohrani razmerje stranic
axis off;                  % skrij osi (enako kot imshow)
%set(gca,'YDir','reverse') % obvezno! da se Y-os obrne kot pri imshow
title('Klikni 4 vogale šahovnice v pravilnem vrstnem redu (npr. levo zgoraj, desno zgoraj, desno spodaj, levo spodaj)');
hold on;
for i = 1:4
    [x(i), y(i)] = ginput(1); % vrne vektor x in y koordinat klikov
    scatter(x(i), y(i), 500, 'red', 'x', 'LineWidth', 2);
    drawnow; % osveži prikaz takoj
end
hold off; % končamo dodajanje, naslednja risba bo nova figura

vhodne_tocke_vogali = [x(:), y(:)]; % 4×2 matrika
[visina, sirina] = size(A); % višina in širina nove slike
izhodne_tocke_vogali = [0 0; sirina-1 0; sirina-1 visina-1; 0 visina-1];

projektivna_transformacija = maketform('projective', vhodne_tocke_vogali, izhodne_tocke_vogali);
poravnana_slika = imtransform(A, projektivna_transformacija, 'XData', [0 sirina-1], 'YData', [0 visina-1]);

figure;
image(poravnana_slika);
%axis image;
axis off;
%set(gca,'YDir','reverse');
title('Poravnana (projektivno popravljena) šahovnica');

st_kvadratkov_X = 12; % število kvadratkov horizontalno
st_kvadratkov_Y = 13; % število kvadratkov vertikalno

vsi_vogali_x = linspace(0, sirina-1, st_kvadratkov_X+1); % +1 ker vogalov je vedno za ena več kot kvadratov
vsi_vogali_y = linspace(0, visina-1, st_kvadratkov_Y+1);

[x, y] = meshgrid(vsi_vogali_x, vsi_vogali_y);
vsi_vogali = [x(:), y(:)];  % vse vogalne točke v poravnani sliki

% Poravnana šahovnica
figure;
image(poravnana_slika);
%axis image;
axis off;
%set(gca,'YDir','reverse');
axis([0 sirina 0 visina]);
hold on; % da lahko dodamo vse vogalne točke
scatter(vsi_vogali(:,1), vsi_vogali(:,2), 'r', 'filled'); % označimo vse vogale
title('Vsi vogali kvadratov na poravnani sliki');
hold off; % zaključimo risanje čez sliko

inverzna_projektivna_transformacija = fliptform(projektivna_transformacija); % inverzna transformacija
originalni_vogali = tformfwd(inverzna_projektivna_transformacija, vsi_vogali); % preslika v izhodiščno sliko

figure;
image(A);
%axis image;
axis off;
%set(gca,'YDir','reverse');
hold on;
scatter(originalni_vogali(:,1), originalni_vogali(:,2), 'r', 'filled');
title('Vsi vogali kvadratov na originalni sliki');

%% Tretja naloga:
A = imread('Image_rect15.tif');
A = repmat(A,[1,1,3]);

f1 = figure;
image(A);
%axis image;
axis off;
%set(gca,'YDir','reverse');
hold on;
calib = load('/home/risbo/Dokumenti/RV_vaje/RV_LV_2/Calib_Results.mat', 'cc'); % središčno točko slike naložimo iz kalibracijskih rezultatov prve naloge
scatter(calib.cc(1), calib.cc(2), 'filled'); 
legend('Optični center');

st_tock = 12; % število točk za vsako vertikalno linijo
uiwait(msgbox('Označi eno vertikalno linijo oglišč na robu šahovnice (12 oglišč).', 'Navodila', 'modal'));
for i = 1:st_tock
    [xe(i), ye(i)] = ginput(1); % vrne vektor x in y koordinat klikov
    scatter(xe(i), ye(i), 500, 'red', 'x', 'LineWidth', 2);
    drawnow; % osveži prikaz takoj
end
uiwait(msgbox('Označi vertikalno linijo oglišč najbližje sredini slike (12 oglišč).', 'Navodila', 'modal'));
for i = 1:st_tock
    [xc(i), yc(i)] = ginput(1); % vrne vektor x in y koordinat klikov
    scatter(xc(i), yc(i), 500, 'green', 'x', 'LineWidth', 2);
    drawnow; % osveži prikaz takoj
end

% Naredimo fit premice na točke samo za prikaz na sliki:
edge_line = fitline([xe; ye]);
center_line = fitline([xc; yc]);

hold on;
% Risanje premice za robne točke:
fplot(@(x) -edge_line(1)/edge_line(2)*x - edge_line(3)/edge_line(2), [0, size(A,2)], 'r', 'LineWidth', 1.5);
ylim([0, size(A,1)]);

% Risanje premice za centralne točke:
fplot(@(x) -center_line(1)/center_line(2)*x - center_line(3)/center_line(2), [0, size(A,2)], 'b', 'LineWidth', 1.5);
ylim([0, size(A,1)]);

% Premik koordinat v center slike:
xe_c = xe - calib.cc(1);
ye_c = ye - calib.cc(2);
xc_c = xc - calib.cc(1);
yc_c = yc - calib.cc(2);

% Fitanje premic v koordinatnem sistemu s središčem v optičnem centru:
[edge_line, edge_dist] = fitline([xe_c(:)'; ye_c(:)']);  
[center_line, center_dist] = fitline([xc_c; yc_c]);

% Izračun skupne napake:
err(1,1) = sqrt(sum(edge_dist.^2));         
err(1,2) = sqrt(sum(center_dist.^2));
err(1,3) = err(1,1) + err(1,2);

% Definicija vektorja parametra f:
f = 400:20:800;

r_e = zeros(st_tock, 1); % radiji robnih točk (edge points), računani od optičnega središča
r_e_cor = zeros(size(f,2), st_tock, 1); % korigirani radiji robnih točk
% Za vsako možno vrednost f bomo shranili nov niz popravljenih radijev r_e_cor.
% Na koncu bomo to uporabili za iskanje optimalnega f, ki manjša napako.

theta_e = zeros(st_tock, 1);
% theta_e bodo koti (v radianih) vsake robne točke glede na optično središče.
% Z njimi bomo kasneje rekonstruirali položaje točk po korekciji (v polarni obliki).

% Pretvorba iz kartezičnih koordinat v polarne koordinate:
r_c = zeros(st_tock, 1);
theta_c = zeros(st_tock, 1);

for i = 1 : st_tock
    r_e(i) = sqrt(xe_c(i)^2 + ye_c(i)^2);
    theta_e(i) = atan2(ye_c(i), xe_c(i));

    r_c(i) = sqrt(xc_c(i)^2 + yc_c(i)^2);
    theta_c(i) = atan2(yc_c(i), xc_c(i));
end

% Izračun korigiranih radijev vseh točk in napake za vsak definiran f:
r_c_cor = zeros(size(f, 2), st_tock, 1);

for j = 1 : size(f, 2) % size(f,2) je dolžina vektorja f, v tem primeru 21 različnih vrednosti.
    for i = 1 : st_tock % Gre čez vse točke, ki smo jih predhodno pretvorili v polarne koordinate (r_e(i) in r_c(i)).
        r_e_cor(j, i) = -f(j)/2 * (exp(-2*r_e(i)/f(j)) - 1) / (exp(-r_e(i)/f(j)));
        r_c_cor(j, i) = -f(j)/2 * (exp(-2*r_c(i)/f(j))-1)/(exp(-r_c(i)/f(j)));
    end

    % Pretvorba nazaj iz polarnih v kartezicne koordinate:
    [x_novi_tmp, y_novi_tmp] = pol2cart(theta_e, r_e_cor(j,:));
    
    % Prileganje premice skozi popravljene robne točke:
    [edge_line, edge_dist] = fitline([x_novi_tmp(:)'; y_novi_tmp(:)']);
    
    % Izračun napake prileganja:
    err(j+1, 1) = sqrt(sum(edge_dist.^2));
    
    % Isto za središčne točke:
    [x_novi_tmp, y_novi_tmp] = pol2cart(theta_c, r_c_cor(j,:));
    [edge_line, edge_dist] = fitline([x_novi_tmp(:)'; y_novi_tmp(:)']);
    err(j+1, 2) = sqrt(sum(edge_dist.^2));
    
    % Skupna napaka za obe liniji:
    err(j+1, 3) = err(j+1, 1) + err(j+1, 2);
end

% Prikaz izračunane napake glede na f:
figure;
plot(f, err(2:end,1), f, err(2:end,2), f, err(2:end,3));
% Zakaj 2:end?
%Ker je bila prva vrstica v err(1,:) rezervirana za izvorno, nekorigirano napako (brez popravka f = 0).
xlabel('f')
ylabel('error')
legend('error - edge','error - center', 'error - sum')

% Prikaz robnih točk pri različnih f:
figure;
polarscatter(theta_e, r_e);
hold on;
polarscatter(theta_e, r_e_cor(:,:));
legend(['original', string(f)]);
hold off;

% Nove korigirane vrednosti:
[minimum, min_index] = min(err(2:end,3));
figure(f1);
hold on;
[x_novi_tmp, y_novi_tmp] = pol2cart(theta_e, r_e_cor(min_index - 1,:)');
x_novi_tmp = x_novi_tmp + calib.cc(1);
y_novi_tmp = y_novi_tmp + calib.cc(2);
scatter(x_novi_tmp, y_novi_tmp, 500, 'yellow', 'x');
[x_novi_tmp, y_novi_tmp]=pol2cart(theta_c, r_c_cor(min_index - 1,:)');
x_novi_tmp = x_novi_tmp + calib.cc(1);
y_novi_tmp = y_novi_tmp + calib.cc(2);
scatter(x_novi_tmp, y_novi_tmp, 500, 'blue', 'x');
legend('optical center', 'uncorrected edge points (red)', 'uncorrected center points (green)', '', '', 'corrected edge points (yellow)', 'corrected center points (blue)');
hold off;

==== END Boris Jovanović | Boris Jovanović_19609_assignsubmission_file | RV_LV_2.m ====

