function output = phase_temporal_adjoint(img)

%Takes an ny x nz x ne array and returns ordinary least squares fit for
%phase at each voxel. Output size is ny x nz x 2; first element of third dimension
%is initial phase, second is phase slope. 

[ny,nz,ne] = size(img);
img = reshape(img,ny*nz,ne)';
A = [ones(8,1),(0:7)'];
M = (A'*A)\A';
beta = M*img;
output = reshape(beta',ny,nz,2);
end