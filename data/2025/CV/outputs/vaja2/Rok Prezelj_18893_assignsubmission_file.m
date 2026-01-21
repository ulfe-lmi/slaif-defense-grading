==== BEGIN Rok Prezelj | Rok Prezelj_18893_assignsubmission_file | calib_data.txt ====

Calibration results after optimization (with uncertainties):

Focal Length:          fc = [ 657.48437   657.92479 ] ± [ 1.30720   1.65250 ]
Principal point:       cc = [ 305.03652   244.77233 ] ± [ 1.60628   1.31562 ]
Skew:             alpha_c = [ 0.00000 ] ± [ 0.00000  ]   => angle of pixel axes = 90.00000 ± 0.00000 degrees
Distortion:            kc = [ -0.25554   0.13507   0.00028   0.00014  0.00000 ] ± [ 0.00743   0.03572   0.00035   0.00037  0.00000 ]
Pixel error:          err = [ 0.12946   0.12428 ]

Note: The numerical errors are approximately three times the standard deviations (for reference).
==== END Rok Prezelj | Rok Prezelj_18893_assignsubmission_file | calib_data.txt ====

==== BEGIN Rok Prezelj | Rok Prezelj_18893_assignsubmission_file | nal2.m ====
function rectify_chessboard(image_path)
% RECTIFY_CHESSBOARD  Projektivna korekcija šahovnice
% Uporaba:
%   rectify_chessboard('Image_rect1.tif')

    % ---- 1) Branje slike ----
    img = imread(image_path);
    img = double(img); % enoten tip

    % ---- 2) Uporabnik izbere kote ----
    figure('Name','Klikni 4 kote (TL, TR, BR, BL)');
    imshow(img, []); title('Klikni 4 kote: ZG-L, ZG-D, SP-D, SP-L');
    [x, y] = ginput(4);
    moving = [x y];
    plot(moving(:,1), moving(:,2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);

    % ---- 3) Vnos parametrov šahovnice ----
    answ = inputdlg({'Širina (kvadrati):','Višina (kvadrati):','Velikost kvadrata [px]:'}, ...
                    'Parametri', 1, {'12','11','80'});
    if isempty(answ), return; end
    cols = str2double(answ{1}); rows = str2double(answ{2}); sq = str2double(answ{3});
    width = cols*sq;
    height = rows*sq;

    % ---- 4) Projektivna korekcija ----
    fixed = [1 1; width 1; width height; 1 height];
    tform = maketform('projective', moving, fixed);
    corrected = imtransform(img, tform, 'XData',[1 width],'YData',[1 height], ...
                            'FillValues', median(img(:)));

    figure('Name','Korigirana slika'); imshow(corrected, []); title('Projektivno popravljena šahovnica');

    % ---- 5) Izris mreže na originalno sliko ----
    [X, Y] = meshgrid(1:sq:width+1, 1:sq:height+1);
    X(X>width)=width; Y(Y>height)=height;
    tform_inv = maketform('projective', fixed, moving);
    [u, v] = tformfwd(tform_inv, X, Y);

    figure('Name','Original z oglišči');
    imshow(img, []); hold on;
    plot(u, v, 'g.', 'MarkerSize', 10);
    for r=1:size(u,1), plot(u(r,:), v(r,:), 'g-'); end
    for c=1:size(u,2), plot(u(:,c), v(:,c), 'g-'); end
    title('Vsa oglišča kvadratov');
end

% Klic:
rectify_chessboard('Image_rect1.tif');
==== END Rok Prezelj | Rok Prezelj_18893_assignsubmission_file | nal2.m ====

==== BEGIN Rok Prezelj | Rok Prezelj_18893_assignsubmission_file | nal3.m ====
function radialna_distorzija(image_path)
% RADIALNA_DISTORZIJA – rešitev 3. naloge
% Uporaba:
%   radialna_distorzija('Image15.tif')   % ali pokličeš brez argumenta
%
% Postopek:
%  1) Prikaže sliko in te z ginput pozove, da klikneš točke dveh VERTIKALNIH kolon
%     vogalov: najprej kolona pri ROBU, potem kolona blizu SREDINE (Enter zaključi vsako kolono).
%  2) Za f = 400:20:800 izvede “odpopačenje” točk po danem inverznem modelu in
%     za vsako vrednost f izračuna vsoto kvadratov razdalj do najboljše premice (za obe koloni).
%  3) Nariše graf SSE(f) in izpiše optimalni f.
%
% Zahteve naloge in uporabljeni model so iz navodil vaje (glej PDF). 

    if nargin < 1 || isempty(image_path)
        image_path = 'Image15.tif';  % po navodilih
    end

    % --- Branje slike (v sivine) ---
    I = imread(image_path);
    if size(I,3) > 1, I = rgb2gray(I); end
    I = im2double(I);

    % --- Prikaz in zajem točk ---
    figure; imshow(I,[]); title('Klikni točke 1. (robne) VERTIKALNE kolone, nato Enter');
    [x1, y1] = ginput;  % prva kolona (pri robu)
    pts1 = [x1 y1];

    title('Zdaj klikni točke 2. (sredinske) VERTIKALNE kolone, nato Enter');
    [x2, y2] = ginput;  % druga kolona (blizu centra)
    pts2 = [x2 y2];

    if size(pts1,1) < 2 || size(pts2,1) < 2
        error('Za vsako kolono označi vsaj dve točki.');
    end

    % --- Središče slike (privzamemo približno v središču) ---
    [h, w] = size(I);
    C = [w/2, h/2];  % (cx, cy); če poznaš boljši principal point, ga vnesi tu

    % --- Interval f-jev po navodilih ---
    fs = 400:20:800;
    SSE = zeros(size(fs));

    use_fitline = exist('fitline','file') == 2;  % če imaš kovesi/fitline.m na poti

    % Glavna zanka po f
    for k = 1:numel(fs)
        f = fs(k);

        % Odpopači obe koloni točk
        und1 = undistort_points_radial(pts1, C, f);
        und2 = undistort_points_radial(pts2, C, f);

        % Oceni “linearno” naravnanost (vsota kvadratov razdalj do najboljše premice)
        if use_fitline
            [~, sse1] = fitline(und1); %#ok<ASGLU>  % vrne tudi koeficiente, a tu rabimo sse
            [~, sse2] = fitline(und2);
        else
            % Fallback: ortogonalna regresija (PCA) na točkah – vrne SSE
            sse1 = orth_line_sse(und1);
            sse2 = orth_line_sse(und2);
        end

        SSE(k) = sse1 + sse2;
    end

    % --- Najboljši f ---
    [SSEmin, idx] = min(SSE);
    f_opt = fs(idx);

    % --- Graf ---
    figure;
    plot(fs, SSE, 'o-','LineWidth',1.5); hold on;
    plot(f_opt, SSEmin, 'p', 'MarkerSize',12, 'MarkerFaceColor','auto');
    grid on; xlabel('f'); ylabel('Vsota kvadratov razdalj (SSE)');
    title(sprintf('Radialna distorzija – najboljše f = %d (SSE = %.4g)', f_opt, SSEmin));

    % --- Izhodna informacija ---
    fprintf('Optimalni f = %d (SSE = %.6g)\n', f_opt, SSEmin);
end

% ================= POMOŽNE FUNKCIJE =================

function und = undistort_points_radial(pts, C, f)
% Inverzni model iz navodil naloge:
% r' -> r'_l po:
%   r'_l = -f^2 * (exp(-2 r'/f) - 1) / exp(-r'/f)
% Kar je numerično stabilno izračunati kot:
%   r'_l = 2 f^2 sinh(r'/f)
%
% Nato točko prestavimo vzdolž radialne smeri:
%   und = C + (r'_l / r') * (pts - C)

    v = pts - C;                          % radialni vektorji
    r_prime = hypot(v(:,1), v(:,2));      % popačen radij r'
    t = r_prime / f;

    % Inverzna preslikava (po enačbi iz navodil; stabilno preko sinh)
    r_l_prime = 2 * (f^2) * sinh(t);      % r'_l

    % Izogni se deljenju z 0 v centru (r' == 0)
    scale = r_l_prime ./ max(r_prime, eps);

    und = C + [scale scale] .* v;
end

function sse = orth_line_sse(pts)
% Ortogonalna regresija: najboljša premica v smislu min. kvadratov
% SSE = vsota kvadratov ort. razdalj točk do premice
    mu = mean(pts,1);
    X = pts - mu;
    if size(X,1) < 2
        sse = 0;
        return
    end
    [U,~,~] = svd(X, 'econ');   %#ok<NASGU>
    dir = U(:,1);               % smer glavne komponente v prostoru točk (2D)
    % Aha, U je NxN; za 2D je bolje uporabiti eigenvektor kovariančne matrike:
    C = (X.'*X) / size(X,1);
    [V, D] = eig(C);            %#ok<ASGLU>
    [~, iMax] = max(diag(D));
    u = V(:, iMax);             % smer enotskega vektorja premice

    % Ortogonalna razdalja = norma (I - u u^T)(x - mu)
    Pperp = eye(2) - (u*u.');
    residuals = (Pperp * X.').';
    sse = sum(sum(residuals.^2, 2));
end
==== END Rok Prezelj | Rok Prezelj_18893_assignsubmission_file | nal3.m ====

==== BEGIN Rok Prezelj | Rok Prezelj_18893_assignsubmission_file | nal4.m ====
function radialna_distorzija(image_path)
% RADIALNA_DISTORZIJA – rešitev 3. naloge (z iskanjem optimalnega f preko fminsearch)
%
% Uporaba:
%   radialna_distorzija('Image15.tif')
%
% Postopek:
%   1) Prikaže sliko in te z ginput pozove, da klikneš točke dveh VERTIKALNIH kolon vogalov:
%        – najprej kolona pri ROBU
%        – nato kolona blizu SREDINE
%      (Vsako zaključiš s tipko Enter)
%   2) Izvede korekcijo po danem modelu in s pomočjo fminsearch poišče optimalni f,
%      ki minimizira vsoto kvadratov razdalj do najboljše premice (SSE).
%   3) Prikaže rezultat in izpiše optimalni f.

    if nargin < 1 || isempty(image_path)
        image_path = 'Image15.tif';  % privzeto ime slike
    end

    % --- Branje slike ---
    I = imread(image_path);
    if size(I,3) > 1, I = rgb2gray(I); end
    I = im2double(I);

    % --- Označevanje točk ---
    figure; imshow(I,[]); title('Klikni točke 1. (robne) vertikalne kolone, nato Enter');
    [x1, y1] = ginput; pts1 = [x1 y1];

    title('Zdaj klikni točke 2. (sredinske) vertikalne kolone, nato Enter');
    [x2, y2] = ginput; pts2 = [x2 y2];

    if size(pts1,1) < 2 || size(pts2,1) < 2
        error('Za vsako kolono označi vsaj dve točki.');
    end

    % --- Središče slike ---
    [h, w] = size(I);
    C = [w/2, h/2];

    % ============================================
    % Iskanje najboljšega f z optimizacijo
    % ============================================
    sse_fun = @(f) total_sse(f, pts1, pts2, C);

    f0 = 600;  % začetna ocena
    fprintf('Iščem optimalni f ...\n');
    f_opt = fminsearch(sse_fun, f0, optimset('Display','iter'));
    SSEmin = sse_fun(f_opt);

    fprintf('\nOptimalni f = %.3f (SSE = %.6g)\n', f_opt, SSEmin);
end

% ================================================================
% POMOŽNE FUNKCIJE
% ================================================================

function und = undistort_points_radial(pts, C, f)
% Inverzni model iz navodil naloge:
% r' -> r'_l po:
%   r'_l = -f^2 * (exp(-2r'/f) - 1) / exp(-r'/f)
% Numerično stabilna oblika:
%   r'_l = 2f^2 * sinh(r'/f)
% Nato točko prestavimo vzdolž radialne smeri.

    v = pts - C;                      
    r_prime = hypot(v(:,1), v(:,2));  
    t = r_prime / f;

    r_l_prime = 2 * (f^2) * sinh(t);  
    scale = r_l_prime ./ max(r_prime, eps);
    und = C + [scale scale] .* v;
end

function sse = orth_line_sse(pts)
% Ortogonalna regresija (najmanjši kvadrati)
    mu = mean(pts,1);
    X = pts - mu;
    if size(X,1) < 2
        sse = 0; return
    end
    C = (X.'*X) / size(X,1);
    [V,D] = eig(C);
    [~,iMax] = max(diag(D));
    u = V(:,iMax);
    Pperp = eye(2) - (u*u.');
    residuals = (Pperp * X.').';
    sse = sum(sum(residuals.^2,2));
end

function sse_total = total_sse(f, pts1, pts2, C)
% Skupna napaka za dano vrednost f
    if f <= 0
        sse_total = inf; return
    end
    und1 = undistort_points_radial(pts1, C, f);
    und2 = undistort_points_radial(pts2, C, f);
    sse_total = orth_line_sse(und1) + orth_line_sse(und2);
end
==== END Rok Prezelj | Rok Prezelj_18893_assignsubmission_file | nal4.m ====

==== BEGIN Rok Prezelj | Rok Prezelj_18893_assignsubmission_file | rnal4_fminsearch.txt ====
Iščem optimalni f ...
 
 Iteration   Func-count         f(x)         Procedure
     0            1      2.74945e+07         
     1            2      2.74945e+07         initial simplex
     2            4      2.16852e+07         expand
     3            6      2.15788e+07         reflect
     4            8      2.07829e+07         contract inside
     5           10      2.07829e+07         contract inside
     6           12      2.07829e+07         contract inside
     7           14      2.07825e+07         contract inside
     8           16      2.07793e+07         contract inside
     9           18      2.07793e+07         contract inside
    10           20      2.07793e+07         contract inside
    11           22      2.07793e+07         contract inside
    12           24      2.07793e+07         contract inside
    13           26      2.07793e+07         contract inside
    14           28      2.07793e+07         contract inside
    15           30      2.07793e+07         contract inside
    16           32      2.07793e+07         contract inside
    17           34      2.07793e+07         contract inside
    18           36      2.07793e+07         contract inside
    19           38      2.07793e+07         contract inside
    20           40      2.07793e+07         contract inside
    21           42      2.07793e+07         contract inside
    22           44      2.07793e+07         contract inside
    23           46      2.07793e+07         contract inside
 
Optimization terminated:
 the current x satisfies the termination criteria using OPTIONS.TolX of 1.000000e-04 
 and F(X) satisfies the convergence criteria using OPTIONS.TolFun of 1.000000e-04 


Optimalni f = 508.059 (SSE = 2.07793e+07)
==== END Rok Prezelj | Rok Prezelj_18893_assignsubmission_file | rnal4_fminsearch.txt ====

