% Sensor saving script

filename = replace(strcat("saved_data\", datestr(datetime), "-second_link_fast.mat"),':','_');
save(filename, 'theta1', 'theta2', 'input')