%% Definizione Parametri Sistema %%

% massa, attrito, inerzia %
m = 1500;
c_a = 15;
J = 3000;

% Lunghezze %
L = 2.2;
l = L - 1.2;
h = 1;
r = 0.2;   % [m]

g = 9.81;

params = [m, c_a, J, L, l, h, r, g];     % parametri filtri
params_incert = [m + normrnd(400, 100), c_a - normrnd(1, 0.2), J + normrnd(500, 50), L, l, h, r, g]; % parametri sistema reale

% Condizioni Iniziali %
F_0 = 1500;
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
laserD_accuracy = 20;        % [mm]    

laserD_params = [laserD_sample_rates, laserD_resolution, laserD_accuracy];


% relative encoder omega:
encoder_accuracy = 2*pi/1200; % [rad]
encoder_resolution = 2*pi/1200; % [rad/pulse]
encoder_sample_rates = 1/50;    % [s]

encoder_params = [r, encoder_accuracy, encoder_resolution, encoder_sample_rates];


% Ricavo la frequenza minima di funzionamento tra i sensori (min freq == max period) 
sample_rates = [encoder_sample_rates, laserD_sample_rates, laserd1_sample_rates]; % Tempo di campionamento di tutti i sensori
min_sample_rates = max(sample_rates); % Il più lento



% Matrice covarianza del rumore del modello di osservazione (sensori)
R_k = diag([(laserD_accuracy/1000)^2, (laserd1_accuracy/1000)^2, (encoder_accuracy/encoder_sample_rates)^2]);

% Condizione iniziale filtri Kalman (q_1|0) 
q_hat_0 = [ normrnd(dq_0(1), 0.1);
            normrnd(dq_0(2), 0.1);
            normrnd(q_0(1), 0.5);
            normrnd(q_0(2), pi/100)];


%% Faccio partire la simulazione su Simulink
simulazione = sim("SistemaFunivia.slx");

