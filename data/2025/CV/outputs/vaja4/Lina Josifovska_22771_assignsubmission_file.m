==== BEGIN Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | drawLines.m ====
function [] = drawLines(image, HoughSpace, N, Operator)
    k = -2:0.01:2;
    n = -200:1:200;

    maximum = zeros(N,2);
    [rows, cols, ~] = size(image);

    for p = 1:N % find top N lines
        [max1, index] = max(HoughSpace);      % max of each column
        [max2, columnId] = max(max1);         % global max
        rowId = index(columnId);              % corresponding row
        maximum(p,1) = k(rowId);
        maximum(p,2) = n(columnId);
        HoughSpace(rowId,columnId) = 0;      % remove this peak

        % Draw the line
        x_vals = 1:cols;
        y_vals = round(k(rowId)*x_vals + n(columnId));

        % Keep points inside image
        valid = y_vals >= 1 & y_vals <= rows;

        % Set line color (red)
        for i = 1:length(x_vals)
            if valid(i)
                image(y_vals(i), x_vals(i), 1) = 255;
                image(y_vals(i), x_vals(i), 2) = 0;
                image(y_vals(i), x_vals(i), 3) = 0;
            end
        end
    end

    figure('Name', Operator);
    imshow(image);
end
==== END Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | drawLines.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | hough_trans.m ====
function akum=hough_trans(binarna_slika)
    k=-2:0.01:2;
    n=-200:1:200;
    akum=zeros(401,401);
    velikost_slike=size(binarna_slika);
    for y=1:velikost_slike(1)
        for x=1:velikost_slike(2)
            if binarna_slika(y,x)==1
                for x_hou=1:401
                    for y_hou=1:401
                        if n(y_hou)==round(y-x*k(x_hou))
                            akum(x_hou,y_hou)=akum(x_hou,y_hou)+1;
                        end
                    end
                end
            end
        end
    end
end
==== END Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | hough_trans.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | naloga1.m ====
hotel=imread('hotel.jpg');
hotel_siv=rgb2gray(hotel);
Sx = [1 0 -1; 2 0 -2; 1 0 -1];
Sy = [1 2 1; 0 0 0; -1 -2 -1];   
Gx=conv2(hotel_siv,Sx, 'same');
Gy=conv2(hotel_siv,Sy, 'same'); %same za enake velikosti
G=sqrt(Gx.^2+Gy.^2);

G_max=max(G(:));
G_norm=G/G_max;
prag = graythresh(G_norm);   % Otsu metoda

G_kon = G_norm > prag;

Canny=edge(hotel_siv,'canny');
figure;
subplot(2,1,1);
imshow(G_kon);
title('Sobel');
Canny=edge(hotel_siv,'canny');
subplot(2,1,2);
imshow(Canny);
title('Canny');
==== END Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | naloga1.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | naloga2.m ====
hotel=imread('hotel.jpg');
hotel_siv=rgb2gray(hotel);
Sx = [1 0 -1; 2 0 -2; 1 0 -1];
Sy = [1 2 1; 0 0 0; -1 -2 -1];   
Gx=conv2(hotel_siv,Sx, 'same');
Gy=conv2(hotel_siv,Sy, 'same'); %same za enake velikosti
G=sqrt(Gx.^2+Gy.^2);

G_max=max(G(:));
G_norm=G/G_max;
prag = graythresh(G_norm);   % Otsu metoda

G_kon = G_norm > prag;

Canny=edge(hotel_siv,'canny');
figure;
subplot(2,1,1);
imshow(G_kon);
title('Sobel');
Canny=edge(hotel_siv,'canny');
subplot(2,1,2);
imshow(Canny);
title('Canny');

akum_sobel = hough_trans(G_kon);
akum_canny = hough_trans(Canny);

figure;
imshow(akum_sobel / max(akum_sobel(:))); title('Hough - Sobel');
figure;
imshow(akum_canny / max(akum_canny(:))); title('Hough - Canny');

drawLines(hotel, akum_sobel, 5, 'sobel');
drawLines(hotel, akum_canny, 5, 'canny');
==== END Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | naloga2.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | naloga3.m ====
video=VideoReader('squash.avi');
frames=read(video,[1 Inf]);
velikost_videa=size(frames);

a=1;
for t=1:20:velikost_videa(4)
    za_ozadje(:,:,:,a)=frames(:,:,:,t);
    a=a+1;
end

povprecje=mode(za_ozadje,4);
imshow(povprecje(:,:,:))
==== END Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | naloga3.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | naloga4.m ====
video=VideoReader('squash.avi');
frames=read(video,[1 Inf]);
velikost_videa=size(frames);

a=1;
for b=1:20:velikost_videa(4)
    za_ozadje(:,:,:,a)=frames(:,:,:,b);
    a=a+1;
end

povprecje=mode(za_ozadje,4);

for t=1:velikost_videa(4)
    razlika=frames(:,:,:,t)-povprecje;
    koncni_frame=frames(:,:,:,t);
    imshow(razlika(:,:,1));
    imagesc(razlika);
    imshow(frames(:,:,:,t))
    for i=1:velikost_videa(1)
        for j=1:velikost_videa(2)
            if razlika(i,j,1)<30
                upragovljeno(i,j)=0;
            else
                upragovljeno(i,j)=1;
            end
        end
    end
    imshow(upragovljeno);
    SE1=strel('rectangle',[3 3]);
    morfoloske1=imopen(upragovljeno,SE1);
    SE2=strel('rectangle',[5 5]);
    morfoloske2=imdilate(morfoloske1,SE2);
    imshow(morfoloske1);
    imshow(morfoloske2);
    
    razdeljen=bwlabel(morfoloske2,4);
    stevilo_podrocji=max(max(razdeljen));
    
    for pod=1:stevilo_podrocji
        stevilo_clenov(pod)=sum(sum(razdeljen==pod));
    end
    index_najvecjega=find(stevilo_clenov==(max(stevilo_clenov)));
    stevilo_clenov2=stevilo_clenov(stevilo_clenov~=(max(stevilo_clenov)));
    index_drugega=find(stevilo_clenov==(max(stevilo_clenov2)));
    
    [x1,y1]=find(razdeljen==index_najvecjega(1));
    [x2,y2]=find(razdeljen==index_drugega(1));
    x1_sredisce=floor(min(x1)+(max(x1)-min(x1))/2);
    y1_sredisce=floor(min(y1)+(max(y1)-min(y1))/2);
    x2_sredisce=floor(min(x2)+(max(x2)-min(x2))/2);
    y2_sredisce=floor(min(y2)+(max(y2)-min(y2))/2);
    koncni_frame(x1_sredisce:x1_sredisce+1,y1_sredisce-2:y1_sredisce+2,1)=0;
    koncni_frame(x1_sredisce:x1_sredisce+1,y1_sredisce-2:y1_sredisce+2,2)=255;
    koncni_frame(x1_sredisce:x1_sredisce+1,y1_sredisce-2:y1_sredisce+2,3)=0;
    koncni_frame(x1_sredisce-2:x1_sredisce+2,y1_sredisce:y1_sredisce+1,1)=0;
    koncni_frame(x1_sredisce-2:x1_sredisce+2,y1_sredisce:y1_sredisce+1,2)=255;
    koncni_frame(x1_sredisce-2:x1_sredisce+2,y1_sredisce:y1_sredisce+1,3)=0;
    koncni_frame(x2_sredisce:x2_sredisce+1,y2_sredisce-2:y2_sredisce+2,1)=0;
    koncni_frame(x2_sredisce:x2_sredisce+1,y2_sredisce-2:y2_sredisce+2,2)=255;
    koncni_frame(x2_sredisce:x2_sredisce+1,y2_sredisce-2:y2_sredisce+2,3)=0;
    koncni_frame(x2_sredisce-2:x2_sredisce+2,y2_sredisce:y2_sredisce+1,1)=0;
    koncni_frame(x2_sredisce-2:x2_sredisce+2,y2_sredisce:y2_sredisce+1,2)=255;
    koncni_frame(x2_sredisce-2:x2_sredisce+2,y2_sredisce:y2_sredisce+1,3)=0;
    koncni_video(:,:,:,t)=koncni_frame;
    
end

writerObj=VideoWriter('4_naloga.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(koncni_video,'uint8'));
close(writerObj);
==== END Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | naloga4.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | naloga5.m ====
video=VideoReader('squash.avi');
frames=read(video,[1 Inf]);
velikost_videa=size(frames);

a=1;
for b=1:20:velikost_videa(4)
    za_ozadje(:,:,:,a)=frames(:,:,:,b);
    a=a+1;
end

povprecje=mode(za_ozadje,4);

%t=20;
for t=1:velikost_videa(4)
    razlika=frames(:,:,:,t)-povprecje;
    koncni_frame=frames(:,:,:,t);
    imshow(razlika(:,:,1));
    imagesc(razlika);
    imshow(frames(:,:,:,t))
    for i=1:velikost_videa(1)
        for j=1:velikost_videa(2)
            if razlika(i,j,1)<30
                upragovljeno(i,j)=0;
            else
                upragovljeno(i,j)=1;
            end
        end
    end
    imshow(upragovljeno);
    SE1=strel('rectangle',[3 3]);
    morfoloske1=imopen(upragovljeno,SE1);
    SE2=strel('rectangle',[5 5]);
    morfoloske2=imdilate(morfoloske1,SE2);
    imshow(morfoloske1);
    imshow(morfoloske2);
    
    razdeljen=bwlabel(morfoloske2,4);
    stevilo_podrocji=max(max(razdeljen));
    
    for pod=1:stevilo_podrocji
        stevilo_clenov(pod)=sum(sum(razdeljen==pod));
    end
    index_najvecjega=find(stevilo_clenov==(max(stevilo_clenov)));
    stevilo_clenov2=stevilo_clenov(stevilo_clenov~=(max(stevilo_clenov)));
    index_drugega=find(stevilo_clenov==(max(stevilo_clenov2)));
    
    [x1,y1]=find(razdeljen==index_najvecjega(1));
    [x2,y2]=find(razdeljen==index_drugega(1));
    x1_sredisce=floor(min(x1)+(max(x1)-min(x1))/2);
    y1_sredisce=floor(min(y1)+(max(y1)-min(y1))/2);
    x2_sredisce=floor(min(x2)+(max(x2)-min(x2))/2);
    y2_sredisce=floor(min(y2)+(max(y2)-min(y2))/2);
    
    vzorec1=frames(x1_sredisce-2:x1_sredisce+2,y1_sredisce-2:y1_sredisce+2,:,t);
    vzorec2=frames(x2_sredisce-2:x2_sredisce+2,y2_sredisce-2:y2_sredisce+2,:,t);
    
    povprecje_vzorec1=mean(vzorec1,[1 2]);
    povprecje_vzorec2=mean(vzorec2,[1 2]);
    
    koncni_frame(x1_sredisce:x1_sredisce+1,y1_sredisce-2:y1_sredisce+2,1)=0;
    koncni_frame(x1_sredisce:x1_sredisce+1,y1_sredisce-2:y1_sredisce+2,2)=255;
    koncni_frame(x1_sredisce:x1_sredisce+1,y1_sredisce-2:y1_sredisce+2,3)=0;
    koncni_frame(x1_sredisce-2:x1_sredisce+2,y1_sredisce:y1_sredisce+1,1)=0;
    koncni_frame(x1_sredisce-2:x1_sredisce+2,y1_sredisce:y1_sredisce+1,2)=255;
    koncni_frame(x1_sredisce-2:x1_sredisce+2,y1_sredisce:y1_sredisce+1,3)=0;
    koncni_frame(x2_sredisce:x2_sredisce+1,y2_sredisce-2:y2_sredisce+2,1)=0;
    koncni_frame(x2_sredisce:x2_sredisce+1,y2_sredisce-2:y2_sredisce+2,2)=255;
    koncni_frame(x2_sredisce:x2_sredisce+1,y2_sredisce-2:y2_sredisce+2,3)=0;
    koncni_frame(x2_sredisce-2:x2_sredisce+2,y2_sredisce:y2_sredisce+1,1)=0;
    koncni_frame(x2_sredisce-2:x2_sredisce+2,y2_sredisce:y2_sredisce+1,2)=255;
    koncni_frame(x2_sredisce-2:x2_sredisce+2,y2_sredisce:y2_sredisce+1,3)=0;
    
    if (povprecje_vzorec1(1)<160 && povprecje_vzorec2(1)>160)
        koncni_frame_1=insertText(koncni_frame,[y1_sredisce x1_sredisce],['A']);
        koncni_frame_crka=insertText(koncni_frame_1,[y2_sredisce x2_sredisce],['B']);
    else
        koncni_frame_1=insertText(koncni_frame,[y1_sredisce x1_sredisce],['B']);
        koncni_frame_crka=insertText(koncni_frame_1,[y2_sredisce x2_sredisce],['A']);
    end
    
    koncni_video(:,:,:,t)=koncni_frame_crka;
    %imshow(koncni_frame_crka);
    
end

writerObj=VideoWriter('5_naloga.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(koncni_video,'uint8'));
close(writerObj);
==== END Lina Josifovska | Lina Josifovska_22771_assignsubmission_file | naloga5.m ====

