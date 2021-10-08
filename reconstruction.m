function [im] = reconstruction(ksp,mask,sens1,n_iterations,lambda,savefile)

[ny, nz, nc, nE] = size(ksp);

% permute mask
masks = permute(mask, [1 2 4 3]);

% normalize sensitivities
sens1_mag = reshape(vecnorm(reshape(sens1, [], nc).'), [ny, nz]);
sens = bsxfun(@rdivide, sens1, sens1_mag);
sens(isnan(sens)) = 0;

%% operators

% ESPIRiT maps operator applied to coefficient images
S_for = @(a) bsxfun(@times, sens, permute(a, [1, 2, 4, 3]));
S_adj = @(as) squeeze(sum(bsxfun(@times, conj(sens), as), 3));
% SHS = @(a) S_adj(S_for(a));

% Fourier transform
F_for = @(x) fft2c(x);
F_adj = @(y) ifft2c(y);

% Sampling mask
P_for = @(y) bsxfun(@times, y, masks);

%Apply sampling mask
ksp = P_for(ksp);

% Phase forward model
Psi_for = @(a) phase_temporal_forward(a,nE);
Psi_adj = @(a) phase_temporal_adjoint(a);

%Phase unwrap operator 
U = @(a) phase_unwrap(a);

% Full forward model
A_for = @(a) P_for(F_for(S_for(Psi_for(a))));
%A_adj = @(y) S_adj(F_adj(T_adj(P_for(y))));
A_adj = @(y) Psi_adj(U(angle(S_adj(F_adj(P_for(y))))));
%AHA = @(a) S_adj(F_adj(T_adj(P_for(T_for(F_for(S_for(a))))))); % slightly faster
%AHA = @(a) A_adj(A_for(a));

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

scaling = 1.0;

fprintf('\nScaling: %f\n\n', scaling);

ksp = ksp ./ scaling;
ksp_adj = A_adj(ksp);

%% ADMM

rho = 0.5;
%iter_ops.objfun = @(a, sv, lam) 0.5*norm_mat(ksp - A_for(a))^2 + lam*sum(sv(:));
%iter_ops.objfun = @(a, sv, lam) 0.5*norm_mat(A_adj(ksp) - a)^2 + lam*sum(sv(:));
beta = admm(A_for,A_adj,ksp_adj,ksp,n_iterations,lambda,rho);
im = angle(exp(1j*scaling*Psi_for(beta)));
save(savefile,'im');
end
