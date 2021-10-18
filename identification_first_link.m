%%Script used for greybox identification of frist link of rotational pendulum
% Danny Looman
clear; clc;
hwinit;

%% Create identification data from multiple experiments
data_array=["06-Oct-2021 09_44_13-first_link_100hz",...
            "06-Oct-2021 09_44_53-first_link_100hz",...
            "06-Oct-2021 09_46_01-first_link_100hz",...
            "18-Oct-2021 13_31_52-full_system_100hz",...
            "18-Oct-2021 13_32_43-full_system_100hz"];
        
for i=1:length(data_array)
    load('saved_data/' + data_array(i) + '.mat');
    Ts = input.time(2) - input.time(1);  % Actual sample time
    
    if 0
        % Convert old save format to new format
        tmp1 = conv_theta(theta1);
        y = [tmp1.data(:,1) - pi, tmp1.data(:, 2)];
        u = input.Data(1:length(theta1.data));
    else
        y = [theta1.data - pi, dtheta1.data];
        u = input.Data(1:length(theta1.data));
    end

    N_end = length(y);
    N_start = max(int32(0.05 * N_end), 1);  % Index integers start at 1
    z_tmp{i} = iddata(y(N_start:N_end,:), u(N_start:N_end, :), Ts, 'Name', 'RotPendulum', 'OutputName', {'\theta_1'; '\theta_1dot'});
end

z = merge(z_tmp{:});

%% Linear grey box identification
file_name = 'model_function_file_first_link_linear';

L1 = 10;
b1 = 2;
g = model.g;
K1 = 8.0;
K2 = 0.0;

Parameters = {'length', L1; 'damping',b1; 'gravity', g; 'Motor Constant', K1; 'Motor Constant 2', K2;};

init_sys = idgrey(file_name, Parameters, 'c');
init_sys.Structure.Parameters(1).Free = false;
init_sys.Structure.Parameters(2).Free = true;
init_sys.Structure.Parameters(3).Free = false;
init_sys.Structure.Parameters(4).Free = true;
init_sys.Structure.Parameters(5).Free = true;

% Run linear identification
opt = greyestOptions;
opt.Display = 'on';
% opt.InitialState = 'estimate';
opt.SearchOptions.MaxIterations = 50;

identified_system = greyest(z, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)


%% Compare results
for i=1:length(data_array)
    figure()
    compare(getexp(z, i), identified_system);
end

%% Validation data
load("saved_data/28-Sep-2021 10_31_04-first_link_validation.mat");  % first link data
y_val = [theta1.data, dtheta1.data];
u_val = input.Data(1:length(theta1.data));

N_end = length(y_val);
N_start = max(int16(0.1 * N_end), 1);  % Index integers start at 1
z_val = iddata(y_val(N_start:N_end,:), u_val(N_start:N_end), Ts, 'Name', 'RotPendulum', 'OutputName', {'Angle'; 'Angular velocity'});


%% Save model to file
save("saved_data/first_link_identified_model", 'identified_system')