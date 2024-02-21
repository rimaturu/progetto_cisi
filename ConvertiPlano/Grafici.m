
close all
clc

LQG;
Mix_sensitivity;
mu_synthesis;


Convertiplano = sim("Modello_Convertiplano.slx", 'StopTime', '50');
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

f_LQG = figure(1);
f_LQG.WindowState = 'maximized';
f_LQG.Name = 'LQG';
f_LQG.NumberTitle = 'off';
f_LQG.Color = "white";

% Plot per Sist. Lineare senza Integratore %
subplot(2, 2, 1);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yL(:, 1), 'Color', 'g', 'LineWidth', 2);
title('z\_L', 'FontSize', 20);
ylabel('[m]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

subplot(2, 2, 2);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yL(:, 2), 'Color', 'r', 'LineWidth', 2);
title('theta\_L', 'FontSize', 20);
ylabel('[Rad/s]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

% Plot per Sist. Non Lineare senza Integratore %
subplot(2, 2, 3);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yNL(1, :), 'Color', 'g', 'LineWidth', 2);
title('z\_NL', 'FontSize', 20);
ylabel('[m]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

subplot(2, 2, 4);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yNL(2, :), 'Color', 'r', 'LineWidth', 2);
title('theta\_NL', 'FontSize', 20);
ylabel('[Rad/s]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

f_LQG_I = figure(2);
f_LQG_I.WindowState = 'maximized';
f_LQG_I.Name = 'LQG con Integratore';
f_LQG_I.NumberTitle = 'off';
f_LQG_I.Color = "white";

% Plot per Sist. Lineare con Integratore %
subplot(2, 2, 1);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yL_I(:, 1), 'Color', 'g', 'LineWidth', 2);
title('z\_L\_I', 'FontSize', 20);
ylabel('[m]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

subplot(2, 2, 2);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yL_I(:, 2), 'Color', 'r', 'LineWidth', 2);
title('theta\_L\_I', 'FontSize', 20);
ylabel('[Rad/s]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

% Plot per Sist. Non Lineare con Integratore %
subplot(2, 2, 3);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yNL_I(1, :), 'Color', 'g', 'LineWidth', 2);
title('z\_NL\_I', 'FontSize', 20);
ylabel('[m]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

subplot(2, 2, 4);
hold on
set(gca, 'FontSize', 15);
plot(t_tot, yNL_I(2, :), 'Color', 'r', 'LineWidth', 2);
title('theta\_NL\_I', 'FontSize', 20);
ylabel('[Rad/s]', 'FontSize', 15, 'Rotation', 0);
grid on;
hold off

%% Plot degli stati da controllare Mixed-Sensitivity %%

f_MS = figure(3);
f_MS.WindowState = 'maximized';
f_MS.Name = 'Mixed-Sensitivity';
f_MS.NumberTitle = 'off';
f_MS.Color = "white";

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

% f_HI = figure(4);
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

f_Mu = figure(5);

f_Mu.WindowState = 'maximized';
f_Mu.Name = 'Mu-Synthesis';
f_Mu.NumberTitle = 'off';
f_Mu.Color = "white";

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
