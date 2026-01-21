==== BEGIN Nejc Ropič | Nejc Ropič_18898_assignsubmission_file | compute_error.m ====
function error = compute_error(f, x_robni, y_robni, x_sredinska, y_sredinska, x_sredina, y_sredina)
    
    % izracun obeh radijev - razdalja vsake tocke od sredisce
    r_rob = sqrt((x_robni - x_sredina).^2 + (y_robni - y_sredina).^2);
    r_center = sqrt((x_sredinska - x_sredina).^2 + (y_sredinska - y_sredina).^2);

    % Preslikava iz popačenih radijev r' v nepopačene r'_l po enačbi (2)
    r_rob_popacen = - (f/2) .* ((exp(-2 .* r_rob ./ f)) - 1) ./ exp(-r_rob ./ f);
    r_center_popacen = - (f/2) .* ((exp(-2 .* r_center ./ f)) - 1) ./ exp(-r_center ./ f);

    % korekcijski faktor
    korekcija_rob = r_rob_popacen ./ r_rob;
    korekcija_center = r_center_popacen ./ r_center;

    % korekcija tock po formuli korig_tocka = sredina + (tocka_premice - sredina) * korekcijski faktor
    x_rob_korigiran = x_sredina + (x_robni - x_sredina) .* korekcija_rob;
    y_rob_korigiran = y_sredina + (y_robni - y_sredina) .* korekcija_rob;

    x_center_korigiran = x_sredina + (x_sredinska - x_sredina) .* korekcija_center;
    y_center_korigiran = y_sredina + (y_sredinska - y_sredina) .* korekcija_center;

    % fit premice
    [C_rob, dist_rob] = fitline([x_rob_korigiran'; y_rob_korigiran']);
    [C_center, dist_center] = fitline([x_center_korigiran'; y_center_korigiran']);

    % vsota kvadratov napaka
    error = sum(dist_rob.^2) + sum(dist_center.^2);
end
==== END Nejc Ropič | Nejc Ropič_18898_assignsubmission_file | compute_error.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_18898_assignsubmission_file | naloga2.m ====
A = imread('Image_rect3.tif');  

[height, width, channels] = size(A);

imshow(A)
hold on;

[x,y] = ginput(4);
%% 2. naloga
x = [197.3159; 502.1915; 499.4055; 112.5398];
y = [95.4254; 144.7786; 425.7736; 358.1119];

U = [x y];
X = [0 0;
     500 0;
     500 500;
     0 500];

T = fitgeotrans(U, X,'projective');
outputView = imref2d([500 500]);

B = imwarp(A, T, 'OutputView', outputView);
figure, imshow(B);

kvadrati_x_os = 13;
kvadrati_y_os = 12;
[Xg, Yg] = meshgrid(linspace(0, 500, kvadrati_x_os), linspace(0, 500, kvadrati_y_os));
idealGrid = [Xg(:), Yg(:)];

% pretvorba idealnih koordinat nazaj v originalne s pomočjo inverzne transformacije
[origX, origY] = transformPointsInverse(T, idealGrid(:,1), idealGrid(:,2));

% zzris mreže oglišč na originalno (popačeno) sliko 
figure, image(A), colormap gray, axis image
title('Označena oglišča vseh kvadratov šahovnice na originalni sliki')
hold on
plot(origX, origY, 'r.', 'MarkerSize', 10);

==== END Nejc Ropič | Nejc Ropič_18898_assignsubmission_file | naloga2.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_18898_assignsubmission_file | naloga34.m ====
%% dolocanje premice
addpath("toolbox_calib\")
A = imread('Image15.tif');
[height, width, ~] = size(A);

imshow(A); hold on;
st_vstavljenih_tock = 5;

[x_robni, y_robni] = ginput(st_vstavljenih_tock);
[x_sredinska, y_sredinska] = ginput(st_vstavljenih_tock);
%% 3. naloga
x_robni = [44.8781; 40.8980; 41.2960; 43.6841; 46.8682];
y_robni = [68.3607; 183.3856; 256.6194; 360.5000; 452.8383];
x_sredinska = [309.5547; 301.1965; 295.6244; 285.6741; 279.3060];
y_sredinska = [86.2711; 196.5199; 265.7736; 364.0821; 452.8383];

principal_point = [ 303.80733   243.91482 ];
x_sredina = principal_point(1);
y_sredina = principal_point(2);
% Interval za f
f_values = 400:20:800;
errors = zeros(size(f_values));

for i = 1:length(f_values)
    f = f_values(i);
    % racunanje napake
    errors(i) = compute_error(f,x_robni, y_robni, x_sredinska, ...
                                    y_sredinska, x_sredina, y_sredina);
end

figure;
plot(f_values, errors, 'b-o');
xlabel('f ');
ylabel('Vsota kvadratov razdalj');
grid on;

%% 4. naloga

% funkcija napake
error_fun = @(f) compute_error(f, x_robni, y_robni, x_sredinska, y_sredinska, x_sredina, y_sredina);

% iskanje minimuma
f0 = 500;
f_opt = fminsearch(error_fun, f0);

figure;
plot(f_values, errors, 'b-o');
xline(f_opt, 'r--', 'LineWidth', 1.5);
xlabel('f');
ylabel('Vsota kvadratov razdalj');
legend('Napake', sprintf('Minimiziran f = %.2f', f_opt));
grid on;


==== END Nejc Ropič | Nejc Ropič_18898_assignsubmission_file | naloga34.m ====

==== BEGIN Nejc Ropič | Nejc Ropič_18898_assignsubmission_file | params.txt ====
Focal Length:          fc = [ 657.86031   658.30200 ] ± [ 0.50909   0.60186 ]
Principal point:       cc = [ 303.80733   243.91482 ] ± [ 1.00057   0.84815 ]
Skew:             alpha_c = [ 0.00000 ] ± [ 0.00000  ]   => angle of pixel axes = 90.00000 ± 0.00000 degrees
Distortion:            kc = [ -0.26004   0.15112   -0.00003   0.00003  0.00000 ] ± [ 0.00423   0.02002   0.00020   0.00021  0.00000 ]
Pixel error:          err = [ 0.12158   0.12325 ]
==== END Nejc Ropič | Nejc Ropič_18898_assignsubmission_file | params.txt ====

