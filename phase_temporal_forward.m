function output = phase_temporal_forward(beta,n_echoes)

output = zeros(size(beta,1),size(beta,2),n_echoes);

t = zeros(1,1,n_echoes);
t(1,1,:) = 0:(n_echoes-1);
t = repmat(t,size(beta,1),size(beta,2),1);
output = repmat(squeeze(beta(:,:,1)),1,1,n_echoes) + repmat(squeeze(beta(:,:,2)),1,1,n_echoes).*t;

end


