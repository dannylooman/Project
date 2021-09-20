function theta_ret = conv_theta(theta_in)
% Function that returns a unwrapped theta function for identification and
% determines a low pass filtered derivative.

% Unwrapping
theta_out = theta_in.Data;
theta_diff = diff(theta_out);
for i = 1:length(theta_diff)-1
    if theta_diff(i) > 6
        if (theta_in.Data(i) < -3 & theta_in.Data(i+1) > 3)
            theta_out(i+1:end) = theta_out(i+1:end) - 2*pi;
        end
    elseif theta_diff(i) < -6
        if (theta_in.Data(i) > 3 & theta_in.Data(i+1) < -3)
            theta_out(i+1:end) = theta_out(i+1:end) + 2*pi;
        end
    end
end

theta_ret.time = theta_in.time;
theta_ret.angle = remove_spikes(theta_out,50);

% Differentiating
dt = theta_in.time(2) - theta_in.time(1);
filter_gain = dt / 0.03;
theta_ret.dot = diff(filter(filter_gain, [1, filter_gain - 1], theta_ret.angle))/dt;

% Resize time and angle datasets:
theta_ret.time = theta_ret.time(2:end);
theta_ret.angle = theta_ret.angle(2:end);
theta_ret = timeseries([theta_ret.angle,theta_ret.dot],theta_ret.time);
end