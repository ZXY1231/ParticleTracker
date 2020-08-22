function new_dim_particles = MutualExcludeBrightDim(bright_particles, dim_particles, dis_error)
    dis_error = dis_error^2;
    new_dim_particles = cell(size(dim_particles));
    for i = 1:size(bright_particles,2)
        % i is frame here
        bright_p = bright_particles{1,i};
        dim_p = dim_particles{1,i};
        delete_dim_p = [];
        for j = 1:size(dim_p,1)
            for k = 1:size(bright_p,1)


                dis = (dim_p(j,1) - bright_p(k,1))^2+(dim_p(j,2) - bright_p(k,2))^2;
                if dis < dis_error
                    delete_dim_p(end+1) = j;

                    break
                end     
            end
        end
        dim_p(delete_dim_p,:) = [];
        new_dim_particles{i} = dim_p;
    end
end 
