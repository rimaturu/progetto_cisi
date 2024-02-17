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
q_0 = [0; 0];


%% Filtro EKF %%

x_hat = [dq_0; q_0];
P = eye(4);

dev_std_fm = 100;
dev_std_fa = 0;
dev_std_z = 1;
dev_std_theta = 0.3;

Q = blkdiag(dev_std_fm ^ 2, dev_std_fa ^ 2);
R = blkdiag(dev_std_z ^ 2, dev_std_theta ^ 2);

dt = 0.02;
t_EKF = 15;

k = 0;
x_EKF = x_hat;

for t = dt:dt:t_EKF
    
    k = k + 1;
    
    % prediction
        [x_hat, P] = predict_EKF(x_hat, P, Q, dt, F_0(1), F_0(2), params_plano);
    % correction
        [x_hat, P] = correct_EKF(x_hat, P, R);
        
        x_EKF = [x_EKF, x_hat];
end


%% 
s = tf('s');

% Linearizzazione sistema convertiplano intorno al punto z = theta = 0 %
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

% Matrice covarianza rumori in inngresso (gli errori di processo sono
% riferiti solo alle equazioni di z: e theta:)
Q = blkdiag(0, 0, dev_std_fm ^ 2, dev_std_fa ^ 2, 0, 0);

% Matrice covarianza errori di misura (y1 = z; y2 = theta)
R = blkdiag(dev_std_z ^ 2, dev_std_theta ^ 2);

% Big matricione di covarianza
QWV = blkdiag(Q, R);

% Matrice di peso per stati e ingressi, dove pesiamo solo gli ingressi e
% gli stati z e theta
Q_pesi = blkdiag(zeros(4), eye(4));

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
Q_z = blkdiag(zeros(4), blkdiag(1,1,1,0.0001));
R_u = eye(2);

% Calcolo del guadagno del controllore con integratori
Kc_int = -lqi(G, Q_z, R_u);

% K_LQG = [A_tot + B_tot*Kc + Kf*C_tot,    Kf;
%                     Kc,                zeros(2)];


%% Calcolo pesi per mix-sensitivity

K_LQG = ss(A_tot + B_tot*Kc + Kf*C_tot, Kf, Kc, zeros(2));
K_LQG = zpk(K_LQG);

G = zpk(G);

S = 1/(eye(2) + G*K_LQG);
%bodemag(S);

T = G*K_LQG/(eye(2) + G*K_LQG);
%bodemag(T);


%% funzione EKF

function [x_hat, P] = predict_EKF(x_hat, P, Q, dt, f_m, f_a, params)
    
    dz = x_hat(1);
    dtheta = x_hat(2);
    z = x_hat(3);
    theta = x_hat(4);
    
    J = params(1);
    m = params(2);
    b = params(3);
    beta = params(4);
    l = params(5);

    g = params(6);
    
    F = [-b/m,          0,          0,          -f_m/m * sin(theta);
           0,       -beta/J,        0,                   0;
           1,           0,          0,                   0;
           0,           1,          0,                   0];

    D = [1/m * cos(theta),          0;
                 0,               2*l/J;
                 0,                 0;
                 0,                 0];
    
    F = dt .* F + eye(4);  
    D = dt .* D;

    x_hat = x_hat + dt * [-b/m * dz + f_m/m * cos(theta) - g;
                           -beta/J * dtheta + 2*l/J * f_a;
                                         dz;
                                       dtheta];

    P = F*P*F' + D*Q*D';

end


function [x_hat, P] = correct_EKF(x_hat, P, R)
    H = [0,     0,      1,      0;
         0,     0,      0,      1];

    M = [1 0
         0 1];
    
    y = [x_hat(3) + normrnd(0, R(1,1)^(1/2));
         x_hat(4) + normrnd(0, R(2,2)^(1/2))];
    
    y_hat = [x_hat(3);
             x_hat(4)];

    e = y - y_hat;
    S = H*P*H' + M*R*M';
    
    L = P*H'*S^(-1);
    x_hat = x_hat + L*e;
    P = (eye(4) - L*H)*P*(eye(4) - L*H)' + L*M*R*M'*L';
end
