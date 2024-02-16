f = figure;
f.WindowState = 'maximized';

subplot(1, 2, 1);
plot(x_EKF(3,:));
grid on;

subplot(1, 2, 2);
hold on
plot(x_EKF(4,:));
grid on;
hold off