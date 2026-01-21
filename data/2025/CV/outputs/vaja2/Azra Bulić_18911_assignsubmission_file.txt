==== BEGIN Azra Bulić | Azra Bulić_18911_assignsubmission_file | projektivna_transf.m ====

img_name = 'Image_rect15.tif';
    % Ucitaj sliku, prebaci u sivu i double
    I = imread(img_name);
    if size(I,3) == 3
        I = rgb2gray(I);
    end
    I = im2double(I);

    % Izaberi 4 vanjska ugla sahovnice
    figure; imshow(I,[]); axis image; hold on;
    title('Izberite 4 zunanje vogale');
    [x,y] = ginput(4);
    k = [x y];

    % Definiraj idealnu geometriju ploce
    %12 kvadrata po sirini, 11 po visini, mreza uglova je (13 x 12)
    s  = 30;
    nx = 12;
    ny = 11;

    % 4 ugla idealne (ispravljene) ploce
    ip = [0 0; s*nx 0; s*nx s*ny; 0 s*ny];

    T = maketform('projective', k, ip);

    %Ispravljena slika
    I_rect = imtransform(I, T, 'XData',[0 s*nx],'YData',[0 s*ny]);
    figure; imshow(I_rect,[]); axis image;
    title('Projektivno ispravljena sahovnica');

    %Svi uglovi mreze u idealnom prostoru
    [U,V] = meshgrid(0:nx, 0:ny);
    ideal_pts = [U(:)*s, V(:)*s];

    %Inverzna transformacija: idealno -> original
    T_inv = maketform('projective', ip, k);
    [xo, yo] = tformfwd(T_inv, ideal_pts(:,1), ideal_pts(:,2));

    % Nacrtaj sve uglove na originalnoj slici
    figure; imshow(I,[]); axis image; hold on;
    plot(xo, yo, 'r+', 'MarkerSize',5, 'LineWidth',1);
    title('Originalna slika');
==== END Azra Bulić | Azra Bulić_18911_assignsubmission_file | projektivna_transf.m ====

==== BEGIN Azra Bulić | Azra Bulić_18911_assignsubmission_file | radialna_distorzija.m ====
img = imread('Image15.tif');

if size(img, 3) == 3
    img = rgb2gray(img);
end
img = im2double(img);

 
disp('Označite 6 tacaka na rubu slike.');
figure();
imshow(img);
[x1,y1] = ginput(6);
close();

disp('Označi 6 tacaka blizu centra.');
figure();
imshow(img);
[x2,y2] = ginput(6);
close();

%Centar slike
[height, width] = size(img);  % Za sivu sliku, visina i širina
x = width / 2; 
y = height / 2;

% Koordinate tačaka sa ivice
xy1 = zeros(2, 6);
for i = 1:6
    xy1(1,i) = x1(i) - x;  % Premesti X-koordinate
    xy1(2,i) = y1(i) - y;  % Premesti Y-koordinate
end

% Koordinate tačaka sa centra
xy2 = zeros(2, 6);
for i = 1:6
    xy2(1,i) = x2(i) - x;  % Premesti X-koordinate
    xy2(2,i) = y2(i) - y;  % Premesti Y-koordinate
end

    
[c1,d1] = fitline(xy1);
[c2,d2] = fitline(xy2);

D_1 = sum(d1 .^ 2);
D_2 = sum(d2 .^ 2);

%Polarne koordinate
r_rub = zeros(1,6);
r_centar = zeros(1,6);
ugao_rob = zeros(1,6);
ugao_centar = zeros(1,6);

[ugao_rob, r_rub] = cart2pol(xy1(1,:), xy1(2,:));
[ugao_centar, r_centar]= cart2pol(xy2(1,:), xy2(2,:));

f_vals = 400:20:800;
disp(length(f_vals));

rn_rob = zeros(1,6);
xy1_n = zeros(2,6);
r_n_centar = zeros(1,6);
xy2_n = zeros(2,6);

%i=1; %brojac
%Greske
D1 = zeros(1, length(f_vals));
D2 = zeros(1, length(f_vals));

for i = 1:length(f_vals)
    f=f_vals(i);
    rn_rob = (- f / 2) .* (exp(-2 * r_rub ./ f) - 1) ./ exp(-r_rub / f);
    r_n_centar = (- f / 2) .* (exp(-2 * r_centar ./ f) - 1) ./ exp(-r_centar / f);

    [xy1_n(1,:),xy1_n(2,:)] = pol2cart(ugao_rob,rn_rob);
    [xy2_n(1,:),xy2_n(2,:)] = pol2cart(ugao_centar,r_n_centar); 

    [c1n, d1n] = fitline(xy1_n);
    [c2n, d2n] = fitline(xy2_n);
    
    D_1n = sum(d1n .^2);
    D1(i) = D_1n;
    D_2n = sum(d2n .^2);
    D2(i) = D_2n;
end

Dsum = D1 + D2;
[minsweep, idxmin] = min(Dsum);
f_min = f_vals(idxmin);

figure; hold on; grid on;
f = 400:20:800;
plot(f, D1, 'g-', f, D2, 'b-', f, Dsum, 'r-', 'LineWidth', 2);

%Oznacen minimum
plot(f_min, minsweep, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'y');
xline(f_min, '--k');
xlabel('Vrednosti parametra f');
ylabel('Suma kvadrata udaljenosti');
legend('Rub','Centar','Zbir','Min(Zbir)');

fprintf('Minimum pri f_min = %.1f\n', f_min);



% Optimizacija
f0=400;
cos_function = @(f)cost_fcn(f, ugao_rob,r_rub, ugao_centar, r_centar); %cos radijalne distorzije
[f_opt,e] = fminsearch(cos_function,f0); 
fprintf('Najboljše korigirana radijalna distrozija je pri f = %d',round(f_opt))

==== END Azra Bulić | Azra Bulić_18911_assignsubmission_file | radialna_distorzija.m ====

==== BEGIN Azra Bulić | Azra Bulić_18911_assignsubmission_file | vaja2_1.txt ====
Slike: [1 3 8 10 12]
Calibration parameters after initialization:  Focal Length:          fc = [ 690.54453   690.54453 ] Principal point:       cc = [ 319.50000   239.50000 ] Skew:             alpha_c = [ 0.00000 ]   => angle of pixel = 90.00000 degrees Distortion:            kc = [ 0.00000   0.00000   0.00000   0.00000   0.00000 ]  Main calibration optimization procedure - Number of images: 5 Gradient descent iterations: 1...2...3...4...5...6...7...8...9...done Estimation of uncertainties...done   Calibration results after optimization (with uncertainties):  Focal Length:          fc = [ 659.47605   660.38579 ] ± [ 1.33261   1.53242 ] Principal point:       cc = [ 306.25617   245.45566 ] ± [ 2.67892   2.30425 ] Skew:             alpha_c = [ 0.00000 ] ± [ 0.00000  ]   => angle of pixel axes = 90.00000 ± 0.00000 degrees Distortion:            kc = [ -0.26069   0.17031   0.00023   0.00020  0.00000 ] ± [ 0.01165   0.06018   0.00052   0.00052  0.00000 ] Pixel error:          err = [ 0.13546   0.20941 ] 
==== END Azra Bulić | Azra Bulić_18911_assignsubmission_file | vaja2_1.txt ====

