==== BEGIN Gašper Lončar | Gašper Lončar_18906_assignsubmission_file | labvaja2.m ====
clc; close all;

slika15 = imread("Image15.tif");

if size(slika15,3) == 3
    slika15 = rgb2gray(slika15);
end

[visina, sirina] = size(slika15);
% optično središče iz 1. naloge
v_sredina = 319.5;        
s_sredina = 239.5;

[x, y] = meshgrid(1:sirina, 1:visina);

% figure; image(slika15); axis image; title('označi središčno premico')
% [x_sred,y_sred] = ginput();
% 
% figure; image(slika15); axis image; title('označi premico najbolj na levem robu');
% [x_rob_levo,y_rob_levo] = ginput();
% 
% figure; image(slika15); axis image; title('označi premico najbolj na desnem robu');
% [x_rob_desno,y_rob_desno] = ginput();

% tabela s točkami
sred_tocke = [x_sred'; y_sred'];
rob_tocke_levo = [x_rob_levo'; y_rob_levo'];
rob_tocke_desno = [x_rob_desno'; y_rob_desno'];

% koeficienti premice a*x + b*y + c = 0, vektor razdalj vsake točke od te premice
[sredina, dolzina_sred] = fitline(sred_tocke);
[rob_levo, dolzina_rob_levo] = fitline(rob_tocke_levo);
[rob_desno, dolzina_rob_desno] = fitline(rob_tocke_desno);

% vsota kvadratov
vs_sred = sum(dolzina_sred.^2); 
vs_rob_levo = sum(dolzina_rob_levo.^2);
vs_rob_desno = sum(dolzina_rob_desno.^2);

% izračun popačenih radijev
r0_sred = sqrt((x_sred - s_sredina).^2 + (y_sred - v_sredina).^2);
r0_rob_levo = sqrt((x_rob_levo - s_sredina).^2 + (y_rob_levo - v_sredina).^2);
r0_rob_desno = sqrt((x_rob_desno - s_sredina).^2 + (y_rob_desno - v_sredina).^2);

f_interval = 400:20:800;
vsota_kvadratov = zeros(size(f_interval));

for i = 1:length(f_interval)
    f = f_interval(i);
    
    % nov radij po inverzni formuli
    r1_sred = -f/2 .* ((exp(-2*r0_sred./f) - 1) ./ exp(-r0_sred./f));
    r1_rob_levo = -f/2 .* ((exp(-2*r0_rob_levo./f) - 1) ./ exp(-r0_rob_levo./f));
    r1_rob_desno = -f/2 .* ((exp(-2*r0_rob_desno./f) - 1) ./ exp(-r0_rob_desno./f));


    % normalizacija x-os ()horizontalno z r1/r0
    k_sred = r1_sred ./ r0_sred;
    k_rob_levo = r1_rob_levo ./ r0_rob_levo;
    k_rob_desno = r1_rob_desno ./ r0_rob_desno;

    % nove koordinate obeh premic
    x_nov_sred = s_sredina + (x_sred - s_sredina) .* k_sred;
    y_nov_sred = v_sredina + (y_sred - v_sredina) .* k_sred;

    x_nov_rob_levo = s_sredina + (x_rob_levo - s_sredina) .* k_rob_levo;
    y_nov_rob_levo = v_sredina + (y_rob_levo - v_sredina) .* k_rob_levo;

    x_nov_rob_desno = s_sredina + (x_rob_desno - s_sredina) .* k_rob_desno;
    y_nov_rob_desno = v_sredina + (y_rob_desno - v_sredina) .* k_rob_desno;

    [~, razdalja_nov_sred] = fitline([x_nov_sred'; y_nov_sred']);
    [~, razdalja_nov_rob_levo] = fitline([x_nov_rob_levo'; y_nov_rob_levo']);
    [~, razdalja_nov_rob_desno] = fitline([x_nov_rob_desno'; y_nov_rob_desno']);

    % vsota kvadratov po korekciji
    vk_sred(i) = sum(razdalja_nov_sred.^2);
    vk_levo(i) = sum(razdalja_nov_rob_levo.^2);
    vk_desno(i) = sum(razdalja_nov_rob_desno.^2);
    vsota_kvadratov(i) = vk_sred(i) + vk_levo(i) + vk_desno(i);
    % fprintf('f=%4d, vsota sred=%.4f, vsota levo=%.4f, vsota desno=%.4f, skupna vsota=%.4f\n', ...
    %     f, vk_sred, vk_levo, vk_desno, vsota_kvadratov);
end

% prikaz vsote kvadratov glede na f - parameter distorzije
figure;
plot(f_interval, vsota_kvadratov);
xlabel('f (parameter distorzije)');
ylabel('Vsota kvadratov razdalj');

% Poiščemo optimalni f
[~, f_opt] = min(vsota_kvadratov);
f_optimal = f_interval(f_opt);
disp(['Optimalna vrednost parametra f = ', num2str(f_optimal)]);

%% Shrani podatke za 4. nalogo
save('radial_data.mat', 'x_rob_desno','y_rob_desno','x_sred', 'y_sred', 'x_rob_levo', 'y_rob_levo', ...
    'r0_sred', 'r0_rob_levo', 'r0_rob_desno','s_sredina', 'v_sredina', ...
    'slika15');
disp('Podatki za 4. nalogo uspešno shranjeni v radial_data.mat');

%% prikaz z odpravljeno distorzijo

f = f_optimal;

r0 = sqrt((x - s_sredina).^2 + (y - v_sredina).^2);
% iz nepopačenih nazaj v popačene
r1 = f .* log( r0./f + sqrt( 1 + (r0./f).^2 ) );
K = r1 ./ r0;

x_korig = (x - s_sredina).*K + s_sredina;
y_korig = (y - v_sredina).*K + v_sredina;

x_korig = min(max(x_korig, 1), sirina);
y_korig = min(max(y_korig, 1), visina);

% uporabi interp2 za preoblikovanje slike
korig = double(slika15);
korigirana_slika = interp2(korig, x_korig, y_korig, 'linear', 0);

figure;
subplot(1,2,1);
imshow(slika15, []); title('Originalna slika');

subplot(1,2,2);
imshow(uint8(korigirana_slika), 'XData', [1 sirina], 'YData', [1 visina]); 
title('Korigirana slika optimal pri:', num2str(f_optimal, '%.2f'));

%% direktno z fminsearch

f_zacetni = 400;

obj_fun = @(f) ...
    local_vsota_kvadratov(f, ...
    x_sred, y_sred, r0_sred, ...
    x_rob_levo,  y_rob_levo,  r0_rob_levo, ...
    x_rob_desno, y_rob_desno, r0_rob_desno, ...
    s_sredina, v_sredina);

% izvedemo optimizacijo
f_opt_nelinearno = fminsearch(obj_fun, f_zacetni);

fprintf('Optimalna vrednost parametra f (nelinearna optimizacija): %.2f\n', f_opt_nelinearno);

%%
function vsota = local_vsota_kvadratov(f, ...
    x_sred, y_sred, r0_sred, ...
    x_robL, y_robL, r0_robL, ...
    x_robD, y_robD, r0_robD, ...
    s_sredina, v_sredina)

    % izračun korekcije za središčno linijo
    r1_sred = -f/2 .* ((exp(-2*r0_sred./f) - 1) ./ exp(-r0_sred./f));
    r1_robL = -f/2 .* ((exp(-2*r0_robL./f) - 1) ./ exp(-r0_robL./f));
    r1_robD = -f/2 .* ((exp(-2*r0_robD./f) - 1) ./ exp(-r0_robD./f));

    k_sred = r1_sred ./ r0_sred;
    k_robL = r1_robL ./ r0_robL;
    k_robD = r1_robD ./ r0_robD;

    x_nov_sred = s_sredina + (x_sred - s_sredina) .* k_sred;
    y_nov_sred = v_sredina + (y_sred - v_sredina) .* k_sred;

    x_nov_robL = s_sredina + (x_robL - s_sredina) .* k_robL;
    y_nov_robL = v_sredina + (y_robL - v_sredina) .* k_robL;

    x_nov_robD = s_sredina + (x_robD - s_sredina) .* k_robD;
    y_nov_robD = v_sredina + (y_robD - v_sredina) .* k_robD;

    % prileganje premic in vsota kvadratov razdalj
    if numel(x_nov_sred) < 3 || numel(x_nov_robL) < 3 || numel(x_nov_robD) < 3
        vsota = 1e9; % če je premalo točk, vrni veliko napako
        return;
    end

    [~, raz_sred] = fitline([x_nov_sred'; y_nov_sred']);
    [~, raz_robL]  = fitline([x_nov_robL';  y_nov_robL']);
    [~, raz_robD]  = fitline([x_nov_robD';  y_nov_robD']);
    vsota = sum(raz_sred.^2) + sum(raz_robL.^2) + sum(raz_robD.^2);
end
==== END Gašper Lončar | Gašper Lončar_18906_assignsubmission_file | labvaja2.m ====

==== BEGIN Gašper Lončar | Gašper Lončar_18906_assignsubmission_file | proj_trans.m ====
%% projekcijska transformacija
clc; close all;

slika =imread("Image_rect2.tif");

% figure; imshow(slika);
% [x,y] = ginput(4);              % moraš označiti v pravilnem vrstnem redu
% tocke = [x y];                  % levo zgoraj, desno zgoraj, desno spodaj, levo spodaj
% close;

velikost_polja = 30;
vrstice = 11; stolpci = 12;

idealna_sahovnica = [0 0;
                     velikost_polja*stolpci 0;
                     velikost_polja*stolpci velikost_polja*vrstice;
                     0 velikost_polja*vrstice];       % naredi idealno šahovnico
                          % levo zgoraj, desno zgoraj, desno spodaj, levo
                          % spodaj

% Ustvari mrežo v koordinatah idealne šahovnice
[Xgrid, Ygrid] = meshgrid(0:velikost_polja:(stolpci*velikost_polja), ...
                          0:velikost_polja:(vrstice*velikost_polja));
        
% izračunaj projektivno transformacijo
tform = maketform('projective', tocke, idealna_sahovnica);

% izvedi transformacijo slike
[projekcija, Xdata, Ydata] = imtransform(slika, tform, ...
    'XData', [0 stolpci*velikost_polja], ...
    'YData', [0 vrstice*velikost_polja]);

% inverzna transformacija za izris mreže na originalni sliki

tform_inv = maketform('projective', idealna_sahovnica, tocke);
[origX, origY] = tformfwd(tform_inv, Xgrid(:), Ygrid(:));           % vrne točke na origginalno sliko

% Prikaži vse tri slike
figure; 

subplot(1,3,1); imshow(slika);
hold on;
plot(tocke(:,1), tocke(:,2), 'bx','MarkerSize',5);
title('Originalna slika + izbrane točke');


subplot(1,3,2); imshow(projekcija, 'XData', Xdata, 'YData', Ydata);
hold on;
plot(Xgrid, Ygrid, 'rx', 'MarkerSize',4);
title('projektivna tranformacija');


subplot(1,3,3); imshow(slika);
hold on;
plot(origX, origY, 'g.');
title('Original slika z mrežo ogljišč po transformaciji');

==== END Gašper Lončar | Gašper Lončar_18906_assignsubmission_file | proj_trans.m ====

