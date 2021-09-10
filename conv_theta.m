function theta_ret = conv_theta(theta_in)

theta_out = theta_in.Data;
dtheta = diff(theta_out);

for i = 1:length(dtheta)-1
    if dtheta(i) > 6
        if (theta_in.Data(i) < -3 & theta_in.Data(i+1) > 3)
            theta_out(i+1:end) = theta_out(i+1:end) - 2*pi;
        end
    elseif dtheta(i) < -6
        if (theta_in.Data(i) > 3 & theta_in.Data(i+1) < -3)
            theta_out(i+1:end) = theta_out(i+1:end) + 2*pi;
        end
    end
end
theta_ret = theta_in;
theta_ret.Data = theta_out;
end