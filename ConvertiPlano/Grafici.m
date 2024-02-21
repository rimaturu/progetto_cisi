close all
clc

LQG;
Mix_sensitivity;
mu_synthesis;

f = figure;
f.WindowState = 'maximized';

Convertiplano = sim("Modello_Convertiplano.slx", 'StopTime', '100');
t_tot = Convertiplano.tout;

% Dati LQG %
yL = Convertiplano.yL.Data;
yL_I = Convertiplano.yL_I.Data;
yNL = Convertiplano.yNL.Data;
yNL_I = Convertiplano.yNL_I.Data;

% Dati Mixed-Sensitivity %
MS_yL = Convertiplano.MS_yL.Data;
MS_yNL = Convertiplano.MS_yNL.Data;

% Dati Mu-synthesis %
Mu_yL = Convertiplano.Mu_yL.Data;
Mu_yNL = Convertiplano.Mu_yNL.Data;

%% Plot degli stati da controllare LQG %%

% Plot per Sist. Lineare senza Integratore %
subplot(4, 2, 1);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yL(:, 1), 'Color', 'g', 'LineWidth', 2);
title('z\_L', 'FontSize', 20);
ylabel('[m]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

subplot(4, 2, 2);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yL(:, 2), 'Color', 'r', 'LineWidth', 2);
title('theta\_L', 'FontSize', 20);
ylabel('[Rad/s]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

% Plot per Sist. Lineare con Integratore %
subplot(4, 2, 3);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yL_I(:, 1), 'Color', 'g', 'LineWidth', 2);
title('z\_L\_I', 'FontSize', 20);
ylabel('[m]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

subplot(4, 2, 4);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yL_I(:, 2), 'Color', 'r', 'LineWidth', 2);
title('theta\_L\_I', 'FontSize', 20);
ylabel('[Rad/s]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

% Plot per Sist. Non Lineare senza Integratore %
subplot(4, 2, 5);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yNL(1, :), 'Color', 'g', 'LineWidth', 2);
title('z\_NL', 'FontSize', 20);
ylabel('[m]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

subplot(4, 2, 6);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yNL(2, :), 'Color', 'r', 'LineWidth', 2);
title('theta\_NL', 'FontSize', 20);
ylabel('[Rad/s]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

% Plot per Sist. Non Lineare con Integratore %
subplot(4, 2, 7);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yNL_I(1, :), 'Color', 'g', 'LineWidth', 2);
title('z\_NL\_I', 'FontSize', 20);
ylabel('[m]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

subplot(4, 2, 8);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yNL_I(2, :), 'Color', 'r', 'LineWidth', 2);
title('theta\_NL\_I', 'FontSize', 20);
ylabel('[Rad/s]', 'FontSize', 15, 'Rotation', 0);
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

% f_HI = figure(3);
% 
% f_HI.WindowState = 'maximized';
% f_HI.Name = 'H-infinity';
% f_HI.NumberTitle = 'off';
% 
% % Plot per Sist. Lineare %
% subplot(2, 2, 1);
% hold on
% set(gca, 'FontSize', 12);
% plot(t_tot, HI_yL(:, 1), 'Color', 'g', 'LineWidth', 2);
% title('z\_L', 'FontSize', 13);
% ylabel('[m]', 'FontSize', 12, 'Rotation', 0);
% grid on;
% hold off
% 
% subplot(2, 2, 2);
% hold on
% set(gca, 'FontSize', 12);
% plot(t_tot, HI_yL(:, 2), 'Color', 'r', 'LineWidth', 2);
% title('theta\_L', 'FontSize', 13);
% ylabel('[Rad/s]', 'FontSize', 12, 'Rotation', 0);
% grid on;
% hold off
% 
% % Plot per Sist. Non Lineare %
% subplot(2, 2, 3);
% hold on
% set(gca, 'FontSize', 12);
% plot(t_tot, HI_yNL(:, 1), 'Color', 'g', 'LineWidth', 2);
% title('z\_NL', 'FontSize', 13);
% ylabel('[m]', 'FontSize', 12, 'Rotation', 0);
% grid on;
% hold off
% 
% subplot(2, 2, 4);
% hold on
% set(gca, 'FontSize', 12);
% plot(t_tot, HI_yNL(:, 2), 'Color', 'r', 'LineWidth', 2);
% title('theta\_NL', 'FontSize', 13);
% ylabel('[Rad/s]', 'FontSize', 12, 'Rotation', 0);
% grid on;
% hold off

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
