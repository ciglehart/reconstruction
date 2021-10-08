clear all;
close all;
clc;

load('teImages');
load('brain_mask');
slice = 32;
nE = 8;
echo = 8;
threshold = 0.10;

Psi_adj = @(a) phase_temporal_adjoint(a);
Psi_for = @(a) phase_temporal_forward(a,nE);
U = @(a) phase_unwrap(a);

phase = U(squeeze(angle(im(:,:,slice,:))));
beta = Psi_adj(phase);
phase_model = Psi_for(beta);

err = 1-cos(phase_model-phase);
err(abs(err)>threshold) = threshold;

img = zeros(256,512,3);
cmap = parula(256);

img(:,1:256,:) = rgb_image(rot90(beta(:,:,1)),rot90(mask),cmap,[0,0,0],[]);
img(:,257:512,:) = rgb_image(rot90(beta(:,:,2)),rot90(mask),cmap,[0,0,0],[]);

f = figure;
imagesc(img);
axis equal;
axis tight;
axis off;
custom_colorbar(min(phase(:)),max(phase(:)),1,cmap,12);

img = zeros(768,1024,3);

ind = find(repmat(mask,1,1,nE)>0);
truth_vals = phase(ind);
model_vals = phase_model(ind);
val_range = [min([min(truth_vals(:)),min(model_vals(:))]),max([max(truth_vals(:)),max(model_vals(:))])];

for i = 1:nE
    img(1:256,((i-1)*256 + 1):256*i,:) = rgb_image(rot90(phase(:,:,i)),rot90(mask),cmap,[0,0,0],val_range);
    img(257:512,((i-1)*256 + 1):256*i,:) = rgb_image(rot90(phase_model(:,:,i)),rot90(mask),cmap,[0,0,0],val_range);
    img(513:768,((i-1)*256 + 1):256*i,:) = rgb_image(rot90(err(:,:,i)),rot90(mask),cmap,[0,0,0],[]);
end

f = figure;
f.Position = [100,100,1200,800];
imagesc(img);
axis equal;
axis tight;
axis off;
custom_colorbar(val_range(1),val_range(2),0,cmap,12);
err = err(ind);
custom_colorbar(min(err(:)),max(err(:)),0,cmap,12);