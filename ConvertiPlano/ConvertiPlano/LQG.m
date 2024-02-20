%% Controllo LQG %%
clear
close all
clc

%% paramtri sistema
% Definizione parametri convertiplano %
J = 5000;
m = 2000;
b = 150;
beta = 15;
l = 10;

g = 9.81;

params_plano = [J, m, b, beta, l, g];

% Definizione parametri attuatori %
Km1 = 500;
Km2 = 100;
T1 = 0.5;
T2 = 0.5;
Tm1 = 5;
Tm2 = 5;

params_attuatori = [Km1, Km2, T1, T2, Tm1, Tm2];


% Condizioni iniziali %
F_0 = [0; 0];

dq_0 = [0; 0];
q_0 = [2; -pi/18];

%% 
s = tf('s');

% Linearizzazione sistema convertiplano intorno al punto z = theta = 0 %
A_nom = [0 1 0 0; ...
         0 -b/m 0 0; ...
         0 0 0 1; ...
         0 0 0 -beta/J];

B_nom = [0     0   ; ...
         1/m   0   ; ...
         0     0   ; ...
         0   2*l/J];

C_nom = [1 0 0 0; ...
         0 0 1 0];

D_nom = zeros(2);

% Creazione sistemi attuatori in forma di stato
G1 = tf([Km1], [Tm1 1]) * exp(-s*T1);
G2 = tf([Km2], [Tm2 1]) * exp(-s*T2);
G_att = blkdiag(G1, G2);

G_att = ss(G_att);

A_att = G_att.A;
B_att = G_att.B;
C_att = G_att.C;
D_att = G_att.D;

% Composizione in serie del sistema dinamico e degli attuatori (forma di
% stato)
A_tot = [      A_att,         zeros(2,4);
            B_nom*C_att,         A_nom   ];

B_tot = [B_att;  B_nom*D_att];

C_tot = [D_nom*C_att,   C_nom];

D_tot = [0, 0;
         0, 0];

G = ss(A_tot, B_tot, C_tot, D_tot);

% Definisco le matrici di covarianza dei rumori in ingresso e dei sensori
dev_std_fm = 100;
dev_std_fa = 10;
dev_std_z = 1;
dev_std_theta = 0.3;

% Matrice covarianza rumori in ingresso (gli errori di processo sono
% riferiti solo alle equazioni di z: e theta:)
Q = blkdiag(0, 0, 0, dev_std_fm ^ 2, 0, dev_std_fa ^ 2);

% Matrice covarianza errori di misura (y1 = z; y2 = theta)
R = blkdiag(dev_std_z ^ 2, dev_std_theta ^ 2);

% Big matricione di covarianza
QWV = blkdiag(Q, R);

% Matrice di peso per stati e ingressi, dove pesiamo solo gli ingressi e
% gli stati z e theta
Q_pesi = blkdiag(zeros(2), 1, 0, 1, 0, eye(2));

% lqg(sistema in forma di stato,
%     pesi per stato e ingressi,
%     matrici di covarianza)
[reg, info] = lqg(G, Q_pesi, QWV);

% Guadagno LQR %
Kc = - info.Kx;

% Guadagno filtro di Kalman %
Kf = info.L;

% Matrici di peso per stati (stati + stati da integrare) e ingressi
% Vado a pesare solo z, theta (2 volte sia per stato stimato che stato integrato)e i 2 ingressi
Q_z = blkdiag(zeros(2), 1, 0, 1, 0, 1, 0.001);
R_u = eye(2);

% Calcolo del guadagno del controllore con integratori
Kc_int = -lqi(G, Q_z, R_u);


%% Calcolo pesi per mix-sensitivity

% K_LQG = [A_tot + B_tot*Kc + Kf*C_tot,    Kf;
%                     Kc,                zeros(2)];

K_LQG = ss(A_tot + B_tot*Kc + Kf*C_tot, Kf, Kc, zeros(2));
K_LQG = zpk(K_LQG);

G = zpk(G);

% Parametri funzioni peso Wp %
A1=1e-4;
M1=2;
wB1=0.1;

A2=1e-4;
M2=2;
wB2=0.1;

wP1=makeweight(1/A1,wB1,1/M1);
wP2=makeweight(1/A2,wB2,1/M2);

% Confronto S e funzioni peso Wp %
S = 1/(eye(2) + G*K_LQG);

figure(1);
S_Wp1 = bodeplot(S(1,1), 1/wP1);
setoptions(S_Wp1, 'PhaseVisible','off');
legend('S(1,1)', '1/wp1');

figure(2);
S_Wp2 = bodeplot(S(2,2), 1/wP2);
setoptions(S_Wp2, 'PhaseVisible','off');
legend('S(2,2)', '1/wp2');
