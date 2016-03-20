function matSubspace()
f0=12345.6;
fs=48e3;
snr=60;
Ntone=1;
Ns=1024;
m = Ns/2; % Ns/2 >= m > 1 
%% generate noisy sinusoid
x = signoise(fs,f0,snr,Ns);
%% Subspace
[fest,sigma] = rootmusic(x,Ntone,fs);
format long
disp(fest)
end

function x = signoise(fs,f0,snr,Ns)
% generates noisy signal
t = (0:Ns-1)/fs;

x= sqrt(2)* exp(1j*2*pi*f0*t);

nvar = 10^(-snr/10);

noise = randn(1,Ns) + 1j*randn(1,Ns);

x = x + sqrt(nvar)*noise;

end