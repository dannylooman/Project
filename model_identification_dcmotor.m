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
y = [theta1.angle, theta1.dot];
u = input.Data(1:length(theta1.angle), :);

z = iddata(y, u, Ts, 'Name', 'RotPendulum');

%% Subspace Identification
subspace_id_sys = n4sid(z,3,'Ts',0,'Form', 'canonical');

%% Create grey box model
file_name = 'dc_motor_model';

J = 0.0084;
b = 0.0076;
K = -0.1411;
L = 0.0003;
R = 0.0814;

Parameters = {'inertia',J; 'friction',b; 'motor_constant',K; 'L',L; 'R', R};

init_sys = idgrey(file_name, Parameters, 'c');
init_sys.Structure.Parameters(1).Free = true;
init_sys.Structure.Parameters(2).Free = true;
init_sys.Structure.Parameters(3).Free = true;
init_sys.Structure.Parameters(4).Free = true;
init_sys.Structure.Parameters(5).Free = true;

%% Run identification
identified_system = greyest(z, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)

%% Compare results
compare(z, identified_system);

%% Save model
dc_motor_ss = ss(identified_system);
save('saved_data\dcmotor_sys.mat', 'dc_motor_ss');
