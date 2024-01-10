%% Regolarizzazione EKF 

% Estrazione dati da Simulink
q_hat_corr = out.q_hat_computed.Data;
P_k_corr = out.P_k_corr.Data;

q_hat_pred = out.q_hat_pred.Data;
P_k_pred = out.P_k_pred.Data;

F_k_smooth = out.F_k.Data;

% Dimensione ciclo for
N = size(out.q_hat_pred.Time, 1);

% Inizializzazione 
q_k_n = q_hat_corr';   % x_n_n
P_k_n = P_k_corr;      % P_n_n

% Algoritmo di regolarizzazione
for k = (N-1):-1:1

    C_k = P_k_corr(:,:,k) * F_k_smooth(:,:,k+1)' * ((P_k_pred(:,:,k+1)) ^ (-1));

    q_k_n(:,k) = q_hat_corr(k,:)' + C_k * (q_k_n(:,k+1) - q_hat_pred(:,:,k+1));
    
    P_k_n(:,:,k) = P_k_corr(:,:,k) + C_k * (P_k_n(:,:,k+1) - P_k_pred(:,:,k+1));

end