function [im] = phase_reconstruction(ksp_file,mask_file,sens_file,n_iterations,lambda,savefile)

load(ksp_file,'ksp');
load(mask_file,'mask');
load(sens_file,'maps');

[ny, nz, nc, nE] = size(ksp);

% permute mask
masks = permute(mask, [1 2 4 3]);

% normalize sensitivities
sens1_mag = reshape(vecnorm(reshape(maps, [], nc).'), [ny, nz]);
sens = bsxfun(@rdivide, maps, sens1_mag);
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
A_adj = @(y) Psi_adj(U(angle(S_adj(F_adj(P_for(y))))));


%% scaling
scaling = 1.0;
fprintf('\nScaling: %f\n\n', scaling);

ksp = ksp ./ scaling;
ksp_adj = A_adj(ksp);

%% ADMM
rho = 0.5;
beta = admm(A_for,A_adj,ksp_adj,ksp,n_iterations,lambda,rho);
im = angle(exp(1j*scaling*Psi_for(beta)));
save(savefile,'im');
end
