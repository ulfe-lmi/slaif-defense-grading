==== BEGIN Jakob Suhadolc | Jakob Suhadolc_26684_assignsubmission_file | Naloga1_vaja5.m ====
%% Naloga 1 - Podvzorcenje slik
clear; clc;
v = VideoReader('Holywood.avi');

scale = [0.5, 0.25, 0.125];  
methods = {'nearest', 'bilinear', 'bilinear_prefilter'}; 

for i = 1:length(methods)           % izbira metode
    for j = 1:length(scale)         % izbira faktorja

        v.CurrentTime = 0;    
        outName = sprintf('out_%s_%dx.avi', methods{i}, round(1/scale(j)));
        w = VideoWriter(outName);   % pripravi zapisovanje
        open(w);

        while hasFrame(v)           % gre cez vse framee
            frame = readFrame(v);   % preberi en frame

            if i == 1
                resized = imresize(frame, scale(j), 'nearest'); % nearest neighbor
            elseif i == 2
                resized = imresize(frame, scale(j), 'bilinear', 'Antialiasing', false); % bilinear brez AA
            else
                resized = imresize(frame, scale(j), 'bilinear', 'Antialiasing', true);  % bilinear z AA
            end

            writeVideo(w, resized); % shrani frame v izhodni video
        end

        close(w);                   
    end
end
==== END Jakob Suhadolc | Jakob Suhadolc_26684_assignsubmission_file | Naloga1_vaja5.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_26684_assignsubmission_file | Naloga2_1_vaja5.m ====
clear; clc;

videoIn  = VideoReader('squash.avi');     
videoOut = VideoWriter('track2.avi');     
open(videoOut);                           

firstFrame = readFrame(videoIn);   %uzami prvi frame in ga prikazi
imshow(firstFrame);                    
selection = round(getrect);  %izberemo pravokotnik [x y w h]

%izrez predloge igralca iz prvega frema  
template = firstFrame( ...   
    selection(2):selection(2)+selection(4)-1, ...
    selection(1):selection(1)+selection(3)-1, :);

posX = selection(1); posY = selection(2); %zacetna pozicija pravokotnika
tplWidth = selection(3); tplHeight = selection(4); %velikost pravokotnika
searchRadius = 15;   % epsilon, lokalno iskanje, uzamemo 20 pikselov okol

while hasFrame(videoIn)   %cez vse naslednje frame-e
    currentFrame = readFrame(videoIn);
    
    %zacetne najbolse vrednosti
    minError = inf; 
    bestX = posX; 
    bestY = posY; 

    % meje iskalnega okna (da ne gremo izven slike)
    yMin = max(1, posY - searchRadius);
    yMax = min(size(currentFrame,1) - tplHeight + 1, posY + searchRadius);
    xMin = max(1, posX - searchRadius);
    xMax = min(size(currentFrame,2) - tplWidth + 1, posX + searchRadius);

    %preizkusimo vse kandidate v okolici
    for y = yMin:yMax
        for x = xMin:xMax
            candidate = currentFrame(y:y+tplHeight-1, x:x+tplWidth-1, :); %kandidatni patch
            diff = double(candidate) - double(template); %razlika do template
            error = sum(diff(:).^2);   % L2^2 (manj-bolj podobno)

            if error < minError %shrani najboljsi kandidat
                minError = error; bestX = x; bestY = y;
            end
        end
    end

    posX = bestX; posY = bestY;            % posodobi lokacijo objekta
    outputFrame = insertShape(currentFrame,'Rectangle',... % narisi bbox
        [posX posY tplWidth tplHeight],'Color','red');

    writeVideo(videoOut, outputFrame);     % shrani frame v izhodni video
end

close(videoOut);                           % zapri izhodni video
==== END Jakob Suhadolc | Jakob Suhadolc_26684_assignsubmission_file | Naloga2_1_vaja5.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_26684_assignsubmission_file | Naloga2_2_vaja5.m ====
clear; clc;

videoIn  = VideoReader('squash.avi');          
videoOut = VideoWriter('track2_chi2.avi');     
open(videoOut);

firstFrame = readFrame(videoIn);   %uzami prvi frame in ga prikazi
imshow(firstFrame);                    
selection = round(getrect);  %izberemo pravokotnik [x y w h]

%izrez predloge igralca iz prvega frema  
template = firstFrame( ...   
    selection(2):selection(2)+selection(4)-1, ...
    selection(1):selection(1)+selection(3)-1, :);

posX = selection(1); posY = selection(2); %zacetna pozicija pravokotnika
tplWidth = selection(3); tplHeight = selection(4); %velikost pravokotnika
searchRadius = 15;   % epsilon, lokalno iskanje, uzamemo 20 pikselov okol
numBins = 8;    % st. binov histograma

templateHist = rgb_hist_fast(template, numBins); %referencni histogram

while hasFrame(videoIn)                        
    currentFrame = readFrame(videoIn);

    %najboljsa (najmanjsa) chi2 razdalja
    minChi2 = inf;                             
    bestX = posX;
    bestY = posY;

    % meje iskalnega okna (da ne gres izven slike)
    yMin = max(1, posY-searchRadius);
    yMax = min(size(currentFrame,1)-tplHeight+1, posY+searchRadius);
    xMin = max(1, posX-searchRadius);
    xMax = min(size(currentFrame,2)-tplWidth+1, posX+searchRadius);

    for y = yMin:yMax                         
        for x = xMin:xMax

            candidate = currentFrame(y:y+tplHeight-1, x:x+tplWidth-1, :); %kandidatni patch
            candidateHist = rgb_hist_fast(candidate, numBins);            %histogram kandidata

            diff = templateHist - candidateHist;  %razlika histogramov
            chi2 = 0.5*sum(diff.^2 ./ (templateHist + candidateHist + eps));  %chi-square razdalja

            %izberi najbolj podoben
            if chi2 < minChi2      
                minChi2 = chi2;
                bestX = x;
                bestY = y;
            end
        end
    end
    
    %posodobi lokacijo
    posX = bestX;                                
    posY = bestY;

    outputFrame = insertShape(currentFrame, 'Rectangle', ... 
        [posX posY tplWidth tplHeight], 'Color', 'green');

    writeVideo(videoOut, outputFrame);           
end

close(videoOut);

%funkcija-RGB histogram,normalizira
function h = rgb_hist_fast(img, bins)

img = uint8(img);     %poskrbi da je 0..255

edges = linspace(0,256,bins+1);  %robovi binov (npr. 0-32-...-256)

hR = histcounts(img(:,:,1), edges); %histogram rdecega kanala
hG = histcounts(img(:,:,2), edges); %histogram zelenega kanala
hB = histcounts(img(:,:,3), edges); %histogram modrega kanala

h = double([hR hG hB]);       %zdruzi v en vektor RGB
h = h / sum(h);    %normalizacija
end
==== END Jakob Suhadolc | Jakob Suhadolc_26684_assignsubmission_file | Naloga2_2_vaja5.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_26684_assignsubmission_file | Naloga3_1vaja5.m ====
clear; clc;

videoIn  = VideoReader('squash.avi');
videoOut = VideoWriter('track3_L2_update.avi');
videoOut.FrameRate = videoIn.FrameRate;
open(videoOut);

firstFrame = readFrame(videoIn);
imshow(firstFrame);
selection = round(getrect);                 % [x y w h]

template = firstFrame( ...
    selection(2):selection(2)+selection(4)-1, ...
    selection(1):selection(1)+selection(3)-1, :);

posX = selection(1); posY = selection(2);
tplWidth = selection(3); tplHeight = selection(4);

searchRadius = 15;
updateEvery = 1;    %posodobi vsak N-ti frame
frameIdx = 0;

while hasFrame(videoIn)
    frameIdx = frameIdx + 1;
    currentFrame = readFrame(videoIn);

    %uzamemo trenutne pozicije kot najboljse
    minError = inf; bestX = posX; bestY = posY;

     % meje iskalnega okna (da ne gres izven slike)
    yMin = max(1, posY - searchRadius);
    yMax = min(size(currentFrame,1) - tplHeight + 1, posY + searchRadius);
    xMin = max(1, posX - searchRadius);
    xMax = min(size(currentFrame,2) - tplWidth  + 1, posX + searchRadius);

    for y = yMin:yMax
        for x = xMin:xMax

            %trenuten kandidat
            candidate = currentFrame(y:y+tplHeight-1, x:x+tplWidth-1, :);

            diff = double(candidate) - double(template);
            error = sum(diff(:).^2);       

            %posodabljane najboljsih najdenih parametrov
            if error < minError
                minError = error;
                bestX = x; bestY = y;
            end
        end
    end

    posX = bestX; posY = bestY;

    %sprotno ucenje (posodobi template)
    newTpl = currentFrame(posY:posY+tplHeight-1, posX:posX+tplWidth-1, :);
    template = newTpl;

    outputFrame = insertShape(currentFrame,'Rectangle', ...
        [posX posY tplWidth tplHeight], 'Color','red','LineWidth',3);

    writeVideo(videoOut, outputFrame);
end

close(videoOut);
==== END Jakob Suhadolc | Jakob Suhadolc_26684_assignsubmission_file | Naloga3_1vaja5.m ====

==== BEGIN Jakob Suhadolc | Jakob Suhadolc_26684_assignsubmission_file | Naloga3_2vaja5.m ====
clear; clc;

videoIn  = VideoReader('squash.avi');
videoOut = VideoWriter('track3_chi2_update.avi');
videoOut.FrameRate = videoIn.FrameRate;
open(videoOut);

firstFrame = readFrame(videoIn);
imshow(firstFrame);
selection = round(getrect);   % [x y w h]

templatePatch = firstFrame( ...
    selection(2):selection(2)+selection(4)-1, ...
    selection(1):selection(1)+selection(3)-1, :);

posX = selection(1); posY = selection(2);
tplWidth = selection(3); tplHeight = selection(4);

searchRadius = 15;
numBins = 8;

templateHist = rgb_hist_fast(templatePatch, numBins);

updateEvery = 1;    %posodobi vsak N-ti frame
frameIdx = 0;

while hasFrame(videoIn)
    frameIdx = frameIdx + 1;
    currentFrame = readFrame(videoIn);

    minChi2 = inf; bestX = posX; bestY = posY;

    yMin = max(1, posY - searchRadius);
    yMax = min(size(currentFrame,1) - tplHeight + 1, posY + searchRadius);
    xMin = max(1, posX - searchRadius);
    xMax = min(size(currentFrame,2) - tplWidth  + 1, posX + searchRadius);

    for y = yMin:yMax
        for x = xMin:xMax
            candidate = currentFrame(y:y+tplHeight-1, x:x+tplWidth-1, :);
            candHist = rgb_hist_fast(candidate, numBins);

            diff = templateHist - candHist;
            chi2 = 0.5*sum(diff.^2 ./ (templateHist + candHist + eps));

            if chi2 < minChi2
                minChi2 = chi2;
                bestX = x; bestY = y;
            end
        end
    end

    posX = bestX; posY = bestY;

    % sprotno ucenje (posodobi histogram)
  
    bestPatch = currentFrame(posY:posY+tplHeight-1, posX:posX+tplWidth-1, :);
    newHist = rgb_hist_fast(bestPatch, numBins);

    templateHist = newHist;
    templateHist = templateHist / sum(templateHist);   %ostani normiran
  

    outputFrame = insertShape(currentFrame,'Rectangle', ...
        [posX posY tplWidth tplHeight], 'Color','green','LineWidth',3);

    writeVideo(videoOut, outputFrame);
end

close(videoOut);

function h = rgb_hist_fast(img, bins)
img = uint8(img);
edges = linspace(0,256,bins+1);
hR = histcounts(img(:,:,1), edges);
hG = histcounts(img(:,:,2), edges);
hB = histcounts(img(:,:,3), edges);
h = double([hR hG hB]);
h = h / sum(h);
end
==== END Jakob Suhadolc | Jakob Suhadolc_26684_assignsubmission_file | Naloga3_2vaja5.m ====

