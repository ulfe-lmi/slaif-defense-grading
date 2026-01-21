==== BEGIN Domen Hauko | Domen Hauko_26689_assignsubmission_file | vaja05.m ====
%% RV vaja 5
%% 1. Podvzorčenje slik

videoResize("Holywood.avi", "holywood/hw1_2_nearest.avi", 2, "nearest", true);
videoResize("Holywood.avi", "holywood/hw1_4_nearest.avi", 4, "nearest", true);
videoResize("Holywood.avi", "holywood/hw1_8_nearest.avi", 8, "nearest", true);
videoResize("Holywood.avi", "holywood/hw1_2_anti.avi", 2, "bilinear", true);
videoResize("Holywood.avi", "holywood/hw1_4_anti.avi", 4, "bilinear", true);
videoResize("Holywood.avi", "holywood/hw1_8_anti.avi", 8, "bilinear", true);
videoResize("Holywood.avi", "holywood/hw1_2_bilinear.avi", 2, "bilinear", false);
videoResize("Holywood.avi", "holywood/hw1_4_bilinear.avi", 4, "bilinear", false);
videoResize("Holywood.avi", "holywood/hw1_8_bilinear.avi", 8, "bilinear", false);
function videoResize(inputFile, outputFile, resize_factor, method, antialias)

    vr = VideoReader(inputFile);
    vw = VideoWriter(outputFile);
    vw.FrameRate = vr.FrameRate;
    open(vw)

    scale = 1 / resize_factor;

    while hasFrame(vr)
        frame = readFrame(vr);                % uint8
        resized = imresize(frame, scale, method, ...
                           "Antialiasing", antialias);
        writeVideo(vw, resized);
    end

    close(vw);
end

%% 2. SQUASH

%% 2.1 Evklidska razdalja

squash = VideoReader("squash.avi");
frame_squash = readFrame(squash);

% Označimo enega igralca na prvem frame-u
% Iščemo njegovo lokacijo v naslednjem frame-u,
% z ničtim redom (igralec se ni premaknil izven okolice E)

figure;
imshow(frame_squash);
title('Označi najprej rdečega in nato belega igralca');
[igralec_red, rect_red] = imcrop(frame_squash);
[igralec_white, rect_white] = imcrop(frame_squash);

% VideoWriter, da naredimo video z rdečim pravokotnikom
v_red = VideoWriter("squash_red_track.avi");
v_red.FrameRate = squash.FrameRate;
open(v_red);

% Loop, ki gre čez naslednje frame-e
while squash.hasFrame()
    frame_new = readFrame(squash);

    %   RDEČI IGRALEC

    % E okolica, ki jo preverjamo: 3x3 večja
    ref_x = rect_red(1);
    ref_y = rect_red(2);
    ref_w = rect_red(3);
    ref_h = rect_red(4);

    x_range = round(ref_x - 1*ref_w) : round(ref_x + 2*ref_w);
    y_range = round(ref_y - 1*ref_h) : round(ref_y + 2*ref_h);

    min_dist = inf;
    new_x = 0;
    new_y = 0;

    for xe = 1:length(x_range)
        for ye = 1:length(y_range)

            % Error handling: če gre nov crop izven robov slike
            [H, W, ~] = size(frame_new);

            x = x_range(xe);
            y = y_range(ye);
            
            if x < 1 || y < 1 || x+ref_w-1 > W || y+ref_h-1 > H
                continue;
            end

            rect_new_red = [x, y, ref_w - 1, ref_h - 1];
            frame_new_crop = imcrop(frame_new, rect_new_red);
            evklid = evklidska_razdalja(igralec_red, frame_new_crop);

            if evklid < min_dist
                min_dist = evklid;
                % Lokacija igralca
                new_x = x;
                new_y = y;
            end
        end 
    end

    % Nova pozicija igralca
    best_x = new_x;
    best_y = new_y;

    rect_lokacija = [best_x best_y ref_w ref_h];
    rect_red = rect_lokacija;   % update tracker
    
    frame_vis = insertShape(frame_new, ...
        'Rectangle', rect_lokacija, ...
        'Color', 'red', ...
        'LineWidth', 3);

    %   BELI IGRALEC

    % E okolica, ki jo preverjamo: 3x3 večja
    ref_x = rect_white(1);
    ref_y = rect_white(2);
    ref_w = rect_white(3);
    ref_h = rect_white(4);

    x_range = round(ref_x - 2*ref_w) : round(ref_x + 3*ref_w);
    y_range = round(ref_y - 2*ref_h) : round(ref_y + 3*ref_h);

    min_dist = inf;
    new_x = ref_x;
    new_y = ref_y;

    for xe = 1:length(x_range)
        for ye = 1:length(y_range)

            % Error handling: če gre nov crop izven robov slike
            [H, W, ~] = size(frame_new);

            x = x_range(xe);
            y = y_range(ye);
            
            if x < 1 || y < 1 || x+ref_w-1 > W || y+ref_h-1 > H
                continue;
            end

            rect_new_white = [x, y, ref_w - 1, ref_h - 1];
            frame_new_crop = imcrop(frame_new, rect_new_white);

            evklid = evklidska_razdalja(igralec_white, frame_new_crop);
        
            if evklid < min_dist
                min_dist = evklid;
                % Lokacija igralca
                new_x = x;
                new_y = y;
            end
        end 
    end
    
    % Nova lokacija igralca
    best_x = new_x;
    best_y = new_y;

    rect_lokacija = [best_x best_y ref_w ref_h];
    rect_white = rect_lokacija;   % update tracker
    
    frame_vis_both = insertShape(frame_vis, ...
        'Rectangle', rect_lokacija, ...
        'Color', 'blue', ...
        'LineWidth', 3);
    
    writeVideo(v_red, frame_vis_both);
end

close(v_red);

fprintf("Narejena evklidska razdalja!\n");

function razlika = evklidska_razdalja(reference, new)
    
    % Evklidska razdalja
    reference = double(reference(:));
    new = double(new(:));
    razlika = norm(reference - new, 2);

end

%% 2.2 Hi kvadrat razdalja


function razlika = razlika_histogramov_hi_kvadrat(reference, new)
    
    % Hi kvadrat razdalja
    reference = reference(:);
    new = new(:);

    eps_val = 1e-10;    % Prepreči deljenje z nič
    razlika = 0.5 * sum((reference - new).^2 ./ (reference + new + eps_val));

end


% Funkcija naredi histogram podane slike v 4x4x4 bine
function hist = histogram_igralca(image)

    % Če je prazna slika, vrne prazen histogram
    if isempty(image) || size(image,3) ~= 3
    hist = zeros(4,4,4);
    return;
    end

    % Bins
    R = image(:,:,1);
    G = image(:,:,2);
    B = image(:,:,3);
    
    % Pretvorba v vektorje
    R = double(R(:));
    G = double(G(:));
    B = double(B(:));
    
    nBins = 4;
    R_bin = min(floor(R / 256 * nBins), nBins-1);
    G_bin = min(floor(G / 256 * nBins), nBins-1);
    B_bin = min(floor(B / 256 * nBins), nBins-1);
    
    hist_ref = zeros(nBins, nBins, nBins);
    for i = 1:length(R_bin)
        hist_ref(R_bin(i)+1, G_bin(i)+1, B_bin(i)+1) = ...
            hist_ref(R_bin(i)+1, G_bin(i)+1, B_bin(i)+1) + 1;
    end
    
    % Normalize reference histogram to sum to 1 (probability distribution)
    hist = hist_ref / sum(hist_ref(:));
end


squash = VideoReader("squash.avi");
frame_squash = readFrame(squash);

% Označimo enega igralca na prvem frame-u
% Iščemo njegovo lokacijo v naslednjem frame-u,
% z ničtim redom (igralec se ni premaknil izven okolice E)

figure;
imshow(frame_squash);
title("Hi kvadrat: Označi rdečega igralca!");
[igralec_red, rect_red] = imcrop(frame_squash);

% histogram igralcev
hist_igralec_red = histogram_igralca(igralec_red);

% VideoWriter, da naredimo video z rdečim pravokotnikom
v_red = VideoWriter("squash_red_track_chi.avi");
v_red.FrameRate = squash.FrameRate;
open(v_red);

% Loop, ki gre čez naslednje frame-e
while squash.hasFrame()
    frame_new = readFrame(squash);

    %   RDEČI IGRALEC

    ref_x = rect_red(1);
    ref_y = rect_red(2);
    ref_w = rect_red(3);
    ref_h = rect_red(4);

    x_range = round(ref_x - 1*ref_w) : round(ref_x + 2*ref_w);
    y_range = round(ref_y - 1*ref_h) : round(ref_y + 2*ref_h);

    min_dist = Inf;
    new_x = ref_x;
    new_y = ref_y;

    for xe = 1:length(x_range)
        for ye = 1:length(y_range)

            % Error handling: če gre nov crop izven robov slike
            [H, W, ~] = size(frame_new);

            x = x_range(xe);
            y = y_range(ye);
            
            if x < 1 || y < 1 || x+ref_w-1 > W || y+ref_h-1 > H
                continue;
            end

            rect_new_red = [x, y, ref_w, ref_h];
            frame_new_crop = imcrop(frame_new, rect_new_red);
            
            % Histogram nove pozicije (E okolica)
            hist_new_frame_red = histogram_igralca(frame_new_crop);
        
            % Razlika histogramov prvi_frame - trenutni
            chi_razlika = razlika_histogramov_hi_kvadrat(hist_igralec_red, hist_new_frame_red);
            if chi_razlika < min_dist
                min_dist = chi_razlika;
                new_x = x;
                new_y = y;
            end

        end 
    end

    % Nova pozicija igralca
    best_x = new_x;
    best_y = new_y;

    rect_lokacija = [best_x best_y ref_w ref_h];
    rect_red = rect_lokacija;   % update tracker
    
    frame_vis = insertShape(frame_new, ...
        'Rectangle', rect_lokacija, ...
        'Color', 'red', ...
        'LineWidth', 3);
    
    writeVideo(v_red, frame_vis);
end

close(v_red);

fprintf("Narejeno sledenje s hi kvadrat!\n");

%% 3. Rdeči igralec, sprotno učenje in Hi kvadrat

function hist = histogram_igralca_sivinski(image)

    % Če je prazna slika, vrne prazen histogram
    if isempty(image)
        hist = zeros(256, 1);
        return;
    end

    % Če je slika RGB, jo pretvori v sivinsko
    if size(image,3) == 3
        % Standardna luminančna pretvorba
        image = 0.2989 * double(image(:,:,1)) + ...
                0.5870 * double(image(:,:,2)) + ...
                0.1140 * double(image(:,:,3));
    else
        image = double(image);
    end

    % Pretvorba v vektor
    gray = image(:);

    % Število binov
    nBins = 8;

    % Izračun binov
    gray_bin = min(floor(gray / 256 * nBins), nBins-1);

    % Histogram
    hist_ref = zeros(nBins, 1);
    for i = 1:length(gray_bin)
        hist_ref(gray_bin(i) + 1) = hist_ref(gray_bin(i) + 1) + 1;
    end

    % Normalizacija (verjetnostna porazdelitev)
    hist = hist_ref / sum(hist_ref);
end

function razlika = razlika_histogramov_hi_kvadrat_sivinski(reference, new)
    
    % Hi kvadrat razdalja
    reference = reference(:);
    new = new(:);

    eps_val = 1e-10;    % Prepreči deljenje z nič
    razlika = 0.5 * sum((reference - new).^2 ./ (reference + new + eps_val));

end


squash = VideoReader("squash.avi");
frame_squash = readFrame(squash);

% Označimo enega igralca na prvem frame-u
% Iščemo njegovo lokacijo v naslednjem frame-u,
% z ničtim redom (igralec se ni premaknil izven okolice E)

figure;
imshow(frame_squash);
title("Hi kvadrat, sprotno učenje: označi rdečega igralca!");
[igralec_red, rect_red] = imcrop(frame_squash);

% histogram igralcev
hist_igralec_red = histogram_igralca_sivinski(igralec_red);

% VideoWriter, da naredimo video z rdečim pravokotnikom
v_red = VideoWriter("squash_white_track_chi_learning.avi");
v_red.FrameRate = squash.FrameRate;
open(v_red);

% Loop, ki gre čez naslednje frame-e
while squash.hasFrame()
    frame_new = readFrame(squash);

    %   RDEČI IGRALEC
    ref_x = rect_red(1);
    ref_y = rect_red(2);
    ref_w = rect_red(3);
    ref_h = rect_red(4);

    % E okolica
    x_okolica = ref_x - 0.5*ref_w;
    y_okolica = ref_y - 0.5*ref_h;
    w_okolica = ref_w * 2;
    h_okolica = ref_h * 2;

    x_range = round(ref_x - 0.5*ref_w) : round(ref_x + 1.5*ref_w);
    y_range = round(ref_y - 0.5*ref_h) : round(ref_y + 1.5*ref_h);

    %D = inf(length(y_range), length(x_range));
    min_dist = Inf;
    best_x = ref_x;
    best_y = ref_y;

    for xe = 1:length(x_range)
        for ye = 1:length(y_range)

            % Error handling: če gre nov crop izven robov slike
            [H, W, ~] = size(frame_new);

            x = x_range(xe);
            y = y_range(ye);
            
            if x < 1 || y < 1 || x+ref_w-1 > W || y+ref_h-1 > H
                continue;
            end

            rect_new_red = [x, y, ref_w, ref_h];
            frame_new_crop = imcrop(frame_new, rect_new_red);
            
            % Histogram nove pozicije (E okolica)
            hist_new_frame_red = histogram_igralca_sivinski(frame_new_crop);
        
            % Razlika histogramov prvi_frame - trenutni
            dist = razlika_histogramov_hi_kvadrat_sivinski(hist_igralec_red, hist_new_frame_red);

            if dist < min_dist
                min_dist = dist;
                best_x = x;
                best_y = y;
                min_hist = hist_new_frame_red;
            end

        end 
    end

    % Nova lokacija igralca
    rect_lokacija = [best_x best_y ref_w ref_h];

    % Rišemo okolico
    rect_okolica = [best_x - 0.5*ref_w, best_y - 0.5*ref_h, w_okolica, h_okolica];
    rect_red = rect_lokacija;   % update tracker
    hist_igralec_red = min_hist;  % update histogram - sprotno učenje
    
    frame_vis = insertShape(frame_new, ...
        'Rectangle', rect_lokacija, ...
        'Color', 'red', ...
        'LineWidth', 3);
    frame_vis_okolica = insertShape(frame_vis, ...
        'Rectangle', rect_okolica, ...
        'Color', 'yellow', ...
        'LineWidth', 3);

    
    writeVideo(v_red, frame_vis_okolica);
end

close(v_red);

fprintf("Narejeno sprotno učenje s hi kvadratom!\n");
==== END Domen Hauko | Domen Hauko_26689_assignsubmission_file | vaja05.m ====

