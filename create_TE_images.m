clear all;
close all;
clc;
addpath('~/Desktop/NIfTI_20140122');
nii_mag = load_untouch_nii('~/Desktop/data/AXL_QSM_QSM_MONO_8TE_IPAT2_6_8phpf_NoFC_20111019141126_3_e1.nii');
nii_ph =  load_untouch_nii('~/Desktop/data/AXL_QSM_QSM_MONO_8TE_IPAT2_6_8phpf_NoFC_20111019141126_4_e1_ph.nii');
mag = double(nii_mag.img);
ph = double(nii_ph.img);
mag = (mag - min(mag(:)))/(max(mag(:)) - min(mag(:)));
delta = 1/(1+max(ph(:)));
m = (2*pi - delta)/(max(ph(:)) - min(ph(:)));
b = -1.0*pi - m*min(ph(:));
ph = m*ph + b;
im = mag.*exp(1j*ph);
save('teims.mat','im');