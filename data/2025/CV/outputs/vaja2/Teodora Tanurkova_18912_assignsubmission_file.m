==== BEGIN Teodora Tanurkova | Teodora Tanurkova_18912_assignsubmission_file | Calibration results.txt ====
Calibration results:
Used pictures - Image2, Image4, Image6, Image10, Image11

Focal Length:          fc = [ 657.38229   657.75723 ] ± [ 0.89116   1.15016 ]
Principal point:       cc = [ 305.69055   243.09500 ] ± [ 1.74946   1.33020 ]
Skew:             alpha_c = [ 0.00000 ] ± [ 0.00000  ]   => angle of pixel axes = 90.00000 ± 0.00000 degrees
Distortion:            kc = [ -0.26367   0.16154   0.00007   0.00052  0.00000 ] ± [ 0.00691   0.03340   0.00033   0.00036  0.00000 ]
Pixel error:          err = [ 0.12381   0.12378 ]
==== END Teodora Tanurkova | Teodora Tanurkova_18912_assignsubmission_file | Calibration results.txt ====

==== BEGIN Teodora Tanurkova | Teodora Tanurkova_18912_assignsubmission_file | fitline.m ====
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




  
       
       
==== END Teodora Tanurkova | Teodora Tanurkova_18912_assignsubmission_file | fitline.m ====

==== BEGIN Teodora Tanurkova | Teodora Tanurkova_18912_assignsubmission_file | normalise2dpts.m ====
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
    
    
    
==== END Teodora Tanurkova | Teodora Tanurkova_18912_assignsubmission_file | normalise2dpts.m ====

==== BEGIN Teodora Tanurkova | Teodora Tanurkova_18912_assignsubmission_file | Vaja2koda.m ====

%% 2 naloga
figure(1);
shahovnica = imread('Image_rect13.tif');
imshow(shahovnica);

[x0,y0] = ginput(4);
points = [x0, y0];
squares_alongX = 12;
squares_alongY = 11;
dxy = 30;

dolzinoX = squares_alongX*dxy;
dolzinoY = squares_alongY*dxy;

OutputP = [0 0;
    dolzinoX 0; 
    dolzinoX dolzinoY; 
    0 dolzinoY];

T = maketform('projective', points, OutputP);
I_corrected = imtransform (shahovnica,T,'XData', [0 dolzinoX],'YData', [0 dolzinoY]);

[xg, yg] = meshgrid(0:dxy:dolzinoX, 0:dxy:dolzinoY); 

figure;
imshow(I_corrected);
hold on;
plot(xg, yg, 'rx', 'MarkerSize', 5);

T_inv = maketform('projective', OutputP, points); 

[x_back, y_back] = tformfwd(T_inv, xg(:), yg(:));

figure; 
imshow(shahovnica);
hold on;
plot(x_back, y_back, 'rx', 'MarkerSize', 6, 'LineWidth',1);
title('Vsa oglišča šahovnice preslikana nazaj na original (inverzna transformacija)');

%% 3 naloga

figure
ImDistortion = imread('Image15.tif');
imshow(ImDistortion);
title('oznaci 6 tocke ki so kotov kvadratkov na eno vertikalo, da bi se izrisali 3 premici')
hold on

cx = 305.69055;
cy = 243.09499;

%X = [43, 41, 40, 41, 44, 47;
 %    311, 304, 298, 292, 284, 279];
%Y = [69, 146, 221, 294, 394, 454;
 %    88, 162, 233, 301, 396, 454];
for i=1:2
    [x2,y2] = ginput(6);
    %x2 = X(i, :);
    %y2 = Y(i, :);
    XY = [x2'; y2']; %jo transporiramo(') ce pisemo tocke z ginuput, da dobimo obliko 2xN, avtomatski pa prevzame Nx2 oblika
    C = fitline(XY);

    yPoints = linspace(min(y2), max(y2), 500);
    xPoints = (-(yPoints*C(2)) - C(3))/ C(1);

    if i == 1
        plot(xPoints, yPoints, 'g')
        alpha1 = atan2(XY(2,:) - cy, XY(1,:) - cx);
        rad1_popacen = sqrt((cx - XY(1, :)).^2 + (cy - XY(2,:)).^2);
    elseif i ==2
        plot(xPoints, yPoints, 'b')
        alpha2 = atan2(XY(2,:) - cy, XY(1,:) - cx);
        rad2_popacen = sqrt((cx - XY(1, :)).^2 + (cy - XY(2,:)).^2);
    end
end

f_values = 400:20:800;
SumSq1 = zeros(size(f_values));
SumSq2 = zeros(size(f_values));
SumAll = zeros(size(f_values));


for k = 1:numel(f_values)
    f = f_values(k);

    r_popr1 = (-f/2) .* ((exp(-(2*rad1_popacen)./f) - 1) ./ (exp(-(rad1_popacen)./f))); %pika zarad mnozenje posebnega elementa iz vektor z vec elementov
    r_popr2 = (-f/2) .* ((exp(-(2*rad2_popacen)./f) - 1) ./ (exp(-(rad2_popacen)./f)));
    
    X1_popr = cx + r_popr1 .* cos(alpha1);
    Y1_popr = cy + r_popr1 .* sin(alpha1);
    XY1 = [X1_popr;Y1_popr]; %tukaj ne transporniramo, ker r_popr1,2,3 so ze vrsticni vektorji 1xN
    [~, dist1] = fitline(XY1);
    SumSq1(k) = sum(dist1.^2);
    
    X2_popr = cx + r_popr2 .* cos(alpha2);
    Y2_popr = cy + r_popr2 .* sin(alpha2);
    XY2 = [X2_popr;Y2_popr]; 
    [~, dist2] = fitline(XY2);
    SumSq2(k) = sum(dist2.^2);
    
    SumAll(k) = SumSq1(k) + SumSq2(k);

end

figure
title("Napaka distorzije")
plot(f_values,SumSq1,'b')
hold on
plot(f_values,SumSq2,'g');
hold on
plot(f_values,SumAll,'y')
legend('Napaka prve črte','Napaka druge črte', 'Skupna napaka')
xlabel("f")
ylabel("Napaka")

% 4 Naloga

r_popacen = {rad1_popacen, rad2_popacen};
alphas = {alpha1, alpha2};
f0 = 600;

[f_optimalen, minNapaka] = fminsearch(@(f) distorzijapopr(f, cx, cy, r_popacen, alphas), f0);
 %@(f) pomeni da vhodni parameter v funkciji je f, ker fminsearch prevzame
 %funkcijo samo z enim parametrom tukaj povedamo s tem da spreminjamo samo f
 %ostale par. v fji ostanejo nespremenjeni, zacne pa iskati pri f0
 fprintf('Optimalni parameter f = %.2f\n', f_optimalen);
 fprintf('Minimalna skupna napaka = %.6f\n', minNapaka);
 
 function skupnaNapaka = distorzijapopr(f, cx, cy, r_popacen, alphas)
        
         skupnaNapaka = 0;
         for i = 1:numel(r_popacen)

             r_popravljen = (-f/2) .* ((exp(-(2*r_popacen{i})./f) - 1) ./ (exp(-(r_popacen{i})./f)));
           
             X_popravljen = cx + r_popravljen .* cos(alphas{i});
             Y_popravljen = cy + r_popravljen .* sin(alphas{i});

             XYo = [X_popravljen; Y_popravljen];
             [~, dist] = fitline(XYo);

             skupnaNapaka = skupnaNapaka + sum(dist.^2);
         end
end

























==== END Teodora Tanurkova | Teodora Tanurkova_18912_assignsubmission_file | Vaja2koda.m ====

