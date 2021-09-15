%%Script used for greybox identification of rotational pendulum
% Danny Looman
clear; clc;

%% Create option structure
opt = greyestOptions;
opt.Display = 'on';
opt.SearchOptions.MaxIterations = 50;

%% Create Identification data
load("saved_data\15-Sep-2021 09_23_40-freq_sweep_stationary_second_link.mat");
Ts = input.time(2) - input.time(1);

% Transform timeseries to arrays and shrink input array to same size as
% output array, multiply with -1 makes it better?
y = conv_theta(theta1).data;
% y = unwrap(theta1.Data);
u = input.Data(1:length(theta1.Data), :);

z = iddata(y, u, Ts, 'Name', 'RotPendulum', 'Inputunit', 'V', 'OutputUnit', 'rad');

%% Subspace Identification
subspace_id_sys = n4sid(z,3,'Ts',0,'Form', 'canonical');

%% Create grey box model
% J, b, K, L, R
file_name = 'dc_motor_model';
Order = [1 1 3];  % 1 outputs, 1 input, 3 states

J = 0.005;
b = 0;
K = -0.1368;
L = 0.0025;
R = 0.08;

Parameters = {'inertia',J; 'friction',b; 'motor_constant',K; 'L',L; 'R', R};


init_sys = idgrey(file_name, Parameters, 'c', 'Name', 'Rotational Pendulum');
init_sys.Structure.Parameters(1).Free = false;
init_sys.Structure.Parameters(2).Free = false;
init_sys.Structure.Parameters(3).Free = false;
init_sys.Structure.Parameters(4).Free = false;
init_sys.Structure.Parameters(5).Free = false;

%% Run identification
identified_system = greyest(z, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)

%% Compare results
compare(z, identified_system);

disp(identified_system.A);
disp(subspace_id_sys.A);
