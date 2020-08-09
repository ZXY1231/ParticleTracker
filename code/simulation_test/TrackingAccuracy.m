function correct_links = TrackingAccuracy(all_gt_ids)
% %function name: describtion 
% %Input    a              : 
% %         b              : 
% %Output:  c              :

    correct_links = zeros(size(all_gt_ids));
    for i = 1:size(all_gt_ids,2)
        gt_ids = all_gt_ids{i};
        valid_links = gt_ids>0;
        gt_ids = gt_ids(valid_links);
        correct_links(i) = length(find(diff(gt_ids)==0));
    end

end 
