function img_log = LogImage(image)
    
    img = double(squeeze(image));
    Log_filter = -fspecial('log', [10,10], 4.0); % fspecial creat predefined filter.Return a filter.
                                       
    img_log = imfilter(img, Log_filter, 'symmetric', 'conv');
 
end 