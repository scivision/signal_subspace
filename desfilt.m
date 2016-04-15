fs=48e3;
L=72; %number of taps
f = [0 0.2 0.3 0.7 0.8 1];
a = [0 0.0 1.0 1.0  0.0 0];
b = remez(L,f,a);


figure(1); clf(1)
[h,w] = freqz(b,1,512);
hold on
plot(f*fs/2,a)
plot(w/pi*fs/2,abs(h))
set(gca,'ylim',[0,1.5])
set(gca,'xlim',[0,fs/2])
legend('Ideal','Remez Design')
title(['FIR Filter Design, L=',int2str(L)])
