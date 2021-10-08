clear all;
close all;
clc;

load('../../data/te_images.mat');
im = squeeze(im(73:172,60:159,32,:));
[s1,s2,s3] = size(im);
a = angle(reshape(im,s1*s2,8))';
a_unwrapped = unwrap(a,[],1);

A = [1:8;ones(1,8)]';
AtA = A'*A;
AtA_inv = inv(AtA);
lsq_fit = (AtA_inv*A')*a_unwrapped;
a_hat = A*lsq_fit;
SS_residuals = sum((a_unwrapped - a_hat).^2,1); 
SS_total = sum((a_unwrapped - mean(a_unwrapped,1)).^2,1);
R_sq = 1 - SS_residuals./SS_total;

complex_plot(im(:,:,1));

figure();
subplot(1,2,1);
plot(a);
title('Wrapped phase over ROI');
xlabel('Echo number');
ylabel('Phase');
subplot(1,2,2);
plot(a_unwrapped);
title('Unwrapped phase over ROI');
xlabel('Echo number');
ylabel('Phase');

figure();
hold on;
for i = 1:10
    plot(a_unwrapped(:,i),'ro');
    plot(a_hat(:,i),'b-');
end
title('Sample linear phase fits')
xlabel('Echo number');
ylabel('Phase');
legend('Data','Linear Model','location','NorthEast');

figure();
histogram(R_sq);
xlabel('R^{2}');
ylabel('Count');
title({'R^{2} histogram for linear phase model over ROI';['Median R^{2} value: ',num2str(median(R_sq))]});