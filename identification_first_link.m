%%Script used for greybox identification of frist link of rotational pendulum
% Danny Looman
clear; clc;
hwinit;

%% Create identification data from multiple experiments
%"06-Oct-2021 09_44_13-first_link_100hz",...

%data_array = ["19-Oct-2021 10_47_14-identification_first_link_square_wave"];

data_array=["20-Oct-2021 10_55_06-no_delay_first_link_freq_sweep1",...
            "20-Oct-2021 10_55_50-no_delay_first_link_freq_sweep2",...
            "06-Oct-2021 09_46_01-first_link_100hz",...
            "20-Oct-2021 10_57_25-no_delay_first_link_ramp",...
            "20-Oct-2021 10_58_47-no_delay_first_link_pulse_generator"];
        
for i=1:length(data_array)
    load('saved_data/' + data_array(i) + '.mat');
    Ts = input.time(2) - input.time(1);  % Actual sample time
    
    y = [theta1.data - pi, dtheta1.data];
    u = input.Data(1:length(theta1.data));   

    N_end = length(y);
    N_start = max(int32(0.05 * N_end), 1);  % Index integers start at 1
    z_tmp{i} = iddata(y(N_start:N_end,:), u(N_start:N_end, :), Ts, 'Name', 'RotPendulum', 'OutputName', {'\theta_1'; '\theta_1dot'});
end

z_id = merge(z_tmp{:});

%% Linear grey box identification
file_name = 'model_function_file_first_link_linear';

L1 = 0.1;
b1 = 30;
c = 1;
g = model.g;
K1 = 0.0;
K2 = 10.0;

Parameters = {'length', L1; 
              'damping',b1; 
              'constant', c; 
              'gravity', g; 
              'Motor Constant', K1; 
              'Motor Constant 2', K2;};

init_sys = idgrey(file_name, Parameters, 'c');
init_sys.Structure.Parameters(1).Free = false;
init_sys.Structure.Parameters(2).Free = true;
init_sys.Structure.Parameters(3).Free = false;
init_sys.Structure.Parameters(4).Free = false;
init_sys.Structure.Parameters(5).Free = false;
init_sys.Structure.Parameters(6).Free = true;

% Run linear identification
opt = greyestOptions;
opt.Display = 'on';
opt.InitialState = 'estimate';
opt.SearchOptions.MaxIterations = 50;

identified_system = greyest(z_id, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)

%% Compare results
for i=1:length(data_array)
    clf(figure(i)); figure(i);
    compare(getexp(z_id, i), identified_system); hold on;
    title(strcat("Trainingset ", num2str(i)));
end

%% Validation data
load("saved_data/28-Sep-2021 10_31_04-first_link_validation.mat");  % first link data
y_val = [theta1.data, dtheta1.data];
u_val = input.Data(1:length(theta1.data));

N_end = length(y_val);
N_start = max(int32(0.05 * N_end), 1);  % Index integers start at 1
z_val = iddata(y_val(N_start:N_end,:), u_val(N_start:N_end), Ts, 'Name', 'RotPendulum', 'OutputName', {'Angle'; 'Angular velocity'});

figure();
compare(z_val, identified_system); hold on;
title("Validation dataset");

%% Save model to file
save("saved_data/first_link_identified_model", 'identified_system')