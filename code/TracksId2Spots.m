function one_image_spots = TracksId2Spots(all_new_tracks, one_image_spots)
%TracksId2Spots: label two spots if there are too closed in a frame
%Input    all_new_tracks                : 1*n cells, n is # of tracks, each cell containes a tracker
%         one_image_spots               : array, m1*m2, the first two is spots location in time t, the third is the usage flag/track id
%Output:  one_image_spots               : array, m1*m2
    new_assigned_spots = find(one_image_spots(:,3)==0);
    for i = 1:size(all_new_tracks,2)
        id = all_new_tracks{i}.track_id;
        one_image_spots(new_assigned_spots(i),3) = id;
%         all_spots{i}(:,end+1) = -1;
    end
    
end