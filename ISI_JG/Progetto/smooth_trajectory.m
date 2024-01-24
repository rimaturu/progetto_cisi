%% Regolarizzazione
Fe = funivia.Fe.Data;
%% Regolarizzazione EKF
x_hat_EKF_correction = funivia.x_hat_EKF_Correction.Data;
x_hat_EKF_prediction = funivia.x_hat_EKF_Prediction.Data;
P_EKF_correction = funivia.P_EKF_Correction.Data;
P_EKF_prediction = funivia.P_EKF_Prediction.Data;
F_EKF = funivia.F_EKF.Data;

[x_hat_EKF_smoothed, P_EKF_smoothed] = Smoothing (x_hat_EKF_correction,x_hat_EKF_prediction,P_EKF_correction,P_EKF_prediction,F_EKF);

%% aggiusto z per il plot
L = param.L;
for i  =  1 : (size(x_hat_EKF_correction,3))
    z_ekf(i,1) = L*cos(x_hat_EKF_smoothed(2,1,i));
end
%% Funzione di Regolarizzazione
function [x_hat_smoothed, P_smoothed] = Smoothing (x_hat_correction,x_hat_prediction,P_correction,P_prediction,F)

    x_hat_smoothed = x_hat_correction;
    P_smoothed = P_correction;
    Ck_plot = zeros (4,4,size(x_hat_correction,3)-1);
    %regolarizzo
    for k = size(x_hat_correction,3)-1:-1:1
        
        % Ck = P_k|k * F_k+1' * P_k+1|k^(-1)
        Ck = P_correction(:,:,k)*F(:,:,k)'/P_prediction(:,:,k);
        
        % x_k|n = x_k|k + Ck*(x_k+1|n - x_k+1|k)
	    x_hat_smoothed(:,1,k) = x_hat_correction(:,1,k) + Ck*(x_hat_smoothed(:,1,k+1) - x_hat_prediction(:,1,k));
        
        % P_k|n = P_k|k + Ck*(P_k+1|n - P_k+1|k)*Ck'
        P_smoothed(:,:,k) = P_correction(:,:,k) + Ck*(P_smoothed(:,:,k+1)-P_prediction(:,:,k))*Ck';
    end

end

