clear all;
close all;
clc;

n_iterations = 5;
lambda = 0.01;

%[~] = run_recon_siemens(lambda,n_iterations,'mask_acc_1','recon_lambda_1e-2_acc_1.mat');
[~] = run_recon_siemens(lambda,n_iterations,'mask_acc_2','recon_lambda_1e-2_acc_2.mat');
[~] = run_recon_siemens(lambda,n_iterations,'mask_acc_4','recon_lambda_1e-2_acc_4.mat');
[~] = run_recon_siemens(lambda,n_iterations,'mask_acc_6','recon_lambda_1e-2_acc_6.mat');
[~] = run_recon_siemens(lambda,n_iterations,'mask_acc_8','recon_lambda_1e-2_acc_8.mat');
[~] = run_recon_siemens(lambda,n_iterations,'mask_acc_10','recon_lambda_1e-2_acc_10.mat');

