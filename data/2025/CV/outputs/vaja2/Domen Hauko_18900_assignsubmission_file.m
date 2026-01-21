==== BEGIN Domen Hauko | Domen Hauko_18900_assignsubmission_file | nonlin_calib.m ====
function nonlin_calib = nonlin_calib(f, corners_edge, corners_middle, principal_point)
% Izračuna vsoto kvadratov napak za dano vrednost f.
% Uporablja enačbo: r' = (f/2)*(exp(r/f) - exp(-r/f)) = f*sinh(r/f)
% in metodo phi–cos/sin za popravljanje koordinat.
    
    % center
    cx = principal_point(1);
    cy = principal_point(2); 

    % x,y od principal point do tock na robu
    dx_e = corners_edge(:,1)   - cx;   
    dy_e = corners_edge(:,2)   - cy;
    % x,y od principal point do tock na sredini
    dx_m = corners_middle(:,1) - cx;   
    dy_m = corners_middle(:,2) - cy;
    
    % radij do tock na robu
    r_e  = sqrt(dx_e.^2 + dy_e.^2);  
    % phi za tocke na robu
    phi_e = atan2(dy_e, dx_e);

    % radij do tock na sredini
    r_m  = sqrt(dx_m.^2 + dy_m.^2);  
    % phi do tock na sredini
    phi_m = atan2(dy_m, dx_m);

    % corrected distortion (po formuli)
    rl_e = (f/2) * (exp(r_e./f) - exp(-r_e./f));
    rl_m = (f/2) * (exp(r_m./f) - exp(-r_m./f));

    % razlika v dolzini ko je r popravljen
    dr_e = rl_e - r_e; % za robne piksle
    dr_m = rl_m - r_m; % za sredinske piksle

    
    % robne tocke
    x_e_corr = corners_edge(:,1)   + dr_e .* cos(phi_e); % x za kolikor se mora premakniti originalno tocko
    y_e_corr = corners_edge(:,2)   + dr_e .* sin(phi_e); % y za kolikor se mora premakniti originalno tocko
    % sredinske tocke
    x_m_corr = corners_middle(:,1) + dr_m .* cos(phi_m); % x za kolikor se mora premakniti originalno tocko
    y_m_corr = corners_middle(:,2) + dr_m .* sin(phi_m); % y za kolikor se mora premakniti originalno tocko

    [~, dist_e] = fitline([x_e_corr'; y_e_corr']);
    [~, dist_m] = fitline([x_m_corr'; y_m_corr']);
    nonlin_calib = sum(dist_e.^2) + sum(dist_m.^2);

end
==== END Domen Hauko | Domen Hauko_18900_assignsubmission_file | nonlin_calib.m ====

==== BEGIN Domen Hauko | Domen Hauko_18900_assignsubmission_file | vaja2 .txt ====

// Number(s) of image(s) to process ([] = all images) = [1 5 7 10 11]


Initialization of the intrinsic parameters - Number of images: 6


Calibration parameters after initialization:

Focal Length:          fc = [ 668.95378   668.95378 ]
Principal point:       cc = [ 319.50000   239.50000 ]
Skew:             alpha_c = [ 0.00000 ]   => angle of pixel = 90.00000 degrees
Distortion:            kc = [ 0.00000   0.00000   0.00000   0.00000   0.00000 ]

Main calibration optimization procedure - Number of images: 6
Gradient descent iterations: 1...2...3...4...5...6...7...8...9...done
Estimation of uncertainties...done


Calibration results after optimization (with uncertainties):

Focal Length:          fc = [ 658.26515   658.41272 ] ± [ 0.70533   0.79651 ]
Principal point:       cc = [ 302.15249   244.27593 ] ± [ 1.42230   1.27927 ]
Skew:             alpha_c = [ 0.00000 ] ± [ 0.00000  ]   => angle of pixel axes = 90.00000 ± 0.00000 degrees
Distortion:            kc = [ -0.26081   0.15406   -0.00004   -0.00024  0.00000 ] ± [ 0.00636   0.03332   0.00030   0.00029  0.00000 ]
Pixel error:          err = [ 0.11500   0.11345 ]

Note: The numerical errors are approximately three times the standard deviations (for reference).
Pixel error:          err = [ 0.11500   0.11345] (all active images)
==== END Domen Hauko | Domen Hauko_18900_assignsubmission_file | vaja2 .txt ====

==== BEGIN Domen Hauko | Domen Hauko_18900_assignsubmission_file | vaja2.m ====
%% 2.

img = imread("Image_rect13.tif");

figure;
imshow(img);
%title("Izberi 4 točke, 12x11 kvadratov. (Zgoraj levo -> Zgoraj desno -> Spodaj desno -> Spodaj levo)");
%corners = ginput(4);
%poklikane tocke
corners = [
    [143.8017,   70.1774];
    [549.1148,  111.1641];
    [467.1414,  398.9820];
    [138.3368,  389.8738]  
];

Nx = 12; % št. kvadratov po x (vodoravno)
Ny = 11; % št. kvadratov po y (navpično)
sq = 30; % velikost kvadrata

W = Nx * sq;    % širina slike mreže
H = Ny * sq;

corners_transformed = [1, 1; W, 1; W, H; 1, H];


T = maketform('projective', corners, corners_transformed);
T_inv = maketform('projective', corners_transformed, corners);

transformed = imtransform(img, T, 'XData', [1 W], 'YData', [1 H]);
figure;
imshow(transformed);
title("transformirana šahovnica");

x_ogl = [];
y_ogl = [];
for x = 1:sq:W+1
    for y = 1:sq:H+1
        [x_orig, y_orig] = tformfwd(T_inv, x, y);
        x_ogl = [x_ogl; x_orig]; % doda na konec
        y_ogl = [y_ogl; y_orig];
    end
end

% druga moznost
%[xg, yg] = meshgrid(1:sq:W+1, 1:sq:H+1);   % (Nx+1) x (Ny+1) oglišč
%[x_ogl, y_ogl] = tformfwd(T_inv, xg(:), yg(:));

figure; 
imshow(img, []); hold on;
plot(x_ogl, y_ogl, 'r.', 'MarkerSize', 12);
title("Označena oglišča na originalni sliki");


%% 3:

img = imread("Image15.tif");
% figure;
% imshow(img); hold on;
% title("Izberi oglišča vertikalne vrstice ob robu slike(12 oglisc)");
% corners_edge = ginput(12);
% plot(corners_edge(:,1), corners_edge(:,2),'r.', 'MarkerSize', 12);
% title("Izberi oglišča vertikalne vrstice na sredini slike(12 oglisc)")
% corners_middle = ginput(12);
% plot(corners_middle(:,1), corners_middle(:,2),'r.', 'MarkerSize', 12);

% poklikane tocke
corners_edge = [
   [43.6120,   69.2666];
   [41.7903,  107.5209];
   [42.7011,  146.6860];
   [41.7903,  184.0294];
   [41.7903,  220.4620];
   [39.9687,  256.8947];
   [39.9687,  293.3273];
   [39.9687,  327.9383];
   [41.7903,  360.7277];
   [44.5228,  392.6063];
   [44.5228,  423.5740];
   [48.1660,  453.6309]
];

corners_middle = [
    [311.3918,   87.4829];
    [306.8378,  123.9156];
    [303.1945,  161.2590];
    [301.3729,  196.7808];
    [297.7296,  233.2135];
    [294.9972,  266.9137];
    [292.2647,  301.5247];
    [288.6214,  333.4032];
    [285.8890,  365.2818];
    [284.0674,  393.5171];
    [280.4241,  424.4848];
    [278.6025,  451.8093]
];

figure;
imshow(img); hold on;
plot(corners_edge(:,1), corners_edge(:,2),'r.', 'MarkerSize', 12);
plot(corners_middle(:,1), corners_middle(:,2),'r.', 'MarkerSize', 12);

XY_edge   = [corners_edge(:,1)';   corners_edge(:,2)'];
XY_middle = [corners_middle(:,1)'; corners_middle(:,2)'];

[c_edge, dist_edge] = fitline(XY_edge);
[c_middle, dist_middle] = fitline(XY_middle);

% c(1)*X + c(2)*Y + c(3) = 0 (iz dokumentacije fitline.m)
% Y = -c(1)*x + c(3)/c(2)
figure;
imshow(img); hold on;
plot(xlim, -(c_edge(1)*xlim + c_edge(3))/c_edge(2), 'r-', 'LineWidth', 1.5);
plot(xlim, -(c_middle(1)*xlim + c_middle(3))/c_middle(2), 'g-', 'LineWidth', 1.5);


principal_point = [ 319.50000   239.50000 ];
center_x = 319.50000;
center_y = 239.50000;
r_edge   = sqrt( (corners_edge(:,1)   - center_x).^2 + (corners_edge(:,2)   - center_y).^2 );
r_middle = sqrt( (corners_middle(:,1) - center_x).^2 + (corners_middle(:,2) - center_y).^2 );

SSE_total = [];
for f = 400:20:800
    corrected_edge_x = [];
    corrected_edge_y = [];
    corrected_middle_x = [];
    corrected_middle_y = [];
    for i = 1 : size(r_edge,1)
        % robni piksli
        x_edge = corners_edge(i,1); % x tocke
        y_edge = corners_edge(i,2); % y tocke
        x_pp_edge = x_edge - center_x; % x od tocke do principal point
        y_pp_edge = y_edge - center_y; % y od tocke do pp
        phi_edge = atan2(y_pp_edge, x_pp_edge); % kot med vodoravno osjo in r
        r_dist_edge = r_edge(i,:); % calculated radial distortion for distorted image
       
        rl_edge = (-f/2) * (exp(-2*r_dist_edge/f) -1) / exp(-r_dist_edge/f); % corrected distortion (po formuli)
        
        dr_edge = rl_edge - r_dist_edge; % razlika v dolzini ko je r popravljen
        dx_edge = dr_edge * cos(phi_edge); % x za kolikor se mora premakniti originalno tocko
        dy_edge = dr_edge * sin(phi_edge); % y za kolikor se mora premakniti originalno tocko

        % shrani novo tocko
        corrected_edge_x = [corrected_edge_x ; x_edge + dx_edge]; 
        corrected_edge_y = [corrected_edge_y ; y_edge + dy_edge];

        % sredinski piksli (enak postopek)
        x_middle = corners_middle(i,1);
        y_middle = corners_middle(i,2);
        x_pp_middle = x_middle - center_x; % x od tocke do principal point
        y_pp_middle = y_middle - center_y; % y od tocke do pp
        phi_middle = atan2(y_pp_middle, x_pp_middle);
        r_dist_middle = r_middle(i,:); % calculated radial distortion for distorted image
       
        rl_middle = (-f/2) * (exp(-2*r_dist_middle/f) -1) / exp(-r_dist_middle/f); %corrected distortion

        dr_middle = rl_middle - r_dist_middle;
        dx_middle = dr_middle * cos(phi_middle);
        dy_middle = dr_middle * sin(phi_middle);


        corrected_middle_x = [corrected_middle_x ; x_middle + dx_middle];
        corrected_middle_y = [corrected_middle_y ; y_middle + dy_middle];
    end
    % izracunane razdalje od premice ki je fittana po novih tockah
    [~, dist_e] = fitline([corrected_edge_x'; corrected_edge_y']);
    [~, dist_m] = fitline([corrected_middle_x';  corrected_middle_y']);
    SSE_total = [SSE_total ; sum(dist_e.^2) + sum(dist_m.^2)]; % vsota kvadratnih napak za popravljene tocke
end

f_values  = (400:20:800).';
figure; 
plot(f_values, SSE_total, '-o', 'LineWidth', 1.5);
grid on; 
xlabel('f'); ylabel('SSE');
title('error');


f0 = 500;
f_opt = fminsearch(@(f) nonlin_calib(f, corners_edge, corners_middle, principal_point), f0);
f_opt


%% DOC za fitline.m
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
==== END Domen Hauko | Domen Hauko_18900_assignsubmission_file | vaja2.m ====

