==== BEGIN Boris Jovanović | Boris Jovanović_28020_assignsubmission_file | RV_LV_5.m ====
%% 1. DEL: Piramida ločljivosti (Holywood.avi)
srcVideo = VideoReader('Holywood.avi');
vRate = srcVideo.FrameRate;
vFrames = srcVideo.NumFrames;
scales = [0.5, 0.25, 0.125];
suffixes = {'_half', '_quarter', '_eighth'};

for s = 1:length(scales)
    % Ustvarjanje objektov za zapisovanje
    outNN = VideoWriter(['Res_NN' suffixes{s} '.avi']);
    outBL = VideoWriter(['Res_BL' suffixes{s} '.avi']);
    outBL_AA = VideoWriter(['Res_BL_AA' suffixes{s} '.avi']);
    
    open(outNN); open(outBL); open(outBL_AA);
    
    for f = 1:vFrames
        img = read(srcVideo, f);
        
        % Nearest Neighbor
        writeVideo(outNN, imresize(img, scales(s), 'nearest'));
        
        % Bilinear brez antialiasinga
        writeVideo(outBL, imresize(img, scales(s), 'bilinear', 'Antialiasing', false));
        
        % Bilinear z antialiasingom
        writeVideo(outBL_AA, imresize(img, scales(s), 'bilinear', 'Antialiasing', true));
    end
    
    close(outNN); close(outBL); close(outBL_AA);
end

%% 2.1 DEL: Evklidska razdalja (L2) - Sledenje
sqVideo = VideoReader('squash.avi');
data = read(sqVideo);
firstImg = data(:,:,:,1);

% Ročna izbira tarče
figure(1); imshow(firstImg); title('Označi igralca (pravokotnik)');
rect = round(getrect()); % [x_min, y_min, width, height]
templ = firstImg(rect(2):rect(2)+rect(4), rect(1):rect(1)+rect(3), :);

% Trenutna pozicija (zgornji levi kot)
currX = rect(1);
currY = rect(2);
searchRadius = 25;
[h, w, ~] = size(templ);

outL2 = VideoWriter('Sledenje_L2.avi');
open(outL2);

for i = 1:size(data, 4)
    frame = data(:,:,:,i);
    
    % Določitev iskalnega okna
    yRange = max(1, currY-searchRadius) : min(size(frame,1)-h, currY+searchRadius);
    xRange = max(1, currX-searchRadius) : min(size(frame,2)-w, currX+searchRadius);
    
    bestDist = inf;
    
    for y = yRange
        for x = xRange
            patch = frame(y:y+h, x:x+w, :);
            % Izračun L2 razdalje
            dist = sum((double(patch) - double(templ)).^2, 'all');
            
            if dist < bestDist
                bestDist = dist;
                currX = x;
                currY = y;
            end
        end
    end
    
    % Vizualizacija s krogom v središču
    resImg = insertShape(frame, 'Circle', [currX+w/2, currY+h/2, 15], 'Color', 'cyan', 'LineWidth', 3);
    writeVideo(outL2, resImg);
end
close(outL2);

%% 2.2 DEL: Barvni Histogrami
% Uporabimo isto izbrano tarčo 'templ', a jo pretvorimo v sivinsko za hist.
templGray = rgb2gray(templ);
% Izračun referenčnega histograma (9 košov)
refHist = histcounts(templGray, 0:32:256, 'Normalization', 'probability');

outHist = VideoWriter('Sledenje_Hist.avi');
open(outHist);

% Ponastavimo pozicijo na začetno
currX = rect(1); currY = rect(2);

for i = 1:size(data, 4)
    imgGray = rgb2gray(data(:,:,:,i));
    
    yRange = max(1, currY-searchRadius) : min(size(imgGray,1)-h, currY+searchRadius);
    xRange = max(1, currX-searchRadius) : min(size(imgGray,2)-w, currX+searchRadius);
    
    minChi = inf;
    
    for y = yRange
        for x = xRange
            sub = imgGray(y:y+h, x:x+w);
            hSub = histcounts(sub, 0:32:256, 'Normalization', 'probability');
            
            % Razdalja med histogrami (kvadratna razdalja)
            d = sum((refHist - hSub).^2);
            
            if d < minChi
                minChi = d;
                currX = x;
                currY = y;
            end
        end
    end
    
    finalFrame = insertShape(data(:,:,:,i), 'FilledCircle', [currX+w/2, currY+h/2, 5], 'Color', 'yellow');
    writeVideo(outHist, finalFrame);
end
close(outHist);

%% 3. DEL: Sproti posodabljanje značilnice (Adaptivno sledenje)
outAdapt = VideoWriter('Sledenje_Adaptivno.avi');
open(outAdapt);

% Začetni parametri
currX = rect(1); currY = rect(2);
dynamicTempl = templ; 

for i = 1:size(data, 4)
    frame = data(:,:,:,i);
    
    yR = max(1, currY-searchRadius) : min(size(frame,1)-h, currY+searchRadius);
    xR = max(1, currX-searchRadius) : min(size(frame,2)-w, currX+searchRadius);
    
    bestD = inf;
    for y = yR
        for x = xR
            p = frame(y:y+h, x:x+w, :);
            d = sum((double(p) - double(dynamicTempl)).^2, 'all');
            if d < bestD
                bestD = d;
                currX = x; currY = y;
            end
        end
    end
    
    % POSODABLJANJE: Nova značilnica postane trenutno najdeni izsek
    dynamicTempl = frame(currY:currY+h, currX:currX+w, :);
    
    res = insertShape(frame, 'Rectangle', [currX, currY, w, h], 'Color', 'green');
    writeVideo(outAdapt, res);
end
close(outAdapt);
==== END Boris Jovanović | Boris Jovanović_28020_assignsubmission_file | RV_LV_5.m ====

