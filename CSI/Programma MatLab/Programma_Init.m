clear all
close all
clc

%% Definizione parametri %%

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

% Definizione parametri incerti %
J_i = 5000;
m_i = 2000;
b_i = ureal('b_i', 150, 'Percentage', [-10,10]);
beta_i=ureal('beta_i', 15, 'Percentage', [-10,10]);
l_i = 10;

% Definizione parametri attuatori incerti%
Km1_i = 500;
Km2_i = 100;
T1_i = 0.5;
T2_i = 0.5;
Tm1_i = 5;
Tm2_i = 5;

% Condizioni iniziali %
F_0 = [0; 0];

dq_0 = [0; 0];
q_0 = [100; -1];
