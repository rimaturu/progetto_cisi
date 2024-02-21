%% mu-synthesis
close all
clc

s = tf('s');

%% Definisco il sistema linearizzato 
% Linearizzazione sistema convertiplano intorno al punto z = theta = 0 (punto di equilibrio) %

A_nom = [-b_i/m_i,           0,            0,                   0;
            0,         -beta_i/J_i,        0,                   0;
            1,               0,            0,                   0;
            0,               1,            0,                   0];

B_nom = [1/m_i,               0;
           0,             2*l_i/J_i;
           0,                 0;
           0,                 0];


C_nom = [0,     0,      1,      0;
         0,     0,      0,      1];
    
D_nom = [0, 0;
         0, 0];

% Trovo matrice di trasferimento del linearizzato
G = ss(A_nom,B_nom,C_nom,D_nom);

[G,Delta_G,Blkstruct]=lftdata(G); % Trovo matrice Delta_G associata ai parametri incerti

G = zpk(G);


%% Definisco le fdt degli attuatori nominali (senza tempo di ritardo) e quelle perturbate
% Calcolo dei pesi con l'utilizzo del sistema nominale e perturbato
Gm1_n = Km1/(Tm1_i*s+1);
Gm1_p = Km1/(Tm1_i*s+1)*exp(-T1_i*s);
Gm2_n = Km2/(Tm2_i*s+1);
Gm2_p = Km2/(Tm2_i*s+1)*exp(-T2_i*s);

reldiff1 = (Gm1_p-Gm1_n)/Gm1_n;
reldiff2 = (Gm2_p-Gm2_n)/Gm2_n;

% Ricavo i pesi W degli attuatori per ispezione dei reldiff
W1 = makeweight(10e-4, 1, 2.5);
W2 = makeweight(10e-4, 1, 2.5);

% figure(1)
% hold on
% grid on
% bodemag(reldiff1,W1)
% hold off
% 
% figure(2)
% hold on
% grid on
% bodemag(reldiff2,W2)
% hold off

% Ricavo la P_att (con il metodo visto a lezione)
P_att = [0      0       W1*Gm1_n       0; 
         0      0          0       W2*Gm2_n;
         1      0        Gm1_n         0; 
         0      1          0         Gm2_n];

% Definisco la matrice di incertezza strutturata degli attuatori
Delta_att1 = ultidyn('Delta_att1',[1 1]);
Delta_att2 = ultidyn('Delta_att2',[1 1]);
Delta_att = [Delta_att1 0; 0 Delta_att2];

%% definisco il peso Wp di prestazione
A1=1e-4;
M1=2;
wB1=0.3;

A2=1e-4;
M2=2;
wB2=0.3;

wP1=makeweight(1/A1,wB1,1/M1);
wP2=makeweight(1/A2,wB2,1/M2);

WP=blkdiag(wP1,wP2); %matrice peso s

%% Creo il sistema P con connect

G.u = {'uD1','uD2','u_G1','u_G2'};
G.y = {'yD1','yD2','y_G1','y_G2'};

P_att.u = {'ud1','ud2','u_att1','u_att2'};
P_att.y = {'yd1','yd2','y_att1','y_att2'};

WP.u = {'e1','e2'};
WP.y = {'z1','z2'};

Sum1 = sumblk ('u_att1 = -u1');
Sum2 = sumblk ('u_att2 = -u2');
Sum3 = sumblk ('e1 = w1  + y_G1');
Sum4 = sumblk ('e2 = w2  + y_G2');
Sum5 = sumblk ('u_G1 = y_att1');
Sum6 = sumblk ('u_G2 = y_att2');


P = connect (G,P_att,WP,Sum1,Sum2,Sum3,Sum4,Sum5,Sum6,{'ud1','ud2','uD1','uD2','w1','w2','u1','u2'},{'yd1','yd2','yD1','yD2','z1','z2','e1','e2'});

Delta = [Delta_att,  zeros(2) ; zeros(2) , Delta_G];

P_delta = lft(Delta,P);

% Calcolo Controllore Mu-Synthesis %
[K_DK,CLperf,info] = musyn(P_delta,2,2);

% Riduco ordine del controllore
K_DK = minreal(zpk(tf(K_DK)),1e-1);
% Tolgo termini non diagonali (guadagni dell'ordine 10e-10!)
K_DK = [zpk(K_DK(1,1)) 0; 0 zpk(K_DK(2,2))];



