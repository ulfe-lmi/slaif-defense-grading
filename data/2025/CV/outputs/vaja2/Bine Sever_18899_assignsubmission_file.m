==== BEGIN Bine Sever | Bine Sever_18899_assignsubmission_file | CalibParameters.txt ====
Focal Length:          fc = [ 657.65096   657.87694 ] ± [ 0.94132   1.02881 ]
Principal point:       cc = [ 303.44701   242.59023 ] ± [ 1.51293   1.36895 ]
Skew:             alpha_c = [ 0.00000 ] ± [ 0.00000  ]   => angle of pixel axes = 90.00000 ± 0.00000 degrees
Distortion:            kc = [ -0.25990   0.14798   -0.00022   0.00003  0.00000 ] ± [ 0.00701   0.03600   0.00033   0.00033  0.00000 ]
Pixel error:          err = [ 0.11975   0.11100 ]
==== END Bine Sever | Bine Sever_18899_assignsubmission_file | CalibParameters.txt ====

==== BEGIN Bine Sever | Bine Sever_18899_assignsubmission_file | fitline.m ====
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




  
       
       
==== END Bine Sever | Bine Sever_18899_assignsubmission_file | fitline.m ====

==== BEGIN Bine Sever | Bine Sever_18899_assignsubmission_file | normalise2dpts.m ====
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
    
    
    
==== END Bine Sever | Bine Sever_18899_assignsubmission_file | normalise2dpts.m ====

==== BEGIN Bine Sever | Bine Sever_18899_assignsubmission_file | Vaja2.m ====
import fitline.*
import normalise2dpts.*


sahovnica = imread("Image_rect7.tif");
imshow(sahovnica);
title("Izberi presečiščne točke oblike 12x11")

[x,y] = ginput(4);

input_points = [x,y];

x_kvadratov = 12;
y_kvadratov = 11;
dxy = 30;

sizex = x_kvadratov*dxy;
sizey = y_kvadratov*dxy;

output_points = [0 0;           
                 sizex 0;
                 sizex sizey;
                 0 sizey];

T = maketform('projective', input_points, output_points);


I_corrected = imtransform(sahovnica, T, 'XData', [0 sizex], 'YData', [0 sizey]);

num_corners_x = x_kvadratov + 1;
num_corners_y = y_kvadratov + 1;

[xg, yg] = meshgrid(0:dxy:(num_corners_x-1)*dxy, 0:dxy:(num_corners_y-1)*dxy);

figure;
imshow(I_corrected);
hold on;
plot(xg, yg, 'ro', 'MarkerSize', 5);
title('Projektivno popravljena slika (maketform + imtransform)');

tocke_pop = [xg(:),yg(:)];

Ti = maketform('projective',output_points, input_points);

[X_orig, Y_Orig] = tformfwd(Ti, tocke_pop(:,1), tocke_pop(:,2));

figure;
imshow(sahovnica)
hold on;
plot(X_orig, Y_Orig,'ro', 'MarkerSize', 5)
title('popravljene točke')

%naloga 3
figure
ImDistorsion = imread("Image15.tif");
imshow(ImDistorsion)
title("Označi 6 presečišč vertikalnih stranic šahovnice to izriše premico, nariši 2 premice")
hold on

cx = 303.44701;
cy = 242.59023;

for i = 1:2
    [x2,y2] = ginput(6);
    XY = [x2'; y2'];
    C = fitline(XY);

    ypoints = linspace(min(y2), max(y2), 500);
    xpoints = (-(ypoints*C(2)) - C(3)) / C(1);

    if i == 1
        plot(xpoints,ypoints,"b")
        alpha1  = atan2(XY(2,:) - cy, XY(1,:) - cx);
        r_dist1 = sqrt((cx-XY(1,:)).^2 + (cy-XY(2,:)).^2);
    elseif i == 2
        plot(xpoints,ypoints,"g")
        alpha2 = atan2(XY(2,:) - cy, XY(1,:) - cx);
        r_dist2 = sqrt((cx-XY(1,:)).^2 + (cy-XY(2,:)).^2);
    end
 
end  
  

r1_popr = r_dist1;
r2_popr = r_dist2;



X1_popr = XY(1);
Y1_popr = XY(2);

f_values = 400:20:800;      
sumSq1 = zeros(size(f_values));
sumSq2 = zeros(size(f_values));
SummAll = zeros(size(f_values));


for k = 1:numel(f_values)
    f = f_values(k);

        r1_popr = (-f/2) .* ((exp(-(2*r_dist1)./f) - 1) ./ exp(-(r_dist1)./f));
        r2_popr = (-f/2) .* ((exp(-(2*r_dist2)./f) - 1) ./ exp(-(r_dist2)./f));

        X1_popr = cx + r1_popr .* cos(alpha1);
        Y1_popr = cy + r1_popr .* sin(alpha1);
        XY1 = [X1_popr; Y1_popr];
        [~,dst1] = fitline(XY1);
        sumSq1(k) = sum(dst1.^2);

        X2_popr = cx + r2_popr .* cos(alpha2);
        Y2_popr = cy + r2_popr .* sin(alpha2);
        XY2 = [X2_popr; Y2_popr];
        [~,dst2] = fitline(XY2);
        sumSq2(k) = sum(dst2.^2);

        SummAll(k) = sumSq1(k) + sumSq2(k);

end
      
figure
title("Napaka distorzije")
plot(f_values,sumSq1,'b')
hold on
plot(f_values,sumSq2,'g');
hold on
plot(f_values,SummAll,'y')
legend('Napaka prve črte','Napaka druge črte', 'skupna napaka')
xlabel("f")
ylabel("Napaka")

%Naloga 4
function skupna_napaka = PopraviDistorzijo(f, cx, cy, r_dists, alphas)

    skupna_napaka = 0;

    for i = 1:numel(r_dists)
        r_corr = (-f/2) .* ((exp(-(2*r_dists{i})./f) - 1) ./ exp(-(r_dists{i})./f));

        X_corr = cx + r_corr .* cos(alphas{i});
        Y_corr = cy + r_corr .* sin(alphas{i});

        [~, dist] = fitline([X_corr; Y_corr]);

        skupna_napaka = skupna_napaka + sum(dist.^2);
    end
end


r_dists = {r_dist1, r_dist2};
alphas = {alpha1, alpha2};

f0 = 600;

f_opt = fminsearch(@(f) PopraviDistorzijo(f, cx, cy, r_dists, alphas), f0);

fprintf('Optimalni parameter f = %.2f\n', f_opt);

    
   
==== END Bine Sever | Bine Sever_18899_assignsubmission_file | Vaja2.m ====

