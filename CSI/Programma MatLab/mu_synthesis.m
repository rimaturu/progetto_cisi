%% mu-synthesis
close all
clc


%% Definisco il sistema linearizzato nel PE
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

% trovo fdt nominale del linearizzato

sys_n = ss(A_nom,B_nom,C_nom,D_nom);

[P,Delta_G,Blkstruct]=lftdata(sys_n);

G_P = zpk(P);


%% Definisco le fdt degli attuatori nominali (senza tempo di ritardo) e perturbate
s = tf('s');

[num1,den1] = pade(T1_i,4);
[num2,den2] = pade(T2_i,4);

pade1 = tf(num1,den1);
pade2 = tf(num2,den2);

Gm1_n = Km1/(Tm1_i*s+1);
Gm1_p = Km1/(Tm1_i*s+1)*pade1;
Gm2_n = Km2/(Tm2_i*s+1);
Gm2_p = Km2/(Tm2_i*s+1)*pade2;

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
M1=2;
wB1=0.1;
A2=1e-4;
M2=2;
wB2=0.1;
wP1=makeweight(1/A1,wB1,1/M1);
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

Delta = [Delta_att,  zeros(2) ; zeros(2) , Delta_G];

P_dist = lft(Delta,P);

[K_DK,CLperf,info] = musyn(P_dist,2,2);

K_DK = minreal(zpk(tf(K_DK)),0.5);

K_DK = [K_DK(1,1) 0; 0 K_DK(2,2)];

%bodemag(K_DK)


%% mu-analysis

% creo incertezza di performance
Delta_perf1 = ultidyn('Delta_perf1',[1 1]);
Delta_perf2 = ultidyn('Delta_perf2',[1 1]);
Delta_perf3 = ultidyn('Delta_perf2',[1 1]);
Delta_perf4 = ultidyn('Delta_perf2',[1 1]);
Delta_perf = [Delta_perf1 Delta_perf2; Delta_perf3 Delta_perf4];
Delta = [ Delta_att,  zeros(2), zeros(2) ; zeros(2) , Delta_G, zeros(2); zeros(2), zeros(2), Delta_perf];

N = lft (P,K_DK);

N_zpk = zpk(N);
% omega=logspace(-3,1,90);
% Nfr=frd(N,omega);

%NS
N22 = N_zpk(5:6,5:6);
nyquistplot(N22)

%RS e RP

N11 = N (1:4,1:4);

blk=[-1 0;-1 0;-1 0;-1 0;2 2];

[mubnds,muinfo]=mussv(N,blk,'c');
muRP=mubnds(:,1);
[muRPinf,MuRPw]=norm(muRP,inf);


usys=lft(Delta,N);
[stabmarg,wcu]=robstab(usys);

