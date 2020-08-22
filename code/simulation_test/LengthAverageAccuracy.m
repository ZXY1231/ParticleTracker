function [accuracy, correct_links] = LengthAverageAccuracy(all_gt_ids_pre, t, p)
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
    
    all_gt_ids = cell(1);
    for i = 1:size(all_gt_ids_pre,2)
        gt_ids = all_gt_ids_pre{i};
        for j = 1:p
            if max(gt_ids(:,j)) ==0
                continue
            end
            all_gt_ids{1,end+1} = gt_ids(:,j);
        end
    end
    all_gt_ids(1) = [];% delete the first empty cell
    size(all_gt_ids)
    correct_links = zeros(size(all_gt_ids));
    for i = 1:size(all_gt_ids,2)
        gt_ids = all_gt_ids{i};
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
end 
