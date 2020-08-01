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