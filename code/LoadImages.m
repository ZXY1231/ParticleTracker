function all_images = LoadImages(source_path)
    source_path
    imges = dir([source_path '*.tif']);
    imge_num = length(imges);
    shapes = size(imread([imges(1).folder '/' imges(1).name]));
    all_images = zeros(imge_num, shapes(1), shapes(2));

    for i = 1:imge_num
        img = imread([imges(i).folder '/' imges(i).name]);
        all_images(i,:,:) = img;

    end
end