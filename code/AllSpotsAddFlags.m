
function all_spots = AllSpotsAddFlags(all_spots)
%AllSpotsAddFlags: add boolean flags to detectde spots for further usage 
%Input    all_spots       : 1*n cells, n is #of frames, each cell
%                                contains (shape m*2) location information
%Output:  all_spots       : 1*n cells, n is #of frames, each cell
%                                contains (shape m*3) location information,
%                                the third is the flag, default 0, unused.

% spots_with_flags = cell(size(all_spots));
    for i = 1:size(all_spots,2)
        all_spots{i}(:,end+1) = 0;
    end
end