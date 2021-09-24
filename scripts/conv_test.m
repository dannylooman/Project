function theta_out = conv_test(theta_in)

theta_out = theta_in;
theta_diff = diff(theta_in);

for i = 1:length(theta_diff)-1
    if theta_diff(i) > 5.8                       
        theta_out(i+1:end) = theta_out(i+1:end) - 2*pi;
    elseif theta_diff(i) < -5.8
        theta_out(i+1:end) = theta_out(i+1:end) + 2*pi;
    end
end
end