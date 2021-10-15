clear all;
close all;
clc;

ksp_file = 'ksp_temp';
sens_file = 'sens_maps_256_256_8';
bas_file = 'temporal_basis_1e-1ms_2000ms_ETL_8';
K = 8;
n_iterations = 10;
lambda = 0.01;

[~] = reconstruction(ksp_file,'mask_acc_1',sens_file,bas_file,K,n_iterations,lambda,'recon_acc_1.mat');
[~] = reconstruction(ksp_file,'mask_acc_2',sens_file,bas_file,K,n_iterations,lambda,'recon_acc_2.mat');
[~] = reconstruction(ksp_file,'mask_acc_4',sens_file,bas_file,K,n_iterations,lambda,'recon_acc_4.mat');
[~] = reconstruction(ksp_file,'mask_acc_6',sens_file,bas_file,K,n_iterations,lambda,'recon_acc_6.mat');
[~] = reconstruction(ksp_file,'mask_acc_8',sens_file,bas_file,K,n_iterations,lambda,'recon_acc_8.mat');
[~] = reconstruction(ksp_file,'mask_acc_10',sens_file,bas_file,K,n_iterations,lambda,'recon_acc_10.mat');