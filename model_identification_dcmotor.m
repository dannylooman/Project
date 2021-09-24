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
theta1 = conv_theta(theta1); %Preprocess theta1

% Transform timeseries to arrays and shrink input array to same size as
% output array

% High pass filter theta1 to remove gravity dynamics
filter_gain = Ts / 250.0;
theta1_filt = filter([1-filter_gain filter_gain-1],[1 filter_gain-1], theta1.data(:, 1));

y = [theta1_filt, theta1.data(:, 2)];
u = input.data(1:length(theta1.data), :);

z = iddata(y, u, Ts, 'Name', 'RotPendulum', 'OutputName', {'Angle'; 'Angular velocity'});

%% Subspace Identification
subspace_id_sys = n4sid(z,3,'Ts',0,'Form', 'canonical');

%% Create grey box model
file_name = 'dc_motor_model';

J = 0.0034;
K = -0.1469;
L = 0.02;
R = 0.1527;

Parameters = {'inertia',J; 'motor_constant',K; 'L',L; 'R', R};

init_sys = idgrey(file_name, Parameters, 'c');
init_sys.Structure.Parameters(1).Free = true;
init_sys.Structure.Parameters(2).Free = true;
init_sys.Structure.Parameters(3).Free = false;
init_sys.Structure.Parameters(4).Free = true;

%% Run identification
identified_system = greyest(z, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)

%% Compare results
compare(z, identified_system);

%% Transform inertia J to mass of link 1
L1 = 0.1;
J = identified_system.Report.Parameters.ParVector(1);
m1 = J/L1^2;

%% Save model
dc_motor_ss = ss(identified_system.A, identified_system.B, identified_system.C, identified_system.D);
dc_motor_ss = c2d(dc_motor_ss, Ts, 'zoh');
save('saved_data\dcmotor_sys.mat', 'dc_motor_ss');
