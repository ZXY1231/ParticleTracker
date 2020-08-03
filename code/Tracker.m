classdef Tracker < handle
    properties
        track_id 
        position_xy
        quality
        frames
    end
    methods
       
        function particle = Tracker(track_id,position_xy,quality,frames)
            particle.track_id = track_id;
            particle.quality = quality;
            particle.position_xy = position_xy;
            particle.frames = frames;
        end
        
        function particle = BlinlingDetector(particle)
            particle = addprop(particle,'Blinking');
        end
      
        function find_spot = FindNext(particle,all_next_spots)
            find_spot = [false -1];
            post_leng = length(all_next_spots);
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
            post_leng = length(all_next_spots);
            
            %velocity = ParticleVelocity(particle);
            velocity = PolynomialPredict(particle);
            
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
        
        
    end
end
