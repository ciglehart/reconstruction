function rgb = rgb_image(img,mask,cmap,null_color,val_range)

ind = find(mask>0);
vals = img(ind);

if isempty(val_range)
    min_val = min(vals(:));
    max_val = max(vals(:));
else
    min_val = val_range(1);
    max_val = val_range(2);
end

rgb = zeros(1,1,3);
rgb(1,1,:) = null_color;
rgb = repmat(rgb,size(img,1),size(img,2));

N = size(cmap,1);
m = (N-1)/(max_val - min_val);
b = 1 - m*min_val;

for ii = 1:size(img,1)
    for jj = 1:size(img,2)
        if mask(ii,jj)>0
            rgb(ii,jj,:) = cmap(round(m*img(ii,jj)+b),:);
        end
    end
end

end