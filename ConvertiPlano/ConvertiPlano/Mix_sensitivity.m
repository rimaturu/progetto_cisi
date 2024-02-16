%% Mix sensitivity
clear
close all
clc

%% paramtri sistema
% Definizione parametri convertiplano %
params_plano.J = 5000;
params_plano.m = 2000;
params_plano.b = 150;
params_plano.beta = 15;
params_plano.l = 10;

params_plano.g = 9.81;

% Definizione parametri attuatori %
params_attuatori.Km1 = 10;
params_attuatori.Km2 = 20;
params_attuatori.T1 = 0.1;
params_attuatori.T2 = 0.2;
params_attuatori.Tm1 = 5;
params_attuatori.Tm2 = 5;


%% Definisco il sistema linearizzato nel PE
% PE = (0,0,0,0)  %(x,x_d,theta,theta_d)

A = [0 1 0 0; 0 -params_plano.b/params_plano.m 0 0; 0 0 0 1; 0 0 0 -params_plano.beta/params_plano.J];

B = [0 0; 1 0; 0 0; 0 2*params_plano.l];

C = [1 0 0 0; 0 0 1 0];

D = zeros(2);

% trovo fdt nominale del linearizzato

sys_n = ss(A,B,C,D);

G_n = zpk(sys_n);

%% Definisco le fdt degli attuatori nominali (senza tempo di ritardo)
s = tf('s');

Gm1_n = params_attuatori.Km1/(params_attuatori.Tm1*s+1);
Gm2_n = params_attuatori.Km2/(params_attuatori.Tm2*s+1);

G_attuators_n = [Gm1_n, 0; 0, Gm2_n];

%% Trovo fdt totale del sistema

G_tot_n = G_n*G_attuators_n;
%bodemag (G_tot_n)

%% Trovo controllore Mix sensitivity


wU=1;
WU=blkdiag(wU,wU); %matrice peso ks
A=1e-4;
M=1.5;
wB1=0.1;
wB2=0.01;
wP1=makeweight(1/A,wB1,1/M);
wP2=makeweight(1/A,wB2,1/M);
WP=blkdiag(wP1,wP2); %matrice peso s
WT = eye(2)-WP;

[K,CLaug,GAM,~] = mixsyn(G_tot_n,WP,WU,WT); 

K = minreal(zpk(tf(K)),1e-2);

S = inv(eye(2) + G_tot_n*K);

T = eye(2) - S;

%% mu-analisys




