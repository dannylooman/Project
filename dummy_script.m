raw = theta1.data;

figure(); hold on;
plot(theta1.time, unwrap(unwrap(raw)));
plot(theta1.time, raw);
plot(conv_theta(theta1));