function all_gt_ids = AllTracksGTIds2(tracks_filename_csv, all_tracks, t, dis_error)
% %function name: describtion 
% %Input    a              : 
% %         b              : 
% %Output:  c              :
% could be replaced by Tracker function 'FindNext' in the furture
%gt ids can be alocated to different tracks at the same time, causing
%overflowed correct links

    tracks_table = readtable(tracks_filename_csv);
    tracks = table2array(tracks_table);
    gt_xs = tracks(:,1);
    gt_ys = tracks(:,2);
    gt_ids = tracks(:,4);
    tt_s = 0:t:size(gt_ids,1)-1;
    n_p = size(gt_ids,1)/t;
    dis_error = dis_error^2;
    
    all_gt_ids = cell(size(all_tracks));
    
    for i = 1:size(all_tracks,2)
        i
        frames = all_tracks{i}.frames;
        pos_xy = all_tracks{i}.position_xy;
        track_gt_id = zeros(t, n_p);% t*n_p array
        for j = 1:length(frames)
            frame = abs(frames(j));

            x = ceil(pos_xy(j,2));% colume2 is x in imagej 
            y = ceil(pos_xy(j,1));% colume1 is y in imagej 
            t_ids = gt_ids(tt_s+frame);
            t_gt_xs = gt_xs(tt_s+frame);
            t_gt_ys = gt_ys(tt_s+frame);

            dis_min = 9999999;
            for k = 1:n_p
                dis = (x-t_gt_xs(k,1))^2 + (y-t_gt_ys(k,1))^2;

                if dis < dis_min
                    dis_min = dis;
                    t_id = t_ids(k);
                end

            end
            if dis_min<dis_error
                track_gt_id(frame, t_id) = 1;
            end
 
        end
        all_gt_ids{i} = track_gt_id;
                  
    end
    
end 
