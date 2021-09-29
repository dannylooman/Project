%%Script used for greybox identification of rotational pendulum
% Danny Looman
clear; clc;
hwinit;

%% Create Identification data

data_array=["27-Sep-2021 14_34_03-4meas-hangin-down",...
    "27-Sep-2021 14_33_04-4meas-hangin-down",...
    "27-Sep-2021 14_31_46-4meas-hangin-down",...
    "27-Sep-2021 14_31_04-4meas-hangin-down"];

for i=1:length(data_array)
    data_array(i)='saved_data/'+data_array(i)+'.mat';
    load(data_array(i));  % dataset "saved_data/27-Sep-2021 14_33_04-4meas-hangin-down.mat"
    Ts = input.time(2) - input.time(1);  % Actual sample time

    y = [theta1.data-pi, dtheta1.data, theta2.data, dtheta2.data];
    u = input.Data(1:length(theta1.data));

    N_end = length(y);
    N_start = max(int16(0.05 * N_end), 1);  % Index integers start at 1
    z{i} = iddata(y(N_start:N_end,:), u(N_start:N_end), Ts, 'Name', 'RotPendulum', 'OutputName', {'Theta1'; 'Theta1_dot'; 'Theta2'; 'Theta2_dot';});
end

z_id = merge(z{1},z{2},z{3},z{4});

%% Linear grey box identification

% Grey box state space model
file_name = 'system_4_states_linear';

% Load identified models for first and second link
model_first_link = load("saved_data\first_link_identified_model.mat").id_sys;
model_second_link = load("saved_data\second_link_identified_model.mat").identified_system_linear;
model_second_link = c2d(idss(model_second_link), Ts);

% Create parameters
a = 0; b = 0; c = 0; d = 0;
Parameters = {'a', a; 
              'b', b; 
              'c', c; 
              'd', d};

init_sys = idgrey(file_name, Parameters, 'd', {model_first_link, model_second_link}, Ts);
init_sys.Structure.Parameters(1).Free = true;
init_sys.Structure.Parameters(2).Free = true;
init_sys.Structure.Parameters(3).Free = true;
init_sys.Structure.Parameters(4).Free = true;

% Run linear identification
opt = greyestOptions;
opt.Display = 'on';
opt.SearchOptions.MaxIterations = 50;

identified_system = greyest(z_id, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)

%% Compare results
figure()
compare(z{1}, identified_system);
figure()
compare(z{2}, identified_system);
figure()
compare(z{3}, identified_system);
figure()
compare(z{4}, identified_system);

%% Validation data
load("saved_data/27-Sep-2021 14_34_03-4meas-hangin-down.mat");  % first link data
Ts = input.time(2) - input.time(1);  % Actual sample time

y_val = [theta1.data-pi, dtheta1.data, theta2.data, dtheta2.data];
u_val = input.Data(1:length(theta1.data));

N_end = length(y_val);
N_start = max(int16(0.1 * N_end), 1);  % Index integers start at 1
z_val = iddata(y_val(N_start:N_end,:), u_val(N_start:N_end), Ts, 'Name', 'RotPendulum', 'OutputName', {'Theta1'; 'Theta1_dot'; 'Theta2'; 'Theta2_dot';});
compare(z_val, identified_system);

%% Save model
if 1
    sys = identified_system;
    save("saved_data/model_full_system_4_states", 'sys')
end