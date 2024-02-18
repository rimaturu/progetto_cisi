clc
close all

% Condizioni iniziali %
F_0 = [0; 0];

% dq_0 = [0; 0];
% q_0 = [100; -1];

dq_0 = [0; 0];
q_0 = [randi([-200,200]); normrnd(0, 2*pi)];

Convertiplano = sim("Modello_Convertiplano.slx");
t_tot = Convertiplano.tout;

% Dati LQG %
LQG_yL = Convertiplano.LQG_yL.Data;
LQG_yL_I = Convertiplano.LQG_yL_I.Data;
LQG_yNL = Convertiplano.LQG_yNL.Data;
LQG_yNL_I = Convertiplano.LQG_yNL_I.Data;

% Dati Mixed-Sensitivity %
MS_yL = Convertiplano.MS_yL.Data;
MS_yNL = Convertiplano.MS_yNL.Data;

% Dati H-infinity %
HI_yL = Convertiplano.HI_yL.Data;
HI_yNL = Convertiplano.HI_yNL.Data;

% Dati Mu-synthesis %
Mu_yL = Convertiplano.Mu_yL.Data;
Mu_yNL = Convertiplano.Mu_yNL.Data;

%% Plot della stima EKF %%
% subplot(4, 2, 1);
% hold on
% plot(0:dt:t_EKF, x_EKF(3,:));
% title('z\_hat');
% grid on;
% hold off
% 
% subplot(4, 2, 2);
% hold on
% plot(0:dt:t_EKF, x_EKF(4,:));
% title('theta\_hat');
% grid on;
% hold off

%% Plot degli stati da controllare LQG %%
f_LQG = figure(1);

f_LQG.WindowState = 'maximized';
f_LQG.Name = 'LQG';
f_LQG.NumberTitle = 'off';

% Plot per Sist. Lineare senza Integratore %
subplot(4, 2, 1);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, LQG_yL(:, 1), 'Color', 'g', 'LineWidth', 2);
title('z\_L', 'FontSize', 13);
ylabel('[m]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

subplot(4, 2, 2);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, LQG_yL(:, 2), 'Color', 'r', 'LineWidth', 2);
title('theta\_L', 'FontSize', 13);
ylabel('[Rad/s]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

% Plot per Sist. Lineare con Integratore %
subplot(4, 2, 3);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, LQG_yL_I(:, 1), 'Color', 'g', 'LineWidth', 2);
title('z\_L\_I', 'FontSize', 13);
ylabel('[m]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

subplot(4, 2, 4);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, LQG_yL_I(:, 2), 'Color', 'r', 'LineWidth', 2);
title('theta\_L\_I', 'FontSize', 13);
ylabel('[Rad/s]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

% Plot per Sist. Non Lineare senza Integratore %
subplot(4, 2, 5);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, LQG_yNL(1, :), 'Color', 'g', 'LineWidth', 2);
title('z\_NL', 'FontSize', 13);
ylabel('[m]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

subplot(4, 2, 6);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, LQG_yNL(2, :), 'Color', 'r', 'LineWidth', 2);
title('theta\_NL', 'FontSize', 13);
ylabel('[Rad/s]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

% Plot per Sist. Non Lineare con Integratore %
subplot(4, 2, 7);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, LQG_yNL_I(1, :), 'Color', 'g', 'LineWidth', 2);
title('z\_NL\_I', 'FontSize', 13);
ylabel('[m]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

subplot(4, 2, 8);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, LQG_yNL_I(2, :), 'Color', 'r', 'LineWidth', 2);
title('theta\_NL\_I', 'FontSize', 13);
ylabel('[Rad/s]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

%% Plot degli stati da controllare Mixed-Sensitivity %%

f_MS = figure(2);

f_MS.WindowState = 'maximized';
f_MS.Name = 'Mixed-Sensitivity';
f_MS.NumberTitle = 'off';

% Plot per Sist. Lineare %
subplot(2, 2, 1);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, MS_yL(:, 1), 'Color', 'g', 'LineWidth', 2);
title('z\_L', 'FontSize', 13);
ylabel('[m]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

subplot(2, 2, 2);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, MS_yL(:, 2), 'Color', 'r', 'LineWidth', 2);
title('theta\_L', 'FontSize', 13);
ylabel('[Rad/s]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

% Plot per Sist. Non Lineare %
subplot(2, 2, 3);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, MS_yNL(:, 1), 'Color', 'g', 'LineWidth', 2);
title('z\_NL', 'FontSize', 13);
ylabel('[m]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

subplot(2, 2, 4);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, MS_yNL(:, 2), 'Color', 'r', 'LineWidth', 2);
title('theta\_NL', 'FontSize', 13);
ylabel('[Rad/s]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

%% Plot degli stati da controllare H-inf %%

f_HI = figure(3);

f_HI.WindowState = 'maximized';
f_HI.Name = 'H-infinity';
f_HI.NumberTitle = 'off';

% Plot per Sist. Lineare %
subplot(2, 2, 1);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, HI_yL(:, 1), 'Color', 'g', 'LineWidth', 2);
title('z\_L', 'FontSize', 13);
ylabel('[m]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

subplot(2, 2, 2);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, HI_yL(:, 2), 'Color', 'r', 'LineWidth', 2);
title('theta\_L', 'FontSize', 13);
ylabel('[Rad/s]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

% Plot per Sist. Non Lineare %
subplot(2, 2, 3);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, HI_yNL(:, 1), 'Color', 'g', 'LineWidth', 2);
title('z\_NL', 'FontSize', 13);
ylabel('[m]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

subplot(2, 2, 4);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, HI_yNL(:, 2), 'Color', 'r', 'LineWidth', 2);
title('theta\_NL', 'FontSize', 13);
ylabel('[Rad/s]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

%% Plot degli stati da controllare Mu-Synthesis %%

f_Mu = figure(4);

f_Mu.WindowState = 'maximized';
f_Mu.Name = 'Mu-Synthesis';
f_Mu.NumberTitle = 'off';

% Plot per Sist. Lineare %
subplot(2, 2, 1);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, Mu_yL(:, 1), 'Color', 'g', 'LineWidth', 2);
title('z\_L', 'FontSize', 13);
ylabel('[m]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

subplot(2, 2, 2);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, Mu_yL(:, 2), 'Color', 'r', 'LineWidth', 2);
title('theta\_L', 'FontSize', 13);
ylabel('[Rad/s]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

% Plot per Sist. Non Lineare %
subplot(2, 2, 3);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, Mu_yNL(:, 1), 'Color', 'g', 'LineWidth', 2);
title('z\_NL', 'FontSize', 13);
ylabel('[m]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off

subplot(2, 2, 4);
hold on
set(gca, 'FontSize', 12);
plot(t_tot, Mu_yNL(:, 2), 'Color', 'r', 'LineWidth', 2);
title('theta\_NL', 'FontSize', 13);
ylabel('[Rad/s]', 'FontSize', 12, 'Rotation', 0);
grid on;
hold off