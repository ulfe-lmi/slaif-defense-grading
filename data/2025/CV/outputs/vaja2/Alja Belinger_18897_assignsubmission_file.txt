==== BEGIN Alja Belinger | Alja Belinger_18897_assignsubmission_file | fitline.m ====
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
==== END Alja Belinger | Alja Belinger_18897_assignsubmission_file | fitline.m ====

==== BEGIN Alja Belinger | Alja Belinger_18897_assignsubmission_file | projektivna_transformacija.m ====
% 2. Projektivna transformacija
clear; close all; clc;

% Preberi sivinsko sliko (že brez radialne distorzije)
I = imread('Image_rect1.tif');  % tukaj vstavi svojo undistorted sliko
if size(I,3) == 3
    I = rgb2gray(I);
end

% Kliknem 4 vogale šahovnice (v smeri urinega kazalca)
figure; imshow(I); title('Klikni 4 vogale šahovnice (v smeri urinega kazalca)');
[x, y] = ginput(4);
hold on; plot(x, y, 'ro-', 'LineWidth', 2);

% Določi idealne (nepopačene) točke
X = [0 640 640 0];
Y = [0 0 480 480];

% Izračun projektivne transformacije (fitgeotrans)
tform = fitgeotrans([x y], [X' Y'], 'projective');

% Korekcija slike (imwarp)
J = imwarp(I, tform, 'OutputView', imref2d(size(I)));

% Rezultati
figure;
subplot(1,2,1); imshow(I); title('Izvirna slika');
subplot(1,2,2); imshow(J); title('Korigirana slika');

% Velikost mreže
numCols = 14; % število stolpcev
numRows = 13; % število vrstic
xv = linspace(0, 640, numCols+1);
yv = linspace(0, 480, numRows+1);

% Generiraj mrežne točke
[Xlist, Ylist] = deal([]);
for i = 1:length(yv)
    for j = 1:length(xv)
        Xlist = [Xlist; xv(j)];
        Ylist = [Ylist; yv(i)];
    end
end
gridPoints = [Xlist, Ylist];

% Inverzna transformacija – iz idealnega koordinatnega sistema v originalno sliko
tform_inv = invert(tform);
[origX, origY] = transformPointsForward(tform_inv, gridPoints(:,1), gridPoints(:,2));

figure; imshow(I); title('Izvirna slika z mrežo (scatter prikaz)');
hold on;
scatter(origX, origY, 20, 'g', 'filled'); % 20 = velikost markerja

% Če želiš obarvati vogalne točke posebej:
cornerIdx = [1, numCols+1, (numRows)*(numCols+1)+1, (numRows+1)*(numCols+1)];
scatter(origX(cornerIdx), origY(cornerIdx), 60, 'r', 'filled'); % rdeče vogale
legend('Mrežne točke', 'Vogali');
==== END Alja Belinger | Alja Belinger_18897_assignsubmission_file | projektivna_transformacija.m ====

==== BEGIN Alja Belinger | Alja Belinger_18897_assignsubmission_file | Radialna_distorzija.m ====
% RADIALNA_DISTORZIJA - Odprava radialne distorzije slike z optimizacijo

function radialna_distorzija(ime_slike)

    if nargin < 1
        ime_slike = 'Image15.tif'; % privzeta slika iz naloge
    end

    % --- 1. Branje slike ---
    I = imread(ime_slike);
    figure, imshow(I);
    title({'Klikni točke na dveh vertikalnih linijah šahovnice', ...
           '(najprej vse točke prve linije, nato vse točke druge)'});

    % --- 2. Označevanje točk ---
    disp('Klikni točke na PRVI liniji, nato pritisni Enter');
    [x1, y1] = ginput; % prva linija
    disp('Klikni točke na DRUGI liniji, nato pritisni Enter');
    [x2, y2] = ginput; % druga linija

    lin1 = [x1'; y1'];
    lin2 = [x2'; y2'];

    % --- 3. Definicija funkcije napake za optimizacijo ---
    err_fun = @(f) napaka_distorzije(f, lin1, lin2, size(I));

    % --- 4. Optimizacija parametra f (z uporabo nelinearne metode) ---
    f0 = 500; % začetna ocena
    f_opt = fminsearch(err_fun, f0);
    fprintf('Optimalni parameter f = %.2f\n', f_opt);

    % --- 5. Korekcija slike z najboljšim f ---
    [Xp1, Yp1] = popravi_tocke(lin1, f_opt, size(I));
    [Xp2, Yp2] = popravi_tocke(lin2, f_opt, size(I));

    % --- 6. Prikaz originalnih in korigiranih točk ---
    figure, imshow(I); hold on;
    plot(lin1(1,:), lin1(2,:), 'ro', 'MarkerFaceColor', 'r');
    plot(lin2(1,:), lin2(2,:), 'bo', 'MarkerFaceColor', 'b');
    plot(Xp1, Yp1, 'go', 'MarkerFaceColor', 'g');
    plot(Xp2, Yp2, 'co', 'MarkerFaceColor', 'c');

    % --- 7. Izračun in prikaz premic (pred in po korekciji) ---
    C1 = fitline(lin1);
    C2 = fitline(lin2);
    C1_corr = fitline([Xp1; Yp1]);
    C2_corr = fitline([Xp2; Yp2]);

    x = 1:size(I,2);
    y1 = -(C1(1)*x + C1(3)) / C1(2);
    y2 = -(C2(1)*x + C2(3)) / C2(2);
    y1_corr = -(C1_corr(1)*x + C1_corr(3)) / C1_corr(2);
    y2_corr = -(C2_corr(1)*x + C2_corr(3)) / C2_corr(2);

    plot(x, y1, 'r-', 'LineWidth', 1.2);
    plot(x, y2, 'b-', 'LineWidth', 1.2);
    plot(x, y1_corr, 'g--', 'LineWidth', 1.5);
    plot(x, y2_corr, 'c--', 'LineWidth', 1.5);

    legend('Linija 1 - original', 'Linija 2 - original', ...
           'Linija 1 - korigirano', 'Linija 2 - korigirano', ...
           'Location', 'southoutside');
    title(['Korigirane točke (f = ', num2str(f_opt, '%.2f'), ')']);
    hold off;

    % --- 8. Analiza napake glede na f ---
    f_values = 400:20:800;
    errors = zeros(size(f_values));

    for i = 1:length(f_values)
        errors(i) = napaka_distorzije(f_values(i), lin1, lin2, size(I));
    end

    figure;
    plot(f_values, errors, 'b-o', 'LineWidth', 1.5);
    xlabel('Parameter f');
    ylabel('Vsota kvadratov razdalj');
    title('Odvisnost napake od parametra f');
    grid on;
end

% -------------------------------------------------------------------------
function E = napaka_distorzije(f, lin1, lin2, img_size)
    % Izračuna povprečno vsoto kvadratov razdalj do idealne premice
    [Xp1, Yp1] = popravi_tocke(lin1, f, img_size);
    [Xp2, Yp2] = popravi_tocke(lin2, f, img_size);

    [~, d1] = fitline([Xp1; Yp1]);
    [~, d2] = fitline([Xp2; Yp2]);

    % Povprečje napak obeh linij
    E = (sum(d1.^2) + sum(d2.^2)) / (length(d1) + length(d2));
end

% -------------------------------------------------------------------------
function [Xp, Yp] = popravi_tocke(XY, f, img_size)
    % Uporabi model iz enačbe (2) za popravek radialne distorzije
    cx = img_size(2) / 2; % središče slike (x)
    cy = img_size(1) / 2; % središče slike (y)

    X = XY(1,:) - cx;
    Y = XY(2,:) - cy;
    r = sqrt(X.^2 + Y.^2);

    % Inverzni model radialne distorzije
    rp = -(f/2) .* ((exp(-2*r./f) - 1) ./ exp(-r./f));

    % Pretvorba nazaj v slikovne koordinate
    Xp = rp .* X ./ (r + eps) + cx;
    Yp = rp .* Y ./ (r + eps) + cy;
end
==== END Alja Belinger | Alja Belinger_18897_assignsubmission_file | Radialna_distorzija.m ====

