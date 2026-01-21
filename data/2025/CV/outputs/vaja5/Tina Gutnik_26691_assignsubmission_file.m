==== BEGIN Tina Gutnik | Tina Gutnik_26691_assignsubmission_file | interpolacija.m ====
function interpolacija(vhodni_video, izhodni_video, faktor_skaliranja, metoda)
% uporabnik vnese ime vhodne datoteke, ime izhodne datoteke, faktor skaliranja in metodo interpolacije
% imeni vhodne in izhodne datoteke sta tipa string
% faktor skaliranja je številski npr. double
% METODA MORA BITI PODANA NA ENEGA IZMED TEH TREH NAČINOV: 'nearest', 'bilinear_aa_off', 'bilinear_aa_on'


    metoda = string(lower(metoda));             % lower za vsak slučaj naredi vnos neobčutljiv na male in velike črke
    
    video = VideoReader(vhodni_video);

    interpoliran_video = VideoWriter(izhodni_video);
    interpoliran_video.FrameRate = video.FrameRate;
    open(interpoliran_video)

    while hasFrame(video)
        frame = readFrame(video);

        if metoda == 'nearest'
            interpoliran_frame = imresize(frame, faktor_skaliranja, 'nearest');

        elseif metoda == 'bilinear_aa_off'
            interpoliran_frame = imresize(frame, faktor_skaliranja, 'bilinear', 'Antialiasing', false);

        elseif metoda == 'bilinear_aa_on'
            interpoliran_frame = imresize(frame, faktor_skaliranja, 'bilinear', 'Antialiasing', true);
        end
            
        writeVideo(interpoliran_video, interpoliran_frame);
    end

    close(interpoliran_video)
end


==== END Tina Gutnik | Tina Gutnik_26691_assignsubmission_file | interpolacija.m ====

==== BEGIN Tina Gutnik | Tina Gutnik_26691_assignsubmission_file | lab_vaja_5.m ====
% 1. naloga
% najprej primerjamo kakovosti zgolj prvega frameja
video = VideoReader('Holywood.avi');
prvi_frame = read(video, 1);

figure;
imshow(prvi_frame); title('Prvi frame videoposnetka');

s = 0.5;
I_nn   = imresize(prvi_frame, s, 'nearest');
I_bl_off = imresize(prvi_frame, s, 'bilinear', 'Antialiasing', false);
I_bl_on  = imresize(prvi_frame, s, 'bilinear', 'Antialiasing', true);

figure;
subplot(1,3,1); imshow(I_nn); title('Najbližji sosed'); axis off
subplot(1,3,2); imshow(I_bl_off); title('Bilinearna brez filtriranja'); axis off
subplot(1,3,3); imshow(I_bl_on); title('Bilinearna s filtriranjem'); axis off

% klicanje funkcije interpolacija, da dobimo 9 posnetkov
interpolacija('Holywood.avi', 'I_nn_0.5.avi', 0.5, 'nearest')
interpolacija('Holywood.avi', 'I_nn_0.25.avi', 0.25, 'nearest')
interpolacija('Holywood.avi', 'I_nn_0.125.avi', 0.125, 'nearest')

interpolacija('Holywood.avi', 'I_bl_off_0.5.avi', 0.5, 'bilinear_aa_off')
interpolacija('Holywood.avi', 'I_bl_off_0.25.avi', 0.25, 'bilinear_aa_off')
interpolacija('Holywood.avi', 'I_bl_off_0.125.avi', 0.125, 'bilinear_aa_off')

interpolacija('Holywood.avi', 'I_bl_on_0.5.avi', 0.5, 'bilinear_aa_on')
interpolacija('Holywood.avi', 'I_bl_on_0.25.avi', 0.25, 'bilinear_aa_on')
interpolacija('Holywood.avi', 'I_bl_on_0.125.avi', 0.125, 'bilinear_aa_on')

%% 2. naloga način 2.1
video = VideoReader('squash.avi');
prvi_frame = readFrame(video);

figure;
imshow(prvi_frame);
title('Izberite levi zgornji rob pravokotnika okoli rdečega igralca in desni spodnji rob.');

[x, y] = ginput(2);            % ginput shrani koordinati teh dveh klikov, nato izrišemo stranice
x = round(x); y = round(y);    % da nimamo decimalnih indeksov stolpcev in vrstic
x1 = min(x); y1 = min(y);
x2 = max(x); y2 = max(y);

[H, W, ~] = size(prvi_frame);
x1 = max(1, min(W, x1)); x2 = max(1, min(W, x2));
y1 = max(1, min(H, y1)); y2 = max(1, min(H, y2));

hold on;
plot([x1 x2], [y1 y1], 'Color', 'b');  
plot([x1 x2], [y2 y2], 'Color', 'b'); 
plot([x1 x1], [y1 y2], 'Color', 'b');  
plot([x2 x2], [y1 y2], 'Color', 'b');  

w = x2 - x1 + 1;               % širina pravokotnika
h = y2 - y1 + 1;               % višina pravokotnika

x = x1;
y = y1;   % trenutna lokacija je točka zgoraj levo

prvi_siv_frame = im2double(rgb2gray(prvi_frame));
okvir_siv = prvi_siv_frame(y1:y2, x1:x2);
okvir_siv_vektor = okvir_siv(:);

okvir_siv_vektor = okvir_siv_vektor - mean(okvir_siv_vektor);
okvir_siv_vektor = okvir_siv_vektor / (std(okvir_siv_vektor) + 1e-6);

sigma = 0.35;
[X, Y] = meshgrid(linspace(-1,1,w), linspace(-1,1,h));
M = exp(-(X.^2 + Y.^2)/(2*sigma^2));
M = M / sum(M(:));
Mvec = M(:);


novi_video = VideoWriter('squash_pravokotnik_L2.avi');
novi_video.FrameRate = video.FrameRate;
open(novi_video)

izhodni_frame = insertShape(prvi_frame, 'rectangle', [x y w h]);
writeVideo(novi_video, izhodni_frame);

% sledenje po okvirjih
eps = 20;
while hasFrame(video)
    frame_rgb = readFrame(video);
    frame_siv = im2double(rgb2gray(frame_rgb));
   
    % določimo meje lokalne okolice
    x_min = max(1, x - eps);
    y_min = max(1, y - eps);
    x_max = min(W - w + 1, x + eps);
    y_max = min(H - h + 1, y + eps);

    najmanjsa_razlika = inf;
    najboljsi_x = x;
    najboljsi_y = y;
       
    for yy = y_min:y_max
        for xx = x_min:x_max
            izsek_siv = frame_siv(yy:yy+h-1, xx:xx+w-1);
            izsek_siv_vektor = izsek_siv(:);

            izsek_siv_vektor = izsek_siv_vektor - mean(izsek_siv_vektor);
            izsek_siv_vektor = izsek_siv_vektor / (std(izsek_siv_vektor) + 1e-6);

            
            d = okvir_siv_vektor - izsek_siv_vektor;
            razlika = sum(Mvec .* (d.^2));
            %razlika = d' * d;

            if razlika < najmanjsa_razlika
                najmanjsa_razlika = razlika;
                najboljsi_x = xx;
                najboljsi_y = yy;
            end
        end
     end

     x = najboljsi_x;
     y = najboljsi_y;

     izhodni_frame = insertShape(frame_rgb, 'rectangle', [x y w h]);
     writeVideo(novi_video, izhodni_frame);
end

close(novi_video);     

%% 2. naloga način 2.2
video = VideoReader('squash.avi');
prvi_frame = readFrame(video);

figure;
imshow(prvi_frame);
title('Izberite levi zgornji rob pravokotnika okoli rdečega igralca in desni spodnji rob.');

[x, y] = ginput(2);            % ginput shrani koordinati teh dveh klikov, nato izrišemo stranice
x = round(x); y = round(y);    % da nimamo decimalnih indeksov stolpcev in vrstic
x1 = min(x); y1 = min(y);
x2 = max(x); y2 = max(y);

[H, W, ~] = size(prvi_frame);
x1 = max(1, min(W, x1)); x2 = max(1, min(W, x2));
y1 = max(1, min(H, y1)); y2 = max(1, min(H, y2));

hold on;
plot([x1 x2], [y1 y1], 'Color', 'b');  
plot([x1 x2], [y2 y2], 'Color', 'b'); 
plot([x1 x1], [y1 y2], 'Color', 'b');  
plot([x2 x2], [y1 y2], 'Color', 'b');  

w = x2 - x1 + 1;               % širina pravokotnika
h = y2 - y1 + 1;               % višina pravokotnika

x = x1;
y = y1;                        % trenutna lokacija je točka zgoraj levo

% značilnica in histogram
okvir_rgb = im2double(prvi_frame(y1:y2, x1:x2, :));
okvir_hsv = rgb2hsv(okvir_rgb);

okvir_H = okvir_hsv(:, :, 1);     

st_binov = 16;
robovi = linspace(0, 1, st_binov + 1);
ref_H = histcounts(okvir_H(:), robovi);
ref_H = ref_H / (sum(ref_H) + 1e-12);


novi_video = VideoWriter('squash_pravokotnik_HSV.avi');
novi_video.FrameRate = video.FrameRate;
open(novi_video)

izhodni_frame = insertShape(prvi_frame, 'rectangle', [x y w h]);
writeVideo(novi_video, izhodni_frame);

% sledenje po okvirjih
eps = 25;
while hasFrame(video) 
    frame_rgb = readFrame(video);
    frame_rgb = im2double(frame_rgb);
    
    
    % določimo meje lokalne okolice
    x_min = max(1, x - eps);
    y_min = max(1, y - eps);
    x_max = min(W - w + 1, x + eps);
    y_max = min(H - h + 1, y + eps);

    najmanjsa_razlika = inf;
    najboljsi_x = x;
    najboljsi_y = y;
       
    for yy = y_min:y_max
        for xx = x_min:x_max
            izsek_hsv = rgb2hsv(frame_rgb(yy:yy+h-1, xx:xx+w-1, :));

            izsek_H = izsek_hsv(:,:,1);
            
            povp_H = histcounts(izsek_H(:), robovi);
            povp_H = povp_H / (sum(povp_H) + 1e-12);

            razlika = 0.5 * sum((ref_H - povp_H).^2 ./ (ref_H + povp_H + 1e-12));


            if razlika < najmanjsa_razlika
                najmanjsa_razlika = razlika;
                najboljsi_x = xx;
                najboljsi_y = yy;
            end
        end
     end

     x = najboljsi_x;
     y = najboljsi_y;

     izhodni_frame = insertShape(frame_rgb, 'rectangle', [x y w h]);
     writeVideo(novi_video, izhodni_frame);
end

close(novi_video);     


%% 3. naloga
% pri načinu 2.2 že brez učenja celoten video pravilno pravokotnik sledi igralcu
% zato sem z učenjem popravila način sledenja iz naloge 2.1

video = VideoReader('squash.avi');
prvi_frame = readFrame(video);

figure;
imshow(prvi_frame);
title('Izberite levi zgornji rob pravokotnika okoli rdečega igralca in desni spodnji rob.');

[x, y] = ginput(2);            % ginput shrani koordinati teh dveh klikov, nato izrišemo stranice
x = round(x); y = round(y);    % da nimamo decimalnih indeksov stolpcev in vrstic
x1 = min(x); y1 = min(y);
x2 = max(x); y2 = max(y);

[H, W, ~] = size(prvi_frame);
x1 = max(1, min(W, x1)); x2 = max(1, min(W, x2));
y1 = max(1, min(H, y1)); y2 = max(1, min(H, y2));

hold on;
plot([x1 x2], [y1 y1], 'Color', 'b');  
plot([x1 x2], [y2 y2], 'Color', 'b'); 
plot([x1 x1], [y1 y2], 'Color', 'b');  
plot([x2 x2], [y1 y2], 'Color', 'b');  

w = x2 - x1 + 1;               % širina pravokotnika
h = y2 - y1 + 1;               % višina pravokotnika

x = x1;
y = y1;   % trenutna lokacija je točka zgoraj levo

prvi_siv_frame = im2double(rgb2gray(prvi_frame));
okvir_siv = prvi_siv_frame(y1:y2, x1:x2);
okvir_siv_vektor = okvir_siv(:);

okvir_siv_vektor = okvir_siv_vektor - mean(okvir_siv_vektor);
okvir_siv_vektor = okvir_siv_vektor / (std(okvir_siv_vektor) + 1e-6);

sigma = 0.35;
[X, Y] = meshgrid(linspace(-1,1,w), linspace(-1,1,h));
M = exp(-(X.^2 + Y.^2)/(2*sigma^2));
M = M / sum(M(:));
Mvec = M(:);


novi_video = VideoWriter('squash_pravokotnik_L2_po_ucenju1.avi');
novi_video.FrameRate = video.FrameRate;
open(novi_video)

izhodni_frame = insertShape(prvi_frame, 'rectangle', [x y w h]);
writeVideo(novi_video, izhodni_frame);

alpha = 0.02;   % hitrost učenja (0.01..0.05)
tau   = 5;      % prag zaupanja (manjši je strožje)
eps = 25;
% sledenje po okvirjih
vx = 0; vy = 0;          % hitrost (v px/frame)
beta = 0.7;              % glajenje hitrosti (0.5..0.9)
eps_min = 20;
eps_max = 80;

while hasFrame(video)
    frame_rgb = readFrame(video);
    frame_siv = im2double(rgb2gray(frame_rgb));
   
    x_pred = round(x + vx);
    y_pred = round(y + vy);
    x_pred = max(1, min(W - w + 1, x_pred));
    y_pred = max(1, min(H - h + 1, y_pred));
    % določimo meje lokalne okolice
    x_min = max(1, x_pred - eps);
    y_min = max(1, y_pred - eps);
    x_max = min(W - w + 1, x_pred + eps);
    y_max = min(H - h + 1, y_pred + eps);

    najmanjsa_razlika = inf;
    najboljsi_x = x;
    najboljsi_y = y;
    
    vx_new = najboljsi_x - x;
    vy_new = najboljsi_y - y;
    vx = beta*vx + (1-beta)*vx_new;
    vy = beta*vy + (1-beta)*vy_new;
    
    % sprotno učenje
    bestPatchVec = okvir_siv_vektor;  % tu si shranimo najboljsi izsek (normaliziran vektor)
   
       
    for yy = y_min:y_max
        for xx = x_min:x_max
            izsek_siv = frame_siv(yy:yy+h-1, xx:xx+w-1);
            izsek_siv_vektor = izsek_siv(:);

            izsek_siv_vektor = izsek_siv_vektor - mean(izsek_siv_vektor);
            izsek_siv_vektor = izsek_siv_vektor / (std(izsek_siv_vektor) + 1e-6);

            d = okvir_siv_vektor - izsek_siv_vektor;
            razlika = sum(Mvec .* (d.^2));

            lambda = 0.02;
            pen = lambda * ((xx - x)^2 + (yy - y)^2);
            score = razlika + pen;
            
            if score < najmanjsa_razlika
                najmanjsa_razlika = score;
                najboljsi_x = xx;
                najboljsi_y = yy;
                bestPatchVec = izsek_siv_vektor; % če uporabljaš učenje
            end
        end
     end

     
     % če je ujemanje sumljivo slabo, ne posodabljaj in ne premikaj
     if najmanjsa_razlika > tau
         najboljsi_x = x;
         najboljsi_y = y;
     else
         % če je ujemanje dobro -> posodobi značilnico 
         okvir_siv_vektor = (1-alpha)*okvir_siv_vektor + alpha*bestPatchVec;

         % po posodobitvi spet normaliziraj
         okvir_siv_vektor = okvir_siv_vektor - mean(okvir_siv_vektor);
         okvir_siv_vektor = okvir_siv_vektor / (std(okvir_siv_vektor) + 1e-6);
     end

     x = najboljsi_x;
     y = najboljsi_y;

     izhodni_frame = insertShape(frame_rgb, 'rectangle', [x y w h]);
     writeVideo(novi_video, izhodni_frame);
end

close(novi_video);


==== END Tina Gutnik | Tina Gutnik_26691_assignsubmission_file | lab_vaja_5.m ====

