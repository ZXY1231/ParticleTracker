function all_gt_ids = AllTracksGTIds(gtmaps_path, all_tracks)
% %function name: describtion 
% %Input    a              : 
% %         b              : 
% %Output:  c              :
% speed limited, searh in large GT_maps costs time
    all_gtmaps = LoadImages(gtmaps_path);% size (#frames,h,w)
    search_pattern_x = [-1,0,1];
    search_pattern_y = [-1,0,1];% need to be modified, pattern + is better
    all_gt_ids = cell(size(all_tracks));
    
    for i = 1:size(all_tracks,2)
        i
        frames = all_tracks{i}.frames;
        pos_xy = all_tracks{i}.position_xy;
        gt_id = zeros(size(frames));
        for j = 1:length(frames)
            frame = frames(j);

            x = ceil(pos_xy(j,2));% colume2 is x in imagej 
            y = ceil(pos_xy(j,1));% colume1 is y in imagej 
            gtmap = squeeze(all_gtmaps(abs(frame),:,:));
            
            if x > size(gtmap,1)%need to be modified
                x = size(gtmap,1);
            end
            
            if y > size(gtmap,2)
                y = size(gtmap,2);
            end
            if x < 1%need to be modified
                x = 1;
            end
            
            if y < 1
                y = 1;
            end
            
            try

                xx = search_pattern_x + x;
                yy = search_pattern_y + y;
                local_gtmap = gtmap(xx,yy);
                if local_gtmap(2:2)~=0
                    gt_id(j) = local_gtmap(2:2);
                else
                    gt_id(j) = max(local_gtmap(:));
                end
            catch%boundaries      
                xx = x;
                yy = y;
                local_gtmap = gtmap(xx,yy);
                gt_id(j) = max(local_gtmap(:));%
            end
        end
        all_gt_ids{i} = gt_id;
    end
    
end 