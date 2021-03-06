function create_ksp_slice(sens_file,te_images_file,slice,savefile)

setPath;

maps = [];

load(sens_file,'maps');
load(te_images_file,'im');

Nx = size(im,1);
Ny = size(im,2);
nE = size(im,4);
nc = size(maps,3);

channel_echo_images = zeros(Ny,Nx,nc,nE);
echo_images = squeeze(im(:,:,slice,:));

ksp = zeros(Ny,Nx,nc,nE);

smin = min(abs(maps(:)));
smax = max(abs(maps(:)));
maps = (maps - smin)/(smax - smin);

tmin = min(abs(echo_images(:)));
tmax = max(abs(echo_images(:)));
echo_images = (echo_images-tmin)/(tmax - tmin);

for ii = 1:nE
    for jj = 1:nc
        channel_echo_images(:,:,jj,ii) = echo_images(:,:,ii).*maps(:,:,jj);
        ksp(:,:,jj,ii) = fft2c(squeeze(channel_echo_images(:,:,jj,ii)));
    end
end

save(savefile,'ksp');
end