function fval = hlogopt_v11_2D(cone,weight,amp)
% NB: no need for such an optimisation step when all the weights are
% equal... a closed form can be used.

% fit cone with slope -1
[aa,fval,~,~] = fminbnd(@(a) sum(sum((weight.*(a*cone-amp)).^2)),0,10e+006);

% plot for testing
% if rand(1)>1  % e.g. set to 0.8 for ~20% of output; 1 of >1 for no output
%     figure
%     surf(aa*cone-amp)
% end
% end