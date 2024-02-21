% launcher.m
% Launching script
close all
clear all
clc

disp('Launching Programma_Init.m...')
run('Programma_Init.m');

disp('Launching Mix_sensitivity_H_Infinity.m...')
run('Mix_sensitivity_H_Infinity.m');

disp('Launching mu_synthesis.m...')
run('mu_synthesis.m');

disp('Launching LQG.m...')
run('LQG.m');

disp('Launching Mu_Analysis.m...')
run('Mu_Analysis.m');

disp('Launching Grafici.m...')
run('Grafici.m');
