function [trc,blinking_mask] = simul2TIFF(trc, parameters)

% function simul2TIFF(trc, parameters)
% generate TIFF images from simulated traces
% see Sergé et al. Nature Methods 2008
% notably for the definition of Gaussian parameters, amplitude alpha, SNR, etc
% AS 8/12/8
%from Arnauld Serge, author of 'Dynamic multiple-target tracing to probe
%spatiotemporal cartography of cell membranes'

%| 20200801 | ZXY1231 |  add blinking mask

name_parameters = ...
    {'save data directory :', 'Filename', ...
    'Number of images in simul file', 'Image size (pxl)', 'number of peaks / image', ...
    'Gaussian radius (pxl)', 'mean signal (cnt)', 'SNR (dB)', 'Offset (cnt)', ...
    'graphic display? (0/1)', 'sampling rate (for peak position)', 'pixel size (µm/pxl)'};

default = ...
    {'cd','simul_test',...
    '100', '200', '128', ...
    '2.0', '300', '20', '0', ...
    '1', '1', '0.16'};

if nargin < 2
    parameters = inputdlg(name_parameters, 'Parameters', 1, default, 'on');
end

%% ----------------- parameters --------------------
cd(eval(parameters{1}));
filename = parameters{2}; % filename to be saved
NImg = str2double(parameters{3}); % NImg : number of images in simul file.
ImSz = str2double(parameters{4}); % image size (pxl)
Nppi = str2double(parameters{5}); % number of peaks / image

%% parameters for gaussian peaks simulating SM
sig = str2double(parameters{6}); % radius (sd) of peaks (pxl), here is the std of gaussian distribution
alpha = str2double(parameters{7}); % signal of peaks (cnt)
SNR_dB = str2double(parameters{8});% 30dB=>31.6 & 40dB=>100
SNR = 10^(SNR_dB/10); % = alpha2/sig_noise2
noise = alpha/sqrt(SNR); % mean noise, = 890..., according to statics, here noise = 3*std(image background)
offset = str2double(parameters{9});

graph = str2double(parameters{10});
if graph, figure('WindowStyle', 'docked'), end

sampling = str2double(parameters{11});
% pxlsize = str2double(parameters{12});

if nargin==0 % test brownien
    trc = randn(NImg*Nppi, 2);
    trc(1:NImg:NImg*Nppi, :) = ImSz*rand(Nppi, 2); % initial positions
    trc = cumsum(trc, 1);
    trc = abs(mod(trc, 2*ImSz)-ImSz); % folding at borders
    subplot(1, 2, 1)
    plot(trc(:, 1), trc(:, 2), '.')
    axis equal xy, axis ([0 ImSz 0 ImSz]), figure(gcf)
    subplot(1, 2, 2)
else
    trc = trc(:,3:4); % keep only x y, if input trc = [n t x y]
% % %     trc = trc/pxlsize; % conv µ => pxl
end

% wn = 7;
g = gausswin2(sig*sampling, ImSz*sampling); % PSF (oversampled)
% g = expand_w(g, ImSz*sampling, ImSz*sampling) ;

fprintf('\r')
filenamei = sprintf('%s_%04.0f', filename, 0); fprintf(filenamei)
%% add blinking mask
blinking_mask = AddBlink(trc,NImg,0.3,0.1);
 
%% **** adding SM to mean image *****

for i = 1:NImg
    indPk = i:NImg:Nppi*NImg; %%%find(trc(:, 1)==i); % peak #  for img i
    xx = trc(indPk, 1);
    yy = trc(indPk, 2);
    in = xx>0 & xx<=ImSz & yy>0 & yy<=ImSz;
    xxs = ceil(xx(in)*sampling);
    yys = ceil(yy(in)*sampling);
    
    one_blinking_mask = blinking_mask(indPk, 1);
    one_blinking_mask = one_blinking_mask(in);
    
    % add blinking mask
    %2*sqrt(pi)*alpha
    intensities = abs(ones(length(xxs),1))*2*sqrt(pi)*alpha;
    intensities = 0.9*intensities.*one_blinking_mask + 0.1*intensities;
 
    
    iImgs = zeros(ImSz*sampling); % oversampled image
    iImgs(sub2ind(size(iImgs), xxs, yys)) = intensities;
    
    iImgs = real(fftshift(ifft2(fft2(iImgs) .* fft2(g)))) ;
    iImg = imresize(iImgs, [ImSz, ImSz]) + offset;
    
    %% **** add noise eventually... ****
    noisyiImg = iImg+noise*randn(ImSz);
    noisyiImg = abs(noisyiImg-1)+1; % positive values for tiff (or max(0, Img) ?)
    
    if graph %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        imagesc(noisyiImg), colorbar
        title(['image ' num2str(i)]); axis image xy % title('peaks + noise')
        set(gca, 'XTick', [1 floor(ImSz/2) ImSz], 'YTick', [1 floor(ImSz/2) ImSz])
        drawnow % figure(gcf)
    end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    filenamei = sprintf('%s_%04.0f', filename, i);
    fprintf(repmat('\b', size(filenamei))), fprintf(filenamei)
    pause(0.01)
    if i==1, imwrite(uint16(noisyiImg), [filename, '.tif'], 'tiff', 'Compression', 'none')
    else, imwrite(uint16(noisyiImg), [filename, '.tif'], 'tiff', 'Compression', 'none', 'WriteMode', 'append')
    end
%% wirte down ground truth
%generate labels
labels = repmat(1:Nppi,[NImg,1]);
labels = labels(:);

writematrix(cat(2, trc, blinking_mask, labels), [num2str(NImg) 'frames.csv'])
end % for i=1:NImg