%% Mix sensitivity
close all
clc

%% Definisco il sistema linearizzato nel PE
% PE = (0,0,0,0)  %(z,z_d,theta,theta_d)

A_nom = [-b/m,           0,          0,                   0;
            0,       -beta/J,        0,                   0;
            1,           0,          0,                   0;
            0,           1,          0,                   0];

B_nom = [1/m,                 0;
           0,             2*l/J;
           0,                 0;
           0,                 0];


C_nom = [0,     0,      1,      0;
         0,     0,      0,      1];
    
D_nom = [0, 0;
         0, 0];

% trovo fdt nominale del linearizzato

G_n = ss(A_nom,B_nom,C_nom,D_nom);

G_n = zpk(G_n);

%% Definisco le fdt degli attuatori nominali (senza tempo di ritardo)
s = tf('s');

Gm1_n = Km1/(Tm1*s+1);
Gm2_n = Km2/(Tm2*s+1);

G_attuators_n = [Gm1_n, 0; 0, Gm2_n];

%% Trovo fdt totale del sistema

G_tot_n = G_n*G_attuators_n;
%bodemag (G_tot_n)

%% Trovo controllore Mix sensitivity

wU=tf(1);
WU=blkdiag(wU,wU); %matrice peso ks

A1=1e-4;
M1=2;
wB1=0.09;
A2=1e-4;
M2=2;
wB2=0.2;

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


