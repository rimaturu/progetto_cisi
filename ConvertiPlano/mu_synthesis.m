%% mu-synthesis
close all
clc

%% paramtri sistema
% Definizione parametri convertiplano %
J = 5000;
m = 2000;
b = ureal('b',150,'Percentage',[-5,5]);
beta=ureal('beta',15,'Percentage',[-5,5]);
l = 10;

g = 9.81;

%params_plano = [J, m, b, beta, l, g];

% Definizione parametri attuatori %
Km1 = 500;
Km2 = 100;
T1 = 0.5;
%params_attuatori.T1=ureal('T1',0.1,'Percentage',[-5,5]);
T2 = 0.5;
%params_attuatori.T2=ureal('T2',0.2,'Percentage',[-5,5]);
Tm1 = 5;
Tm2 = 5;

%params_attuatori = [Km1, Km2, T1, T2, Tm1, Tm2];

%% Definisco il sistema linearizzato nel PE
% PE = (0,0,0,0)  %(x,x_d,theta,theta_d)

A = [0   1  0    0;... 
     0 -b/m 0    0;...
     0   0  0    1;...
     0   0  0 -beta/J];

B = [ 0    0;...
     1/m   0;...
      0    0;...
      0  2*l/J];

C = [1 0 0 0;...
     0 0 1 0];

D = zeros(2);

% trovo fdt nominale del linearizzato

sys_n = ss(A,B,C,D);

[P,Delta_G,Blkstruct]=lftdata(sys_n);

G_P = zpk(P);


%% Definisco le fdt degli attuatori nominali (senza tempo di ritardo) e perturbate
s = tf('s');

Gm1_n = Km1/(Tm1*s+1);
Gm1_p = Km1/(Tm1*s+1)*exp(-T1*s);
Gm2_n = Km2/(Tm2*s+1);
Gm2_p = Km2/(Tm2*s+1)*exp(-T2*s);

reldiff1 = (Gm1_p-Gm1_n)/Gm1_n;
reldiff2 = (Gm2_p-Gm2_n)/Gm2_n;

% ricavo i pesi Wi degli attuatori
Wi1 = makeweight(10^-4,1,2.5);
Wi2 = makeweight(10^-4,1,2.5);
%Wi1 = 0.003*5*10^4*(s+0.03)/(s+15);
%Wi2 = 0.012*10^4*(s+0.03)/(s+15)^2;

% figure(1)
% hold on
% grid on
% bodemag(reldiff1,Wi1)
% hold off
% 
% figure(2)
% hold on
% grid on
% bodemag(reldiff2,Wi2)
% hold off

% creo la upper lft degli attuatori

P_att = [0 0 Wi1*Gm1_n 0; 0 0 0 Wi2*Gm2_n;1 0 Gm1_n 0; 0 1 0 Gm2_n];

Delta_att1 = ultidyn('Delta_att1',[1 1]);
Delta_att2 = ultidyn('Delta_att2',[1 1]);
Delta_att = [Delta_att1 0; 0 Delta_att2];

%% definisco il peso Wp di prestazione
A1=1e-4;
M1=2;
wB1=0.1;
A2=1e-4;
M2=2;
wB2=0.13;
wP1=makeweight(1/A1,wB1,1/M2);
wP2=makeweight(1/A2,wB2,1/M2);
WP=blkdiag(wP1,wP2); %matrice peso s

%% creo il sistema con connect

G_P.u = {'uD1','uD2','u_G_P1','u_G_P2'};
G_P.y = {'yD1','yD2','y_G_P1','y_G_P2'};

P_att.u = {'ud1','ud2','u_P_att1','u_P_att2'};
P_att.y = {'yd1','yd2','y_P_att1','y_P_att2'};

WP.u = {'e1','e2'};
WP.y = {'z1','z2'};

Sum1 = sumblk ('u_P_att1 = -u1');
Sum2 = sumblk ('u_P_att2 = -u2');
Sum3 = sumblk ('e1 = w1  + y_G_P1');
Sum4 = sumblk ('e2 = w2  + y_G_P2');
Sum5 = sumblk ('u_G_P1 = y_P_att1');
Sum6 = sumblk ('u_G_P2 = y_P_att2');


P = connect (G_P,P_att,WP,Sum1,Sum2,Sum3,Sum4,Sum5,Sum6,{'ud1','ud2','uD1','uD2','w1','w2','u1','u2'},{'yd1','yd2','yD1','yD2','z1','z2','e1','e2'});

Delta = [ Delta_att,  zeros(2) ; zeros(2) , Delta_G];

P_dist = lft(Delta,P);

[K_DK,CLperf,info] = musyn(P_dist,2,2);

K_DK = minreal(zpk(tf(K_DK)),0.5);

K_DK = [K_DK(1,1) 0; 0 K_DK(2,2)];

%bodemag(K_DK)




