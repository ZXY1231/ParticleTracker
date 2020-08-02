function SaveLogImage(all_images, filename)
    if nargin < 2
        filename = 'LogImg';
    end
    for i = 1:size(all_images,1)
        i 
        log_img = LogImage(all_images(i,:,:));

        if i==1, imwrite(uint16(log_img), [filename, '.tif'], 'tiff', 'Compression', 'none')
        else, imwrite(uint16(log_img), [filename, '.tif'], 'tiff', 'Compression', 'none', 'WriteMode', 'append')
        end
    end 
end 