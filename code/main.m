clear all;
format long;
% Main function
% Matlab is pass-by-value.
% | Version | Author | Date     | Commit
% | 0.1     | ZhouXY | 20.02.12 | The init version
% | 0.2     | ZhouXY | 20.07.03 | Reconstruct the model for compatbility
% | 0.3     | ZhouXY | 20.07.09 | add gap filling
% | 1.0     | ZhouXY | 20.07.31 | Modify model structure, commit to github
% TODO: put the parameters outside function but main function
%test version is used for testing center fitting in time series
%% 

tic;
% Parameters
frames_path = '/Users/apple/Desktop/TrackMaster/TestFigure2/';
result_path = '/Users/apple/Desktop/TrackMaster/TestResult/';
all_images = LoadImages(frames_path);% size (#frames,h,w)
log_images = zeros(size(all_images));

global all_images_bright_particles all_images_dim_particles
all_images_bright_particles = cell(1,size( all_images,1));
all_images_dim_particles = cell(1,size(all_images,1));

high_threshold = 5;
low_threshold = 1;
gap_max = 5;
%% 

for i = 1:size(all_images,1)
    i 
    log_img = LogImage(all_images(i,:,:));
    log_images(i,:,:) = log_img;
    
    all_images_bright_particles(i) = {IdentifySpots(log_img, high_threshold)};
    all_images_dim_particles(i) = {IdentifySpots(log_img, low_threshold)};
end


%% add usage flag to all detected spots in all frames
all_images_bright_particles = AllSpotsAddFlags(all_images_bright_particles);
all_images_dim_particles = AllSpotsAddFlags(all_images_dim_particles);

%%  
%Initialize trackers with bright spots in the first frame here

all_tracks = TrackerInitializaon(all_images_bright_particles{1});

%% link detected spots between frames

time_length = size(all_images,1);

% % here only link particles without gaps
% for i = 2:time_length
%     find_spot = AllFindNext(all_tracks, all_images_bright_particles{i}, all_images_dim_particles{i});
% end

% include gaps
track_num = size(all_tracks,2);
for i = 2:time_length
    i
    for j  = 1:size(all_tracks,2)
        %determine gap, here is a bit rundundant computation. At each time
        %point, all tracks are used for claculating gaps, including those
        %whose gaps are over gap_max.
        last_gap_start = find(all_tracks{j}.frames>0,1,'last');
        if i- last_gap_start> gap_max
            continue
        end
        find_spot = FindNext(all_tracks{j}, all_images_bright_particles{i}, all_images_dim_particles{i}, i);
        if find_spot(1)
            all_tracks{j}.frames(end+1) = i;
        else
            all_tracks{j}.frames(end+1) = -i;
        end
    end
    
    new_tracks = AllNewTracks(all_tracks{end}.track_id, all_images_bright_particles{i}, i);
    all_tracks = [all_tracks new_tracks];

end

%% test module
tracks_length = AllTracksLength(all_tracks);

%% 
toc;

% %% functions
% %function name: describtion 
% %Input    a              : 
% %         b              : 
% %Output:  c              :
% 
% % source_path is root path of images

% function all_images = LoadImages(source_path)
%     source_path
%     imges = dir([source_path '*.tif']);
%     imge_num = length(imges);
%     shapes = size(imread([imges(1).folder '/' imges(1).name]));
%     all_images = zeros(imge_num, shapes(1), shapes(2));
% 
%     for i = 1:imge_num
%         img = imread([imges(i).folder '/' imges(i).name]);
%         all_images(i,:,:) = img;
% 
%     end
% end

% LoG detector for particles detection 
% function img_log = LogImage(image)
%     
%     img = double(squeeze(image));
%     Log_filter = -fspecial('log', [10,10], 4.0); % fspecial creat predefined filter.Return a filter.
%                                        
%     img_log = imfilter(img, Log_filter, 'symmetric', 'conv');
%  
% end

function imgxy = IdentifySpots(img, thresh)
% Extract locations from image
% | Version | Author | Date     | Commit
% | 0.1     | ZhouXY | 18.07.19 | The init version
% | 0.2     | H.F.   | 18.09.05 |
% | 1.0     | ZhouXY | 20.07.05 | Reconstruction
% To Do: Binarize image with locally adaptive thresholding or only take
% threshold but keep graydrade
%We use function LocateSpotCentre_b1 here, which is outside the main file.

% Choose the threshold of image
img_thresh = imbinarize(img,thresh);

% Find connected components in binary image
CC = bwconncomp(img_thresh, 6); % should use 8 connected for 2d image

% Due to cellfun limit, size of img must be a cell form, all inout arguments must be cell form  
s = size(img_thresh);
SizeCell = cell(1,numel(CC.PixelIdxList));
SizeCell(1:end) = {s};

CenterTypeCell = cell(1,numel(CC.PixelIdxList));
CenterTypeCell(1:end) = {'Centroid'};

ImgCell = cell(1,numel(CC.PixelIdxList));
ImgCell(1:end) = {img};

% Find out the centre of worm
[imgy, imgx] = cellfun(@LocateSpotCentre_b1, CC.PixelIdxList, SizeCell, CenterTypeCell, ImgCell);

% center = cell2mat(center);
% center = real(center);

% size(centers)
% [x, y] = ind2sub(s, centers); % Transfer linear index to subscript
% imgx = y;
% imgy = x;

imgxy = cat(2,imgx',imgy');
%imgy = s(2)-imgy; % What is mean? invert the image 
end

function ShowParticles(xy, image)
%     figure(11) 
    imshow(image)
    hold on
    plot(xy(:,1),xy(:,2),'r*','MarkerSize',1)
    hold off
end

%Initialize trackers based on the first_frame_bright_spot
function all_tracks = TrackerInitializaon(first_frame_bright_spots)
    all_tracks = cell(1,size(first_frame_bright_spots,1));
    for i  = 1:size(first_frame_bright_spots,1)
        all_tracks{i} = Tracker(i,first_frame_bright_spots(i,:),0,1);
    end
end

function find_spot = AllFindNext(all_tracks, next_bright_particles, next_dim_particles)
%AllFindNext: all tracks search for next positions based on provided next all bright and dim locations
%Input    all_tracks              : 1*n cells, n is # of current tracks, each cell 
%                                   contains a tracker(self-defined class)
%         next_bright_particles   : 1*t cells, t is # of frames, each cell containes one array
%                                   providing bright spots detected at i-th frame with shape m1*2
%         next_dim_particles      :1*t cells, t is # of frames, each cell containes one array
%                                   providing dim spots detected at i-th frame with shape m2*2
%Output:  find_spot                    :[1, next spot ID] or 0 , it is the last tracker's result. 
    find_spot = false;
    
    for i = 1:size(all_tracks,2)
        find_spot = all_tracks{i}.FindNext(next_bright_particles);
        if find_spot(1)
            
        else 
            find_spot = all_tracks{i}.FindNextDim(next_dim_particles);
        end
        
    end
end

function find_spot = FindNext(one_tracker, next_bright_particles, next_dim_particles,t)
%FindNext: one track search for next positions based on provided next all bright
%and dim locations, alter flag of found spot to 1
%Input    one_tracker              : tracker
%         next_bright_particles   : 1*t cells, t is # of frames, each cell containes one array
%                                   providing bright spots detected at i-th frame with shape m1*2
%         next_dim_particles      :1*t cells, t is # of frames, each cell containes one array
%                                   providing dim spots detected at i-th frame with shape m2*2
%         t                       : t indicateds t-th frame of detected spots
%Output:  find_spot                    :[1, next spot ID] or 0
    
    global all_images_bright_particles all_images_dim_particles
    find_spot = one_tracker.FindNext(next_bright_particles);
    if find_spot(1)
        all_images_bright_particles{t}(find_spot(2),3) = 1;
    else 
        find_spot = one_tracker.FindNextDim(next_dim_particles);
        if find_spot(1)
            all_images_dim_particles{t}(find_spot(2),3) = 1;
        end
    end
end

function tracks_length = AllTracksLength(all_tracks)
    tracks_length = zeros(size(all_tracks));
    for i  = 1:size(all_tracks,2)
        tracks_length(i) = length(find(all_tracks{i}.frames>0));
    end
    tracks_length = tracks_length';
end

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

function new_tracks = AllNewTracks(track_id_end, next_spots,t)
%AllNewTracks: creat trackers based on t-th new spots
%Input    all_tracks              : 1*n cells, n is # of current tracks, each cell 
%                                   contains a tracker(self-defined class)
%         all_next_spots          : m1*3 array, m is # of spots detected at
%                                   current frame t, in each row, [x y usage_flag]
%         t                       : t indicateds t-th frame of detected spots
%Output:  new_tracks              :1*m2 cells , m2 is # of tracks start at t, each cell 
%                                   contains a tracker(self-defined class),
%                                   m2<=m1
    unused_flage = 0;
    unused_spots = find(next_spots(:,3)==unused_flage);
    new_tracks = cell(1,length(unused_spots));
    for i = 1:length(unused_spots)
        new_tracks{i} = Tracker(track_id_end+i, next_spots(unused_spots(i),:), 0, t);
    end
end




