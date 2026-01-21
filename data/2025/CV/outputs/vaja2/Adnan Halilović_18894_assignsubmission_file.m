==== BEGIN Adnan Halilović | Adnan Halilović_18894_assignsubmission_file | projektivna_transformacija.m ====
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
%Scatter za risanje pikic
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
numCols = 12; % število stolpcev
numRows = 11; % število vrstic
stepX = 640 / numCols;
stepY = 480 / numRows;

[Xg, Yg] = meshgrid(0:stepX:640, 0:stepY:480);
gridPoints = [Xg(:), Yg(:)];

% Inverzna transformacija – iz idealnega koordinatnega sistema v originalno sliko
tform_inv = invert(tform);
[origX, origY] = transformPointsForward(tform_inv, gridPoints(:,1), gridPoints(:,2));

% Prikaži mrežo na originalni sliki
figure; imshow(I); title('Izvirna slika z izrisano mrežo (inverzna transformacija)');
hold on;
plot(origX, origY, 'g.', 'MarkerSize', 10);

% Po želji izrišeš povezave (linije med točkami)
for r = 1:size(Yg,1)
    idx = (r-1)*(numCols+1)+(1:(numCols+1));
    plot(origX(idx), origY(idx), 'y-');
end
for c = 1:size(Xg,2)
    idx = c:(numCols+1):numel(Xg);
    plot(origX(idx), origY(idx), 'y-');
end
==== END Adnan Halilović | Adnan Halilović_18894_assignsubmission_file | projektivna_transformacija.m ====

==== BEGIN Adnan Halilović | Adnan Halilović_18894_assignsubmission_file | Radialna_distorzija.m ====


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
    % Hardcode pikic
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
==== END Adnan Halilović | Adnan Halilović_18894_assignsubmission_file | Radialna_distorzija.m ====

