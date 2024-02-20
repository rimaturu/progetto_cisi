%% Mix sensitivity
close all
clc

s = tf('s');

%% Definisco il sistema linearizzato e scelta modello nominale
% Linearizzazione sistema convertiplano intorno al punto z = theta = 0 (punto di equilibrio) %

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

% Definisco la matrice di trasferimento nominale del convertiplano %
G_n = ss(A_nom,B_nom,C_nom,D_nom);
G_n = zpk(G_n);

% Definisco le fdt degli attuatori nominali (trascuro tempo di ritardo)
Gm1_n = Km1/(Tm1*s+1);
Gm2_n = Km2/(Tm2*s+1);

G_attuators_n = [Gm1_n, 0; 0, Gm2_n];

% Calcolo Matrice di trasferimento del sistema + attuatori (G_tot nominale)
G_tot_n = G_n*G_attuators_n;

%% Calcolo controllore Mix sensitivity

% Modello i pesi WU, WP, WT %

wU=tf(1);
WU=blkdiag(wU,wU); 

A1=1e-4;
M1=2;
wB1=0.16;
A2=1e-4;
M2=2;
wB2=0.16;

wP1 = makeweight(1/A1,wB1,1/M1);
wP2 = makeweight(1/A2,wB2,1/M2);
WP = blkdiag(wP1,wP2); 

wT1 = makeweight(1/M1,wB1,1/A1);
wT2 = makeweight(1/M2,wB2,1/A2);
WT = blkdiag(wT1,wT2);

% Calcolo Controllore Mix-Syn %
[K_ms,CL_ms,GAM_ms,~] = mixsyn(G_tot_n,WP,WU,WT); 

% Riduco ordine del controllore
% K_ms = minreal(zpk(tf(K_ms)),1e-1);
% Tolgo termini non diagonali (guadagni dell'ordine 10e-10!)
K_ms = [K_ms(1,1) 0; 0 K_ms(2,2)];

% Calcolo delle matrici S, T, KS %
S = inv(eye(2) + G_tot_n*K_ms);
KS =K_ms*S;
T = eye(2) - S;

bodemag(S(1,1),1/wP1)

bodemag(S(2,2),1/wP2)

bodemag(KS(1,1),1/wU)

bodemag(KS(2,2),1/wU)

bodemag(T(1,1),1/wT1)

bodemag(T(2,2),1/wT2)

% step(T(1,1))

%% Calcolo controllore H-inf

% Definisco ingressi e uscite blocchi sistema per connect %
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

% Calcolo della matrice P %
P_hinf = connect(G_tot_n,WP,WT,WU,Sum1,Sum2,Sum3,Sum4,{'w1','w2','uG1','uG2'},{'zp1','zp2','zt1','zt2','zu1','zu2','ek1','ek2'});

% Calcolo controllore H-Inf %
[K_hinf,CL_hinf,GAM_hinf] = hinfsyn(P_hinf,2,2);

% Riduco ordine del controllore
% K_hinf = minreal(zpk(tf(K_hinf)),1e-1);
% Tolgo termini non diagonali (guadagni dell'ordine 10e-10!)
K_hinf = [K_hinf(1,1) 0; 0 K_hinf(2,2)];


