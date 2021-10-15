function [im] = reconstruction(ksp_file,mask_file,sens_file,bas_file,K,n_iterations,lambda,savefile)

setPath;

load(ksp_file,'ksp');
load(mask_file,'mask');
load(sens_file,'maps');
load(bas_file,'bas');

[ny, nz, nc, nE] = size(ksp);

% permute mask
masks = permute(mask, [1 2 4 3]);

% normalize sensitivities
sens_mag = reshape(vecnorm(reshape(maps, [], nc).'), [ny, nz]);
sens = bsxfun(@rdivide, maps, sens_mag);
sens(isnan(sens)) = 0;

% Truncated subspace basis
Phi = bas(:,1:K);

%% Common operators

% ESPIRiT maps operator applied to coefficient images
S_for = @(a) bsxfun(@times, sens, permute(a, [1, 2, 4, 3]));
S_adj = @(s) squeeze(sum(bsxfun(@times, conj(sens), s), 3));

% Fourier transform
F_for = @(x) fft2c(x);
F_adj = @(y) ifft2c(y);

% Sampling mask
P_for = @(y) bsxfun(@times, y, masks);

%% Magnitude recon-specific operators

% Temporal projection operator
T_for = @(a) temporal_forward(a, Phi);
T_adj = @(x) temporal_adjoint(x, Phi);

% Full forward model
A_for_mag = @(a) P_for(T_for(F_for(S_for(a))));
A_adj_mag = @(y) T_adj(S_adj(F_adj(P_for(y))));
AHA_mag = @(a) S_adj(F_adj(T_adj(P_for(T_for(F_for(S_for(a))))))); % slightly faster

%% Phase recon-specific operators

% Phase forward model
Psi_for = @(a) phase_temporal_forward(a,nE);
Psi_adj = @(a) phase_temporal_adjoint(a);

%Phase unwrap operator 
U = @(a) phase_unwrap(a);

% Full forward model
A_for_phase = @(a) P_for(F_for(S_for(Psi_for(a))));
A_adj_phase = @(y) Psi_adj(U(angle(S_adj(F_adj(P_for(y))))));

%% Synthesize undersampled data
ksp_mag = P_for(ksp);
ksp_adj_mag = A_adj_mag(ksp_mag);

ksp_phase = P_for(ksp);
ksp_adj_phase = A_adj_phase(ksp_phase);


%% scaling
% tmp = dimnorm(ifft2c(bsxfun(@times, ksp, masks)), 3);
% tmpnorm = dimnorm(tmp, 4);
% tmpnorm2 = sort(tmpnorm(:), 'ascend');
% % match convention used in BART
% p100 = tmpnorm2(end);
% p90 = tmpnorm2(round(.9 * length(tmpnorm2)));
% p50 = tmpnorm2(round(.5 * length(tmpnorm2)));
% if (p100 - p90) < 2 * (p90 - p50)
%     scaling = p90;
% else
%     scaling = p100;
% end
% 
% fprintf('\nScaling: %f\n\n', scaling);
%% ADMM
% 
iter_ops.max_iter = n_iterations;
iter_ops.rho = .1;
iter_ops.objfun = @(a, sv, lam) 0.5*norm_mat(ksp_mag - A_for_mag(a))^2 + lam*sum(sv(:));

llr_ops.lambda = lambda;
llr_ops.block_dim = [8,8];

lsqr_ops.max_iter = 10;
lsqr_ops.tol = 1e-4;

alpha_ref = RefValue;
alpha_ref.data = zeros(ny, nz, K);

history = iter_admm(alpha_ref, iter_ops, llr_ops, lsqr_ops, AHA_mag, ksp_adj_mag);

alpha = alpha_ref.data;
im = T_for(alpha);
mag = abs(im);

ksp_phase = fft2c(S_for(im));
ksp_adj_phase = A_adj_phase(ksp_phase);

rho = 0.5;
%iter_ops.objfun = @(a, sv, lam) 0.5*norm_mat(ksp - A_for(a))^2 + lam*sum(sv(:));
%iter_ops.objfun = @(a, sv, lam) 0.5*norm_mat(A_adj(ksp) - a)^2 + lam*sum(sv(:));
beta = admm(A_for_phase,A_adj_phase,ksp_adj_phase,ksp_phase,n_iterations,lambda,rho);
im = mag.*exp(1j*Psi_for(beta));
save(savefile,'im');
end
