function theta_ret = merge_theta(theta_in, dtheta_in)
% Function that returns a unwrapped theta function for identification and
% determines a low pass filtered derivative.

theta_ret = timeseries([theta_in.data(2:end), dtheta_in.data(2:end)], theta_in.time(2:end));
end