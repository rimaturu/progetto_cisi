f = figure;
f.WindowState = 'maximized';

Convertiplano = sim("Modello_Convertiplano.slx");
t_tot = Convertiplano.tout;
yL = Convertiplano.yL.Data;
yL_I = Convertiplano.yL_I.Data;
yNL = Convertiplano.yNL.Data;
yNL_I = Convertiplano.yNL_I.Data;

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
