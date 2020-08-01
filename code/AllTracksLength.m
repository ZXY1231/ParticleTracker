function tracks_length = AllTracksLength(all_tracks)
    tracks_length = zeros(size(all_tracks));
    for i  = 1:size(all_tracks,2)
        tracks_length(i) = length(find(all_tracks{i}.frames>0));
    end
    tracks_length = tracks_length';
end