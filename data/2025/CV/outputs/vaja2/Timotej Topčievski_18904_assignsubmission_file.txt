==== BEGIN Timotej Topčievski | Timotej Topčievski_18904_assignsubmission_file | calib_data.txt ====
fc =
  657.4439
  657.8187

cc =
  303.1567
  241.9562

kc =
   -0.2617
    0.1617
   -0.0006
   -0.0000
         0

alpha_c =
     0

==== END Timotej Topčievski | Timotej Topčievski_18904_assignsubmission_file | calib_data.txt ====

==== BEGIN Timotej Topčievski | Timotej Topčievski_18904_assignsubmission_file | fminsearch.txt ====
Optimalna vrednost f = 563.0589
==== END Timotej Topčievski | Timotej Topčievski_18904_assignsubmission_file | fminsearch.txt ====

==== BEGIN Timotej Topčievski | Timotej Topčievski_18904_assignsubmission_file | vaja2.m ====
%% Naloga 2.1: Kalibracija
calib_gui

%% Naloga 2.2: Projektivna transformacija

% 1. Preberi sliko in pokaži
Slika1 = imread("Image_rect2.tif");  
figure; imshow(Slika1); axis image;
hold on

disp('Klikni 4 kote šahovnice v urinem vrstnem redu, začni zgoraj levo.');
[x, y] = ginput(4);   % input
src = [x y];          % izvorne koordinate
plot(x, y, 'ro', 'MarkerSize', 8, 'LineWidth', 2);

hold off

W = 500; H = 500;              % velikost slike (px)
dst = [0 0; W 0; W H; 0 H];    % zgoraj-levo, zgoraj-desno, spodaj-desno, spodaj-levo

tform = maketform('projective', src, dst);
% tform = fitgeotrans(src, dst, 'projective');

T = imtransform(Slika1, tform, 'XData', [0 W], 'YData', [0 H], 'Size', [H W]);
figure; imshow(T); axis image;
title('Projektivno poravnana slika');

num_squares_x = 12; % število kvadratov v x smeri
num_squares_y = 11; % število kvadratov v y smeri
[xg, yg] = meshgrid(linspace(0, W, num_squares_x+1), linspace(0, H, num_squares_y+1));
grid_pts = [xg(:), yg(:)];

inv_tform = maketform('projective', dst, src); % inverzna transformacija
[x_back, y_back] = tformfwd(inv_tform, grid_pts(:,1), grid_pts(:,2));

figure; imshow(Slika1); axis image; hold on;
plot(x_back, y_back, 'rs', 'MarkerSize', 6, 'LineWidth', 1.2);
title('Originalna slika z mrežo napovedanih oglišč');
hold off;

%% Naloga 2.3: Radialna distorzija

Slika3 = imread("Image15.tif");
figure; imshow(Slika3); axis image; hold on;

num_points = 13;

% Prva vrstica (ob robu slike)
disp('Klikni 13 vogalov v vertikalni vrstici ob robu slike (od zgoraj navzdol)');
x1 = zeros(num_points,1);
y1 = zeros(num_points,1);

for i = 1:num_points
    [x1(i), y1(i)] = ginput(1);
    plot(x1(i), y1(i), 'rs', 'MarkerSize', 5, 'LineWidth', 2);
end

% Druga vrstica (na sredini)
disp('Klikni 13 vogalov v sredinski vertikalni vrstici (od zgoraj navzdol)');
x2 = zeros(num_points,1);
y2 = zeros(num_points,1);

for i = 1:num_points
    [x2(i), y2(i)] = ginput(1);
    plot(x2(i), y2(i), 'bs', 'MarkerSize', 5, 'LineWidth', 2);
end
hold off;

% Središče slike
cx = size(Slika3,2)/2;
cy = size(Slika3,1)/2;

r_edge = sqrt((x1 - cx).^2 + (y1 - cy).^2);    % radiji za robno vrstico
r_center = sqrt((x2 - cx).^2 + (y2 - cy).^2);  % radiji za sredinsko vrstico

f_values = 400:20:800;
errors = zeros(size(f_values));

for i = 1:length(f_values)
    f = f_values(i);
 
    r_lin_edge = -(f/2) * ((exp(-2*r_edge/f) - 1) ./ exp(-r_edge/f));
    r_lin_center = -(f/2) * ((exp(-2*r_center/f) - 1) ./ exp(-r_center/f));
    
    theta_edge = atan2(y1 - cy, x1 - cx);
    theta_center = atan2(y2 - cy, x2 - cx);

    x1_corr = cx + r_lin_edge .* cos(theta_edge);
    y1_corr = cy + r_lin_edge .* sin(theta_edge);
    x2_corr = cx + r_lin_center .* cos(theta_center);
    y2_corr = cy + r_lin_center .* sin(theta_center);

    XY1_corr = [x1_corr'; y1_corr'];
    XY2_corr = [x2_corr'; y2_corr'];

    [~, dist_edge] = fitline(XY1_corr);
    [~, dist_center] = fitline(XY2_corr);

    sse_edge = sum(dist_edge.^2);
    sse_center = sum(dist_center.^2);

    errors(i) = sse_edge + sse_center;

end

% Rezultat
figure;
plot(f_values, errors, '-o', 'LineWidth', 1.5);
xlabel('f [pix]');
ylabel('Vsota kvadratov razdalj (napaka)');
title('Iskanje optimalne goriščne razdalje f');
grid on;

[min_error, idx] = min(errors);
fprintf('Najmanjša napaka pri f = %.2f px (SSE = %.3f)\n', f_values(idx), min_error);

%% Naloga 2.4: Nelinearna optimizacija parametra f z uporabo fminsearch

% Slika in točke iz naloge 3
I = imread("Image15.tif");
cx = size(I,2)/2;
cy = size(I,1)/2;

num_points = 13;
figure; imshow(I); axis image; title('Klikni 13 vogalov ob robu slike (od zgoraj navzdol)');
hold on;

x1 = zeros(num_points,1);
y1 = zeros(num_points,1);

% Prva vrstica
for i = 1:num_points
    [x1(i), y1(i)] = ginput(1);
    plot(x1(i), y1(i), 'rs', 'MarkerSize', 6, 'LineWidth', 1.5);
    if i > 1
        plot(x1(i-1:i), y1(i-1:i), 'r-', 'LineWidth', 1.2);
    end
end

% Druga vrstica
title('Klikni 13 vogalov v sredini slike (od zgoraj navzdol)');
x2 = zeros(num_points,1);
y2 = zeros(num_points,1);

for i = 1:num_points
    [x2(i), y2(i)] = ginput(1);
    plot(x2(i), y2(i), 'bs', 'MarkerSize', 6, 'LineWidth', 1.5);
    if i > 1
        plot(x2(i-1:i), y2(i-1:i), 'b-', 'LineWidth', 1.2);
    end
end

hold off

% Napaka kot funkcija f
error_fun = @(f) compute_error(f, x1, y1, x2, y2, cx, cy);

% Začetna vrednost f
f0 = 600;  % začetni približek

% Nelinearna optimizacija
f_opt = fminsearch(error_fun, f0);

fid = fopen('fminsearch.txt', 'w');
fprintf(fid, 'Optimalna vrednost f = %.4f\n', f_opt);
fclose(fid);

fprintf('Optimalna vrednost f = %.4f\n', f_opt);

function E = compute_error(f, x1, y1, x2, y2, cx, cy)
    
r1 = sqrt((x1 - cx).^2 + (y1 - cy).^2);
    r2 = sqrt((x2 - cx).^2 + (y2 - cy).^2);

    r_lin1 = -(f/2) * ((exp(-2*r1/f) - 1) ./ exp(-r1/f));
    r_lin2 = -(f/2) * ((exp(-2*r2/f) - 1) ./ exp(-r2/f));

    theta1 = atan2(y1 - cy, x1 - cx);
    theta2 = atan2(y2 - cy, x2 - cx);

    x1_corr = cx + r_lin1 .* cos(theta1);
    y1_corr = cy + r_lin1 .* sin(theta1);
    x2_corr = cx + r_lin2 .* cos(theta2);
    y2_corr = cy + r_lin2 .* sin(theta2);

    XY1_corr = [x1_corr'; y1_corr'];
    XY2_corr = [x2_corr'; y2_corr'];

    [~, dist1] = fitline(XY1_corr);
    [~, dist2] = fitline(XY2_corr);

    E = sum(dist1.^2) + sum(dist2.^2);
end
==== END Timotej Topčievski | Timotej Topčievski_18904_assignsubmission_file | vaja2.m ====

