% Definizione dei parametri
% syms s; % Variabile complessa di Laplace
% syms a11 a12 a13 a14 a21 a22 a23 a24 a31 a32 a33 a34 a41 a42 a43 a44 real; % Parametri di A
% syms b11 b12 b21 b22 b31 b32 b41 b42 real; % Parametri di B
% syms c11 c12 c13 c14 c21 c22 c23 c24 c31 c32 c33 c34 real; % Parametri di C
% syms d11 d12 d21 d22 real; % Parametri di D
% 
% % Definizione delle matrici
% A = [a11 a12 a13 0; a21 a22 a23 0; a31 a32 a33 0; 0 0 1 0];
% B = [b11 0; 0 0; 0 b32; 0 0];
% C = [c11 c12 0 c14; c21 c22 0 c24; 0 0 1 0];
% 
% 
% % Calcolo di (sI - A)^(-1)
% inv_sIA = inv(s*eye(4) - A);
% 
% % Costruzione della matrice di trasferimento G(s)
% G_s = C * inv_sIA * B ;
% 
% % Visualizzazione della matrice di trasferimento
% pretty(G_s)

syms s; % Variabile complessa di Laplace
syms m11 m22 m33 d11 d22 d33 u cpsi spsi;


% Definizione delle matrici
A = [  -d11/m11           0             0       0;...
           0          -d22/m22      -m11/m22*u  0;...
           0       (m11-m22)/m33*u  -d33/m33    0;...
           0              0             1       0];

B = [1/m11  0;...
      0     0;...
      0   1/m33;...
      0     0];

C = [1 0 0 0;...
     0 1 0 u;...
     0 0 1 0];

% Calcolo di (sI - A)^(-1)
inv_sIA = inv(s*eye(4) - A);

% Costruzione della matrice di trasferimento G(s)
G_s = C * inv_sIA * B ;

% Visualizzazione della matrice di trasferimento
pretty(G_s)




