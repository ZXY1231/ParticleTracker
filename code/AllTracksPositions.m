function tracks_position = AllTracksPositions(all_tracks)
    tracks_length = zeros(size(all_tracks));
    tracks_length2 = zeros(size(all_tracks));
    num_tracks = size(all_tracks,2);
    for i = 1:num_tracks
        tracks_length(i) = length(find(all_tracks{i}.frames>0));
        tracks_length2(i) = length(all_tracks{i}.frames);
    end
    tracks_length = cat(2,tracks_length', tracks_length2');
    
    leng_max = max(tracks_length(:,2));

    tracks_position = zeros(num_tracks, leng_max, 3);
    
    for i = 1:num_tracks
        tracks_position(i,1:length(all_tracks{i}.frames),:) = all_tracks{i}.position_xy();
    end
    
    
end