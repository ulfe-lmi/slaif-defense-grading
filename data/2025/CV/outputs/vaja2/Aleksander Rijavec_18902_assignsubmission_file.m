==== BEGIN Aleksander Rijavec | Aleksander Rijavec_18902_assignsubmission_file | fitline.m ====
%SLIKE 2 3 6 8 13
% NAPAKA od -1 do 1

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
% School of Computer Science & Software Engineering
% The University of Western Australia
% http://www.csse.uwa.edu.au/
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
==== END Aleksander Rijavec | Aleksander Rijavec_18902_assignsubmission_file | fitline.m ====

==== BEGIN Aleksander Rijavec | Aleksander Rijavec_18902_assignsubmission_file | Naloga2.m ====
slika = imread('Image_rect2.tif'); 
slika = repmat(slika, [1, 1, 3]);

figure;
image(slika);
title('Izberite 4 točke na sliki');
[x, y] = ginput(4); 

% risanje točk
hold on;
plot(x, y, 'ro', 'MarkerSize', 5); %rdeči krogi
hold off;

% Definiranje vhodnih in idelnih točk za projektivno transformacijo
input = [x(1) y(1); x(2) y(2); x(3) y(3); x(4) y(4)]; 
ideal = [0 0; 0 255; 255 255; 255 0]; 

% projektivna transformacija
T = maketform("projective", input, ideal); 
transf = imtransform(slika, T, 'XData', [0, 255], 'YData', [0, 255]);

% sahovnica
korakX = 255 / 11;
korakY = 255 / 12;
[X, Y] = meshgrid(0:korakX:255, 0:korakY:255);
vogal = [X(:), Y(:)];

figure;
imshow(transf);
title('Korigirana slika');
hold on;
plot(vogal(:,1), vogal(:,2), 'rx');
hold off;

% inverzna transformacija
T_inverz = maketform('projective', ideal, input);

% prikaz oglišč na osnovni sliki
vogal_ = tformfwd(T_inverz, vogal);

figure;
imshow(slika);
title('Označeni vsi vogali');
hold on;
plot(vogal_(:,1), vogal_(:,2), 'rx');
hold off;
==== END Aleksander Rijavec | Aleksander Rijavec_18902_assignsubmission_file | Naloga2.m ====

==== BEGIN Aleksander Rijavec | Aleksander Rijavec_18902_assignsubmission_file | Naloga3_final.m ====
slika = imread('Image15.tif');
rgb_slika = repmat(slika, 1, 1, 3);
figure;
imshow(rgb_slika);
title('Kliknite 12 točk: prvih 6 na robu, naslednjih 6 v središču');

[x_koordinate, y_koordinate] = ginput(12);
disp('Izbrane točke (x, y):');
tabela_tock = [x_koordinate, y_koordinate];
disp(tabela_tock);
[visina, sirina, ~] = size(slika);
tocke_rob = [(sirina / 2 - x_koordinate(1:6))'; (visina / 2 - y_koordinate(1:6))'];
tocke_center = [(sirina / 2 - x_koordinate(7:12))'; (visina / 2 - y_koordinate(7:12))'];
[theta_rub, r_rub] = cart2pol(tocke_rob(1,:), tocke_rob(2,:));
[theta_center, r_center] = cart2pol(tocke_center(1,:), tocke_center(2,:));


[koef_rub, pocetna_greska_rub] = fitline(tocke_rob);
[koef_srediste, pocetna_greska_srediste] = fitline(tocke_center);
ukupna_greska_rub = sqrt(sum(pocetna_greska_rub.^2));
ukupna_greska_srediste = sqrt(sum(pocetna_greska_srediste.^2));
suma_odstupanja_rub = ukupna_greska_rub;
suma_odstupanja_srediste = ukupna_greska_srediste;

for f = 400:20:800
    optimizirani_rob_r = (-f / 2) .* ((exp(-2 .* r_rub ./ f) - 1) ./ exp(-r_rub ./ f));
    optimizirani_center_r = (-f / 2) .* ((exp(-2 .* r_center ./ f) - 1) ./ exp(-r_center ./ f));

    % polarni v krtezicni
    [x_rub_opt, y_rub_opt] = pol2cart(theta_rub, optimizirani_rob_r);
    [x_srediste_opt, y_srediste_opt] = pol2cart(theta_center, optimizirani_center_r);

    rub_opt_tocke = [x_rub_opt; y_rub_opt];
    srediste_opt_tocke = [x_srediste_opt; y_srediste_opt];

    % Izračun grešaka za optimizirane točke
    [~, greska_rub] = fitline(rub_opt_tocke);
    [~, greska_srediste] = fitline(srediste_opt_tocke);
    
    suma_odstupanja_rub = [suma_odstupanja_rub, sqrt(sum(greska_rub.^2))];
    suma_odstupanja_srediste = [suma_odstupanja_srediste, sqrt(sum(greska_srediste.^2))];
end

% prikaz
f_values = 400:20:800;
figure;
plot(f_values, suma_odstupanja_rub(2:end) + suma_odstupanja_srediste(2:end));
title('Skupna napaka v odvisnosti od f');
xlabel('f');
ylabel('Skupna vsota kvadratov napak');
==== END Aleksander Rijavec | Aleksander Rijavec_18902_assignsubmission_file | Naloga3_final.m ====

==== BEGIN Aleksander Rijavec | Aleksander Rijavec_18902_assignsubmission_file | Naloga4.m ====
slika = imread('Image15.tif');
rgb_slika = repmat(slika, 1, 1, 3);
%figure;
%imshow(rgb_slika);
%title('Kliknite 12 točk: prvih 6 na robu, naslednjih 6 v središču');

% Izberi 12 točk na sliki
%[x_koordinate, y_koordinate] = ginput(12);
x_koordinate = [43.8898, 42.0124, 40.7608, 38.8833, 43.2640, 43.8898,274.8155, 271.6864, 266.6799, 259.1701, 254.1636, 251.6604]';
y_koordinate = [67.1493, 144.7503, 221.0997, 257.3970, 326.2366, 392.5730,82.1688, 120.3435, 194.1897, 266.1584, 333.7464, 396.3279]';
[visina, sirina, ~] = size(slika);


% Razdeli točke na robne in sredinske
tocke_rob = [(sirina / 2 - x_koordinate(1:6))'; (visina / 2 - y_koordinate(1:6))'];
tocke_center = [(sirina / 2 - x_koordinate(7:12))'; (visina / 2 - y_koordinate(7:12))'];

% Pretvori točke iz kartezičnih v polarne koordinate
[theta_rub, r_rub] = cart2pol(tocke_rob(1,:), tocke_rob(2,:));
[theta_center, r_center] = cart2pol(tocke_center(1,:), tocke_center(2,:));
% Začetni izračun napak brez optimizacije
[koef_rub, pocetna_greska_rub] = fitline(tocke_rob);
[koef_srediste, pocetna_greska_srediste] = fitline(tocke_center);
ukupna_greska_rub = sqrt(sum(pocetna_greska_rub.^2));
ukupna_greska_srediste = sqrt(sum(pocetna_greska_srediste.^2));
suma_odstupanja_rub = ukupna_greska_rub;
suma_odstupanja_srediste = ukupna_greska_srediste;

% Funkcija za izračun skupne napake glede na f
function skupna_napaka = izracunNapake(f, theta_rub, r_rub, theta_center, r_center)
    % Optimiziraj robne točke
    optimizirani_rob_r = (-f / 2) .* ((exp(-2 .* r_rub ./ f) - 1) ./ exp(-r_rub ./ f));
    optimizirani_center_r = (-f / 2) .* ((exp(-2 .* r_center ./ f) - 1) ./ exp(-r_center ./ f));
    
    % Pretvori nazaj v kartezične koordinate
    [x_rub_opt, y_rub_opt] = pol2cart(theta_rub, optimizirani_rob_r);
    [x_srediste_opt, y_srediste_opt] = pol2cart(theta_center, optimizirani_center_r);
    
    rub_opt_tocke = [x_rub_opt; y_rub_opt];
    srediste_opt_tocke = [x_srediste_opt; y_srediste_opt];

    % Izračunaj napake
    [~, greska_rub] = fitline(rub_opt_tocke);
    [~, greska_srediste] = fitline(srediste_opt_tocke);
    
    % Skupna napaka
    skupna_napaka = sqrt(sum(greska_rub.^2)) + sqrt(sum(greska_srediste.^2));
end

% Optimizacija z uporabo fminsearch
f_optimalno = fminsearch(@(f) izracunNapake(f, theta_rub, r_rub, theta_center, r_center), 400);

% Izpis optimalne vrednosti f
disp(['Optimalna vrednost f: ', num2str(f_optimalno)]);

==== END Aleksander Rijavec | Aleksander Rijavec_18902_assignsubmission_file | Naloga4.m ====

==== BEGIN Aleksander Rijavec | Aleksander Rijavec_18902_assignsubmission_file | normalise2dpts.m ====
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
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/~pk
%
% May 2003      - Original version
% February 2004 - Modified to deal with points at infinity.
% December 2008 - meandist calculation modified to work with Octave 3.0.1
%                 (thanks to Ron Parr)
function [newpts, T] = normalise2dpts(pts)
    if size(pts,1) ~= 3
        error('pts must be 3xN');
    end
    
    % Find the indices of the points that are not at infinity
    finiteind = find(abs(pts(3,:)) > eps);
    
    if length(finiteind) ~= size(pts,2)
        warning('Some points are at infinity');
    end
    
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
==== END Aleksander Rijavec | Aleksander Rijavec_18902_assignsubmission_file | normalise2dpts.m ====

==== BEGIN Aleksander Rijavec | Aleksander Rijavec_18902_assignsubmission_file | rezultati.txt ====
Calibration parameters after initialization:

Focal Length:          fc = [ 673.11557   673.11557 ]
Principal point:       cc = [ 319.50000   239.50000 ]
Skew:             alpha_c = [ 0.00000 ]   => angle of pixel = 90.00000 degrees
Distortion:            kc = [ 0.00000   0.00000   0.00000   0.00000   0.00000 ]

Main calibration optimization procedure - Number of images: 5
Gradient descent iterations: 1...2...3...4...5...6...7...8...9...done
Estimation of uncertainties...done


Calibration results after optimization (with uncertainties):

Focal Length:          fc = [ 657.80229   658.31588 ] ± [ 0.99820   1.30280 ]
Principal point:       cc = [ 303.98022   242.14626 ] ± [ 1.57532   1.24311 ]
Skew:             alpha_c = [ 0.00000 ] ± [ 0.00000  ]   => angle of pixel axes = 90.00000 ± 0.00000 degrees
Distortion:            kc = [ -0.26155   0.16080   -0.00059   0.00010  0.00000 ] ± [ 0.00808   0.04345   0.00033   0.00034  0.00000 ]
Pixel error:          err = [ 0.12617   0.11789 ]

Note: The numerical errors are approximately three times the standard deviations (for reference).


Pixel error:          err = [ 0.12617   0.11789] (all active images)
==== END Aleksander Rijavec | Aleksander Rijavec_18902_assignsubmission_file | rezultati.txt ====

