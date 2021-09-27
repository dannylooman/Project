function theta_ret = merge_theta(theta_in, dtheta_in)
% Function that returns a unwrapped theta function for identification and
% determines a low pass filtered derivative.

theta_ret = timeseries([theta_in.data, dtheta_in.data], theta_in.time);
end