function custom_colorbar(low,high,vertical,cmap,fontsize)

w = size(cmap,1);
h = round(w/15);
im = zeros(1,w,3);
im(1,:,:) = cmap;
im = repmat(im,h,1,1);
im(1,:,:) = zeros(1,w,3);
im(h,:,:) = zeros(1,w,3);
im(:,1,:) = zeros(h,1,3);
im(:,w,:) = zeros(h,1,3);
im(round(3*h/4):h,round(w/2),:) = zeros(1+h-round(3*h/4),1,3);

figure;
if vertical
    im = permute(im,[2,1,3]);
    imagesc(im);
    text(h+2.5,5,sprintf('%2.3f',high),'FontWeight','bold','FontSize',fontsize)
    text(h+2.5,w/2,sprintf('%2.3f',0.5*(high+low)),'FontWeight','bold','FontSize',fontsize)
    text(h+5,w-5,sprintf('%2.3f',low),'FontWeight','bold','FontSize',fontsize)
else
    imagesc(im);
    text(w-15,h+5,sprintf('%2.3f',high),'FontWeight','bold','FontSize',fontsize)
    text(w/2-7.5,h+5,sprintf('%2.3f',0.5*(high+low)),'FontWeight','bold','FontSize',fontsize)
    text(0,h+5,sprintf('%2.3f',low),'FontWeight','bold','FontSize',fontsize)
end

axis equal;
axis off;

end