function [accuracy,correct_links] = LengthAverageAccuracy2(tracks_filename_csv, all_gt_ids, t, p)
% %function TrackingAccuracy: calculate correct links for each track,  
% %Input    all_gt_ids       : 1*n cells, each cell contains a
%                            array save assigned ground truth ids for each track 
% %Output:  correct_links    : 1*n cells, each cell contains a int, whcih
%                              is the number of correct links for this track
%
%a minor bug, for gt-ids with 2-D shape,
%gt-ids should indicate it if it has multi-ids for one track

%     tracks_table = readtable(tracks_filename_csv);
%     tracks = table2array(tracks_table);
%     gt_ids = tracks(:,4);
    
%     temporal solution

    tracks_table = readtable(tracks_filename_csv);
    tracks = table2array(tracks_table);
    gt_blinks = tracks(:,3);
    gt_blinks = reshape(gt_blinks, [t, p]);
    

    labels = repmat(1:p,[t,1]);
    for i = 1:size(all_gt_ids,2)
        all_gt_ids{1,i} = all_gt_ids{i}.*labels.*gt_blinks; 
    end
    
%     size(all_gt_ids)
    correct_links = zeros(size(all_gt_ids));
    for i = 1:size(all_gt_ids,2)
        gt_ids = sum(all_gt_ids{i},2);
        valid_links = gt_ids>0;
        gt_ids = gt_ids(valid_links);
        correct_links(i) = length(find(diff(gt_ids)==0));
    end

    accuracy = 0;
    t = t - 1;
    for i  = 1:size(correct_links,2)
        accuracy = accuracy + correct_links(i)*correct_links(i)/t;
    end
    accuracy = accuracy/(t*p);
%     accuracy = correct_links;
end 
