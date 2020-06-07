% clc;
% close all;
% clear vars;
% 
% %% Read Data
% mask_vessel = niftiread('result/Vesselness_air_and_lumen.nii');
% vessel_mask = niftiread('result/Vesselness_air_mask_0.4.nii');
% 
% %% Plot the max projection of the vesselness of input data
% img_max = squeeze(max(vessel_mask));
% figure();
% imshow(img_max, []);
% 
% %% Perform Centerline Extraction
% segs = Matlab3DThinning(vessel_mask, 0, 0);  % Parameters 2 and 3 are optional to define pruning and smoothing.
% 
% %% Perform Centerline Extraction (With Pruning and Smoothing)
% segs2 = Matlab3DThinning(vessel_mask, 20, 0); 
% 
% %% Display Results (All unsmoothed)
% figure('Name', 'All centerlines unsmoothed');
% for k = 1:length(segs)
%     plot3(segs{k}(:,1)+1, segs{k}(:,2)+1, segs{k}(:,3)+1, 'LineWidth', 1); % One is added since coordinates are zero based
%     hold on;
% end
% title('All Centerlines unsmoothed');
% axis equal;
% 
% %% Display Results (Pruned and smoothed)
% figure('Name', 'Pruned and smoothed centerlines');
% for k = 1:length(segs2)
%     plot3(segs2{k}(:,1)+1, segs2{k}(:,2)+1, segs2{k}(:,3)+1, 'LineWidth', 1); % One is added since coordinates are zero based
%     hold on;
% end
% title('Pruned and smoothed centerlines');
% axis equal;
% 
% %% Gen center lines of vessels
% 
% roi_value = zeros(size(mask_vessel));
% 
% for k = 1:length(segs2)    
%     for j=1:size(segs2{k},1)
%         roi_value(round(segs2{k}(j,2)+1), round(segs2{k}(j,1)+1), round(segs2{k}(j,3)+1)) = 1; % One is added since coordinates are zero based    
%     end
% end
% 
% 
% %% Gen center lines of vessels
% 
% centerline_vessels = zeros(size(mask_vessel));
% % mean_centerline_vessels =  zeros(size(segs2,1),1);
% % 
% % for k = 1:length(segs2)
% %     unrotind = round(segs2{k}+1); 
% %     unrotind = unrotind(:,[2,1,3]); % Permute ind orders since Matlab3DThinning changes ind order  
% %     my_ind = sub2ind(size(roi_value),unrotind(:,1),unrotind(:,2),unrotind(:,3));
% %     mean_val = median(mask_vessel(my_ind)); 
% %     
% % 
% %     mean_centerline_vessels(k) = mean_val; % One is added since coordinates are zero based
% %  end
% 
% %% Gen index of segs2 and centerline_vessels
% 
% ind = find(vessel_mask>0);
% [row,col,sli]=ind2sub(size(vessel_mask) ,ind);
% segs2_col =round(cell2mat(segs2));
% ind_segs= zeros(size(segs2_col,1),1);
% point = 1;
% 
% for k = 1:length(segs2)
%     ind_segs(point:(point+size(segs2{k},1)-1))=k;
%     point = point+size(segs2{k},1);
% end
% 
% for j = 1:size(row,1)
%     tmp_dis = (segs2_col(:,2)+1-row(j)).^2+ (segs2_col(:,1)+1-col(j)).^2 +(segs2_col(:,3)+1-sli(j)).^2;
%         [val,loc] = min(tmp_dis);
%         
% centerline_vessels(row(j),col(j),sli(j)) = ind_segs(loc);
% end

lumen_ind={};
wall_ind={};

compressed_centerline_vessels_ind = find(centerline_vessels>0);
compressed_centerline_vessels = centerline_vessels(compressed_centerline_vessels_ind);
compressed_mask_vessel  = mask_vessel(compressed_centerline_vessels_ind);
output = zeros(size(mask_vessel));
compressed_output = zeros(size(compressed_centerline_vessels));

for i = 1:length(segs2) 
    ind=find(compressed_centerline_vessels==i);
    
    data = compressed_mask_vessel(ind);
    data=normalize(data,'range');
    
%     [counts,x] = imhist(data,16);
%     stem(x,counts)
    if isempty( data) 
            lumen_ind{i}={};
            wall_ind{i}={};
        continue;
    end
    T = otsuthresh(data); 
    lumen_ind{i}=ind(find(data>T));
    wall_ind{i}=ind(find(data<=T));

end

for i = 1:length(segs2)
    if ~ isempty(lumen_ind{i})
        compressed_output(lumen_ind{i})=2;
    end
        if ~ isempty(wall_ind{i})

    compressed_output(wall_ind{i})=1;
        end

end
output(compressed_centerline_vessels_ind)=compressed_output;

niftiwrite(output,'result/output.nii')
niftiwrite(centerline_vessels,'result/centerline_vessels.nii')

