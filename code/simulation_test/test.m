tracks_gt_maps = all_gt_ids2{1};
for i = 2:size(all_gt_ids2,2)
    tracks_gt_maps = tracks_gt_maps + all_gt_ids2{i};
end

tracks_gt_maps2 = tracks_gt_maps(:);

tracks_table = readtable('Z:\SimulationData\20200805\100f_8p_200pxl\100frames.csv');
tracks = table2array(tracks_table);
blinking = tracks(:,3);
tracks_gt_maps2_exclude_blinking = tracks_gt_maps2.*blinking;