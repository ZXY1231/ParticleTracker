function find_spot = AllFindNext(all_tracks, next_bright_particles, next_dim_particles)
%AllFindNext: all tracks search for next positions based on provided next all bright and dim locations
%Input    all_tracks              : 1*n cells, n is # of current tracks, each cell 
%                                   contains a tracker(self-defined class)
%         next_bright_particles   : 1*t cells, t is # of frames, each cell containes one array
%                                   providing bright spots detected at i-th frame with shape m1*2
%         next_dim_particles      :1*t cells, t is # of frames, each cell containes one array
%                                   providing dim spots detected at i-th frame with shape m2*2
%Output:  find_spot                    :[1, next spot ID] or 0 , it is the last tracker's result. 
    find_spot = false;
    
    for i = 1:size(all_tracks,2)
        find_spot = all_tracks{i}.FindNext(next_bright_particles);
        if find_spot(1)
            
        else 
            find_spot = all_tracks{i}.FindNextDim(next_dim_particles);
        end
        
    end
end
