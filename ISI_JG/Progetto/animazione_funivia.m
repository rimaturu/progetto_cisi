%% ------ANIMAZIONE FUNIVIA------ %%
close all
clear all


% avvio lo script di inizializzazione
inizializzazione;
% selezioni della simulazione
plot_dinamico = false;
real_simulation = true;
T_simulazione = 100;
if real_simulation
    funivia = sim("Real_model.slx");                                       %creo struttura con tutti gli out dati da simulink
else
    funivia = sim("Nominal_model.slx");                                     %creo struttura con tutti gli out dati da simulink
end

% prendo i parametri dallo script di inizializzazione
h = param.h;
L = param.L;
l = param.l;
r = param.r;
lenght_cabin = param.length_cabin;
high_cabin = param.High_cabin;

% creazione figura
if(plot_dinamico)
     f = figure;
     f.WindowState = 'maximized';                                       %metto figura a schermo intero
end

%%
%passo i dati dalla struttura creata in precedenza a delle variabili
x_hat_ekf = funivia.x_hat_EKF_Correction.Data;
x_hat_part = funivia.x_hat_PF_Correction.Data;
q_mod = funivia.q.Data(:,:,1:size(x_hat_ekf,3));
q_d_mod = funivia.q_d.Data(:,:,1:size(x_hat_ekf,3));
z_mod = funivia.z_mod.Data;
z_ekf = funivia.z_EKF.Data;
z_part = funivia.z_PF.Data;
tout = funivia.tout(1:size(x_hat_ekf,3),1);

%% Regolarizzazione
%i passaggi nelle delle variabili servono a far funzionare il codice nel
%caso che si commenti la regolarizzazione
x_hat_EKF_smoothed = funivia.x_hat_EKF_Correction.Data;
smooth_trajectory;                                                      %script per regolarizzazione
x_ekf = x_hat_EKF_smoothed(:,1,:);

%% alleggerimento simulazione
%ricampionamento temporale a 0.033 per il modello
time_mod  =  0 : 0.03 : tout(end);
q_pp_mod  =  zeros(3,size(time_mod,2));
for i  =  1 : size(time_mod,2)
    [d, ix_mod]  =  min(abs(tout-time_mod(i)));                         %abs restituisce il valore assoluto di ogni elemento del vettore al suo interno
    q_pp_mod(1,i) = q_mod(1,1,ix_mod);                                  %creo un vettore con tutte le q ad ogni istante
    q_pp_mod(2,i) = z_mod(ix_mod,1);
    q_pp_mod(3,i) = q_mod(2,1,ix_mod);
end

%ricampionamento temporale a dt_animazione per l'ekf
%time_mod  =  0 : 0.033 : tout(end);
q_pp_ekf  =  zeros(3,size(time_mod,2));
for i  =  1 : size(time_mod,2)
    [d, i_ekf]  =  min(abs(tout-time_mod(i)));                          %abs restituisce il valore assoluto di ogni elemento del vettore al suo interno
    q_pp_ekf(1,i) = x_ekf(1,1,i_ekf);                                   %creo un vettore con tutte le q ad ogni istante
    q_pp_ekf(2,i) = z_ekf(i_ekf,1);
    q_pp_ekf(3,i) = x_ekf(2,1,i_ekf);
end

%ricampionamento temporale a dt_animazione per il filtro a particelle
%time_mod  =  0 : 0.033 : tout(end);
q_pp_part  =  zeros(3,size(time_mod,2));
for i  =  1 : size(time_mod,2)
    [d, i_part]  =  min(abs(tout-time_mod(i)));                        %abs restituisce il valore assoluto di ogni elemento del vettore al suo interno
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

%variabile creata a causa di un errore dato da matlab utilizzando la variabile tout
% tempo = zeros(size(q_ekf,3),1);                     
% for i = 1 : 1 : size(q_ekf,3)
%     tempo(i) = tout(i);
% end
tempo = tout;

% genero un vettore per ogni variabile di stato di modello e filtri (anche regolarizzazione)
% in modo da passare ai plot vettori di dimensioni minori di 3 (altrimenti da errore)
x_mod = zeros(size(x_ekf,3),1);
x_EKF = zeros(size(x_ekf,3),1);
x_EKF_smooth = zeros(size(x_ekf,3),1);
x_PF = zeros(size(x_ekf,3),1);

x_d_mod = zeros(size(x_ekf,3),1);
x_d_EKF = zeros(size(x_ekf,3),1);
x_d_EKF_smooth = zeros(size(x_ekf,3),1);
x_d_PF = zeros(size(x_ekf,3),1);

theta_mod = zeros(size(x_ekf,3),1);
theta_EKF = zeros(size(x_ekf,3),1);
theta_EKF_smooth = zeros(size(x_ekf,3),1);
theta_PF = zeros(size(x_ekf,3),1);

theta_d_mod = zeros(size(x_ekf,3),1);
theta_d_EKF = zeros(size(x_ekf,3),1);
theta_d_EKF_smooth = zeros(size(x_ekf,3),1);
theta_d_PF = zeros(size(x_ekf,3),1);

for i = 1 : 1 : size(x_ekf,3)
    x_mod(i) = q_mod(1,1,i);
    x_EKF(i) = funivia.x_hat_EKF_Correction.Data(1,1,i);
    x_EKF_smooth(i) = x_ekf(1,1,i);
    x_PF(i) = x_hat_part(1,1,i);

    x_d_mod(i) = q_d_mod(1,1,i);
    x_d_EKF(i)  = funivia.x_hat_EKF_Correction.Data(3,1,i);
    x_d_EKF_smooth(i) = x_ekf(3,1,i);
    x_d_PF(i) = x_hat_part(3,1,i);

    theta_mod(i) = q_mod(2,1,i);
    theta_EKF(i) = funivia.x_hat_EKF_Correction.Data(2,1,i);
    theta_EKF_smooth(i) = x_ekf(2,1,i);
    theta_PF(i) = x_hat_part(2,1,i);

    theta_d_mod(i) = q_d_mod(2,1,i);
    theta_d_EKF(i)  = funivia.x_hat_EKF_Correction.Data(4,1,i);
    theta_d_EKF_smooth(i) = x_ekf(4,1,i);
    theta_d_PF(i) = x_hat_part(4,1,i);
end

%% Plot grafici modello 

figure('color','white','WindowState','maximized')

%creo i subplot
subplot(2,2,1,'position',[0.05, 0.55, 0.42 ,0.4])
hold on
grid on
box on
plot(tempo, x_mod , 'k', 'LineWidth', 2.5)
plot(tempo, x_EKF,'r', 'LineWidth', 2)
% plot(tempo, x_EKF_smooth ,'g-.', 'LineWidth',2 )
plot(tempo, x_PF,'b', 'LineWidth', 2)
ylabel('x [m]')
xlabel('time [s]')
legend('x','x-EKF','x-PF') %'x-EKF-smooth',
set(gca, 'FontSize', 14);  % Imposta la grandezza del font per l'asse corrente
hold off

subplot(2,2,2,'position',[0.55, 0.55, 0.42 ,0.4])
hold on
grid on
box on
plot(tempo, theta_mod , 'k', 'LineWidth', 2.5)
plot(tempo, theta_EKF,'r', 'LineWidth', 2)
% plot(tempo, theta_EKF_smooth ,'g-.', 'LineWidth',2 )
plot(tempo, theta_PF,'b', 'LineWidth', 2)
ylabel('theta [m]')
xlabel('time [s]')
legend('theta','theta-EKF','theta-PF') %'theta-EKF-smooth',
set(gca, 'FontSize', 14);  % Imposta la grandezza del font per l'asse corrente
hold off

subplot(2,2,3,'position',[0.05, 0.075, 0.42 ,0.4])
hold on
grid on
box on
plot(tempo, x_d_mod , 'k', 'LineWidth', 2.5)
plot(tempo, x_d_EKF,'r', 'LineWidth', 2)
% plot(tempo, x_d_EKF_smooth ,'g-.', 'LineWidth',2 )
plot(tempo, x_d_PF,'b', 'LineWidth', 2)
ylabel('x_{dot} [m]')
xlabel('time [s]')
legend('x_{dot}','x_{dot}-EKF','x_{dot}-PF') %,'x_{dot}-EKF-smooth'
set(gca, 'FontSize', 14);  % Imposta la grandezza del font per l'asse corrente
hold off

subplot(2,2,4,'position',[0.55, 0.075, 0.42 ,0.4])
hold on
grid on
box on
plot(tempo, theta_d_mod , 'k', 'LineWidth', 2.5)
plot(tempo, theta_d_EKF,'r', 'LineWidth', 2)
% plot(tempo, theta_d_EKF_smooth ,'g-.', 'LineWidth',2 )
plot(tempo, theta_d_PF,'b', 'LineWidth', 2)
ylabel('theta_{dot} [m]')
xlabel('time [s]')
legend('theta_{dot}','theta_{dot}-EKF','theta_{dot}-PF') %,'theta_{dot}-EKF-smooth'
set(gca, 'FontSize', 14);  % Imposta la grandezza del font per l'asse corrente
hold off

%% plot regolarizzazione EKF

%plot x
figure('color','white','WindowState','maximized')
hold on
grid on
box on
plot(tempo, x_mod , 'b', 'LineWidth', 2)
plot(tempo, x_EKF,'r', 'LineWidth', 2)
plot(tempo, x_EKF_smooth ,'g-.', 'LineWidth',2 )
ylabel('x [m]')
xlabel('time [s]')
legend('x','x-EKF','x-EKF-smooth')
set(gca, 'FontSize', 14);  % Imposta la grandezza del font per l'asse corrente
hold off

%plot theta
figure('color','white','WindowState','maximized')
hold on
grid on
box on
plot(tempo, theta_mod , 'b', 'LineWidth', 2)
plot(tempo, theta_EKF,'r', 'LineWidth', 2)
plot(tempo, theta_EKF_smooth ,'g-.', 'LineWidth',2 )
ylabel('theta [m]')
xlabel('time [s]')
legend('theta','theta-EKF','theta-EKF-smooth')
set(gca, 'FontSize', 14);  % Imposta la grandezza del font per l'asse corrente
hold off

%% plot errori

figure('color','white','WindowState','maximized')

%creo i subplot
subplot(2,2,1,'position',[0.05, 0.55, 0.42 ,0.4])
hold on
grid on
box on
e_x_EKF = x_mod - x_EKF;
plot(tempo, e_x_EKF,'r', 'LineWidth', 2)
e_x_PF = x_mod - x_PF;
plot(tempo, e_x_PF,'b', 'LineWidth', 2)
ylabel('x [m]')
xlabel('time [s]')
legend('e-x-EKF','e-x-PF') %'x-EKF-smooth',
set(gca, 'FontSize', 14);  % Imposta la grandezza del font per l'asse corrente
hold off

subplot(2,2,2,'position',[0.55, 0.55, 0.42 ,0.4])
hold on
grid on
box on
e_theta_EKF = theta_mod - theta_EKF;
plot(tempo, e_theta_EKF,'r', 'LineWidth', 2)
e_theta_PF = theta_mod - theta_PF;
plot(tempo, e_theta_PF,'b', 'LineWidth', 2)
ylabel('theta [m]')
xlabel('time [s]')
legend('e-theta-EKF','e-theta-PF') %'theta-EKF-smooth',
set(gca, 'FontSize', 14);  % Imposta la grandezza del font per l'asse corrente
hold off

subplot(2,2,3,'position',[0.05, 0.075, 0.42 ,0.4])
hold on
grid on
box on
e_x_d_EKF = x_d_mod - x_d_EKF;
plot(tempo, e_x_d_EKF,'r', 'LineWidth', 2)
e_x_d_PF = x_d_mod - x_d_PF;
plot(tempo, e_x_d_PF,'b', 'LineWidth', 2)
ylabel('x_{dot} [m]')
xlabel('time [s]')
legend('e-x_{dot}-EKF','e-x_{dot}-PF') %,'x_{dot}-EKF-smooth'
set(gca, 'FontSize', 14);  % Imposta la grandezza del font per l'asse corrente
hold off

subplot(2,2,4,'position',[0.55, 0.075, 0.42 ,0.4])
hold on
grid on
box on
e_theta_d_EKF = theta_d_mod - theta_d_EKF;
plot(tempo, e_theta_d_EKF,'r', 'LineWidth', 2)
e_theta_d_PF = theta_d_mod - theta_d_PF;
plot(tempo, e_theta_d_PF,'b', 'LineWidth', 2)
ylabel('theta_{dot} [m]')
xlabel('time [s]')
legend('e-theta_{dot}-EKF','e-theta_{dot}-PF') %,'theta_{dot}-EKF-smooth'
set(gca, 'FontSize', 14);  % Imposta la grandezza del font per l'asse corrente
hold off


