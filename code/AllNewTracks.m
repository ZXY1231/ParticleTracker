function new_tracks = AllNewTracks(track_id_end, next_spots,t)
%AllNewTracks: creat trackers based on t-th new spots
%Input    all_tracks              : 1*n cells, n is # of current tracks, each cell 
%                                   contains a tracker(self-defined class)
%         all_next_spots          : m1*3 array, m is # of spots detected at
%                                   current frame t, in each row, [x y usage_flag]
%         t                       : t indicateds t-th frame of detected spots
%Output:  new_tracks              :1*m2 cells , m2 is # of tracks start at t, each cell 
%                                   contains a tracker(self-defined class),
%                                   m2<=m1
    unused_flage = 0;
    unused_spots = find(next_spots(:,3)==unused_flage);
    new_tracks = cell(1,length(unused_spots));
    for i = 1:length(unused_spots)
        new_tracks{i} = Tracker(track_id_end+i, next_spots(unused_spots(i),:), 0, t);
    end
end
