m11 = 19;   %[kg]
m22 = 35;   %[kg]
m33 = 4;   %[kg]

d11 = 3;    %[kg/s]
d22 = 10;    %[kg/s]
d33 = 1;    %[kg/s]

params = [m11, m22, m33, d11, d22, d33];

tau_u_0 = 0;
tau_r_0 = 0;

u_0 = 0;
v_0 = 0;
r_0 = 0;

x_0 = 0;
y_0 = 0;
phi_0 = 0;

% TODO
Km1 = 1;
Km2 = 1;
Tm1 = 1;
Tm2 = 1;
T1 = 1;

%% sensors

gps_var = 10;
heading_var = 1;
f_s = 100;


