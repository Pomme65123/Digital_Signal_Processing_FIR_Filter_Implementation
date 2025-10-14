clear all;close all;clc;

fs=13000; 

a=4;
b=[1 1 1 1];
c=2^12;
[h,f]=freqz(b,a,c,fs);
plot(f,abs(h),'b-','LineWidth',2)
grid on
title('FIR Filter frequency response')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
axis([0 fs/2 0 1])
hold off