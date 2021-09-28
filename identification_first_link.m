%%Script used for greybox identification of rotational pendulum
% Danny Looman
clear; clc;
hwinit;

%% Create Identification data
load("saved_data/27-Sep-2021 15_45_53-first_link_only.mat");  % first link data

Ts = input.time(2) - input.time(1);
%%
% Transform timeseries to arrays and shrink input array to same size as
% output array, multiply with -1 makes it better?

y = [theta1.data, dtheta1.data];
u = input.Data(1:length(theta1.data));

N_end = length(y);
N_start = max(int16(0.1 * N_end), 1);  % Index integers start at 1
z = iddata(y(N_start:N_end,:), u(N_start:N_end), Ts, 'Name', 'RotPendulum', 'OutputName', {'Angle'; 'Angular velocity'});

%% Linear grey box identification
file_name = 'model_function_file_first_link_linear';

L2 = 0.0881;
b2 = 0.8089;
g = 9.806;
K = 0.2;

Parameters = {'length', L2; 'damping',b2; 'gravity', g; 'Motor Constant', K};

init_sys = idgrey(file_name, Parameters, 'c');
init_sys.Structure.Parameters(1).Free = false;
init_sys.Structure.Parameters(2).Free = true;
init_sys.Structure.Parameters(3).Free = false;
init_sys.Structure.Parameters(4).Free = true;

% Run linear identification
opt = greyestOptions;
opt.Display = 'on';
opt.SearchOptions.MaxIterations = 50;

identified_system = greyest(z, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)

%%
id_sys = ssest(z, 2, 'Ts', Ts, 'DisturbanceModel', 'none', 'Form', 'canonical');

% Compare results
compare(z, identified_system, id_sys);

%% Validation data
load("saved_data/28-Sep-2021 10_31_04-first_link_validation.mat");  % first link data
y_val = [theta1.data, dtheta1.data];
u_val = input.Data(1:length(theta1.data));

N_end = length(y_val);
N_start = max(int16(0.1 * N_end), 1);  % Index integers start at 1
z_val = iddata(y_val(N_start:N_end,:), u_val(N_start:N_end), Ts, 'Name', 'RotPendulum', 'OutputName', {'Angle'; 'Angular velocity'});

compare(z_val, id_sys);