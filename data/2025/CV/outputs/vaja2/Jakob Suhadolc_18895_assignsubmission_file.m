==== BEGIN Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | fitline.m ====
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




  
       
       
==== END Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | fitline.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | KalibracijeKamere_parametri_N1.txt ====
%Kalibracija kamera 
%Mihaela Temelkova & Jakob Suhadolc
Dobljeni rezultat po kalibraciji kameri s pomočjo slik: [1,2,4,8,13]

Calibration parameters after initialization:

Focal Length:          fc = [ 682.93657   682.93657 ]
Principal point:       cc = [ 319.50000   239.50000 ]
Skew:             alpha_c = [ 0.00000 ]   => angle of pixel = 90.00000 degrees
Distortion:            kc = [ 0.00000   0.00000   0.00000   0.00000   0.00000 ]

Main calibration optimization procedure - Number of images: 5


Calibration results after optimization (with uncertainties):

Focal Length:          fc = [ 657.95911   658.65428 ] ± [ 0.80636   1.03431 ]
Principal point:       cc = [ 304.14257   244.43037 ] ± [ 1.68351   1.38936 ]
Skew:             alpha_c = [ 0.00000 ] ± [ 0.00000  ]   => angle of pixel axes = 90.00000 ± 0.00000 degrees
Distortion:            kc = [ -0.25547   0.13456   0.00006   -0.00001  0.00000 ] ± [ 0.00712   0.03294   0.00034   0.00035  0.00000 ]
Pixel error:          err = [ 0.13038   0.11913 ]

Pixel error:      err = [0.13038   0.11913] (all active images)
==== END Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | KalibracijeKamere_parametri_N1.txt ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | NelinearnaOptimizacija_fminsearch_N4.m ====
%Nelinearna optimizacija fminsearch
%Mihaela Temelkova & Jakob Suhadolc
inputImage = imread('Image15.tif');
imshow(inputImage)
imageCenterX = 319.5;
imageCenterY = 239.5;

disp('Oznaci tocke za robno navpicno linijo')
[selectedEdgeX, selectedEdgeY] = ginput;
edgePoints = [selectedEdgeX'; selectedEdgeY'];

disp('Oznaci tocke za centralno navpicno linijo:')
[selectedCenterX, selectedCenterY] = ginput;
centerPoints = [selectedCenterX'; selectedCenterY'];
%%
%preveris ali je f=540

selectedEdgeX = [43 44 40 43 41 39 41 45 44 49];
selectedEdgeY = [69 106 146 181  221  259  290  392 423  451];
selectedCenterY=[84 124 157 195 231 332 394 428 454];
selectedCenterX=[275 272 269 265 262 256 251 250 250];
edgePoints   = [selectedEdgeX; selectedEdgeY];
centerPoints = [selectedCenterX; selectedCenterY];

objective = @(f) total_error_for_f(f, edgePoints, centerPoints, imageCenterX, imageCenterY);

initialGuess = 600;
bestFocalLength = fminsearch(objective, initialGuess);

fprintf('Najboljsi: %.3f\n', bestFocalLength);

f = bestFocalLength;
[xGrid, yGrid] = meshgrid(1:size(inputImage,2), 1:size(inputImage,1));
radialDistanceOriginal = sqrt((xGrid - imageCenterX).^2 + (yGrid - imageCenterY).^2);
radialDistanceMapped = f .* log((radialDistanceOriginal ./ f) + sqrt(1 + (radialDistanceOriginal ./ f).^2));
xGridCorrected = imageCenterX + (xGrid - imageCenterX) .* (radialDistanceMapped ./ radialDistanceOriginal);
yGridCorrected = imageCenterY + (yGrid - imageCenterY) .* (radialDistanceMapped ./ radialDistanceOriginal);

correctedImage = interp2(double(inputImage), xGridCorrected, yGridCorrected, 'linear', 0);
imshow(uint8(correctedImage))
title(sprintf('Popravljena slika (f = %.0f)', f))



function totalError = total_error_for_f(f, edgePoints, centerPoints, imageCenterX, imageCenterY)
    edgeError = compute_line_error(edgePoints, f, imageCenterX, imageCenterY);
    centerError = compute_line_error(centerPoints, f, imageCenterX, imageCenterY);
    totalError = edgeError + 1.0 * centerError;
end


function lineError = compute_line_error(points, f, imageCenterX, imageCenterY)
    x = points(1, :);
    y = points(2, :);
    radialDistanceOriginal = sqrt((x - imageCenterX).^2 + (y - imageCenterY).^2);
    radialDistanceCorrected = -(f/2) .* ((exp(-2*radialDistanceOriginal/f)) - 1) ./ exp(-radialDistanceOriginal/f);
    correctedX = imageCenterX + (x - imageCenterX) .* (radialDistanceCorrected ./ radialDistanceOriginal);
    correctedY = imageCenterY + (y - imageCenterY) .* (radialDistanceCorrected ./ radialDistanceOriginal);
    [~, distancesToLine] = fitline([correctedX; correctedY]);
    lineError = sum(distancesToLine.^2);
end
==== END Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | NelinearnaOptimizacija_fminsearch_N4.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | NelinearnaOptimizacija_fminsearch_part2N4.m ====
%Nelinearna optimizacija - fminsearch
%Mihaela Temelkova & Jakob Suhadolc

close all; clear; clc;

inputImage = imread('Image15.tif');
imshow(inputImage)
  
imageCenterX = 319.5;
imageCenterY = 239.5;

disp('Označi točke za robno navpično linijo in pritisni ENTER')
[selectedEdgeX, selectedEdgeY] = ginput;
edgePoints = [selectedEdgeX'; selectedEdgeY'];

disp('Označi točke za centralno navpično linijo in pritisni ENTER')
[selectedCenterX, selectedCenterY] = ginput;
centerPoints = [selectedCenterX'; selectedCenterY'];

selectedPoints = [selectedEdgeX'; selectedEdgeY'];
size(selectedPoints)
%%
% varovalo, da ne optimiziramo s praznimi podatki
if isempty(edgePoints) || isempty(centerPoints)
    error('Klikni nekaj tock na obeh linijah in pritisni Enter.');
end

%Preveris ce se ujema f = 540
selectedEdgeX = [43 44 40 43 41 39 41 45 44 49];
selectedEdgeY = [69 106 146 181  221  259  290  392 423  451];

selectedCenterY=[84 124 157 195 231 332 394 428 454];
selectedCenterX=[275 272 269 265 262 256 251 250 250];

edgePoints   = [selectedEdgeX; selectedEdgeY];
centerPoints = [selectedCenterX; selectedCenterY];

% minimizacija napake preko fminsearch 
objective = @(f) ...
    line_error(edgePoints,f,imageCenterX,imageCenterY) + ...
    line_error(centerPoints,f,imageCenterX,imageCenterY);

initialGuess = 600;
bestF = fminsearch(objective, initialGuess);

%  total error pri najboljšem f (in razbij po linijah) 
errEdge   = line_error(edgePoints,   bestF, imageCenterX, imageCenterY);
errCenter = line_error(centerPoints, bestF, imageCenterX, imageCenterY);
totalErr  = errEdge + errCenter;

fprintf('Najboljsi f = %.3f | total error = %.6f (edge=%.6f, center=%.6f)\n', ...
        bestF, totalErr, errEdge, errCenter);

%  popravek slike 
f = bestF;
[xGrid, yGrid] = meshgrid(1:size(inputImage,2), 1:size(inputImage,1));
r = sqrt((xGrid - imageCenterX).^2 + (yGrid - imageCenterY).^2);
r = max(r, eps);
r_mapped = f .* log((r./f) + sqrt(1 + (r./f).^2));
ratio = r_mapped ./ r;
xCorr = imageCenterX + (xGrid - imageCenterX).*ratio;
yCorr = imageCenterY + (yGrid - imageCenterY).*ratio;

correctedImage = interp2(double(inputImage), xCorr, yCorr, 'linear', 0);
figure; imshow(uint8(correctedImage));
title(sprintf('Popravljena slika (f = %.0f)', f));

% funcija ki racuna koliko je linija iskrivljena
function err = line_error(points, f, cx, cy)
    % prisili f v smiseln interval (da fminsearch ne pobegne)
    f = max(400, min(800, f));

    x = points(1,:);  y = points(2,:);
    r = sqrt((x - cx).^2 + (y - cy).^2);
    r = max(r, eps);  % varovalo proti deljenju z 0

    % inverse model: r = f^{-1}(r')
    r_corr = -(f/2) .* (exp(-2*r/f) - 1) ./ exp(-r/f);

    % popravljene koordinate
    scale = r_corr ./ r;
    x_corr = cx + (x - cx) .* scale;
    y_corr = cy + (y - cy) .* scale;

    % razdalje tock do najboljse premice
    [~, d] = fitline([x_corr; y_corr]);

    err = sum(d.^2);
end

==== END Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | NelinearnaOptimizacija_fminsearch_part2N4.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | normalise2dpts.m ====
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
    
    
    
==== END Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | normalise2dpts.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | ProjektivnaTransformacija_N2.m ====
% Mihaela Temelkova & Jakob Suhadolc
% Projektivna transformacija sahovnice
clear; close all; clc;
I = imread('Image1.tif');  

figure; imshow(I); title('Klikni: TL, TR, BR, BL'); 
[x,y] = ginput(4);                    
tocke_slika = [x y];   

st_kvad_x = 12;  % kvadratki po širini
st_kvad_y = 11;  % kvadratki po višini
dx = 30;  % [px]

W = st_kvad_x*dx;
H = st_kvad_y*dx;

% Idealne točke 
tocke_ideal = [0 0; W 0; W H; 0 H];

% Izračun projektivne transformacije
tform = maketform('projective', tocke_slika, tocke_ideal);

% Izvedemo transformacijo slike (poravnamo sahovnico)
[korigirana, xdata, ydata] = imtransform(I, tform, 'XData', [0 W], 'YData', [0 H]);
figure;
imshow(korigirana, []);
title('Korigirana (poravnana) sahovnica');

% Ustvarimo mrežo vseh oglišč (v idealni poravnani ravnini)
nx = st_kvad_x + 1;  % število stolpcev oglišč
ny = st_kvad_y + 1;  % število vrstic oglišč

[xg, yg] = meshgrid(linspace(0, W, nx), linspace(0, H, ny));

% Inverzna transformacija – iz idealnih koordinat v originalno sliko
tform_inv = maketform('projective', tocke_ideal, tocke_slika);
[mx, my] = tformfwd(tform_inv, xg, yg);

% 9. Narišemo mrežo oglišč na originalni sliki
figure;
imshow(I, []);
hold on;
title('Oglisca sahovnice');
axis image;

for j = 1:ny
    for i = 1:nx
        % Rdeče pike za oglišča
        plot(mx(j,i), my(j,i), 'x', 'MarkerSize', 4, 'LineWidth', 1);
    end
end

hold off;
==== END Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | ProjektivnaTransformacija_N2.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | radialna_distorzija.m ====
%Radialna distorzija 
%Jakob Suhadolc & Mihaela Temelkova
inputImage = imread('Image15.tif');
imshow(inputImage)

imageCenterX = 319.5;
imageCenterY = 239.5;

%selectamo dve navpicni liniji in potrdimo s ENTER
disp('Oznaci tocke za robno navpicno linijo')
[selectedEdgeX, selectedEdgeY] = ginput;
edgePoints = [selectedEdgeX'; selectedEdgeY'];

disp('Oznaci tocke za centralno navpicno linijo:')
[selectedCenterX, selectedCenterY] = ginput;
centerPoints = [selectedCenterX'; selectedCenterY'];

selectedPoints = [selectedEdgeX'; selectedEdgeY'];
size(selectedPoints)
%%
%Preveris ce se ujema f = 540
selectedEdgeX = [43 44 40 43 41 39 41 45 44 49]';
selectedEdgeY = [69 106 146 181  221  259  290  392 423  451]';

selectedCenterY=[84 124 157 195 231 332 394 428 454]';
selectedCenterX=[275 272 269 265 262 256 251 250 250]';

edgePoints   = [selectedEdgeX; selectedEdgeY];
centerPoints = [selectedCenterX; selectedCenterY];

focalLengthCandidates = 400:20:800;
totalErrorPerCandidate = zeros(size(focalLengthCandidates));


for idx = 1:length(focalLengthCandidates)
    currentFocalLength = focalLengthCandidates(idx);

    edgeRadialDistanceOriginal = sqrt((selectedEdgeX - imageCenterX).^2 + (selectedEdgeY - imageCenterY).^2);
    edgeRadialDistanceCorrected = -(currentFocalLength/2) .* ((exp(-2*edgeRadialDistanceOriginal/currentFocalLength)) - 1) ./ exp(-edgeRadialDistanceOriginal/currentFocalLength);
    correctedEdgeX = imageCenterX + (selectedEdgeX - imageCenterX) .* (edgeRadialDistanceCorrected ./ edgeRadialDistanceOriginal);
    correctedEdgeY = imageCenterY + (selectedEdgeY - imageCenterY) .* (edgeRadialDistanceCorrected ./ edgeRadialDistanceOriginal);
    [~, edgePointLineDistances] = fitline([correctedEdgeX'; correctedEdgeY']);
    edgeLineError = sum(edgePointLineDistances.^2);

    centerRadialDistanceOriginal = sqrt((selectedCenterX - imageCenterX).^2 + (selectedCenterY - imageCenterY).^2);
    centerRadialDistanceCorrected = -(currentFocalLength/2) .* ((exp(-2*centerRadialDistanceOriginal/currentFocalLength)) - 1) ./ exp(-centerRadialDistanceOriginal/currentFocalLength);
    correctedCenterX = imageCenterX + (selectedCenterX - imageCenterX) .* (centerRadialDistanceCorrected ./ centerRadialDistanceOriginal);
    correctedCenterY = imageCenterY + (selectedCenterY - imageCenterY) .* (centerRadialDistanceCorrected ./ centerRadialDistanceOriginal);
    [~, centerPointLineDistances] = fitline([correctedCenterX'; correctedCenterY']);
    centerLineError = sum(centerPointLineDistances.^2);

    totalErrorPerCandidate(idx) = edgeLineError + 1.0 * centerLineError;
end

figure('Name','SSD vs f'); 
plot(focalLengthCandidates, totalErrorPerCandidate, '-o');
grid on; xlabel('f'); ylabel('Vsota kvadratov razdalje'); title('Iskanje najboljšega f');


[~, bestIndex] = min(totalErrorPerCandidate);
bestFocalLength = focalLengthCandidates(bestIndex)

f = bestFocalLength;
[xGrid, yGrid] = meshgrid(1:size(inputImage,2), 1:size(inputImage,1));
radialDistanceOriginal = sqrt((xGrid - imageCenterX).^2 + (yGrid - imageCenterY).^2);

radialDistanceMapped = f .* log((radialDistanceOriginal ./ f) + sqrt(1 + (radialDistanceOriginal ./ f).^2));
xGridCorrected = imageCenterX + (xGrid - imageCenterX) .* (radialDistanceMapped ./ radialDistanceOriginal);
yGridCorrected = imageCenterY + (yGrid - imageCenterY) .* (radialDistanceMapped ./ radialDistanceOriginal);

figure('Name','Popravljena slika');
correctedImage = interp2(double(inputImage), xGridCorrected, yGridCorrected, 'linear', 0);
imshow(uint8(correctedImage))
title(sprintf('Popravljena slika (f = %.0f)', f))
==== END Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | radialna_distorzija.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | Radialna_distorzija_part2_N3.m ====

%Radialna distorzija 
%Jakob Suhadolc & Mihaela Temelkova

inputImage = imread('Image15.tif');
imshow(inputImage)

imageCenterX = 319.5;
imageCenterY = 239.5;

% izberi dve navpični liniji (Enter za konec)
disp('Označi točke za robno navpično linijo in pritisni ENTER')
[selectedEdgeX, selectedEdgeY] = ginput;
edgePoints = [selectedEdgeX; selectedEdgeY];
% Xedge=[43 44 40 43 41 39 41 45 44 49]
% Yedge=[69 106 146 181  221  259  290  392 423  451]

disp('Označi točke za centralno navpično linijo in pritisni ENTER')
[selectedCenterX, selectedCenterY] = ginput;
centerPoints = [selectedCenterX; selectedCenterY];
%Xcen=[275 272 269 265 262 256 251 250 250]
%Ycen=[84 124 157 195 231 332 394 428 454]

selectedPoints = [selectedEdgeX; selectedEdgeY];
size(selectedPoints)

%%
%Preveris ce se ujema f = 540
% selectedEdgeX = [43 44 40 43 41 39 41 45 44 49]';
% selectedEdgeY = [69 106 146 181  221  259  290  392 423  451]';
% 
% selectedCenterY=[84 124 157 195 231 332 394 428 454]';
% selectedCenterX=[275 272 269 265 262 256 251 250 250]';
% 
% edgePoints   = [selectedEdgeX; selectedEdgeY];
% centerPoints = [selectedCenterX; selectedCenterY];
% 
focalLengthCandidates = 400:20:800;
totalErrorPerCandidate = zeros(size(focalLengthCandidates));

for idx = 1:length(focalLengthCandidates)
    f = focalLengthCandidates(idx);

    %  ROBNA linija
    % radialna razdalja r' (od centra) za vsako robno točko
    rE = sqrt((selectedEdgeX - imageCenterX).^2 + (selectedEdgeY - imageCenterY).^2);
    rE = max(rE, eps); % varovalo
    rE_corr = -(f/2) .* (exp(-2*rE/f) - 1) ./ exp(-rE/f);  % podana enačba

    scaleE = rE_corr ./ rE;
    xE = imageCenterX + (selectedEdgeX - imageCenterX).*scaleE;
    yE = imageCenterY + (selectedEdgeY - imageCenterY).*scaleE;
    [~, dE] = fitline([xE'; yE']);
    errE = sum(dE.^2);

 
    % CENTRALNA linija
    rC = sqrt((selectedCenterX - imageCenterX).^2 + (selectedCenterY - imageCenterY).^2);
    rC = max(rC, eps);
    rC_corr = -(f/2) .* (exp(-2*rC/f) - 1) ./ exp(-rC/f);

    scaleC = rC_corr ./ rC;
    xC = imageCenterX + (selectedCenterX - imageCenterX).*scaleC;
    yC = imageCenterY + (selectedCenterY - imageCenterY).*scaleC;

    [~, dC] = fitline([xC'; yC']);
    errC = sum(dC.^2);

    % skupna SSD napaka (rob + center)
    totalErrorPerCandidate(idx) = errE + errC;
end

% graf SSD
figure('Name','SSD vs f'); 
plot(focalLengthCandidates, totalErrorPerCandidate, '-o'); grid on;
xlabel('f'); ylabel('Vsota kvadratov razdalj (SSD)');
title('Iskanje najboljšega f');

[~, bestIndex] = min(totalErrorPerCandidate);
bestFocalLength = focalLengthCandidates(bestIndex)
hold on;

plot(bestFocalLength, totalErrorPerCandidate(bestIndex), 'rx', 'MarkerSize', 12, 'LineWidth', 2);
xline(bestFocalLength, '--r', sprintf('  best f = %d', bestFocalLength), 'LabelVerticalAlignment','bottom');
hold off;

% popravek slike
f = bestFocalLength;
[xGrid, yGrid] = meshgrid(1:size(inputImage,2), 1:size(inputImage,1));
r_new = sqrt((xGrid - imageCenterX).^2 + (yGrid - imageCenterY).^2);
r_new = max(r_new, eps); % varovalo

% inverzni model: r' = f * log( r/f + sqrt(1 + (r/f)^2) )
r_old = f .* log((r_new./f) + sqrt(1 + (r_new./f).^2));
ratio = r_old ./ r_new;
xGridCorrected = imageCenterX + (xGrid - imageCenterX).*ratio;
yGridCorrected = imageCenterY + (yGrid - imageCenterY).*ratio;

figure('Name','Popravljena slika');
correctedImage = interp2(double(inputImage), xGridCorrected, yGridCorrected, 'linear', 0);
imshow(uint8(correctedImage));
title(sprintf('Popravljena slika (f = %d)', f));
==== END Jakob Suhadolc | Jakob Suhadolc_18895_assignsubmission_file | Radialna_distorzija_part2_N3.m ====

