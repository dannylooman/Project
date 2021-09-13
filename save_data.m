% Sensor saving script

filename = replace(strcat("saved_data\", datestr(datetime), "-freq_sweep.mat"),':','_');
save(filename, 'theta1', 'theta2', 'input')