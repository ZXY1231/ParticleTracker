function all_closed_spots_labels = ClosedSpotsLabel(all_images_particles,dis_error)
    %ClosedSpotsLabel: label two spots if there are too closed in a frame
    %Input    all_images_particles                : 1*t cells, t is # of frames, each cell containes one array
    %                                               providing spots detected at i-th frame with shape m1*m2
    %         dis_error                           : double, distance lower than dis_error will be considered as too closed
    %Output:  all_closed_spots_labels             : 1*t cells,  each cell has a m*2 array, m/2 is the pair of closed spots ids, 
    %                                               each row has a pair of closed spots
    %             
    all_closed_spots_labels = cell(size(all_images_particles));
    for t = 1:size(all_images_particles,2)
        closed_spots_labels = [];
        xys = all_images_particles{t}(:,1:2);
        dis = pdist2(xys,xys);
        
        [row, col] = find(dis < dis_error);
        dis_diag = find(row == col);

        row(dis_diag) = [];
        col(dis_diag) = [];
        if isempty(row)
            continue
        end

        for i = 1: size(row ,1)
            closed_spots_labels(end+1,1) = row(i);
            closed_spots_labels(end,2) = col(i);
        end
        all_closed_spots_labels{t} = closed_spots_labels;

    end
end
