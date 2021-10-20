%%Script used for greybox identification of rotational pendulum
% Danny Looman
clear; clc;
hwinit;

%% Create Identification data

first_link_down = true;
% first link down - second link down
% data_array=["27-Sep-2021 14_34_03-4meas-hangin-down",...
%             "27-Sep-2021 14_33_04-4meas-hangin-down",...
%             "27-Sep-2021 14_31_46-4meas-hangin-down",...
%             "27-Sep-2021 14_31_04-4meas-hangin-down"];

% data_array=["18-Oct-2021 13_31_52-full_system_100hz",...
%             "18-Oct-2021 13_32_43-full_system_100hz",...
%             "19-Oct-2021 11_59_15-identification_down_down_backandforth"];   
        
        
data_array=["20-Oct-2021 11_07_25-no_delay_sys_1",...
            "20-Oct-2021 11_11_21-no_delay_sys_3",...
            "20-Oct-2021 11_09_51-no_delay_sys_2"];   
        
% data_array=["19-Oct-2021 11_59_15-identification_down_down_backandforth"];
        
% first link up - second link down
% data_array=["29-Sep-2021 10_51_39-id_upward_hangin",...
%             "29-Sep-2021 10_52_11-id_upward_hangin",...
%             "29-Sep-2021 10_52_56-id_upward_hangin",...
%             "29-Sep-2021 10_54_59-id_upward_hangin"];

for i=1:length(data_array)
    data_array(i)='saved_data/'+data_array(i)+'.mat';
    load(data_array(i));  % dataset "saved_data/27-Sep-2021 14_33_04-4meas-hangin-down.mat"
    Ts = input.time(2) - input.time(1);  % Actual sample time
    
    if first_link_down
        y = [theta1.data - pi, dtheta1.data, theta2.data, dtheta2.data];
    else
        y = [theta1.data, dtheta1.data, theta2.data, dtheta2.data];
    end
    u = input.Data(1:length(theta1.data));

    N_end = length(y);
    N_start = max(int32(0.05 * N_end), 1);  % Index integers start at 1
    z{i} = iddata(y(N_start:N_end,:), u(N_start:N_end), Ts, 'Name', 'RotPendulum', 'OutputName', {'Theta1'; 'Theta1_dot'; 'Theta2'; 'Theta2_dot';});
end

z_id = merge(z{:});

%% Linear grey box identification
% Grey box state space model
file_name = 'system_4_states_linear';

% Load identified models for first and second link
model_first_link = load("saved_data\first_link_identified_model.mat").identified_system;
model_second_link = load("saved_data\second_link_identified_model.mat").identified_system_linear;

% Create parameters with random initial values
a = 100*randn(); b = 100*randn(); c = 100*randn(); d = -0.8233;
Parameters = {'a', a; 
              'b', b;
              'c', c;
              'd', d;};

% init_sys = idgrey(file_name, Parameters, 'd', {model_first_link, model_second_link}, Ts);
init_sys = idgrey(file_name, Parameters, 'c', {model_first_link, model_second_link});
init_sys.Name = "Identified system";
init_sys.Structure.Parameters(1).Free = true;
init_sys.Structure.Parameters(2).Free = true;
init_sys.Structure.Parameters(3).Free = true;
init_sys.Structure.Parameters(4).Free = true;

% Run linear identification
opt = greyestOptions;
opt.Display = 'off';
opt.InitialState = 'estimate';
opt.SearchOptions.MaxIterations = 50;
opt.EnforceStability = true;

identified_system = greyest(z_id, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)

%% Compare results
for i=1:length(data_array)
    clf(figure(i)); figure(i);
    compare(getexp(z_id, i), identified_system); hold on;
    title(strcat("Trainingset ", num2str(i)));
end

%% Validation data
load("saved_data/27-Sep-2021 14_34_03-4meas-hangin-down.mat");  % first link data
Ts = input.time(2) - input.time(1);  % Actual sample time

y_val = [theta1.data-pi, dtheta1.data, theta2.data, dtheta2.data];
u_val = input.Data(1:length(theta1.data));

N_end = length(y_val);
N_start = max(int16(0.1 * N_end), 1);  % Index integers start at 1
z_val = iddata(y_val(N_start:N_end,:), u_val(N_start:N_end), Ts, 'Name', 'RotPendulum', 'OutputName', {'Theta1'; 'Theta1_dot'; 'Theta2'; 'Theta2_dot';});

figure();
compare(z_val, identified_system); hold on;
title("Validation dataset");

%% Save model
if 1
    sys = identified_system;
    save("saved_data/model_full_system_4_states", 'sys')
end