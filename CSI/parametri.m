clear
close all
clc

s = tf('s');

m11_nom = 19;   %[kg]
m22_nom = 35;   %[kg]
m33_nom = 4;    %[kg]

d11_nom = 3;    %[kg/s]
d22_nom = 10;   %[kg/s]
d33_nom = 1;    %[kg/s]

params_nom = [m11_nom, m22_nom, m33_nom, d11_nom, d22_nom, d33_nom];

m11 = ureal('m11', m11_nom, 'Percentage', [-10, 10]);
m22 = 35;   %[kg]
m33 = 4;   %[kg]

d11 = 3;    %[kg/s]
d22 = ureal('d22', d22_nom, 'Percentage', [-10, 10]);
d33 = 1;    %[kg/s]

params = [m11, m22, m33, d11, d22, d33];

% Condizioni iniziali
tau_u_0 = 0;
tau_r_0 = 0;

u_0 = 0;
v_0 = 0;
r_0 = 0;

x_0 = 0;
y_0 = 0;
phi_0 = 0;

x_hat_0 = [u_0; v_0; r_0; phi_0];

P0 = zeros(4,4);

% TODO
Km1 = 1;
Km2 = 1;
Tm1 = 1;
Tm2 = 1;
T1_nom = 1;
T1 = ureal('T1', T1_nom, 'Percentage', [-5,5]);

%% sensors

gps_var = 10;
heading_var = 1;
R_k = blkdiag(gps_var, gps_var, heading_var);
f_s = 100;

%% Mixed Sensitivity
P_E = [1, 0 ,0 ,0];     %[u, v, r, phi]
u = P_E(1);
v = P_E(2);
r = P_E(3);
phi = P_E(4);

% Modello stato incerto
A = [-(d11/m11),            (m22/m11)*r,            (m22/m11)*v,        0;
     -(m11/m22)*r,          -(d22/m22),             -(m11/m22)*u,       0;
     ((m11 - m22)/m33)*v,   ((m11 - m22)/m33)*u,    -(d33/m33),         0;
            0,                      0,                  1,              0];

B = [(1/m11),   0;
    0   ,       0;  
    0   , (1/m33);
    0   ,      0];

C = [cos(phi),  -sin(phi),  0,  -u*sin(phi) - v*cos(phi);
     sin(phi),   cos(phi),  0,   u*cos(phi) - v*sin(phi)];

D = [0,0;0,0];

% Modello stato nominale
A_nom = [-(d11_nom/m11_nom),                (m22_nom/m11_nom)*r,                (m22_nom/m11_nom)*v,        0;
         -(m11_nom/m22_nom)*r,              -(d22_nom/m22_nom),                 -(m11_nom/m22_nom)*u,       0;
         ((m11_nom - m22_nom)/m33_nom)*v,   ((m11_nom - m22_nom)/m33_nom)*u,    -(d33_nom/m33_nom),         0;
                0,                                         0,                               1,              0];

B_nom = [(1/m11_nom),   0;
        0   ,           0;  
        0   , (1/m33_nom);
        0   ,          0];

C_nom = [cos(phi),  -sin(phi),  0,  -u*sin(phi) - v*cos(phi);
         sin(phi),   cos(phi),  0,   u*cos(phi) - v*sin(phi)];

D_nom = [0,0;0,0];


% Conversione in matrice di trasferimento MIMO
sys_mimo = ss(A, B, C, D);
sys_mimo_nom = ss(A_nom, B_nom, C_nom, D_nom);

% Creazione della matrice di trasferimento MIMO
simplify(sys_mimo, "full");
simplify(sys_mimo_nom, "full");

% H_mimo = tf(sys_mimo);
% H_mimo_nom = tf(sys_mimo_nom);
% 
% % Poli e Zeri 
% Poli_MIMO = pole(H_mimo_nom);
% Zeri_MIMO = tzero(H_mimo_nom);  % trasmission zero

Gs_rand = usample(sys_mimo, 100);
bodemag(Gs_rand);

% % Calcolo matrici di peso
% wu = 1;
% WU = blkdiag(wu, wu);       % Matrice peso per KS
% 
% A = 1e-2;
% M = 1;
% wB1 = 1;
% wB2 = 1;
% 
% % wP = (s/M+wB1)/(s+wB1*A);
% wP1 = makeweight(1/A, [0.01, (0.01/M+wB1)/(0.01+wB1*A)], 1/M);    
% wP2 = makeweight(1/A, [0.01, (0.01/M+wB1)/(0.01+wB1*A)], 1/M);
% 
% WP = blkdiag(wP1, wP2);     % Matrice peso per S
% 
% % Sintesi Controllore
% [K1_real, CLaug1, GAM1, ~] = mixsyn(H_mimo, [], [], []);
% 
% K1_real = zpk(K1_real);
% 
% K1 = minreal(K1_real);

%% Attuators
% tau_u attuator
G_u = Km1/(Tm1*s+1)/(T1*s+1);
G_u = tf(G_u);

% tau_v attuator
G_v = Km2/(Tm2*s+1)/(Tm2/100*s+1);
G_v = tf(G_v);

G_att = [G_u 0;0 G_v];

%%

G_tot = H_mimo * G_att;

[P,delta,struct] = lftdata(G_tot);




