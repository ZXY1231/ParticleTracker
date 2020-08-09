function all_trackmate_tracks = TrackmateTracks(tracks_filename_csv)
% %function name: describtion 
% %Input    a              : 
% %         b              : 
% %Output:  c              :
    tracks_table = readtable(tracks_filename_csv);
    trackmate_tracks(:,1)= tracks_table.TRACK_ID+1;
    trackmate_tracks(:,2)= tracks_table.POSITION_X; % x
    trackmate_tracks(:,3)= tracks_table.POSITION_Y; % y
    trackmate_tracks(:,4)= tracks_table.FRAME+1;
    
    all_trackmate_tracks = cell(1,trackmate_tracks(end,1));
    for i = 1:size(all_trackmate_tracks,2)
        particle_index = find(trackmate_tracks(:,1)==i);
        position_x = trackmate_tracks(particle_index,2);
        position_y = trackmate_tracks(particle_index,3);
        frames = trackmate_tracks(particle_index,4)';
        
        position_xy = cat(2,position_x,position_y);
        all_trackmate_tracks{i} = Tracker(i,position_xy,0,frames);
    end
end 