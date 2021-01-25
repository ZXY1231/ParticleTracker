classdef Tracker < handle
    properties
        track_id 
        position_xy
        quality
        frames
        my_patterns
    end
    methods
       
        function particle = Tracker(track_id,position_xy,quality,frames)
            particle.track_id = track_id;
            particle.quality = quality;
            particle.position_xy = position_xy;
            particle.frames = frames;
            particle.my_patterns = [];
        end
        
        function particle = BlinlingDetector(particle)
            particle = addprop(particle,'Blinking');
        end
      
        function find_spot = FindNext(particle,all_next_spots)
            find_spot = [false -1];
            post_leng = size(all_next_spots,1);
            x = particle.position_xy(end,1);
            y = particle.position_xy(end,2);
            
            near = 9999999;
            for i = linspace(1, post_leng, post_leng)
                dis = (x-all_next_spots(i,1))^2 + (y-all_next_spots(i,2))^2;
                if dis < near
                    near = dis;
                    next_x = all_next_spots(i,1);
                    next_y = all_next_spots(i,2);
                    find_spot(2) = i;
                end
            end
            if near < 25
                particle.position_xy(end+1,[1,2]) = [next_x,next_y];
                find_spot(1) = true;
            else
                find_spot(1) = false;
            end
        end
        
        %Here, all_next_xy should be particles xy with low threshold, we
        %use fun ParticleVelocity here.
        function find_spot = FindNextDim(particle,all_next_spots)
            find_spot = [false -1];
            post_leng = size(all_next_spots,1);
            
            %velocity = ParticleVelocity(particle);
%             velocity = PolynomialPredict(particle);
            velocity = [0,0];
            x = particle.position_xy(end,1) + velocity(1);
            y = particle.position_xy(end,2) + velocity(2);
            near = 9999999;
            for i = linspace(1, post_leng, post_leng)
                dis = (x-all_next_spots(i,1))^2 + (y-all_next_spots(i,2))^2;
                if dis < near
                    near = dis;
                    next_x = all_next_spots(i,1);
                    next_y = all_next_spots(i,2);
                    find_spot(2) = i;
                end
            end
            if near < 25
                particle.position_xy(end+1,[1,2]) = [next_x,next_y];
                find_spot(1) = true;
            else
                find_spot(1) = false;
                %predicated xy results
                particle.position_xy(end+1,[1,2]) = [x,y];
            end
        end
        
        % particles velocities estimation
        function velocity = ParticleVelocity(particle)
            if size(particle.position_xy,1) <2
%                 particle.track_id
%                 error('Velocity calculation should be started with at least the 2nd frame.');
                velocity = [0,0];
            else
                velocity = particle.position_xy(end,:) - particle.position_xy(end-1,:);
                %If copy values directly form matlab variables, the
                %difference will be slightly different for some reason.
            end
        end
        
        % particles velocities estimation, 
        function velocity = PolynomialPredict(particle)
            if size(particle.position_xy,1) <2
%                 particle.track_id
%                 error('Velocity calculation should be started with at least the 2nd frame.');
                velocity = [0,0];
            else
                previous_xy = particle.position_xy(:,1:2);
                velocity = [0,0];
                leng = length(previous_xy);
                for i = 1:leng-2
                    velocity = velocity + 0.5^i*(previous_xy(end-i+1,:)-previous_xy(end-i,:));
                end
                velocity = velocity + 0.5^(leng-2)*(previous_xy(2,:)-previous_xy(1,:));
                %velocity = velocity + previous_xy(end,:);             
            end
        end
        
        %retrieve particle's pattern
        function pattern = MyPattern(particle, all_full_images, n, region)
        %MyPattern: return pattern of the particle, (averaged over the last n patterns)
        %Input    particle                : tracker, refer to Tracker function particle = Tracker(track_id,position_xy,quality,frames)
        %          
        %         all_full_images         : array, size (#frames,h,w), 
        %         n                       : int, the parttern is average over the last n frame from the current time
        %         region                  : w*h array, pattern range = x-h/2+1:x+h/2, y-w/2+1:y+w/2, x, y is position in particle.position_xy
        %Output:  pattern                 : has the same size with region
            %
            pattern = zeros(size(region));
            h = size(region,1);
            w = size(region,2);
            image_size = size(squeeze(all_full_images(1,:,:)));
            xxs = ceil(particle.position_xy(:,2));%pay attention to here xy
            yys = ceil(particle.position_xy(:,1));
            t = 0;
            
            while t < n && t < size(particle.position_xy,1)
                t_frame = particle.frames(end-t);
                if t_frame<0
                    t = t+1;
                    n = n+1; 
                    continue
                end

                x = xxs(end-t,1);
                y = yys(end-t,1);%pay attention to here xy

                if x-h/2+1 <= 0 || x+h/2 > image_size(1) || y-w/2+1 <= 0 || y+w/2 > image_size(2)

                    break;
                end
                
                image = squeeze(all_full_images(t_frame,:,:));
                pattern = pattern + image(x-h/2+1:x+h/2, y-w/2+1:y+w/2);
                t = t + 1;
                
            end
            pattern = pattern.*region/n;
            
        end
        
        %retrieve particle's pattern
        function pattern = MyPattern2(particle, all_full_images, n, region)
        %MyPattern: return pattern of the particle, (averaged over the first n patterns) 
        %Input    particle                : tracker, refer to Tracker function particle = Tracker(track_id,position_xy,quality,frames)         
        %         all_full_images         : array, size (#frames,h,w), 
        %         n                       : int, the parttern is average over the first n frames from start
        %         region                  : w*h array, pattern range = x-h/2+1:x+h/2, y-w/2+1:y+w/2, x, y is position in particle.position_xy
        %Output:  pattern                 : has the same size with region
            pattern = zeros(size(region));
            h = size(region,1);
            w = size(region,2);
            image_size = size(squeeze(all_full_images(1,:,:)));
            xxs = ceil(particle.position_xy(:,2));%pay attention to here xy
            yys = ceil(particle.position_xy(:,1));
            t = 1;
            
            while t < n && t < size(particle.position_xy,1)
                t_frame = particle.frames(t);
                if t_frame<0
                    t = t+1;
                    n = n+1; 
                    continue
                end

                x = xxs(t,1);
                y = yys(t,1);%pay attention to here xy

                if x-h/2+1 <= 0 || x+h/2 > image_size(1) || y-w/2+1 <= 0 || y+w/2 > image_size(2)

                    break;
                end
                
                image = squeeze(all_full_images(t_frame,:,:));
                pattern = pattern + image(x-h/2+1:x+h/2, y-w/2+1:y+w/2);
                t = t + 1;
                
            end
            pattern = pattern.*region/n;
            
        end
        

        function pattern = MyFastPattern(particle, one_image, region)
        %MyPattern: return pattern of the particle, (averaged over the first n patterns) 
        %Input    particle                : tracker, refer to Tracker function particle = Tracker(track_id,position_xy,quality,frames)         
        %         all_full_images         : array, size (#frames,h,w), 
        %         n                       : int, the parttern is average over the first n frames from start
        %         region                  : w*h array, pattern range = x-h/2+1:x+h/2, y-w/2+1:y+w/2, x, y is position in particle.position_xy
        %Output:  pattern                 : has the same size with region
            pattern = zeros(size(region));
            h = size(region,1);
            w = size(region,2);
            image_size = size(one_image);
            xxs = ceil(particle.position_xy(:,2));%pay attention to here xy
            yys = ceil(particle.position_xy(:,1));
            x = xxs(end,1);
            y = yys(end,1);%pay attention to here xy
            if x-h/2+1 <= 0 || x+h/2 > image_size(1) || y-w/2+1 <= 0 || y+w/2 > image_size(2)
%                pass
            else
                image = one_image;
                pattern = pattern + image(x-h/2+1:x+h/2, y-w/2+1:y+w/2);
            end
            
        end
        
        function pattern = MyPatternVideo(particle, all_full_images, t1, t2, region)
   
            %
            pattern = zeros([size(region),t2-t1+1]);
            h = size(region,1);
            w = size(region,2);
            image_size = size(squeeze(all_full_images(1,:,:)));
            xxs = ceil(particle.position_xy(:,2));%pay attention to here xy
            yys = ceil(particle.position_xy(:,1));
            for i = t1:t2
                t_frame = abs(particle.frames(i));
                x = xxs(i,1);
                y = yys(i,1);%pay attention to here xy
                if x-h/2+1 <= 0 || x+h/2 > image_size(1) || y-w/2+1 <= 0 || y+w/2 > image_size(2)
                    break;
                end

                image = squeeze(all_full_images(t_frame,:,:));
                pattern(:,:,i-t1+1) = image(x-h/2+1:x+h/2, y-w/2+1:y+w/2);

            end
            
        end
        

        function position_z = EstimateZ(particle,particle_pattern,a,b) 
        %EstimateZ: return z estimation of the particle
        %Input    particle                : tracker, refer to Tracker function particle = Tracker(track_id,position_xy,quality,frames)         
        %         particle_pattern        : parttern of the pattern,
        %         a                       : experimental parameter
        %         b                       : experimental parameter
        %Output:  position_z              : double, z position
        %         |     yunlei            | 20200824
        %         paper reference: Three-dimensional localization microscopy in live flowing cells
            if nargin<3
                a = 2343.4;
                b = 820.7;
            end

            H = size(particle_pattern,1);
            W = size(particle_pattern,2);
            [X, Y] = meshgrid(1:H, 1:W);
            X_fit = X-(H-1)/2;
            Y_fit = Y-(W-1)/2;
            XY(:,:,1)=X_fit;
            XY(:,:,2)=Y_fit;

            func = @(var,x) (var(1)*exp(-(x(:,:,1)-var(2)).^2/(2*var(4)^2)-(x(:,:,2)-var(3)).^2/(2*var(5)^2)));  
            try
                options = optimset('MaxFunEvals',100000,'MaxIter',100000);
                result = lsqcurvefit(func,[1,0,0,1,1],XY,particle_pattern,[],[],options);
                position_z = a*log(result(4)/result(5)) + b;

            catch

            end
            particle.position_xy(end,4) = position_z;
        end
        
        function SavePatterns(particle, all_full_images, region, filename)
            if nargin < 4
                particle.track_id
                filename = ['Id_' num2str(particle.track_id) '_Patterns'];
            end
            
            patterns = zeros([size(particle.position_xy,1) size(region)]);
            h = size(region,1);
            w = size(region,2);
            image_size = size(squeeze(all_full_images(1,:,:)));
            xxs = ceil(particle.position_xy(:,2));%pay attention to here xy
            yys = ceil(particle.position_xy(:,1));
            
            for t = 1:size(particle.position_xy,1)
                t_frame = abs(particle.frames(t));
                x = xxs(t,1);
                y = yys(t,1);%pay attention to here xy
                if x-h/2+1 < 0 || x+h/2 > image_size(1) || y-w/2+1 < 0 || y+w/2 > image_size(2)
                    break;
                end
                
                image = squeeze(all_full_images(t_frame,:,:));
                patterns(t,:,:) = image(x-h/2+1:x+h/2, y-w/2+1:y+w/2);
                
            end
            
            for i = 1:size(patterns, 1)
                if max(patterns(i,:,:))==0
                    patterns(i,:,:) = [];
                end
            end
            
            for i = 1:size(patterns,1)
                i 
                pattern = squeeze(patterns(i,:,:));
                if i==1, imwrite(uint16(pattern), [filename, '.tif'], 'tiff', 'Compression', 'none')
                else, imwrite(uint16(pattern), [filename, '.tif'], 'tiff', 'Compression', 'none', 'WriteMode', 'append')
                end
            end 
        end
        
        function SavePatterns2(particle, filename)
            %save 
            if nargin < 2
                particle.track_id
                filename = ['Id_' num2str(particle.track_id) '_Patterns'];
            end
            
            for i = 1:size(particle.my_patterns,1)
                i 
                pattern = squeeze(particle.my_patterns(i,:,:));
                if i==1, imwrite(uint16(pattern), [filename, '.tif'], 'tiff', 'Compression', 'none')
                else, imwrite(uint16(pattern), [filename, '.tif'], 'tiff', 'Compression', 'none', 'WriteMode', 'append')
                end
            end
            
        end


        
        
        
        
    end
end
