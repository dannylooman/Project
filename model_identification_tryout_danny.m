%%Script used for greybox identification of rotational pendulum
% Danny Looman
%clear; clc;

%% Create option structure
opt = nlgreyestOptions;
opt.Display = 'on';
opt.SearchOptions.MaxIterations = 50;

%% Create Identification data
load("saved_data\07-Sep-2021 11_44_42.mat");
Ts = input.time(2) - input.time(1);

% Transform timeseries to arrays and shrink input array to same size as
% output array, multiply with -1 makes it better?
y = [unwrap(theta1.Data), unwrap(theta2.Data)];
u = input.Data(1:length(theta1.Data), :);

z = iddata(y, u, Ts, 'Name', 'RotPendulum', 'Inputunit', 'V', 'OutputUnit', ['rad'; 'rad']);

%% Create grey box model
file_name = 'model_function_file';
Order = [2 1 5];  % 2 outputs, 1 input, 5 states

Parameters = [struct('Name', 'L1',  'Value', 0.1000, 'Unit', 'm',     'Minimum', 0.05,  'Maximum', 0.15, 'Fixed', true);
              struct('Name', 'L2',  'Value', 0.0884, 'Unit', 'm',     'Minimum', 0.05,  'Maximum', 0.15, 'Fixed', true);
              struct('Name', 'm_1', 'Value', 0.1000, 'Unit', 'kg',    'Minimum', 0.00,  'Maximum', 0.20, 'Fixed', true);
              struct('Name', 'm_2', 'Value', 0.1124, 'Unit', 'kg',    'Minimum', 0.00,  'Maximum', 100.00, 'Fixed', true);
              struct('Name', 'C1',  'Value', 0.7500, 'Unit', '-',     'Minimum', 0.30,  'Maximum', 1.00, 'Fixed', true);
              struct('Name', 'b2',  'Value', 0.0125, 'Unit', '-',     'Minimum', 0.00,  'Maximum', 0.10, 'Fixed', true);
              struct('Name', 'g',   'Value', 9.8100, 'Unit', 'm/s^2', 'Minimum', 0.00,  'Maximum', 10.0, 'Fixed', true);
              struct('Name', 'R_a', 'Value', 0.2000, 'Unit', 'Ohm',   'Minimum', 0.00,  'Maximum', 5.00, 'Fixed', true);
              struct('Name', 'K_m', 'Value', -0.050, 'Unit', '-',     'Minimum', -5.00, 'Maximum', 5.00, 'Fixed', true);
              struct('Name', 'L_a', 'Value', 3e-06, 'Unit', 'H',     'Minimum', 0.00,  'Maximum', 5.00, 'Fixed', true);
              ];

InitialStates = [struct('Name', 'x1', 'Value', theta1.Data(1), 'Unit', 'rad',   'Minimum', -pi, 'Maximum', pi, 'Fixed', true);
                 struct('Name', 'x2', 'Value', theta2.Data(1), 'Unit', 'rad',   'Minimum', -pi, 'Maximum', pi, 'Fixed', true);
                 struct('Name', 'x3', 'Value', 0.0, 'Unit', 'A',     'Minimum', -0.5, 'Maximum', 0.5, 'Fixed', true);
                 struct('Name', 'x4', 'Value', 0.0, 'Unit', 'rad/s', 'Minimum', -0.5, 'Maximum', 0.5, 'Fixed', true);
                 struct('Name', 'x5', 'Value', 0.0, 'Unit', 'rad/s', 'Minimum', -0.5, 'Maximum', 0.5, 'Fixed', true);
                ];
Sample_time = 0; % Continuous model

init_sys = idnlgrey(file_name, Order, Parameters, InitialStates, Sample_time, 'Name', 'Rotational Pendulum');

%% Run identification
identified_system = nlgreyest(z, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)

%% Compare results
compare(z, identified_system);