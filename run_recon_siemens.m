function im = run_recon_siemens(lambda,n_iterations,maskfile,savefile)

setPath;

Ny = 256;
Nx = 256;
nc = 8;
nE = 8;
slice = 32;

maps = [];
im = [];
mask = [];

load(maskfile);
load('sens_maps_256_256_8');
load('teImages');

teIms = single(zeros(Ny,Nx,nc,nE));
teImages = single(im);
teImages = squeeze(teImages(:,:,slice,:));
clear im;

k = zeros(Ny,Nx,nc,nE);
m = mask;
s = maps;

smin = min(abs(maps(:)));
smax = max(abs(maps(:)));
maps = (maps - smin)/(smax - smin);

tmin = min(abs(teImages(:)));
tmax = max(abs(teImages(:)));
teImages = (teImages-tmin)/(tmax - tmin);

for ii = 1:nE
    for jj = 1:nc
        
        teIms(:,:,jj,ii) = teImages(:,:,ii).*maps(:,:,jj);
        k(:,:,jj,ii) = fft2c(squeeze(teIms(:,:,jj,ii)));
    end
end

im = t2_star_reconstruction(k,m,s,n_iterations,lambda);
save(savefile,'im');
end
