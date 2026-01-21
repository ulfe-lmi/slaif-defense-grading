==== BEGIN Teodora Tanurkova | Teodora Tanurkova_22777_assignsubmission_file | Vaja4_1do2.m ====
%% Naloga 1

Img=imread('hotel.jpg');

figure;
imshow('hotel.jpg')
title('hotel');

sivaSLika = rgb2gray(Img);

%Sobel

Sx=[1 0 -1;
    2 0 -2;
    1 0 -1];

Sy = [1 2 1;
    0 0 0;
    -1 -2 -1];

Gx = conv2(sivaSLika, Sx, 'vali');
Gy = conv2(sivaSLika, Sy, 'valid');
G=sqrt(Gx.^2+Gy.^2);
T = 0.35 * max(G(:));
robSobel = G>T;

figure;
imshow(robSobel);
title('Magnituda gradienta po Sobelu');

%Canny
robCanny=edge(sivaSLika,'canny');

figure;
subplot(1,2,1); imshow(robCanny); title('Canny');
subplot(1,2,2); imshow(robSobel); title('Sobel');

% Naloga 2

n_interval = -200:1:200;
k_interval = -2:0.01:2;
N = length(n_interval);
K = length(k_interval);

for j=1:2
    if j == 1
       rob = robSobel;
       metoda = 'Sobel';
    else 
       rob = robCanny;
       metoda = 'Canny';
    end

    [y,x,~] = size(rob);
    HoughT = zeros(K, N);

    for yy = 1:y
        for xx = 1:x
            if rob(yy,xx)
            for ik=1:K %indekse ik
                k = k_interval(ik); %vrednosti k
                n = yy-k*xx; %vrednosti n
                if n >= -200 && n <= 200
                   in = round(n-(-200))+1; %za celostevilske indekse in
                   HoughT(ik,in) = HoughT(ik, in)+1; 
                end
            end
            end
        end
    end

    figure;
    imagesc(n_interval, k_interval, HoughT);
    colormap(gray);
    xlabel('n');
    ylabel('k'); 
    title('Houghov prostor', metoda);
    colorbar;

    [maxvStolpec, indexN] = max(HoughT, [], 2); 

    NPremic = 5;
    [~, indexVrstic] = maxk(maxvStolpec, NPremic);

    k_maximalni = k_interval(indexVrstic);            % izbrani nakloni
    n_maximalni = n_interval(indexN(indexVrstic));      % pripadajoči preseki

    figure; 
    imshow(Img);
    hold on;
    xpremica=1:size(Img,2);

    for i = 1:NPremic
        ypremica=k_maximalni(i)*xpremica + n_maximalni(i);
        plot(xpremica,ypremica ,'LineWidth', 1);
    end

    title(['Najbolj izrazite premice - ' metoda]);

 end






























==== END Teodora Tanurkova | Teodora Tanurkova_22777_assignsubmission_file | Vaja4_1do2.m ====

==== BEGIN Teodora Tanurkova | Teodora Tanurkova_22777_assignsubmission_file | Vaja4_3do5.m ====
%% 3 naloga odstranjevanje igralci z mode-om
video3=VideoReader('squash.avi');
korak = 10;
vsiOkviri3 = video3.NumFrames;
StIzbraneOkvire = floor(vsiOkviri3/korak);

okvir1 = read(video3,1);
[vrstice, stolpci, ~] = size(okvir1);

%4D matrika
IzbraniOkviri3 = zeros(vrstice, stolpci, 3, StIzbraneOkvire,'uint8');

stevec = 1;
for i = 1:korak:vsiOkviri3
    IzbraniOkviri3(:,:,:,stevec)=read(video3, i);
    stevec = stevec+1;
end

ozadje = zeros(vrstice, stolpci,3,'uint8');

for k = 1:3
    matriko4D = IzbraniOkviri3(:,:,k,:);
    ozadjeKanal = mode(matriko4D,4); %po casu naredi modus

    ozadje(:,:,k) = uint8(ozadjeKanal);
end

figure;
imshow(ozadje); 
title('ozadje -mode');


%% 4 naloga sledenje igralci

video4=VideoReader('squash.avi');
vsiOkviri4 = video4.NumFrames;

okvir1 = read(video4,1);
[vrstice, stolpci, ~] = size(okvir1);

izhodniVideo4 = VideoWriter('squashRezultat4Naloga.avi');
open(izhodniVideo4);

maskaIgrisca = zeros(vrstice, stolpci);

% meje igrišča 
y1Igrisce = round(0.08 * vrstice);
y2Igrisce = round(0.92 * vrstice);
x1Igrisce = round(0.18 * stolpci);
x2Igrisce = round(0.85 * stolpci);

maskaIgrisca(y1Igrisce:y2Igrisce, x1Igrisce:x2Igrisce) = 1;

figure('visible','off');          % ne odpira vsakič novih oken

for j = 1:vsiOkviri4
    
    okvir = read(video4, j);

    % evklidska razd med okvirjem in ozadjem
    razlika =double(okvir) - double(ozadje);
    evklidskaRazd = sqrt( sum( razlika.^2 , 3) ); % po RGB kanali

    maxVrednost = max(evklidskaRazd(maskaIgrisca == 1));
   
    T =0.15*maxVrednost;

    binSlikaEVKLID = evklidskaRazd > T; 
    binSlikaEVKLID(maskaIgrisca == 0) = 0; %vse kar ni igrisca postane 0

    % Morfoloski operaciji
    binCista = bwmorph(binSlikaEVKLID,'clean');        % odstrani majhne objekte
    binCista = bwmorph(binCista, 'open');     
    binCista = bwmorph(binCista, 'close'); 

    if j == 5
        maxMASK = max(evklidskaRazd(maskaIgrisca == 1));
        disp(['max v maski ' num2str(maxMASK)]);
        figure; 
        imagesc(evklidskaRazd);
        colormap gray;
        colorbar;
        title('evklidska razdalja okvir - 5');

        figure;
        imshow(binSlikaEVKLID);
        title('upragovljena slika okvir 5');
       
        figure;
        imshow(binCista);
        title('pocistena slika okvir 5');
    end     

    % oznacevanje igralcev
    [L, stObjektov] = bwlabel(binCista, 8); %8 - pomeni da so povezani po elevi desni gor dol in tudi diagonalah
    LastnostiObjektov = regionprops(L, 'Area', 'Centroid');

    % če ni objektov, samo zapišemo originalni okvir
    if stObjektov >= 1
       % izberi največ 2 največji področji
       [~, indexSort] = sort([LastnostiObjektov.Area], 'descend');
       
       idxIgralci = indexSort(1:min(2, stObjektov)); % vzame 2 najvecja 1:2, ce stObjektov = 1 potem vzami samo ta 1:1
       % kopija slike
       okvirRisani = okvir;

       % nariši samo težišča
       for i = 1:numel(idxIgralci)
           c = LastnostiObjektov(idxIgralci(i)).Centroid;
           okvirRisani = insertMarker(okvirRisani, c, 'o', 'Color','red','Size',12);
       end
    else
    % če ni igralcev → uporabi original
    okvirRisani = okvir;
    end

% shrani frame v video
writeVideo(izhodniVideo4, okvirRisani);
end

close(izhodniVideo4);


%% 5. naloga A=rdeci, B=beli
video5 = VideoReader('squash.avi');
vsiOkviri = video5.NumFrames;

okvir1 = read(video5,1);
[vrstice, stolpci, ~] = size(okvir1);

izhodniVideo5 = VideoWriter('squashRezultat5Naloga.avi');
open(izhodniVideo5);

maskaIgrisca = zeros(vrstice, stolpci);

y1Igrisce = round(0.08 * vrstice);
y2Igrisce = round(0.92 * vrstice);
x1Igrisce = round(0.18 * stolpci);
x2Igrisce = round(0.85 * stolpci);

maskaIgrisca(y1Igrisce:y2Igrisce, x1Igrisce:x2Igrisce) = 1;

figure('visible','off');

for j = 1:vsiOkviri

    okvir = read(video5, j);

    razlika = double(okvir) - double(ozadje);
    evklidskaRazd = sqrt(sum(razlika.^2, 3));

    maxVrednost = max(evklidskaRazd(maskaIgrisca == 1));
    T = 0.15 * maxVrednost;

    binSlika = evklidskaRazd > T;
    binSlika(maskaIgrisca == 0) = 0;

    binCista = bwmorph(binSlika,'clean');
    binCista = bwmorph(binCista,'open');
    binCista = bwmorph(binCista,'close');

    [L1, stObjektov1] = bwlabel(binCista, 8);
    LastnostiObjektov1 = regionprops(L1, 'Area', 'Centroid', 'PixelIdxList');

    okvirRisani1 = okvir;   % privzeto original

    if stObjektov1 >= 1

        [~, indexSort] = sort([LastnostiObjektov1.Area], 'descend');
        idxIgralci1 = indexSort(1:min(2, stObjektov1));

        R = okvir(:,:,1);
        G = okvir(:,:,2);
        B = okvir(:,:,3);

        if numel(idxIgralci1) == 2

            idx1 = idxIgralci1(1);
            idx2 = idxIgralci1(2);

            pix1 = LastnostiObjektov1(idx1).PixelIdxList;
            pix2 = LastnostiObjektov1(idx2).PixelIdxList;

            meanR1 = mean(double(R(pix1)));
            meanG1 = mean(double(G(pix1)));
            meanB1 = mean(double(B(pix1)));

            meanR2 = mean(double(R(pix2)));
            meanG2 = mean(double(G(pix2)));
            meanB2 = mean(double(B(pix2)));

            redScore1 = meanR1 - (meanG1 + meanB1)/2;
            redScore2 = meanR2 - (meanG2 + meanB2)/2;

            whiteScore1 = (meanR1 + meanG1 + meanB1)/3 - (abs(meanR1-meanG1)+abs(meanR1-meanB1)+abs(meanG1-meanB1));
            whiteScore2 = (meanR2 + meanG2 + meanB2)/3 - (abs(meanR2-meanG2)+abs(meanR2-meanB2)+abs(meanG2-meanB2));

            if redScore1 >= redScore2
                idxA = idx1; 
                idxB = idx2;
            else
                idxA = idx2;
                idxB = idx1;
            end

            if abs(redScore1 - redScore2) < 5
                if whiteScore1 >= whiteScore2
                    idxB = idx1; 
                    idxA = idx2;
                else
                    idxB = idx2; 
                    idxA = idx1;
                end
            end

            if idxA == idxB
                idxA = idx1;
                idxB = idx2;
            end

           
            cA = LastnostiObjektov1(idxA).Centroid;
            okvirRisani1 = insertMarker(okvirRisani1, cA, 'o', 'Color','red','Size',12);
            okvirRisani1 = insertText(okvirRisani1, cA+[10 0], 'A', 'TextColor','red', 'BoxOpacity',0);

            cB = LastnostiObjektov1(idxB).Centroid;
            okvirRisani1 = insertMarker(okvirRisani1, cB, 'o', 'Color','white','Size',12);
            okvirRisani1 = insertText(okvirRisani1, cB+[10 0], 'B', 'TextColor','white', 'BoxOpacity',0);

        else
            
            c = LastnostiObjektov1(idxIgralci1(1)).Centroid;
            okvirRisani1 = insertMarker(okvirRisani1, c, 'o', 'Color','yellow','Size',12);
            okvirRisani1 = insertText(okvirRisani1, c+[10 0], '?', 'TextColor','yellow', 'BoxOpacity',0);
        end
    end

    writeVideo(izhodniVideo5, okvirRisani1);

end

close(izhodniVideo5);
==== END Teodora Tanurkova | Teodora Tanurkova_22777_assignsubmission_file | Vaja4_3do5.m ====

