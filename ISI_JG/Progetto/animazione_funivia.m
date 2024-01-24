%% ------ANIMAZIONE FUNIVIA------ %%
close all
clear all


%avvio lo script di inizializzazione
inizializzazione;
T_simulazione = 9.5;
funivia = sim("Nominal_model.slx");                                     %creo struttura con tutti gli out dati da simulink
%funivia = sim("Real_model.slx");                                       %creo struttura con tutti gli out dati da simulink

plot_dinamico = false;
%prendo i parametri dallo sript di inizializzazione
h = param.h;
L = param.L;
l = param.l;
r = param.r;
lenght_cabin = param.length_cabin;
high_cabin = param.High_cabin;

%creazione figura
if(plot_dinamico)
     f = figure;
     f.WindowState = 'maximized';                                           %metto figura a schermo intero
end

%%
%passo i dati dalla struttura creata in precedenza a delle variabili
q_mod = funivia.q.Data;
q_d_mod = funivia.q_d.Data;
x_hat_ekf = funivia.x_hat_EKF_Correction.Data;
x_hat_part = funivia.x_hat_PF_Correction.Data;
z_mod = funivia.z_mod.Data;
z_ekf = funivia.z_EKF.Data;
z_part = funivia.z_PF.Data;
tout = funivia.tout;

%% Regolarizzazione
%i passaggi nelle delle variabili servono a far funzionare il codice nel
%caso che si commenti la regolarizzazione
x_hat_EKF_smoothed = funivia.x_hat_EKF_Correction.Data;
smooth_trajectory;                                                      %script per regolarizzazione
q_ekf = x_hat_EKF_smoothed(1:2,1,:);

%% alleggerimento simulazione
%ricampionamento temporale a 0.033 per il modello
time_mod  =  0 : 0.033 : tout(end);
q_pp_mod  =  zeros(3,size(time_mod,2));
for i  =  1 : size(time_mod,2)
    [d, ix_mod]  =  min(abs(tout-time_mod(i)));                         %abs restituisce il valore assoluto di ogni elemento del vettore al suo interno
    q_pp_mod(1,i) = q_mod(1,1,ix_mod);                                  %creo un vettore con tutte le q ad ogni istante
    q_pp_mod(2,i) = z_mod(ix_mod,1);
    q_pp_mod(3,i) = q_mod(2,1,ix_mod);
end

%ricampionamento temporale a dt_animazione per l'ekf
time_ekf  =  0 : 0.033 : tout(end);
q_pp_ekf  =  zeros(3,size(time_ekf,2));
for i  =  1 : size(time_ekf,2)
    [d, i_ekf]  =  min(abs(tout-time_ekf(i)));                          %abs restituisce il valore assoluto di ogni elemento del vettore al suo interno
    q_pp_ekf(1,i) = q_ekf(1,1,i_ekf);                                   %creo un vettore con tutte le q ad ogni istante
    q_pp_ekf(2,i) = z_ekf(i_ekf,1);
    q_pp_ekf(3,i) = q_ekf(2,1,i_ekf);
end

%ricampionamento temporale a dt_animazione per il filtro a particelle
time_part  =  0 : 0.033 : tout(end);
q_pp_part  =  zeros(3,size(time_part,2));
for i  =  1 : size(time_part,2)
    [d, i_part]  =  min(abs(tout-time_part(i)));                        %abs restituisce il valore assoluto di ogni elemento del vettore al suo interno
    q_pp_part(1,i) = x_hat_part(1,1,i_part);                                %creo un vettore con tutte le q ad ogni istante
    q_pp_part(2,i) = z_part(i_part,1);
    q_pp_part(3,i) = x_hat_part(2,1,i_part);
end

%-- creo la figura--%
if plot_dinamico
    hold on
    axis equal
    axis ([-10 100 -15 10])
    grid on
    title('Moto funivia')
end

%% --plot dinamico-- %%

if plot_dinamico
    for i = 1 : 1 : size(q_pp_mod,2)
        cla;                                                                %cancella il tutto ciò che è disegnato nell'immagine
    
        %--cerco i punti utili per il disegno del modello--%
    
        trasl_mod = (q_pp_mod(2,i) - (l+r)*cos(q_pp_mod(3,i))) - (L-l-r);   %mi sevre per bloccare il cavo portante e traslare il resto di conseguenza
        %trovo vertice in basso a sinistra della cabina
        rect_x_mod = q_pp_mod(1,i) + (h-high_cabin/2)*sin(q_pp_mod(3,i)) -...
            lenght_cabin/2;                                                 %ATTENZIONE: il rettangolo rimane orizzontale
        rect_z_mod = -(q_pp_mod(2,i) + (h-high_cabin/2)*cos(q_pp_mod(3,i)) +...
            high_cabin) + trasl_mod;
    
        %trovo la fine dell'asta in basso
        x_asta_low_mod = q_pp_mod(1,i) + (h - high_cabin/2)*sin(q_pp_mod(3,i));
        z_asta_low_mod = -(q_pp_mod(2,i) + ...
            (h - high_cabin/2)*cos(q_pp_mod(3,i))) + trasl_mod;
    
        %trovo la fine dell'asta in alto
        x_asta_high_mod = q_pp_mod(1,i) - L*sin(q_pp_mod(3,i));
        z_asta_high_mod = trasl_mod;
    
        %trovo il centro della puleggia
        x_puleggia_mod = q_pp_mod(1,i) - (l+r)*sin(q_pp_mod(3,i));                                                      %visto che il comando rectangle disegna partendo dal vertice in basso a sinista devo togliere il raggio per centrarla
        z_puleggia_mod = - (L-l-r) ;
    
    
    
    
    
        %--cerco i punti utili per il disegno dell'ekf--%
    
        trasl_ekf = (q_pp_ekf(2,i) - (l+r)*cos(q_pp_ekf(3,i))) - (L-l-r);                                               %traslazione utile a far stare ffermo il cavo "portante" e muovere quello "di spinta"
        %trovo vertice in basso a sinistra della cabina
        rect_x_ekf = q_pp_ekf(1,i) + (h-high_cabin/2)*sin(q_pp_ekf(3,i))...
            - lenght_cabin/2;                                               %ATTENZIONE: il rettangolo rimane orizzontale
        rect_z_ekf = -(q_pp_ekf(2,i) + (h-high_cabin/2)*cos(q_pp_ekf(3,i))...
            + high_cabin) + trasl_ekf;
    
        %trovo la fine dell'asta in basso
        x_asta_low_ekf = q_pp_ekf(1,i) + (h - high_cabin/2)*sin(q_pp_ekf(3,i));
        z_asta_low_ekf = -(q_pp_ekf(2,i) + ...
            (h - high_cabin/2)*cos(q_pp_ekf(3,i))) + trasl_ekf;
    
        %trovo la fine dell'asta in alto
        x_asta_high_ekf = q_pp_ekf(1,i) - L*sin(q_pp_ekf(3,i));
        z_asta_high_ekf = trasl_ekf;
    
        %trovo il centro della puleggia
        x_puleggia_ekf = q_pp_ekf(1,i) - (l+r)*sin(q_pp_ekf(3,i));                                                      %visto che il comando rectangle disegna partendo dal vertice in basso a sinista devo togliere il raggio per centrarla
        z_puleggia_ekf = - (L-l-r); 
    
    
    
    
    
        %--cerco i punti utili per il disegno del filtro a particelle--%

        trasl_part = (q_pp_part(2,i) - (l+r)*cos(q_pp_part(3,i))) - (L-l-r);
        %trovo vertice in basso a sinistra della cabina
        rect_x_part = q_pp_part(1,i) + (h-high_cabin/2)*sin(q_pp_part(3,i))...
            - lenght_cabin/2;                                               %ATTENZIONE: il rettangolo rimane orizzontale
        rect_z_part = -(q_pp_part(2,i) + (h-high_cabin/2)*cos(q_pp_part(3,i))...
            + high_cabin) + trasl_part;

        %trovo la fine dell'asta in basso
        x_asta_low_part = q_pp_part(1,i) + (h - high_cabin/2)*sin(q_pp_part(3,i));
        z_asta_low_part = -(q_pp_part(2,i) + ...
            (h - high_cabin/2)*cos(q_pp_part(3,i))) + trasl_part;

        %trovo la fine dell'asta in alto
        x_asta_high_part = q_pp_part(1,i) - L*sin(q_pp_part(3,i));
        z_asta_high_part = trasl_part;

        %trovo il centro della puleggia
        x_puleggia_part = q_pp_part(1,i) - (l+r)*sin(q_pp_part(3,i));                                                   %visto che il comando rectangle disegna partendo dal vertice in basso a sinista devo togliere il raggio per centrarla
        z_puleggia_part = - (L-l-r);
    
    
        %plot
        %cabina 
        R_r_mod(1) = rectangle('Position', ...
            [rect_x_mod, rect_z_mod, lenght_cabin, high_cabin],'EdgeColor',...
            'black');                            %modello
        R_r_ekf(1) = rectangle('Position', ...
            [rect_x_ekf, rect_z_ekf, lenght_cabin, high_cabin],'EdgeColor',...
            'blue');                             %ekf
        R_r_part(1) = rectangle('Position', ...
            [rect_x_part, rect_z_part, lenght_cabin, high_cabin],'EdgeColor',...
            'green');                         %filtro a particelle
        % asta
        R_r_mod(2) = line([x_asta_high_mod x_asta_low_mod],...
            [z_asta_high_mod z_asta_low_mod], 'color', 'black');                                %modello
        R_r_ekf(2) = line([x_asta_high_ekf x_asta_low_ekf],...
            [z_asta_high_ekf z_asta_low_ekf], 'color', 'blue');                                 %ekf
        R_r_part(2) = line([x_asta_high_part x_asta_low_part],...
            [z_asta_high_part z_asta_low_part], 'color', 'green');                           %filtro a particelle
        %centro di massa
        R_r_mod(3) = rectangle('Position',...
            [q_pp_mod(1,i)-0.05 -q_pp_mod(2,i)-0.05+trasl_mod 0.1 0.1],...
            'Curvature', [1,1],'EdgeColor', 'black');                       %modello
        R_r_ekf(3) = rectangle('Position',...
            [q_pp_ekf(1,i)-0.05 -q_pp_ekf(2,i)-0.05+trasl_ekf 0.1 0.1],...
            'Curvature', [1,1],'EdgeColor', 'blue');                        %ekf
        R_r_part(3) = rectangle('Position',...
            [q_pp_part(1,i)-0.05 -q_pp_part(2,i)-0.05+trasl_part 0.1 0.1],...
            'Curvature', [1,1],'EdgeColor', 'green');                       %filtro a particelle
        %puleggia
        R_r_mod(4) = rectangle('Position',...
            [x_puleggia_mod-r z_puleggia_mod-r 2*r 2*r], 'curvature',...
            [1,1],'EdgeColor', 'black');                                    %modello
        R_r_ekf(4) = rectangle('Position',...
            [x_puleggia_ekf-r z_puleggia_ekf-r 2*r 2*r], 'curvature',...
            [1,1],'EdgeColor', 'blue');                    %ekf
        R_r_part(4) = rectangle('Position',...
            [x_puleggia_part-r z_puleggia_part-r 2*r 2*r], 'curvature',...
            [1,1],'EdgeColor', 'green');                                    %filtro a particelle
    
        %cavi (traslano con la cabina)
        line([x_asta_high_mod - 10, x_asta_high_mod + 40],...
            [z_asta_high_mod, z_asta_high_mod], 'Linestyle', '-', 'Color',...
            'k', 'LineWidth',1);  %cavo superiore
        line([x_puleggia_mod - 10, x_puleggia_mod + 40],...
            [z_puleggia_mod-r, z_puleggia_mod-r], 'LineStyle','-','Color',...
            'k','LineWidth',1);      %cavo inferiore
    
        % Aggiorno gli assi con la coordinata della cabina
        xlim([q_pp_mod(1,i) - 5, q_pp_mod(1,i) + 30]);
        ylim([-8, 0.5]);
    
        drawnow                                                         
        %exportgraphics(f,'Figura_animazione/fig.gif',"Append",true)
        pause(0.033)
        
    end
end


%% ---plot grafici--- %%
%% plot regolarizzazione EKF

%variabile creata a causa di un errore dato da matlab utilizzando la variabile tout
tempo = zeros(size(q_ekf,3),1);                     
for i = 1 : 1 : size(q_ekf,3)
    tempo(i) = tout(i);
end

%plot theta
figure(2)
hold on
grid on
box on
%axis equal
xlabel('time [s]')
ylabel('theta [rad]')

theta_mod = zeros(size(q_ekf,3),1);
theta_EKF = zeros(size(q_ekf,3),1);
theta_EKF_smooth = zeros(size(q_ekf,3),1);
theta_PF = zeros(size(q_ekf,3),1);
for i = 1 : 1 : size(q_ekf,3)
    theta_mod(i) = q_mod(2,1,i);
    theta_EKF(i) = funivia.x_hat_EKF_Correction.Data(2,1,i);
    theta_EKF_smooth(i) = q_ekf(2,1,i);
    theta_PF(i) = x_hat_part(2,1,i);
end

%plot in sovrapposizione di modello e filtri per theta
ground_truth_tetha = ...
    plot(tempo, theta_mod , 'm', 'LineWidth', 1.2);
estimated_plot_tetha = ...
    plot(tempo , theta_EKF ,'r--', 'LineWidth', 1.2);
smoothed_plot_tetha = ...
    plot(tempo, theta_EKF_smooth ,'b--', 'LineWidth', 1.2);
estimated_plot_theta_PF = ...
    plot(tempo , theta_PF ,'g--', 'LineWidth', 1.2);

legend('mod','EKF','smooth_EKF','PF')
hold off

%plot x
figure(3)
hold on
grid on
box on
%axis equal
ylabel('x [m]')
xlabel('time [s]')

x_mod = zeros(size(q_ekf,3),1);
x_EKF = zeros(size(q_ekf,3),1);
x_EKF_smooth = zeros(size(q_ekf,3),1);
x_PF = zeros(size(q_ekf,3),1);
for i = 1 : 1 : size(q_ekf,3)
    x_mod(i) = q_mod(1,1,i);
    x_EKF(i) = funivia.x_hat_EKF_Correction.Data(1,1,i);
    x_EKF_smooth(i) = q_ekf(1,1,i);
    x_PF(i) = x_hat_part(1,1,i);
end

%plot in sovrapposizione di modello e filtri per x
ground_truth_x = ...
    plot(tempo, x_mod , 'm', 'LineWidth', 1.2);
estimated_plot_x = ...
    plot(tempo, x_EKF,'r--', 'LineWidth', 1.2);
smoothed_plot_x = ...
    plot(tempo, x_EKF_smooth ,'b--', 'LineWidth', 1.2);
estimated_plot_x_PF = ...
    plot(tempo , x_PF ,'g--', 'LineWidth', 1.2);

legend('mod','EKF','smooth_EKF','PF')
hold off

%% P
Autov_P_cor = zeros(4,size(P_EKF_correction,3));
Autov_P_pre = zeros(4,size(P_EKF_correction,3));
Autov_P_smoothed = zeros(4,size(P_EKF_correction,3));
for i = 1 : 1 : size(P_EKF_correction,3)
    Autov_P_cor(:,i) = eig (P_EKF_correction(:,:,i));
    Autov_P_pre(:,i) = eig (P_EKF_prediction(:,:,i));
    Autov_P_smoothed(:,i) = eig (P_EKF_smoothed(:,:,i));
end

figure(4)
hold on
grid on
box on
plot(Autov_P_cor(1,:),'--','LineWidth', 1.2)
plot(Autov_P_pre(1,:),':','LineWidth', 1.2)
%plot(Autov_P_smoothed(1,:),'-','LineWidth', 1.2)
legend('correction','prediction','smoothed')
hold off

figure(5)
hold on
grid on
box on
plot(Autov_P_cor(2,:),'--','LineWidth', 1.2)
plot(Autov_P_pre(2,:),':','LineWidth', 1.2)
%plot(Autov_P_smoothed(2,:),'-','LineWidth', 1.2)
legend('correction','prediction','smoothed')
hold off

figure(6)
hold on
grid on
box on
plot(Autov_P_cor(3,:),'--','LineWidth', 1.2)
%plot(Autov_P_pre(3,:),':','LineWidth', 1.2)
plot(Autov_P_smoothed(3,:),'-','LineWidth', 1.2)
legend('correction','prediction','smoothed')
hold off

figure(7)
hold on
grid on
box on
plot(Autov_P_cor(4,:),'--','LineWidth', 1.2)
plot(Autov_P_pre(4,:),':','LineWidth', 1.2)
%plot(Autov_P_smoothed(4,:),'-','LineWidth', 1.2)
legend('correction','prediction','smoothed')
hold off


