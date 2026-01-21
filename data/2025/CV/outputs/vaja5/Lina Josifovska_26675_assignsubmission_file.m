==== BEGIN Lina Josifovska | Lina Josifovska_26675_assignsubmission_file | naloga1.m ====
holywood=VideoReader("Holywood.avi");
frames=read(holywood,[1 Inf]);
velikost_videa=size(frames);

for i=1:velikost_videa(4)
    holywood_neighbor_pol(:,:,:,i)=imresize(frames(:,:,:,i),1/2,'nearest');
    holywood_neighbor_cet(:,:,:,i)=imresize(frames(:,:,:,i),1/4,'nearest');
    holywood_neighbor_osm(:,:,:,i)=imresize(frames(:,:,:,i),1/8,'nearest');
    holywood_bi_pol(:,:,:,i)=imresize(frames(:,:,:,i),1/2,'bilinear','Antialiasing',false);
    holywood_bi_cet(:,:,:,i)=imresize(frames(:,:,:,i),1/4,'bilinear','Antialiasing',false);
    holywood_bi_osm(:,:,:,i)=imresize(frames(:,:,:,i),1/8,'bilinear','Antialiasing',false);
    holywood_predbi_pol(:,:,:,i)=imresize(frames(:,:,:,i),1/2,'bilinear','Antialiasing',true);
    holywood_predbi_cet(:,:,:,i)=imresize(frames(:,:,:,i),1/4,'bilinear','Antialiasing',true);
    holywood_predbi_osm(:,:,:,i)=imresize(frames(:,:,:,i),1/8,'bilinear','Antialiasing',true);
end

writerObj=VideoWriter('1_naloga_neighbor_pol.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(holywood_neighbor_pol,'uint8'));
close(writerObj);

writerObj=VideoWriter('1_naloga_neighbor_cet.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(holywood_neighbor_cet,'uint8'));
close(writerObj);

writerObj=VideoWriter('1_naloga_neighbor_osm.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(holywood_neighbor_osm,'uint8'));
close(writerObj);

writerObj=VideoWriter('1_naloga_bi_pol.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(holywood_bi_pol,'uint8'));
close(writerObj);

writerObj=VideoWriter('1_naloga_bi_cet.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(holywood_bi_cet,'uint8'));
close(writerObj);

writerObj=VideoWriter('1_naloga_bi_osm.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(holywood_bi_osm,'uint8'));
close(writerObj);

writerObj=VideoWriter('1_naloga_predbi_pol.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(holywood_predbi_pol,'uint8'));
close(writerObj);

writerObj=VideoWriter('1_naloga_predbi_cet.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(holywood_predbi_cet,'uint8'));
close(writerObj);

writerObj=VideoWriter('1_naloga_predbi_osm.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(holywood_predbi_osm,'uint8'));
close(writerObj);
==== END Lina Josifovska | Lina Josifovska_26675_assignsubmission_file | naloga1.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_26675_assignsubmission_file | naloga2a.m ====
clear all;
squash=VideoReader("squash.avi");
frames=read(squash,[1 Inf]);
velikost_videa=size(frames);

imshow(frames(:,:,:,1));
[y_zac,x_zac]=ginput(2);
y_zac=floor(y_zac);
x_zac=floor(x_zac);
znacilka_evk=frames(x_zac(1):x_zac(2),y_zac(1):y_zac(2),:,1);
velikost_znacilke_evk=size(znacilka_evk);
%imshow(znacilka_evk);

eps=35;
sred_x=x_zac(1);
sred_y=y_zac(2);

%i=3;  %samo za teste
for i=1:velikost_videa(4)
    okolica=frames((sred_y-eps):(sred_y+eps),(sred_x-eps):(sred_x+eps),:,i);
    velikost_okolice=size(okolica);
    
    for y=1:(velikost_okolice(2)-velikost_znacilke_evk(2))
        for x=1:(velikost_okolice(1)-velikost_znacilke_evk(1))
            evk(x,y)=mean(sqrt(sum((double(double(znacilka_evk)-double(okolica(x:(x+velikost_znacilke_evk(1)-1),y:(y+velikost_znacilke_evk(2)-1),:)))).^2)),"all");
        end
    end
    
    minimum=min(min(evk));
    [poz1, poz2]=find(evk==minimum);
    sred_x=poz2-eps+sred_x+floor(velikost_znacilke_evk(2)/2);
    sred_y=poz1-eps+sred_y+floor(velikost_znacilke_evk(1)/2);
    
    koncna_slika_evk(:,:,:,i)=insertShape(frames(:,:,:,i),"Circle",[sred_x sred_y 20],'LineWidth',3);
    %imshow(koncna_slika_evk(:,:,:,i));   %samo za teste
end

writerObj=VideoWriter('2a_naloga.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(koncna_slika_evk,'uint8'));
close(writerObj);
==== END Lina Josifovska | Lina Josifovska_26675_assignsubmission_file | naloga2a.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_26675_assignsubmission_file | naloga2b.m ====
clear all;
squash=VideoReader("squash.avi");
frames=read(squash,[1 Inf]);
velikost_videa=size(frames);

imshow(frames(:,:,:,1));
[y_zac,x_zac]=ginput(2);
y_zac=floor(y_zac);
x_zac=floor(x_zac);
znacilka_hi=frames(x_zac(1):x_zac(2),y_zac(1):y_zac(2),:,1);
velikost_znacilke_hi=size(znacilka_hi);
%imshow(znacilka_hi);

histogram_znacilke_hi=poisci_histogram(znacilka_hi);
max_vrednost_hist=max(max(max(histogram_znacilke_hi)));
koef=255/max_vrednost_hist;
for i=1:8
    for j=1:8
        for k=1:8
            histogram_znacilke_hi_norm(i,j,k)=floor((histogram_znacilke_hi(i,j,k)*koef));
        end
    end
end

eps=35;
sred_x=x_zac(1);
sred_y=y_zac(2);

%i=5;  %samo za teste
for i=1:250
    okolica=frames((sred_y-eps):(sred_y+eps),(sred_x-eps):(sred_x+eps),:,i);
    velikost_okolice=size(okolica);
    
    for y=1:(velikost_okolice(2)-velikost_znacilke_hi(2))
        for x=1:(velikost_okolice(1)-velikost_znacilke_hi(1))
            opazovani_del_okolice=okolica(x:(x+velikost_znacilke_hi(1)-1),y:(y+velikost_znacilke_hi(2)-1),:);
            histogram_opa_dela=poisci_histogram(opazovani_del_okolice);
            
            max_vrednost_hist=max(max(max(histogram_opa_dela)));
            koef=255/max_vrednost_hist;
            for m=1:8
                for j=1:8
                    for k=1:8
                        histogram_opa_dela_norm(m,j,k)=floor((histogram_opa_dela(m,j,k)*koef));
                    end
                end
            end
            
            hi_kvadrat(x,y)=sum((histogram_opa_dela_norm-histogram_znacilke_hi_norm).^2,'all');
            
        end
    end
    
    minimum=min(min(hi_kvadrat));
    [poz1, poz2]=find(hi_kvadrat==minimum);
    sred_x=poz2(1)-eps+sred_x(1)+floor(velikost_znacilke_hi(2)/2);
    sred_y=poz1(1)-eps+sred_y(1)+floor(velikost_znacilke_hi(1)/2);
    
    koncna_slika_hi(:,:,:,i)=insertShape(frames(:,:,:,i),"Circle",[sred_x(1) sred_y(1) 20],'LineWidth',3,"Color",'green');
    %imshow(koncna_slika_hi(:,:,:,i));  %samo za teste
end

writerObj=VideoWriter('2b_naloga.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(koncna_slika_hi,'uint8'));
close(writerObj);
==== END Lina Josifovska | Lina Josifovska_26675_assignsubmission_file | naloga2b.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_26675_assignsubmission_file | naloga3.m ====
clear all;
squash=VideoReader("squash.avi");
frames=read(squash,[1 Inf]);
velikost_videa=size(frames);

imshow(frames(:,:,:,1));
[y_zac,x_zac]=ginput(2);
y_zac=floor(y_zac);
x_zac=floor(x_zac);
znacilka_evk3=frames(x_zac(1):x_zac(2),y_zac(1):y_zac(2),:,1);
velikost_znacilke_evk3=size(znacilka_evk3);

%imshow(znacilka_evk);
eps=25;
sred_x=floor(x_zac(1)+(x_zac(2)-x_zac(1))/2);
sred_y=floor(y_zac(1)+(y_zac(2)-y_zac(1))/2);

%i=3;  %samo za teste
for i=1:velikost_videa(4)
    okolica=frames((sred_y-eps):(sred_y+eps),(sred_x-eps):(sred_x+eps),:,i);
    velikost_okolice=size(okolica);
    
    for y=1:(velikost_okolice(2)-velikost_znacilke_evk3(2))
        for x=1:(velikost_okolice(1)-velikost_znacilke_evk3(1))
            evk(x,y)=mean(sqrt(sum((double(double(znacilka_evk3)-double(okolica(x:(x+velikost_znacilke_evk3(1)-1),y:(y+velikost_znacilke_evk3(2)-1),:)))).^2)),"all");
        end
    end
    
    minimum=min(min(evk));
    [poz1, poz2]=find(evk==minimum);
    sred_x=poz2-eps+sred_x(1)+floor(velikost_znacilke_evk3(2)/2);
    sred_y=poz1-eps+sred_y(1)+floor(velikost_znacilke_evk3(1)/2);
    
    koncna_slika_evk3(:,:,:,i)=insertShape(frames(:,:,:,i),"Circle",[sred_x(1) sred_y(1) 20],'LineWidth',3);
    %imshow(koncna_slika_evk3(:,:,:,i));   %samo za teste
    
    znacilka_evk3=okolica((poz1(1)):(poz1(1)+velikost_znacilke_evk3(1)-1),(poz2(1)):(poz2(1)+velikost_znacilke_evk3(2)-1),:);
    %imshow(znacilka_evk3);
end

writerObj=VideoWriter('3_naloga.avi');
writerObj.FrameRate=25;
open(writerObj);
writeVideo(writerObj,cast(koncna_slika_evk3,'uint8'));
close(writerObj);
==== END Lina Josifovska | Lina Josifovska_26675_assignsubmission_file | naloga3.m ====

==== BEGIN Lina Josifovska | Lina Josifovska_26675_assignsubmission_file | poisci_histogram.m ====
function histogram=poisci_histogram(vzorec)
    dim_vzorca=size(vzorec);
    histogram=zeros(8,8,8);
    for R_vrednost=0:32:224
        for G_vrednost=0:32:224
            for B_vrednost=0:32:224
                for j=1:dim_vzorca(2)
                    for i=1:dim_vzorca(1)
                        if ((vzorec(i,j,1)>=R_vrednost) && (vzorec(i,j,1)<=(R_vrednost+31)) && (vzorec(i,j,2)>=G_vrednost) && (vzorec(i,j,2)<=(G_vrednost+31)) && (vzorec(i,j,3)>=B_vrednost) && (vzorec(i,j,3)<=(B_vrednost+31)))
                            histogram((R_vrednost/32)+1,(G_vrednost/32)+1,(B_vrednost/32)+1)=histogram((R_vrednost/32)+1,(G_vrednost/32)+1,(B_vrednost/32)+1)+1;
                        end
                    end
                end
            end
        end
    end
end
==== END Lina Josifovska | Lina Josifovska_26675_assignsubmission_file | poisci_histogram.m ====

