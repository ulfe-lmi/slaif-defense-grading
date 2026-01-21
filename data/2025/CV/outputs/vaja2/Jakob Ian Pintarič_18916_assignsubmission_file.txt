==== BEGIN Jakob Ian Pintarič | Jakob Ian Pintarič_18916_assignsubmission_file | fitline.m ====
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
==== END Jakob Ian Pintarič | Jakob Ian Pintarič_18916_assignsubmission_file | fitline.m ====

==== BEGIN Jakob Ian Pintarič | Jakob Ian Pintarič_18916_assignsubmission_file | normalise2dpts.m ====
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
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
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
    
    
    
==== END Jakob Ian Pintarič | Jakob Ian Pintarič_18916_assignsubmission_file | normalise2dpts.m ====

==== BEGIN Jakob Ian Pintarič | Jakob Ian Pintarič_18916_assignsubmission_file | Vaja2.m ====
%% kalib kamere
toolbox = 'C:\Users\Jakob\MATLAB\Računalniški_vid\Vaja2\toolbox_calib';
vaja = 'C:\Users\Jakob\MATLAB\Računalniški_vid\Vaja2';
images = 'C:\Users\Jakob\MATLAB\Računalniški_vid\Vaja2';
addpath(toolbox);
cd(vaja);
cd(images);

calib_gui;

% 
% Focal Length:          fc = [ 658.19118   658.68772 ] ± [ 0.79780   0.99914 ]
% Principal point:       cc = [ 305.26520   243.22067 ] ± [ 1.75385   1.53715 ]
% Skew:             alpha_c = [ 0.00000 ] ± [ 0.00000  ]   => angle of pixel axes = 90.00000 ± 0.00000 degrees
% Distortion:            kc = [ -0.25420   0.12458   0.00004   0.00023  0.00000 ] ± [ 0.00821   0.04228   0.00036   0.00033  0.00000 ]
% Pixel error:          err = [ 0.12107   0.10919 ]

%% projekt transform
img = imread('Image_rect4.tif');
figure, imshow(img), title('Izberite 4 vogale šahovnice:');

% [x, y] = ginput(4);
% source_points = [x y];
source_points = [  249.9286  113.3571
  544.2143   83.0714
  516.2143  396.7857
  141.9286  363.6429];

width = 300;
height = 300;
target_points = [0 0; width 0; width height; 0 height];

T = maketform('projective', source_points, target_points);
img_corrected = imtransform(img, T, 'XData', [0 width], 'YData', [0 height]);
figure,imshow(img_corrected);

[imagePoints, boardSize] = detectCheckerboardPoints(img_corrected);

step_x = width / boardSize(1);
step_y = height / boardSize(2);

[xg, yg] = meshgrid(0:step_x:width, 0:step_y:height);
outer_points = [xg(:), yg(:)];

J = insertMarker(img_corrected, outer_points, 'o', 'MarkerColor', 'red', 'Size', 2);
figure, imshow(J);
title('Zaznana + zunanja vozlišča šahovnice');

invT = maketform('projective', target_points, source_points);
[x2, y2] = tformfwd(invT, outer_points(:,1), outer_points(:,2));

img_marked_orig = insertMarker(img, [x2 y2], 'o', 'MarkerColor', 'red', 'Size', 2);
figure, imshow(img_marked_orig), title('Vozlišča (vključno z zunanjimi) na originalni sliki');

%% 3. Radialna distorzija

img = imread('Image15.tif');
figure, imshow(img), title('Označi dve vertikalni vrstici: najprej ob robu, nato v središču slike');
disp('Označi točke ob robu slike:');
hold on;

%[x1, y1] = ginput;  
source_points1  = [45.9286   28.2143;
   43.6429   65.9286;
   43.0714  105.9286;
   41.9286  145.3571;
   40.2143  183.0714;
   40.7857  220.7857;
   40.7857  257.3571;
   40.7857  292.2143;
   42.5000  327.0714;
   43.6429  360.2143;
   44.7857  391.6429;
   45.9286  423.0714;
   47.0714  452.2143;
   48.2143  477.9286];
x1 = source_points1(:,1);
y1 = source_points1(:,2);
plot(x1, y1, 'o-','LineWidth', 1.5);  

disp('Zdaj označi točke v središču slike:');
%[x2, y2] = ginput;  
source_points2  = [314.5000   49.3571;
  311.6429   85.9286;
  307.6429  123.0714;
  304.2143  159.6429;
  301.3571  196.2143;
  297.9286  231.6429;
  293.9286  267.0714;
  292.2143  300.2143;
  288.2143  332.7857;
  287.0714  363.6429;
  283.0714  395.6429;
  280.2143  424.7857;
  280.2143  453.3571;
  277.3571  479.0714  ];
x2 = source_points2(:,1);
y2 = source_points2(:,2);
plot(x2, y2, '*-', 'MarkerSize', 8, 'LineWidth', 1.5);  
legend('Ob robu', 'V središču');

cx = size(img,2)/2;
cy = size(img,1)/2;

r_edge = sqrt((x1 - cx).^2 + (y1 - cy).^2);
r_center = sqrt((x2 - cx).^2 + (y2 - cy).^2);

f_values = 400:20:800;
sumSq = zeros(size(f_values));

for i = 1:length(f_values)
    f = f_values(i);

    rl_edge = -(f/2) * ((exp(-2*r_edge/f) - 1) ./ exp(-r_edge/f));
    rl_center = -(f/2) * ((exp(-2*r_center/f) - 1) ./ exp(-r_center/f));

    x1_corr = cx + (x1 - cx) .* (rl_edge ./ r_edge);
    y1_corr = cy + (y1 - cy) .* (rl_edge ./ r_edge);
    x2_corr = cx + (x2 - cx) .* (rl_center ./ r_center);
    y2_corr = cy + (y2 - cy) .* (rl_center ./ r_center);

    [~, dist1] = fitline([x1_corr'; y1_corr']);
    [~, dist2] = fitline([x2_corr'; y2_corr']);

    sumSq(i) = sum(dist1.^2) + sum(dist2.^2);
end

figure;
plot(f_values, sumSq, 'o-', 'LineWidth', 1.5);
xlabel('Parameter f');
ylabel('Vsota kvadratov razdalj');
title('Optimizacija radialne distorzije');
grid on;

[~, idx] = min(sumSq);
best_f = f_values(idx);
disp(['Najboljša vrednost parametra f = ', num2str(best_f)]);

%% 4. fminsearch

errorFun = @(f) computeError(f, x1, y1, x2, y2, cx, cy, r_edge, r_center);

f0 = 600;

options = optimset('Display', 'iter', 'TolX', 1e-6);

[f_opt, fval] = fminsearch(errorFun, f0, options);

disp('----------------------------------------------------');
fprintf('Optimalna vrednost parametra f = %.4f\n', f_opt);
fprintf('Minimalna vsota kvadratov razdalj = %.6f\n', fval);

rl_edge = -(f_opt/2) * ((exp(-2*r_edge/f_opt) - 1) ./ exp(-r_edge/f_opt));
rl_center = -(f_opt/2) * ((exp(-2*r_center/f_opt) - 1) ./ exp(-r_center/f_opt));

x1_corr = cx + (x1 - cx) .* (rl_edge ./ r_edge);
y1_corr = cy + (y1 - cy) .* (rl_edge ./ r_edge);
x2_corr = cx + (x2 - cx) .* (rl_center ./ r_center);
y2_corr = cy + (y2 - cy) .* (rl_center ./ r_center);

figure;
imshow(img), hold on;
plot(x1_corr, y1_corr, 'go-', 'LineWidth', 1.2);
plot(x2_corr, y2_corr, 'ro-', 'LineWidth', 1.2);
title(['Korigirane točke za optimalni f = ', num2str(f_opt)]);
legend('Leva linija', 'Sredinska linija');

%% ce
function E = computeError(f, x1, y1, x2, y2, cx, cy, r_edge, r_center)
    rl_edge = -(f/2) * ((exp(-2*r_edge/f) - 1) ./ exp(-r_edge/f));
    rl_center = -(f/2) * ((exp(-2*r_center/f) - 1) ./ exp(-r_center/f));

    x1_corr = cx + (x1 - cx) .* (rl_edge ./ r_edge);
    y1_corr = cy + (y1 - cy) .* (rl_edge ./ r_edge);
    x2_corr = cx + (x2 - cx) .* (rl_center ./ r_center);
    y2_corr = cy + (y2 - cy) .* (rl_center ./ r_center);

    [~, dist1] = fitline([x1_corr'; y1_corr']);
    [~, dist2] = fitline([x2_corr'; y2_corr']);

    E = sum(dist1.^2) + sum(dist2.^2);
end


==== END Jakob Ian Pintarič | Jakob Ian Pintarič_18916_assignsubmission_file | Vaja2.m ====

