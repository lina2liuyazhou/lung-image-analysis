function [lung_seg_img_3d,T]=fn_segmentation(lung_img_3d)
    
%% get image size

    [xnum,ynum,znum]=size(lung_img_3d);
    
%% Tresholding
%     T=(lung_img_3d)<-600; %intensity values all less than -400 (HU field)--> store in T
    T_i=-500;
    
    for i=1:znum
        
        T_n_logic_l=(lung_img_3d(:,:,i))<T_i;
        T_n_l=lung_img_3d(:,:,i).*T_n_logic_l;
        T_n_logic_h=T_n_l>-1000;
        T_n=lung_img_3d(:,:,i).*T_n_logic_h;
        
        T_b_logic_h=(lung_img_3d(:,:,i))>T_i;
        T_b_h=lung_img_3d(:,:,i).*T_b_logic_h;
        T_b_logic_l=T_b_h<1000;
        T_b=lung_img_3d(:,:,i).*T_b_logic_l;
        
        u_n=mean(T_n(:));        
        u_b=mean(T_b(:));
        T_ip=(u_n+u_b)/2;
        
        if abs(T_i-T_ip)<0.3
            T_v=T_ip;
            break;
        else
            T_i=T_ip;
        end
        
    end
        
    T=(lung_img_3d)<T_v;
    
    
%%  lung_extraction

    %get the center points
    xcenter=round(xnum/2); 
    ycenter=round(ynum/2);
    zcenter=round(znum/2);
    
    
    lung_seg_label=bwlabeln(T,18); %label connected components in threshold lung images

    %get the left & right side via centerpoints    
    lung_left=lung_seg_label(ycenter,1:xcenter,zcenter);
    lung_right=lung_seg_label(ycenter,xcenter:end,zcenter);
    
    %get the intensity value which has the most # of intensities bigger than zero.
    lung_left_table=tabulate(lung_left(lung_left>0)); 
    lung_right_table=tabulate(lung_right(lung_right>0));
    
    lung_left_label=lung_left_table(end,1);
    lung_right_label=lung_right_table(end,1);
        
    %get the region grown 3d lung image
    lung_seg_img_3d_rg=(lung_seg_label==lung_left_label)|(lung_seg_label==lung_right_label);
    
%% morphological process
    
    se=strel('disk', 2); %make disk for processing the dilation
    se_erode=strel('disk', 1); %make disk for processing the dilation

    lung_seg_img_3d=zeros(size(lung_img_3d)); %dilate the lung 
    
    %morphological close and erode the lung 3d images and stack them
    
    for z=1:znum
%          lung_seg_img_3d_dilation(:,:,z) = imdilate(lung_seg_img_3d_rg(:,:,z),se);
         lung_seg_img_3d(:,:,z) = imerode(imclose(lung_seg_img_3d_rg(:,:,z),se),se_erode);
    end
    
    lung_seg_img_3d=imfill(lung_seg_img_3d, 'holes');
        
 %% Contour correction

end