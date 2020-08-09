function links_num = GTLinks(tracks_filename_csv,t)
% %function name: describtion 
% %Input    a              : 
% %         b              : 
% %Output:  c              :

    tracks_table = readtable(tracks_filename_csv);
    tracks = table2array(tracks_table);
    blinkings = tracks(:, 3);
    links_num = length(find(blinkings>0.3))-length(blinkings)/t;

end 
