function theta_ret = conv_theta(theta_in)
% Function that returns a unwrapped theta function for identification and
% determines a low pass filtered derivative.

% Unwrapping
theta_out = theta_in.Data;
theta_diff = diff(theta_out);
c1 = 1; c2 = 1;

for i = 1:length(theta_diff)-1
    if theta_diff(i) > 1 || c1 > 1                          % when detecting a jump bigger than 1
        if (theta_in.Data(i-c1) - theta_in.Data(i) < -5.6)  % check if we jumped at least 5.6 in value
            theta_out(i+1:end) = theta_out(i+1:end) - 2*pi; % if yes correct with 2 pi
            c1 = 1;                                         % reset counter
        else
            c1 = c1+1;                                      % if jump is smaller than 5.6 increment counter
            if c1 > 5                                       % if in 5 samples we have not made a sufficiently big jump, reset counter
                c1 = 1;
            end
        end
    elseif theta_diff(i) < -1 || c2 > 1
        if (theta_in.Data(i-c2) - theta_in.Data(i) > 5.6)
            theta_out(i+1:end) = theta_out(i+1:end) + 2*pi;
            c2 = 1;
        else
            c2 = c2+1;
            if c2 > 5
                c2 = 1;
            end
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