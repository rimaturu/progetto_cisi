%% Progetto_Funivia_JacopoConti_MatteoGafforio

clear all
close all

%% Parametri dei modelli nominale e reale
% Definizione Dati ideali
param.M = 2000;                                 % [kg]       % massa totale
param.J = 2800;                                 % [kg*m^2]   % momento di inerzia
param.Ca = 20;                                  % [N*s/m]    % coefficiente attrito viscoso
param.L = 3;                                    % [m]        % Lunghezza fune-centro di massa
param.l = 1.1;                                  % [m]        % Lunghezza puleggia-centro di massa
param.h = 2.25;                                 % [m]        % Lunghezza centro cabina-centro di massa
param.r = 0.1;                                  % [m]        % raggio puleggia
param.High_cabin = 2.5;                         % [m]        % altezza cabina
param.length_cabin = 5;                         % [m]        % larghezza cabina

% definizione Dati reali
var = randn*500;                                    % variabile che usiamo per far variare massa e momento d'inerzia in modo proporzionale, essendo le 2 grandezze legate
param_real.M = param.M + var;                       % [kg]       % massa
param_real.J = param.J + var*(param.l+param.r)^2;   % [kg*m^2]   % momento di inerzia
param_real.Ca = param.Ca + randn*3;                 % [N*s/m]    % coefficiente di attrito viscoso

% Costanti
param.g = 9.81;                                     % [m/s^2]    % accellerazione gravitazionale

%% Caratteristiche dei sensori
% sensore Dc (radio)
sensor.Dc.freq = 50;                            % [Hz]
precisione_Dc = 1;                              % [m] 
sensor.Dc.std_dev = sqrt(precisione_Dc/3);      % [m]        % std_dev=precisone/3
sensor.Dc.seed = 19;                            % seed per generare i soliti rumori

% sensore encoder
sensor.omega.freq = 1000;                       % [Hz]
precisione_omega = 1;                           % [rad/s]
sensor.omega.std_dev = sqrt(precisione_omega/3);% [rad/s]    % std_dev=precisone/3
sensor.omega.seed = 255;                        % seed per generare i soliti rumori

% sensore d2
sensor.d2.freq = 1000;                          % [Hz]
precisione_d2 = 0.1;                            % [m]
sensor.d2.std_dev = sqrt(precisione_d2/3);      % [m]        % std_dev=precisone/3
sensor.d2.seed = 45;                            % seed per generare i soliti rumori

%% Caratteristiche dell'ingresso
% ingresso Fext
Fext.mean_value = 500;                          % [N]
Fext.std_dev = sqrt(1000*0.05/3);               % [N]
Fext.seed = 71;                                 % seed per generare i soliti rumori


%% Inizializzazione stato dei modelli nominale e reale
% Media dello stato iniziale
x0 = 0;                                         % [m]        % variabile=[tempo valore]
x0_d = 0;                                       % [m/s]
tetha0 = 0;                                     % [rad]
tetha0_d = 0;                                   % [rad/s]
% Deviazione standard dello stato iniziale
x_std_dev = 5;                                  % [m]
x_d_std_dev = 0.1;                              % [m/s]
tetha_std_dev = pi/8;                           % [rad]
tetha_d_std_dev = pi/16;                        % [rad/s]

% Genero lo stato iniziale dei sistemi in modo casuale
% metto in forma vettoriale
init.q0 = [x0 ; tetha0];                      
init.q0_d = [x0_d ; tetha0_d];
init.q_std_dev = [x_std_dev 0;...
                  0 tetha_std_dev];
init.q_d_std_dev = [x_d_std_dev 0;...
                    0 tetha_d_std_dev];
% genero lo stato
init.real_q0 = init.q0 + 2*((rand(1,2)-[0.5 0.5])*init.q_std_dev)';
init.real_q0_d = init.q0_d + 2*((rand(1,2)-[0.5 0.5])*init.q_d_std_dev)';

%% Inizializzazione filtri
% EKF
x0_hat = [init.q0(1) init.q0(2) init.q0_d(1) init.q0_d(2)]';    % uso la media dello stato iniziale
P0 = [init.q_std_dev(1,1)^2 0 0 0;...                           % uso la deviazione dello stato iniziale
      0 init.q_std_dev(2,2)^2 0 0;...
      0 0 init.q_d_std_dev(1,1)^2 0;...
      0 0 0 init.q_d_std_dev(2,2)^2];
% PF
N = 5000;                                       % numero particelle per PF
particles0 = mvnrnd (x0_hat, P0, N);            % genero le particelle
weights0 = 1/N*ones(N,1);                       % inizializzo i pesi

%frequenza filtri
%trovo le frequenze del sensore più lento e più veloce 
if (sensor.omega.freq > sensor.Dc.freq)
    f_max = sensor.omega.freq;
    f_min = sensor.Dc.freq;
    if (sensor.d2.freq > f_max) 
        f_max = sensor.d2.freq;
    elseif (sensor.d2.freq < f_min)
        f_min = sensor.d2.freq;
    end
else
    f_min = sensor.omega.freq;
    f_max = sensor.Dc.freq;
    if (sensor.d2.freq > f_max) 
        f_max = sensor.d2.freq;
    elseif (sensor.d2.freq < f_min)
        f_min = sensor.d2.freq;
    end
end 
dT_max = 1/f_min;                               % Periodo utilizzato per la correzione
dT = 1/f_max;                                   % Perido dei filtri di kalman

%% Caratteristiche della simulazione
T_simulazione = 30;                             % tempo di simulazione

