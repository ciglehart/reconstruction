function output = show_results(filename,threshold)
nE = 8;
load('brain_mask');
load('teImages');
truth = unwrap(angle(squeeze(im(:,:,32,:))),[],3);
load(filename);
recon = unwrap(im,[],3);

err = 1-cos(recon-truth);
err(abs(err)>threshold) = threshold;

img = zeros(768,1024,3);
cmap = parula(256);

ind = find(repmat(mask,1,1,nE)>0);
truth_vals = truth(ind);
recon_vals = recon(ind);
val_range = [min([min(truth_vals(:)),min(recon_vals(:))]),max([max(truth_vals(:)),max(recon_vals(:))])];

for i = 1:nE
    img(1:256,((i-1)*256 + 1):256*i,:) = rgb_image(rot90(truth(:,:,i)),rot90(mask),cmap,[0,0,0],val_range);
    img(257:512,((i-1)*256 + 1):256*i,:) = rgb_image(rot90(recon(:,:,i)),rot90(mask),cmap,[0,0,0],val_range);
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
end