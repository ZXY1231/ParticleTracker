function GTMap(tracks_filename_csv, t, image_size, save_filename)
% %function name: describtion 
% %Input    a              : 
% %         b              : 
% %Output:  c              :
    if nargin < 4
        save_filename = 'GTMaps';
    end
    if nargin < 3
        image_size = [1000,1000];
    end
    tracks_table = readtable(tracks_filename_csv);
    tracks = table2array(tracks_table);
    all_tarcks_maps = zeros([t, image_size]);
    leng = size(tracks,1);
    id_pattern_x = [0,0,0;-1,0,1;0,0,0];
    id_pattern_y = [0,-1,0;0,0,0;0,1,0];% need to be modified
    for i = 1:t
        current_particles_positions = i:t:leng; 
        
        xx = tracks(current_particles_positions, 1);
        yy = tracks(current_particles_positions, 2);

        in = xx>0 & xx<image_size(1) & yy>0 & yy<image_size(2);
        xxs = ceil(xx(in));
        yys = ceil(yy(in));
        for j = 1:length(xxs)
%             xxs_pattern = id_pattern_x+xxs(j);
%             yys_pattern = id_pattern_y+yys(j);
            xxs_pattern = xxs(j);
            yys_pattern = yys(j);
            all_tarcks_maps(i, xxs_pattern, yys_pattern)= j;
        end

        if i==1, imwrite(uint16(squeeze(all_tarcks_maps(i,:,:))), [save_filename, '.tif'], 'tiff', 'Compression', 'none')
        else, imwrite(uint16(squeeze(all_tarcks_maps(i,:,:))), [save_filename, '.tif'], 'tiff', 'Compression', 'none', 'WriteMode', 'append')
        end
    end
    
%     if nargin < 2
%         filename = 'LogImg';
%     end
%     for i = 1:size(all_images,1)
%         i 
%         log_img = LogImage(all_images(i,:,:));
% 
%         if i==1, imwrite(uint16(log_img), [filename, '.tif'], 'tiff', 'Compression', 'none')
%         else, imwrite(uint16(log_img), [filename, '.tif'], 'tiff', 'Compression', 'none', 'WriteMode', 'append')
%         end
%     end 

end 
