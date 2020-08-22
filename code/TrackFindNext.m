function find_spot = TrackFindNext(one_tracker, next_bright_particles, next_dim_particles,t)
%FindNext: one track search for next positions based on provided next all bright
%and dim locations, alter flag of found spot to 1
%Input    one_tracker              : tracker
%         next_bright_particles   : 1*t cells, t is # of frames, each cell containes one array
%                                   providing bright spots detected at i-th frame with shape m1*2
%         next_dim_particles      :1*t cells, t is # of frames, each cell containes one array
%                                   providing dim spots detected at i-th frame with shape m2*2
%         t                       : t indicateds t-th frame of detected spots
%Output:  find_spot                    :[1, next spot ID] or 0

%provide multi-particles assignment temporary solution
    
    global all_images_bright_particles all_images_dim_particles
    find_spot = one_tracker.FindNext(next_bright_particles);
    
    if find_spot(1) && all_images_bright_particles{t}(find_spot(2),3) == 0% multi-particles assignment temporary solution
%     if find_spot(1)
        all_images_bright_particles{t}(find_spot(2),3) = 1;
    else 
        if find_spot(1)
            one_tracker.position_xy(end,:) = [];% delete multi-assigned pisitions
        end
        find_spot = one_tracker.FindNextDim(next_dim_particles);
        if find_spot(1)
            all_images_dim_particles{t}(find_spot(2),3) = 1;
        end
    end
end
