==== BEGIN Lovro Perme | Lovro Perme_18908_assignsubmission_file | Calib_Results.m ====
% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 658.258484286437351 ; 658.470068776869994 ];

%-- Principal point:
cc = [ 301.949082796280038 ; 247.626789189710280 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ -0.252305349795715 ; 0.118604048368815 ; 0.001085539247132 ; -0.000310053389292 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 1.400416920140060 ; 1.327940595032410 ];

%-- Principal point uncertainty:
cc_error = [ 1.789213752342592 ; 1.903142559816316 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.006446782406967 ; 0.021811137473766 ; 0.000450781014550 ; 0.000460304751092 ; 0.000000000000000 ];

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
omc_1 = [ 1.660053e+00 ; 1.657371e+00 ; -6.660928e-01 ];
Tc_1  = [ -1.762330e+02 ; -9.026317e+01 ; 8.536316e+02 ];
omc_error_1 = [ 1.966203e-03 ; 2.414649e-03 ; 3.251892e-03 ];
Tc_error_1  = [ 2.319946e+00 ; 2.453018e+00 ; 1.945496e+00 ];

%-- Image #2:
omc_2 = [ NaN ; NaN ; NaN ];
Tc_2  = [ NaN ; NaN ; NaN ];
omc_error_2 = [ NaN ; NaN ; NaN ];
Tc_error_2  = [ NaN ; NaN ; NaN ];

%-- Image #3:
omc_3 = [ 1.747128e+00 ; 2.083248e+00 ; -4.995893e-01 ];
Tc_3  = [ -1.240293e+02 ; -1.805916e+02 ; 7.753175e+02 ];
omc_error_3 = [ 1.614262e-03 ; 2.425342e-03 ; 3.648879e-03 ];
Tc_error_3  = [ 2.116719e+00 ; 2.201224e+00 ; 1.908562e+00 ];

%-- Image #4:
omc_4 = [ 1.831516e+00 ; 2.124477e+00 ; -1.099380e+00 ];
Tc_4  = [ -6.321020e+01 ; -1.607874e+02 ; 7.788072e+02 ];
omc_error_4 = [ 1.438593e-03 ; 2.816747e-03 ; 4.048846e-03 ];
Tc_error_4  = [ 2.130376e+00 ; 2.218109e+00 ; 1.663082e+00 ];

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
omc_7 = [ NaN ; NaN ; NaN ];
Tc_7  = [ NaN ; NaN ; NaN ];
omc_error_7 = [ NaN ; NaN ; NaN ];
Tc_error_7  = [ NaN ; NaN ; NaN ];

%-- Image #8:
omc_8 = [ NaN ; NaN ; NaN ];
Tc_8  = [ NaN ; NaN ; NaN ];
omc_error_8 = [ NaN ; NaN ; NaN ];
Tc_error_8  = [ NaN ; NaN ; NaN ];

%-- Image #9:
omc_9 = [ NaN ; NaN ; NaN ];
Tc_9  = [ NaN ; NaN ; NaN ];
omc_error_9 = [ NaN ; NaN ; NaN ];
Tc_error_9  = [ NaN ; NaN ; NaN ];

%-- Image #10:
omc_10 = [ -1.508542e+00 ; -2.084074e+00 ; 1.834177e-01 ];
Tc_10  = [ -2.820436e+01 ; -3.071035e+02 ; 8.592158e+02 ];
omc_error_10 = [ 1.883498e-03 ; 2.120247e-03 ; 4.457731e-03 ];
Tc_error_10  = [ 2.408279e+00 ; 2.467605e+00 ; 2.324743e+00 ];

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
omc_16 = [ 1.892946e+00 ; 2.341514e+00 ; -1.654389e-01 ];
Tc_16  = [ -1.497726e+01 ; -1.756793e+02 ; 6.951694e+02 ];
omc_error_16 = [ 1.900097e-03 ; 2.111545e-03 ; 4.106862e-03 ];
Tc_error_16  = [ 1.898401e+00 ; 1.979895e+00 ; 1.684070e+00 ];

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

==== END Lovro Perme | Lovro Perme_18908_assignsubmission_file | Calib_Results.m ====

==== BEGIN Lovro Perme | Lovro Perme_18908_assignsubmission_file | CV_Vaja2.m ====
%% Naloga 2 - projektivna transformacija
close all;
clear all;
clc;

checkerboard = imread('Image_rect18.tif');
f1 = figure;
image(repmat(checkerboard,[1,1,3]));
axis image;
uiwait(msgbox('Označi 4 vogale v smeri urinega kazalca, začni zgoraj levo', 'Navodila', 'modal'));
hold on;            %da lahko čez sliko narišemo še scatter za točke
[x,y] = ginput(4);
scatter(x,y,500,'red','x');           %500 je velikost križcev, x je za obliko
hold off;

in_corners = [x,y];

img_size = 480;         %velikost izhodne slike
out_corners = [0 0; img_size-1 0; img_size-1 img_size-1; 0 img_size-1];

T = maketform("projective",in_corners,out_corners);

projected_checkerboard = imtransform(checkerboard, T,'Xdata',[0 img_size-1],'Ydata',[0 img_size-1]);
f2 = figure;
image(repmat(projected_checkerboard,[1,1,3]));
axis image;

% CORNER DETECTION:
% Naredimo gradient sivinske slike. nato izberemo gradient po x in naredimo še enkrat gradient, da dobimo drugi odvod, sedaj gledamo gradient po y
% naredimo binarno sliko, kjer porečemo vse vrhove in tako dobimo območja vrhov. S pomočjo regionprops dobimo središča teh območij, nato samo dodamo točke na slike
% nato še inverzni transform in inverzno transformacijo točk, ki jih overlayamo čez začetno sliko

[gradient_x, gradient_y] = imgradientxy(projected_checkerboard, "prewitt");
f3 = figure;
surf(gradient_x);
[gradient2_x, gradient2_y] = imgradientxy(gradient_x, "prewitt");
f4 = figure;
surf(gradient2_y);
binary_peaks = gradient2_y > 80 | gradient2_y < -80;
f5 = figure;
image(repmat(binary_peaks,[1,1,3]));
axis image;
peak_stats = regionprops(binary_peaks,'Centroid');
peak_centers = cat(1, peak_stats.Centroid);
hold on;
scatter(peak_centers(:,1),peak_centers(:,2),'filled','r');
hold off;
figure(f2);
hold on;
scatter(peak_centers(:,1),peak_centers(:,2),'filled','r');
hold off;
%inverzna tranformacija in transform vogalov na prvotne koordinate
T_inv = fliptform(T);
peaks_original = tformfwd(T_inv,peak_centers);
figure(f1);
hold on;
scatter(peaks_original(:,1),peaks_original(:,2),'filled','r');
hold off;

uiwait(msgbox('Potrdi za nadaljevanje na nalogo 3 in 4', 'Potrditev'));

%% Naloga 3 - Radialna distorzija

close all;
clear all;
clc;

checkerboard = imread('Image15.tif');
f1 = figure;
image(repmat(checkerboard,[1,1,3]));
axis image;
hold on;
%fetch optičnega središča in prikaz na sliki
calib = load("Calib_Results.mat", "cc");    %središčno točko slike naložimo iz kalibracijskih rezultatov prve naloge
scatter(calib.cc(1), calib.cc(2), 'filled');
legend('optical center');

num_points = 12;
uiwait(msgbox('Označi eno vertikalno linijo oglišč na robu šahovnice (12 oglišč)', 'Navodila', 'modal'));
[xe,ye] = ginput(num_points);
scatter(xe,ye,500,'red','x');           %500 je velikost križcev, x je za obliko
legend('optical center', 'uncorrected edge points');

uiwait(msgbox('Označi vertikalno linijo oglišč najbližje sredini slike (12 oglišč)', 'Navodila', 'modal'));
[xc,yc] = ginput(num_points);
scatter(xc,yc,500,'green','x');           %500 je velikost križcev, x je za obliko
legend('optical center', 'uncorrected edge points', 'uncorrected center points');
hold off;

%naredimo fit premice na točke samo za prikaz na sliki
edge_line = fitline([xe.';ye.']);      % transponirane matrike, da so prave oblike za fitline funkcijo
center_line = fitline([xc.';yc.']);
hold on;

%prikaz premic na sliki
fplot(@(x) -edge_line(1)/edge_line(2)*x - edge_line(3)/edge_line(2), [0, size(checkerboard,2)]);
ylim([0, size(checkerboard,1)]);
fplot(@(x) -center_line(1)/center_line(2)*x - center_line(3)/center_line(2), [0, size(checkerboard,2)]);
ylim([0, size(checkerboard,1)]);
legend('optical center', 'uncorrected edge points', 'uncorrected center points'); %še enkrat, drugače začen zraven dodajat še legendo za premice

% IZRAČUN IN KOREKCIJA RADIJEV:
% zapis s koordinatnim središčem v optičnem središču slike
xe_c = xe - calib.cc(1);
ye_c = ye - calib.cc(2);
xc_c = xc - calib.cc(1);
yc_c = yc - calib.cc(2);

% f ki jih bomo sprobali za korekcijo radijev
f = 400:20:800;

% osnovne premice, tokrat s središčnim koordinatnim sistemom, da izračunamo osnovno napako brez korekcij
[edge_line, edge_dist] = fitline([xe_c.';ye_c.']);      % transponirane matrike, da so prave oblike za fitline funkcijo
[center_line, center_dist] = fitline([xc_c.';yc_c.']);
err = zeros(size(f,2) + 1, 3);  %za eno daljši od vektorja f, ker zapišem v 0 originalno napako, druga dimenzija 3 za robne, centralne in seštevek točk
err(1,1) = sqrt(sum(edge_dist.^2));         % v prvo vrstico arraya err zapišemo nekorigirane napake
err(1,2) = sqrt(sum(center_dist.^2));
err(1,3) = err(1,1) + err(1,2);

% preddefiniranje arrayev za hitrejše delovanje
r_e = zeros(num_points, 1);
r_e_cor = zeros(size(f,2), num_points);
theta_e = zeros(num_points, 1);
r_c = zeros(num_points, 1);
r_c_cor = zeros(size(f,2), num_points);
theta_c = zeros(num_points, 1);

% pretvorba v polarni koordinatni sistem s središčem v optičnem središču slike
for i = 1 : num_points
    r_e(i) = sqrt(xe_c(i).^2 + ye_c(i).^2);
    theta_e(i) = atan2(ye_c(i), xe_c(i));
    
    r_c(i) = sqrt(xc_c(i).^2 + yc_c(i).^2);
    theta_c(i) = atan2(yc_c(i), xc_c(i));
end

% Izračun korigiranih radijev vseh točk in napake za vsak definiran f
for j = 1 : size(f,2)
    for i = 1 : num_points
        r_e_cor(j, i) = -f(j)/2 * (exp(-2*r_e(i)/f(j))-1)/(exp(-r_e(i)/f(j)));
        r_c_cor(j, i) = -f(j)/2 * (exp(-2*r_c(i)/f(j))-1)/(exp(-r_c(i)/f(j)));
    end
    
    %fitanje premice in izračun napake za robne točke
    [x_temp,y_temp]=pol2cart(theta_e,r_e_cor(j,:).');
    [edge_line, edge_dist] = fitline([x_temp.';y_temp.']);
    err(j+1,1) = sqrt(sum(edge_dist.^2));
    
    %fitanje premice in izračun napake za središčne točke
    [x_temp,y_temp]=pol2cart(theta_c,r_c_cor(j,:).');
    [edge_line, edge_dist] = fitline([x_temp.';y_temp.']); 
    err(j+1,2) = sqrt(sum(edge_dist.^2));
    
    %seštevek obeh napak, da gledamo najboljši popravek na celi sliki
    err(j+1,3) = err(j+1,1) + err(j+1,2);
end

% prikaz izračunane napake glede na f
f2 = figure;
plot(f, err(2:end,1), f, err(2:end,2), f, err(2:end,3));     % od drugega elementa naprej, saj je v prvem shranjena nekorigirana napaka
xlabel('f')
ylabel('error')
legend('error - edge','error - center', 'error - sum')

% prikaz robnih točk pri različnih f
f3 = figure;
polarscatter(theta_e,r_e);
hold on;
polarscatter(theta_e,r_e_cor(:,:));
legend(['original',string(f)]);
hold off;

% iskanje najmanjše napake in f pri te napaki
[minimum, min_index] = min(err(2:end,3));
fprintf('Najboljši f pri 3. nalogi je: %.0f \n', f(min_index));

% prikaz najbolje korigiranih točk na prvotni sliki
figure(f1);
hold on;
[x_temp,y_temp] = pol2cart(theta_e, r_e_cor(min_index, :).');
x_temp = x_temp + calib.cc(1);
y_temp = y_temp + calib.cc(2);
scatter(x_temp,y_temp,500,'yellow','x');

[x_temp,y_temp] = pol2cart(theta_c, r_c_cor(min_index, :).');
x_temp = x_temp + calib.cc(1);
y_temp = y_temp + calib.cc(2);
scatter(x_temp,y_temp,500,'blue','x');
legend('optical center', 'uncorrected edge points', 'uncorrected center points', '', '', 'corrected edge points (naloga 3)', 'corrected center points (naloga 3)');
hold off;


%% Naloga 4 - nelinearna optimizacija radialne distorzije
%najprej je treba pognat nalogo 3
[best4f, min4error] = fminsearch(@(f) min_finder(xe, ye, calib.cc(1), calib.cc(2), f), 500);
fprintf('Najboljši f pri 4. nalogi je: %f \n', best4f);


function error = min_finder(x_array, y_array, center_x, center_y,f)
    x_array = x_array - center_x;
    y_array = y_array - center_y;

    r = zeros(length(x_array), 1);
    r_cor = zeros(length(x_array), 1);
    theta = zeros(length(x_array), 1);
    
    for i = 1 : length(x_array)
        r(i) = sqrt(x_array(i)^2 + y_array(i)^2);
        theta(i) = atan2(y_array(i), x_array(i));
        r_cor(i) = -f/2 * (exp(-2*r(i)/f)-1)/(exp(-r(i)/f));
    end
    
    [x_temp,y_temp]=pol2cart(theta,r_cor);
    [edge_line, edge_dist] = fitline([x_temp.';y_temp.']); 
    error = sqrt(sum(edge_dist.^2));  
end
==== END Lovro Perme | Lovro Perme_18908_assignsubmission_file | CV_Vaja2.m ====

==== BEGIN Lovro Perme | Lovro Perme_18908_assignsubmission_file | fitline.m ====
% FITLINE - Least squares fit of a line to a set of points
%
% Usage:   [C, dist] = fitline(XY)
%
% Where:   XY  - 2xNpts array of xy coordinates to fit line to data of
%                the form 
%                [x1 x2 x3 ... xN
%                 y1 y2 y3 ... yN]
%                
%                XY can also be a 3xNpts array of homogeneous coordinates.
%
% Returns: C    - 3x1 array of line coefficients in the form
%                 c(1)*X + c(2)*Y + c(3) = 0
%          dist - Array of distances from the fitted line to the supplied
%                 data points.  Note that dist is only calculated if the
%                 function is called with two output arguments.
%
% The magnitude of C is scaled so that line equation corresponds to
%   sin(theta)*X + (-cos(theta))*Y + rho = 0
% where theta is the angle between the line and the x axis and rho is the
% perpendicular distance from the origin to the line.  Rescaling the
% coefficients in this manner allows the perpendicular distance from any
% point (x,y) to the line to be simply calculated as
%   r = abs(c(1)*X + c(2)*Y + c(3))
%
% If you want to convert this line representation to the classical form 
%     Y = a*X + b
% use
%  a = -c(1)/c(2)
%  b = -c(3)/c(2)
%
% Note, however, that this assumes c(2) is not zero

% Copyright (c) 2003-2008 Peter Kovesi
% www.peterkovesi.com
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% June      2003 - Original version
% September 2004 - Rescaling to allow simple distance calculation.
% November  2008 - Normalising of coordinates added to condition the
%                  solution.
% December  2016 - Simplified rescaling of coefficients to allow line
%                  distances to be calculated


function [C, dist] = fitline(XY)
  
  [rows,npts] = size(XY);    

  if npts < 2
      error('Too few points to fit line');
  end  
  
  if rows ==2    % Add homogeneous scale coordinate of 1 
      XY = [XY; ones(1,npts)];
  end

  if npts == 2    % Pad XY with a third column of zeros
    XY = [XY zeros(3,1)]; 
  end
  
  % Normalise points so that centroid is at origin and mean distance from
  % origin is sqrt(2).  This conditions the equations. 
  [XYn, T] = normalise2dpts(XY);
  
  % Set up constraint equations of the form  XYn'*C = 0,
  % where C is a column vector of the line coefficients
  % in the form   c(1)*X + c(2)*Y + c(3) = 0.

  [u d v] = svd(XYn',0);   % Singular value decomposition.
  C = v(:,3);              % Solution is last column of v.

  % Denormalise the solution
  C = T'*C;
  
  % Rescale coefficients so that line equation corresponds to
  %   sin(theta)*X + (-cos(theta))*Y + rho = 0
  % so that the perpendicular distance from any point (x,y) to the line
  % to be simply calculated as 
  %   r = abs(c(1)*X + c(2)*Y + c(3))
  C = C / sqrt(C(1)^2 + C(2)^2);
  
  % If requested, calculate the distances from the fitted line to
  % the supplied data points 
  if nargout==2   
      dist = abs(C(1)*XY(1,:) + C(2)*XY(2,:) + C(3));
  end




  
       
       
==== END Lovro Perme | Lovro Perme_18908_assignsubmission_file | fitline.m ====

==== BEGIN Lovro Perme | Lovro Perme_18908_assignsubmission_file | normalise2dpts.m ====
% NORMALISE2DPTS - normalises 2D homogeneous points
%
% Function translates and normalises a set of 2D homogeneous points 
% so that their centroid is at the origin and their mean distance from 
% the origin is sqrt(2).  This process typically improves the
% conditioning of any equations used to solve homographies, fundamental
% matrices etc.
%
% Usage:   [newpts, T] = normalise2dpts(pts)
%
% Argument:
%   pts -  3xN array of 2D homogeneous coordinates
%
% Returns:
%   newpts -  3xN array of transformed 2D homogeneous coordinates.  The
%             scaling parameter is normalised to 1 unless the point is at
%             infinity. 
%   T      -  The 3x3 transformation matrix, newpts = T*pts
%           
% If there are some points at infinity the normalisation transform
% is calculated using just the finite points.  Being a scaling and
% translating transform this will not affect the points at infinity.

% Peter Kovesi
% www.peterkovesi.com
%
% May 2003      - Original version
% February 2004 - Modified to deal with points at infinity.
% December 2008 - meandist calculation modified to work with Octave 3.0.1
%                 (thanks to Ron Parr)
% December 2016 - Disabled warning messgae for points at infinity.


function [newpts, T] = normalise2dpts(pts)

    if size(pts,1) ~= 3
        error('pts must be 3xN');
    end
    
    % Find the indices of the points that are not at infinity
    finiteind = find(abs(pts(3,:)) > eps);
    
%    if length(finiteind) ~= size(pts,2)
%        warning('Some points are at infinity');
%    end
    
    % For the finite points ensure homogeneous coords have scale of 1
    pts(1,finiteind) = pts(1,finiteind)./pts(3,finiteind);
    pts(2,finiteind) = pts(2,finiteind)./pts(3,finiteind);
    pts(3,finiteind) = 1;
    
    c = mean(pts(1:2,finiteind)')';            % Centroid of finite points
    newp(1,finiteind) = pts(1,finiteind)-c(1); % Shift origin to centroid.
    newp(2,finiteind) = pts(2,finiteind)-c(2);
    
    dist = sqrt(newp(1,finiteind).^2 + newp(2,finiteind).^2);
    meandist = mean(dist(:));  % Ensure dist is a column vector for Octave 3.0.1
    
    scale = sqrt(2)/meandist;
    
    T = [scale   0   -scale*c(1)
         0     scale -scale*c(2)
         0       0      1      ];
    
    newpts = T*pts;
    
    
    
==== END Lovro Perme | Lovro Perme_18908_assignsubmission_file | normalise2dpts.m ====

