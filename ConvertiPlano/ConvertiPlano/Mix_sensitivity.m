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
params_attuatori.Km1 = 1000;
params_attuatori.Km2 = 100;
params_attuatori.T1 = 0.5;
params_attuatori.T2 = 0.5;
params_attuatori.Tm1 = 10;
params_attuatori.Tm2 = 10;


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


wU=tf(1);
WU=blkdiag(wU,wU); %matrice peso ks
A1=1e-4;
M1=1.5;
wB1=0.3;
A2=1e-4;
M2=1.5;
wB2=0.5;
wP1=makeweight(1/A1,wB1,1/M2);
wP2=makeweight(1/A2,wB2,1/M2);
WP=blkdiag(wP1,wP2); %matrice peso s
wT = (s+1)/2/(0.001*s+1);
WT = [wT 0;0 wT];

[K_ms,CL_ms,GAM_ms,~] = mixsyn(G_tot_n,WP,WU,WT); 

K_ms = minreal(zpk(tf(K_ms)),1e-1);

K_ms = [K_ms(1,1) 0; 0 K_ms(2,2)];

S = inv(eye(2) + G_tot_n*K_ms);

KS =K_ms*S;

T = eye(2) - S;
% 
% bodemag(S(1,1),1/wP1)
% 
% bodemag(S(2,2),1/wP2)
% 
% bodemag(KS(1,1),1/wU)
% 
% bodemag(KS(2,2),1/wU)
% 
% bodemag(T(1,1),1/wT)
% 
% bodemag(T(2,2),1/wT)

step(T(1,1))

%% controllo H-inf

G_tot_n.u = {'uG1','uG2'};
G_tot_n.y = {'yG1','yG2'};

WP.u = {'e1','e2'};
WP.y = {'zp1','zp2'};

WT.u = {'yG1','yG2'};
WT.y = {'zt1','zt2'};

WU.u = {'uG1','uG2'};
WU.y = {'zu1','zu2'};

Sum1 = sumblk ('e1 = yG1 + w1');
Sum2 = sumblk ('e2 = yG2 + w2');
Sum3 = sumblk ('ek1 = -e1');
Sum4 = sumblk ('ek2 = -e2');

P_hinf = connect(G_tot_n,WP,WT,WU,Sum1,Sum2,Sum3,Sum4,{'w1','w2','uG1','uG2'},{'zp1','zp2','zt1','zt2','zu1','zu2','ek1','ek2'});

[K_hinf,CL_hinf,GAM_hinf] = hinfsyn(P_hinf,2,2);

K_hinf = minreal(zpk(tf(K_hinf)),1e-1);

K_hinf = [K_hinf(1,1) 0; 0 K_hinf(2,2)];



