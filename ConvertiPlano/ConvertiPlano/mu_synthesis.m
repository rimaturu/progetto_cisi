%% mu-synthesis
clear
close all
clc

%% paramtri sistema
% Definizione parametri convertiplano %
J = 5000;
m = 2000;
b = ureal('b',150,'Percentage',[-5,5]);
beta=ureal('beta',15,'Percentage',[-5,5]);
l = 10;

params_plano.g = 9.81;

% Definizione parametri attuatori %
Km1 = 500;
Km2 = 100;
T1 = 0.5;
%params_attuatori.T1=ureal('T1',0.1,'Percentage',[-5,5]);
T2 = 0.5;
%params_attuatori.T2=ureal('T2',0.2,'Percentage',[-5,5]);
Tm1 = 5;
Tm2 = 5;


%% Definisco il sistema linearizzato nel PE
% PE = (0,0,0,0)  %(x,x_d,theta,theta_d)

A = [0 1 0 0; 0 -b/m 0 0; 0 0 0 1; 0 0 0 -beta/J];

B = [0 0; 1 0; 0 0; 0 2*l];

C = [1 0 0 0; 0 0 1 0];

D = zeros(2);

% trovo fdt nominale del linearizzato

sys_n = ss(A,B,C,D);

[P,Delta_G,Blkstruct]=lftdata(sys_n);

G_P = zpk(P);


%% Definisco le fdt degli attuatori nominali (senza tempo di ritardo) e perturbate
s = tf('s');

[num1,den1] = pade(T1,4);
[num2,den2] = pade(T2,4);

pade1 = tf(num1,den1);
pade2 = tf(num2,den2);

Gm1_n = Km1/(Tm1*s+1);
Gm1_p = Km1/(Tm1*s+1)*pade1;
Gm2_n = Km2/(Tm2*s+1);
Gm2_p = Km2/(Tm2*s+1)*pade2;

reldiff1 = (Gm1_p-Gm1_n)/Gm1_n;
reldiff2 = (Gm2_p-Gm2_n)/Gm2_n;

% ricavo i pesi Wi degli attuatori
Wi1 = 0.003*5*10^4*(s+0.03)/(s+15)^2;
Wi2 = 0.012*10^4*(s+0.03)/(s+15)^2;

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
M1=1.001;
wB1=0.3;
A2=1e-4;
M2=1.001;
wB2=0.5;
wP1=makeweight(1/A1,wB1,1/M2);
wP2=makeweight(1/A2,wB2,1/M2);
WP=blkdiag(wP1,wP2); %matrice peso s

Delta_perf1 = ultidyn('Delta_perf1',[1 1]);
Delta_perf2 = ultidyn('Delta_perf2',[1 1]);
Delta_perf3 = ultidyn('Delta_perf2',[1 1]);
Delta_perf4 = ultidyn('Delta_perf2',[1 1]);
Delta_perf = [Delta_perf1 Delta_perf2; Delta_perf3 Delta_perf4];

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
Sum7 = sumblk ('ydp1 = z1');
Sum8 = sumblk ('ydp2 = z2');
Sum9 = sumblk ('w1 = udp1 + w11');
Sum10 = sumblk ('w2 = udp2 + w22');

P = connect (G_P,P_att,WP,Sum1,Sum2,Sum3,Sum4,Sum5,Sum6,Sum7,Sum8,Sum9,Sum10,{'ud1','ud2','uD1','uD2','udp1','udp2','w11','w22','u1','u2'},{'yd1','yd2','yD1','yD2','ydp1','ydp2','z1','z2','e1','e2'});

Delta = [ Delta_att,  zeros(2), zeros(2)  ; zeros(2) , Delta_G, zeros(2); zeros(2), zeros(2),  Delta_perf];

P_dist = lft(Delta,P);

[K,CLperf,info] = musyn(P_dist,2,2);

K = minreal(zpk(tf(K)),1e-2);



