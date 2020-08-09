function tab_param_Brownian = simul_tab_param_Brownian(n_steps, n_trc, im_sz, D, do_plot, tbleach)

% function tab_param_Brownian = simul_tab_param_Brownian(n_steps, n_trc, im_sz, D, do_plot, tbleach)
% def: tab_param_Brownian = simul_tab_param_Brownian(300, 10, 100, 1, 0, 80)

global N_PARAM
if isempty(N_PARAM), MTTparams_def; end

if nargin<1, n_steps = 300; end
if nargin<2, n_trc = 10; end
if nargin<3, im_sz = 100; end
if nargin<4, D = 1; end 
if nargin<5, do_plot = 0; end
if nargin<6, tbleach = 80; end

tab_param_Brownian = ones(N_PARAM*n_steps,n_trc); % t, i, j, a, r, m0, blink

sig_free = sqrt(2*D); % r2 = x2 + y2 = 4Dt, with t = 1 step

t = (1:n_steps)';
ij = sig_free * randn(n_steps,2*n_trc); % [i j] % generates random steps with Gaussian distrib for diffusion at sig_free
ij(1,:) = rand(1,2*n_trc)*im_sz; % positions ini
ij = cumsum(ij); % build traj by summing steps

tab_param_Brownian(1:N_PARAM:end,:) = repmat(t,1,n_trc);
tab_param_Brownian(2:N_PARAM:end,:) = ij(:,1:2:end);
tab_param_Brownian(3:N_PARAM:end,:) = ij(:,2:2:end);

for n=1:n_trc
    t_off = min(ceil(exprnd(tbleach)), n_steps);
    tab_param_Brownian(t_off*N_PARAM+1:end, n) = 0;
end

% tab_param_Brownian(4:N_PARAM:end) = alpha;
% tab_param_Brownian(5:N_PARAM:end) = r;
% tab_param_Brownian(6:N_PARAM:end) = m;
% tab_param_Brownian(7:N_PARAM:end) = b;

if do_plot
    figure('WindowStyle','docked'), figure(gcf), hold on
    clr = jet(n_trc);
    for n=1:n_trc
        plot(tab_param_Brownian(3:N_PARAM:end,n), tab_param_Brownian(2:N_PARAM:end,n), '.', 'color', clr(n,:))
    end
    axis([0 im_sz 0 im_sz]), axis off equal
end