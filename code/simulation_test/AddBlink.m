function blinking_mask = AddBlink(trc,t,on,off)
%% functions AddBlink, add blink properties to traces
%Input    trc              : m*2 array, m = # of particles * time
%                           P1: x1, y1
%                               x2, y2
%                               ...
%                           P2: x1, y1
%                               x2, y2
%                               ...
% 
%                               ...
%                           Pn: x1, y1
%                               x2, y2
%                               ...
%         t                : int, time length
%         on               : probability of turning on the blinking particle at the dim state
%         off              : probability of turning off the blinking particle at the bright state
%Output:  trc              : m*3 array, the thrid colum is blinking
%                            properties, intensity scale
%%
leng = length(trc);
blinking_mask = ones(leng,1);
blink_pro_on = on;
blink_pro_off = off;
pro_list = rand(1,leng);
for i  = 1:leng
    if mod(i,t) == 1
        continue
    end
    if blinking_mask(i-1,1) == 1
        blinking_mask(i,1) = pro_list(i) >  blink_pro_off;
        
    else
        blinking_mask(i,1) = pro_list(i) >  1-blink_pro_on;
    end
        
end

end

%     % add blinking mask
%     %2*sqrt(pi)*alpha
%     blink_p = 0.1;
%     intensities = abs(ones(1,length(xxs)))*2*sqrt(pi)*alpha;
%     blinking_mask = rand(1,length(xxs))>blink_p;
%     intensities = 0.7*intensities.*blinking_mask + 0.3*intensities;  