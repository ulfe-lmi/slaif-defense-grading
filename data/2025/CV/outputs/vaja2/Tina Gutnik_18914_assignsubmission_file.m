==== BEGIN Tina Gutnik | Tina Gutnik_18914_assignsubmission_file | Calib_Results.m ====
% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 658.298175283636851 ; 658.713077493047876 ];

%-- Principal point:
cc = [ 303.353680333920636 ; 243.313729537312781 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ -0.257802768808243 ; 0.149247379376497 ; -0.000403077183852 ; -0.000130674481519 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 0.806747119135988 ; 1.011818391676628 ];

%-- Principal point uncertainty:
cc_error = [ 1.732929450772104 ; 1.465721885334871 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.008329090266652 ; 0.045546410049400 ; 0.000341784525374 ; 0.000342851846383 ; 0.000000000000000 ];

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
omc_1 = [ 1.655518e+00 ; 1.652114e+00 ; -6.687624e-01 ];
Tc_1  = [ -1.780469e+02 ; -8.463011e+01 ; 8.537233e+02 ];
omc_error_1 = [ 1.579082e-03 ; 2.469103e-03 ; 2.620392e-03 ];
Tc_error_1  = [ 2.244724e+00 ; 1.900292e+00 ; 8.921122e-01 ];

%-- Image #2:
omc_2 = [ NaN ; NaN ; NaN ];
Tc_2  = [ NaN ; NaN ; NaN ];
omc_error_2 = [ NaN ; NaN ; NaN ];
Tc_error_2  = [ NaN ; NaN ; NaN ];

%-- Image #3:
omc_3 = [ 1.742766e+00 ; 2.077589e+00 ; -5.041005e-01 ];
Tc_3  = [ -1.256742e+02 ; -1.753972e+02 ; 7.761754e+02 ];
omc_error_3 = [ 1.462091e-03 ; 2.518635e-03 ; 3.000022e-03 ];
Tc_error_3  = [ 2.047206e+00 ; 1.724167e+00 ; 9.272774e-01 ];

%-- Image #4:
omc_4 = [ NaN ; NaN ; NaN ];
Tc_4  = [ NaN ; NaN ; NaN ];
omc_error_4 = [ NaN ; NaN ; NaN ];
Tc_error_4  = [ NaN ; NaN ; NaN ];

%-- Image #5:
omc_5 = [ NaN ; NaN ; NaN ];
Tc_5  = [ NaN ; NaN ; NaN ];
omc_error_5 = [ NaN ; NaN ; NaN ];
Tc_error_5  = [ NaN ; NaN ; NaN ];

%-- Image #6:
omc_6 = [ NaN ; NaN ; NaN ];
Tc_6  = [ NaN ; NaN ; NaN ];
omc_error_6 = [ NaN ; NaN ; NaN ];
Tc_error_6  = [ NaN ; NaN ; NaN ];

%-- Image #7:
omc_7 = [ 1.996655e+00 ; 1.930965e+00 ; 1.312325e+00 ];
Tc_7  = [ -8.318953e+01 ; -7.820560e+01 ; 4.409133e+02 ];
omc_error_7 = [ 3.096844e-03 ; 1.193755e-03 ; 3.175904e-03 ];
Tc_error_7  = [ 1.180123e+00 ; 9.881391e-01 ; 8.235165e-01 ];

%-- Image #8:
omc_8 = [ 1.961471e+00 ; 1.823779e+00 ; 1.327793e+00 ];
Tc_8  = [ -1.703959e+02 ; -1.040571e+02 ; 4.629057e+02 ];
omc_error_8 = [ 2.889312e-03 ; 1.171101e-03 ; 2.920912e-03 ];
Tc_error_8  = [ 1.291832e+00 ; 1.076784e+00 ; 9.284523e-01 ];

%-- Image #9:
omc_9 = [ NaN ; NaN ; NaN ];
Tc_9  = [ NaN ; NaN ; NaN ];
omc_error_9 = [ NaN ; NaN ; NaN ];
Tc_error_9  = [ NaN ; NaN ; NaN ];

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
omc_12 = [ -1.838554e+00 ; -2.086954e+00 ; -5.169996e-01 ];
Tc_12  = [ -1.338213e+02 ; -1.778691e+02 ; 6.057285e+02 ];
omc_error_12 = [ 1.436410e-03 ; 2.359154e-03 ; 3.466145e-03 ];
Tc_error_12  = [ 1.623628e+00 ; 1.374934e+00 ; 8.723691e-01 ];

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

==== END Tina Gutnik | Tina Gutnik_18914_assignsubmission_file | Calib_Results.m ====

==== BEGIN Tina Gutnik | Tina Gutnik_18914_assignsubmission_file | lab_vaja_2.m ====
addpath('C:\Users\tgutn\TOOLBOX_calib');
calib_gui;

%% Projektivna transformacija

I = imread('Image_rect3.tif');
image(I); colormap gray; hold on;

[x,y] = ginput(4); %označimo 4 točke (levo zgoraj!, desno zgoraj, desno spodaj, levo spodaj)
tocke = [x(:) y(:)]; %shranimo koordinate točk v matriko 4x2, kjer je vsaka vrstica ena točka [x y]
plot(tocke([1:4 1],1), tocke([1:4 1],2)); %narišemo te točke(1 znotraj [] je, da je zaprt pravokotnik, na koncu spet prva točka)

W = 12*30; %širina šahovnice je 12 kvadratkov po 30mm
H = 11*30; %višina šahovnice
piksli = 3; %ločljivost naj bo 3 piksli/mm
pravokotnik = [0 0; W 0; W H; 0 H]; %to je ciljni pravokotnik, v katerega želimo izvesti projektivno transformacijo

G = fitgeotrans(tocke, pravokotnik, 'projective');   %ocenimo projektivno preslikavo iz tocke v pravokotnik
tform = maketform('projective', G.T); %ustvari tform, ki ga razume imtransform  %T je 3x3 homogena matrika projektivne trans.
%Irect = imtransform(I, tform); %podamo še velikosti x in y, da dobimo sliko zgolj šahovnice, ne pa tudi ozadja
Irect = imtransform(I, tform, 'XData', [0 W], 'YData', [0 H]); %preslika sliko v ciljni pravokotnik
figure; image(Irect); colormap gray; axis image off; hold on;
[X,Y] = meshgrid(0:30:W, 0:30:H); 
plot(X(:), Y(:), 'mx');



Tinv = inv(G.T); % inverzna 3x3 matrika
inv_tform = maketform('projective', Tinv);
[x0, y0] = tformfwd(inv_tform, X(:), Y(:));

figure; image(I); colormap gray; axis image off; hold on;
plot(x0(:), y0(:), 'mx');   


%% Radialna distorzija 
figure;
R = imread('Image15.tif');
image(R); colormap gray; hold on;

W = 12*30; 
H = 11*30;
piksli = 3;

% fitline pričakuje 2*N matriko, prva vrstica x, druga y
% vrne koeficiente premice ax+by+c=0 z normo sqrt(a^2+b^2)=1, torej C = [a;b;c] 
% vrne tudi d - pravokotna razdalja vsake točke do premice 

% stranska premica
[x1,y1] = ginput(12); %poklikati je potrebno vsa presečišča stranske premice 
plot(x1,y1,'rx');
[C1,d1] = fitline([x1'; y1']); 
a1=C1(1); b1=C1(2); c1=C1(3);

if abs(b1) > eps %primer, ko premica ni vertikalna 
    x = [0 W];
    y = -(a1*x + c1)/b1;        
    plot(x, y, 'r');
else
    x0 = -c1/a1;  %vertikalna premica x=x0, nagib je neskončen, b=0 torej ax+c=0
    plot(x0, [0 H], 'r');
end


% sredinska premica
[x2,y2] = ginput(12); %poklikati je potrebno vsa presečišča sredinske premice 
plot(x2,y2,'gx');
[C2,d2] = fitline([x2'; y2']);
a2=C2(1); b2=C2(2); c2=C2(3);

if abs(b2) > eps %primer, ko premica ni vertikalna 
    x = [0 W];
    y = -(a2*x + c2)/b2;        
    plot(x, y, 'g');
else
    x0 = -c2/a2;  % vertikalna premica x=x0, nagib je neskončen, b=0 torej ax+c=0
    plot(x0, [0 H], 'g');
end


% minimizacija vsote kvadratov razdalj
load Calib_Results.mat;
cx = cc(1);            %središče v pikslih cx= 303, cy=243
cy = cc(2);              

% popačeni radiji
r0_rob    = hypot(x1 - cx, y1 - cy);   %hypot - hipotenuza 
r0_center = hypot(x2 - cx, y2 - cy);

% nepopačeni radiji
f = 400:20:800;
vsota_kvadratov = zeros(size(f)); 

for i = 1:size(f,2)  %f je vrstični vektor (21)
    ft = f(i);

    rl_rob = -(ft/2) .* (exp(-2 .* r0_rob ./ ft) - 1) ./ exp(-r0_rob ./ ft);  % ., ker množimo in delimo po elementih (r0_rob je lahko element in vektor)
    rl_center = -(ft/2) .* (exp(-2 .* r0_center ./ ft) - 1) ./ exp(-r0_center ./ ft);

    s1 = rl_rob ./ r0_rob; %radialni faktor
    s2 = rl_center ./ r0_center;

    x1u = cx + (x1 - cx).*s1;   y1u = cy + (y1 - cy).*s1; %x in y koor. undistorted robnih točk
    x2u = cx + (x2 - cx).*s2;   y2u = cy + (y2 - cy).*s2; %x in y koor. undistorted centerskih točk
    
    [~,d1] = fitline([x1u'; y1u']); %fitline undistorted točk
    [~,d2] = fitline([x2u'; y2u']);

    vsota_kvadratov(i) = sum(d1.^2) + sum(d2.^2);
    %vsota_kvadratov(i)= sqrt((sum(d1.^2) + sum(d2.^2)) / (numel(d1)+numel(d2)) ); če bi želeli rms 
end

figure; plot(f, vsota_kvadratov);
xlabel('f'); ylabel('vsota kvadratov razdalj');

% Nelinearna optimizacija vrednosti parametra distorzije
f0 = 500;
obj = @(ft) optimizacija(ft, x1, y1, x2, y2, r0_rob, r0_center, cx, cy); %anonimna fun., da dostopamo do vseh elementov
f_opt = fminsearch(obj, f0)
==== END Tina Gutnik | Tina Gutnik_18914_assignsubmission_file | lab_vaja_2.m ====

==== BEGIN Tina Gutnik | Tina Gutnik_18914_assignsubmission_file | optimizacija.m ====
function  vsota_kvadratov = optimizacija (ft, x1, y1, x2, y2, r0_rob, r0_center, cx, cy) 
    rl_rob = -(ft/2) .* (exp(-2 .* r0_rob ./ ft) - 1) ./ exp(-r0_rob ./ ft);  % ., ker množimo in delimo po elementih (r0_rob je lahko element in vektor)
    rl_center = -(ft/2) .* (exp(-2 .* r0_center ./ ft) - 1) ./ exp(-r0_center ./ ft);

    s1 = rl_rob ./ r0_rob; %radialni faktor
    s2 = rl_center ./ r0_center;

    x1u = cx + (x1 - cx).*s1;   y1u = cy + (y1 - cy).*s1; %x in y koor. undistorted robnih točk
    x2u = cx + (x2 - cx).*s2;   y2u = cy + (y2 - cy).*s2; %x in y koor. undistorted centerskih točk
    
    [~,d1] = fitline([x1u'; y1u']); %fitline undistorted točk
    [~,d2] = fitline([x2u'; y2u']);

    vsota_kvadratov = sum(d1.^2) + sum(d2.^2);
end
==== END Tina Gutnik | Tina Gutnik_18914_assignsubmission_file | optimizacija.m ====

