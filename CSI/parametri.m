clear
close all
clc

m11 = 19;   %[kg]
m22 = 35;   %[kg]
m33 = 4;   %[kg]

d11 = 3;    %[kg/s]
d22 = 10;    %[kg/s]
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
T1 = 1;

%% sensors

gps_var = 10;
heading_var = 1;
R_k = blkdiag(gps_var, gps_var, heading_var);
f_s = 100;

%%
P_E = [1, 0 ,0 ,0];     %[u, v, r, phi]
u = P_E(1);
v = P_E(2);
r = P_E(3);
phi = P_E(4);

A = [-(d11/m11),            (m22/m11)*r,            (m22/m11)*v,        0;
     -(m11/m22)*r,          -(d22/m22),             -(m11/m22)*u,       0;
     ((m11 - m22)/m33)*v,   ((m11 - m22)/m33)*u,    -(d33/m33),         0;
            0,                      0,                  1,              0];

B = [(1/m11),   0;
    0   ,       0;  
    0   , (1/m33);
    0   ,      0];

C = [cos(phi),  -sin(phi),  0,  -u*sin(phi) - v*cos(phi);
     sin(phi),   cos(phi),  0,   u*cos(phi) - v*sin(phi);
        0,          0,      1,              0];

D = [0,0;0,0;0,0];



% Conversione in matrice di trasferimento MIMO
sys_mimo = ss(A, B, C, D);

% Creazione della matrice di trasferimento MIMO
H_mimo = tf(sys_mimo);


