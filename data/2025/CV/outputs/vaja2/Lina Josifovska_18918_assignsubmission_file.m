==== BEGIN Lina Josifovska | Lina Josifovska_18918_assignsubmission_file | funkcija_za_fminsearch_from_points.m ====
function napaka = funkcija_za_fminsearch_from_points(f, x_rel, y_rel)
    x_rel = x_rel(:); y_rel = y_rel(:);
    n = numel(x_rel);
    r = sqrt(x_rel.^2 + y_rel.^2);
    theta = atan2(y_rel, x_rel);
    r_pop = f .* sinh(r ./ f);   

    [x_corr, y_corr] = pol2cart(theta, r_pop); 

    XY = [x_corr.'; y_corr.'];

    finiteIdx = all(isfinite(XY),1);
    XY = XY(:, finiteIdx);
    if size(XY,2) < 2
        napaka = Inf; return;
    end

    [~, dist] = fitline(XY);
    napaka = sqrt(sum(dist.^2));
end
==== END Lina Josifovska | Lina Josifovska_18918_assignsubmission_file | funkcija_za_fminsearch_from_points.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_18918_assignsubmission_file | Naloga2ProjektivnaTransformacija.m ====
clear; close all; clc;

imgName = 'Image_rect3.tif';
outSize = 300;        
numCols = 12;         
numRows = 11;         
markerColor = 'red';
markerSize = 4;

I = imread(imgName);
figure; imshow(I); title('Klikni 4 vogale');
[x, y] = ginput(4);
inputPts = [x(:), y(:)];

a = [0; outSize; outSize; 0];
b = [0; 0; outSize; outSize];
idealPts = [a, b];
T = maketform('projective', inputPts, idealPts);

Irect = imtransform(I, T, 'XData', [0 outSize], 'YData', [0 outSize]);

xs = linspace(0, outSize, numCols+1);   
ys = linspace(0, outSize, numRows+1);   
[GX, GY] = meshgrid(xs, ys);
gridRect = [GX(:), GY(:)];  

Irect_marked = insertMarker(Irect, gridRect, 'o', 'Color', markerColor, 'Size', markerSize);
figure; imshow(Irect_marked); title('Popravljena slika s presecisci mreze');

invT = maketform('projective', idealPts, inputPts);
[xOrig, yOrig] = tformfwd(invT, gridRect(:,1), gridRect(:,2)); 

Iorig_marked = insertMarker(I, [xOrig, yOrig], 'o', 'Color', markerColor, 'Size', markerSize);
figure; imshow(Iorig_marked); title('Originalna slika s preslikanimi presecisci mreze');

==== END Lina Josifovska | Lina Josifovska_18918_assignsubmission_file | Naloga2ProjektivnaTransformacija.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_18918_assignsubmission_file | Naloga3.m ====
clear; close all; clc;

I = imread('Image15.tif');
figure; imshow(I); title('Select points: first column (edge), then second column (center)');
hold on;

stevilo_tock = 10;
disp('Izberi točk v prvi stolpec, nato pritisni Enter.');
[x1_zajete, y1_zajete] = ginput(stevilo_tock);
disp('Izberi točk v drugi stolpec, nato pritisni Enter.');
[x2_zajete, y2_zajete] = ginput(stevilo_tock);

plot(x1_zajete,y1_zajete,'ro','MarkerFaceColor','r');
plot(x2_zajete,y2_zajete,'go','MarkerFaceColor','g');

cc = [319.5, 239.5];   
xc = cc(1);             
yc = cc(2);             
   
x1 = x1_zajete - xc;
y1 = y1_zajete - yc;
x2 = x2_zajete - xc;
y2 = y2_zajete - yc;

r1 = sqrt(x1.^2 + y1.^2);     
r2 = sqrt(x2.^2 + y2.^2);
theta1 = atan2(y1, x1);
theta2 = atan2(y2, x2);

f = 400:20:800;   
napaka = zeros(size(f));     

for aind = 1:length(f)
    ff = f(aind);
    rl1 = ff .* sinh(r1 ./ ff);   
    rl2 = ff .* sinh(r2 ./ ff);
   
    [X1, Y1] = pol2cart(theta1, rl1);  
    [X2, Y2] = pol2cart(theta2, rl2);
    
    X1_img = X1 + xc;  Y1_img = Y1 + yc;
    X2_img = X2 + xc;  Y2_img = Y2 + yc;
    
    XY1 = [X1_img(:)'; Y1_img(:)'];
    XY2 = [X2_img(:)'; Y2_img(:)'];
   
   [~, d1] = fitline(XY1);
   [~, d2] = fitline(XY2);
   
    napaka(aind) = sum(d1.^2) + sum(d2.^2);   
    
end

figure;
plot(f, napaka, '-o', 'LineWidth', 1.4);
xlabel('f'); ylabel('Sum of squared distances'); grid on;
title('f vs napaka');

[bestVal, idx] = min(napaka);
bestF = f(idx);
fprintf('Best f = %.3f (sumsq = %.6g) at index %d\n', bestF, bestVal, idx);

% ----- optional: show corrected points for best f -----
ff = bestF;
rl1 = ff .* sinh(r1 ./ ff); rl2 = ff .* sinh(r2 ./ ff);
[X1b, Y1b] = pol2cart(theta1, rl1); [X2b, Y2b] = pol2cart(theta2, rl2);
X1b = X1b + xc; Y1b = Y1b + yc; X2b = X2b + xc; Y2b = Y2b + yc;

figure; imshow(I); hold on;
plot(x1_zajete, y1_zajete, 'ro', 'MarkerFaceColor','r');    % originals
plot(x2_zajete, y2_zajete, 'go', 'MarkerFaceColor','g');
plot(X1b, Y1b, 'rx','MarkerSize',10,'LineWidth',1.2);       % corrected
plot(X2b, Y2b, 'gx','MarkerSize',10,'LineWidth',1.2);

% draw fitted straight lines on corrected points
XY1b = [X1b(:)'; Y1b(:)']; XY2b = [X2b(:)'; Y2b(:)'];
[C1b, d1b] = fitline(XY1b); [C2b, d2b] = fitline(XY2b);
draw_line(C1b, 'y-'); draw_line(C2b, 'y-');
title(sprintf('Corrected points for f = %.3f', bestF));

% helper to draw line (same as before)
function draw_line(C, style)
    a = C(1); b = C(2); c = C(3);
    ax = axis;
    xs = linspace(ax(1), ax(2), 2);
    if abs(b) > 1e-9
        ys = -(a*xs + c)/b;
    else
        xs = -c/a * ones(1,2);
        ys = linspace(ax(3), ax(4), 2);
    end
    plot(xs, ys, style, 'LineWidth', 1.5);
end
==== END Lina Josifovska | Lina Josifovska_18918_assignsubmission_file | Naloga3.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_18918_assignsubmission_file | Naloga4fminsearch.m ====
clear; close all; clc;

I = imread('Image15.tif');
figure; imshow(I); title('Izberi točk'); hold on;

disp('Izberi točk v robni vrstici.');
[x1_zajete, y1_zajete] = ginput(10);
disp('Izberi točk v notranji vrstici.');
[x2_zajete, y2_zajete] = ginput(10);

cc = [319.5, 239.5];   
xc = cc(1);             
yc = cc(2);             

x_rel = [x1_zajete; x2_zajete] - xc;
y_rel = [y1_zajete; y2_zajete] - yc;

options = optimset('MaxFunEvals',5000);
f_opt = fminsearch(@(ff) funkcija_za_fminsearch_from_points(ff, x_rel, y_rel), 400);
fprintf('Optimalni f = %.6f\n', f_opt);
==== END Lina Josifovska | Lina Josifovska_18918_assignsubmission_file | Naloga4fminsearch.m ====

