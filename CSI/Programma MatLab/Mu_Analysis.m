%% Mu-analysis %%

% Creo incertezza di performance per RP
Delta_perf = ultidyn('Delta_perf', [2 2]);


% Struttura matrice Delta_RP
Delta_RP = [ Delta_att,  zeros(2), zeros(2) ; zeros(2) , Delta_G, zeros(2); zeros(2), zeros(2), Delta_perf];
blk_RP = [-1 0; -1 0; -1 0; -1 0; 2 2];

% Struttura matrice Delta
Delta = [Delta_att,  zeros(2) ; zeros(2) , Delta_G];
blk_RS = [-1 0; -1 0; -1 0; -1 0];

%% Mu-Synthesis

N = lft(P, K_DK);
N_zpk = zpk(N);

%NS
N22 = N_zpk(5:6, 5:6);

%RS e RP
N11 = N(1:4, 1:4);

mubnds_mu = mussv(N, blk_RP);
muRP_mu = mubnds_mu(:,1);
[muRPinf_mu, MuRPw_mu] = norm(muRP_mu,inf);

mubnds_mu = mussv(N11, blk_RS);
muRS_mu = mubnds_mu(:,1);
[muRSinf_mu, MuRSw_mu] = norm(muRS_mu,inf);

RP_mu = lft(Delta_RP,N);
[stabmargRP_mu, wcuRP_mu] = robstab(RP_mu);

RS_mu = lft(Delta,N11);
[stabmargRS_mu, wcuRS_mu] = robstab(RS_mu);

%% Mixed-Sensitivity e H-inf

N = lft(P, K_ms);
N_zpk = zpk(N);

%NS
N22 = N_zpk(5:6, 5:6);

%RS e RP
N11 = N(1:4, 1:4);

mubnds_mix = mussv(N, blk_RP);
muRP_mix = mubnds_mix(:,1);
[muRPinf_mix, MuRPw_mix] = norm(muRP_mix,inf);

mubnds_mix = mussv(N11, blk_RS);
muRS_mix = mubnds_mix(:,1);
[muRSinf_mix, MuRSw_mix] = norm(muRS_mix,inf);

RP_mix = lft(Delta_RP,N);
[stabmargRP_mix, wcuRP_mix] = robstab(RP_mix);

RS_mix = lft(Delta,N11);
[stabmargRS_mix, wcuRS_mix] = robstab(RS_mix);


%% Plot %%

w = logspace(-7, 2, 100);

% Confronto upperbound del valore singolare strutturato per RP
figure(1);
RP = bodeplot(muRP_mu, muRP_mix, tf(1), 'k', w);
setoptions(RP, 'PhaseVisible','off', 'Grid', 'on');
legend('muRP\_mu', 'muRP\_mix');


% Confronto upperbound del valore singolare strutturato per RS
figure(2);
RS = bodeplot(muRS_mu, muRS_mix, tf(1), 'k', w);
setoptions(RS, 'PhaseVisible','off', 'Grid', 'on');
legend('muRS\_mu', 'muRS\_mix');


% Confronto norma H-inf del valore singolare strutturato per RP
muRPinf = [muRPinf_mu; muRPinf_mix];
% Confronto norma H-inf del valore singolare strutturato per RS
muRSinf = [muRSinf_mu; muRSinf_mix];


stabmargRP = [stabmargRP_mu.UpperBound,        stabmargRP_mix.UpperBound;
              stabmargRP_mu.LowerBound,        stabmargRP_mix.LowerBound;  
              stabmargRP_mu.CriticalFrequency, stabmargRP_mix.CriticalFrequency];

stabmargRS = [stabmargRS_mu.UpperBound,        stabmargRS_mix.UpperBound;
              stabmargRS_mu.LowerBound,        stabmargRS_mix.LowerBound;  
              stabmargRS_mu.CriticalFrequency, stabmargRS_mix.CriticalFrequency];

