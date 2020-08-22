function correct_links = CorrectLinks(all_gt_ids)
% %function TrackingAccuracy: calculate correct links for each track,  
% %Input    all_gt_ids       : 1*n cells, each cell contains a
%                            array save assigned ground truth ids for each track 
% %Output:  correct_links    : 1*n cells, each cell contains a int, whcih
%                              is the number of correct links for this track
%
%a minor bug, for gt-ids with 2-D shape,

    correct_links = zeros(size(all_gt_ids));
    for i = 1:size(all_gt_ids,2)
        gt_ids = all_gt_ids{i};
        valid_links = gt_ids>0;
        gt_ids = gt_ids(valid_links);
        correct_links(i) = length(find(diff(gt_ids)==0));
    end

end 
