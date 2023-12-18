%% Definizione Parametri Sistema %%

% massa, attrito, inerzia %
m = 1500;
c_a = 0;%15;
J = 3000;

% Lunghezze %
L = 2.2;
l = L - 1.2;
h = 1;

g = 9.80;

params = [m, c_a, J, L, l, h, g];

% Condizioni Iniziali %
F_0 = +100;
dq_0 = [0; 0];
q_0 = [0; 0];


%% parametri sensori
% sensore laser d1
laserd1_sample_rates = 1/50;   % [50 Hz]
laserd1_resolution = 1;        % [mm]
laserd1_accuracy = 3;          % [mm]

laserd1_params = [laserd1_sample_rates, laserd1_resolution, laserd1_accuracy];

% sensor laser D:
% https://www.acuitylaser.com/wp-content/uploads/ar3000-datasheet.pdf

laserD_sample_rates = 1/100; % [50 Hz]
laserD_resolution = 1;       % [mm]
laserD_accuracy = 20;        % [mm]    % TODO:check if +-20 mm is the dev std or the 95perc of confidence [in this case we need to consider accuracy/3]

laserD_params = [laserD_sample_rates, laserD_resolution, laserD_accuracy];

% relative encoder omega:

r = 0.2;   % [m]
encoder_accuracy = 1;
encoder_resolution = 2*pi/1200; % [rad/pulse]
encoder_sample_rates = 1/50;    % [s]
encoder_params = [r, encoder_accuracy, encoder_resolution, encoder_sample_rates];


% define the slowest sample rate (min freq == max period) of all the sensors to set up the zero order hold block
sample_rates = [encoder_sample_rates, laserD_sample_rates, laserd1_sample_rates]; % sample rates of all the sensors period
min_sample_rates = max(sample_rates); % slowest one

theta_old = 0;

