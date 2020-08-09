function tracks_length = AllTracksLength(all_tracks)
% %function AllTracksLength: return all tracks length 
% %Input    all_tracks                 : 1*m cell each cell contains a tracker(self defined class)
% %Output:  tracks_length              : n*2 array, the first column
% is lengths exclude blinkings, while the second colum include
    tracks_length = zeros(size(all_tracks));
    tracks_length2 = zeros(size(all_tracks));
    for i  = 1:size(all_tracks,2)
        tracks_length(i) = length(find(all_tracks{i}.frames>0));
        tracks_length2(i) = length(all_tracks{i}.frames);
    end
    tracks_length = cat(2,tracks_length', tracks_length2');
end