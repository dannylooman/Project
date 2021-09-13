function [dx, y] = model_function_file(t, x, u, L1, L2, m_1, m_2, C1, b2, g, R_a, K_m, L_a, varargin)
% Subsitutions made from nonlinfun value
%
% Parameters: %L1, L2, m_1, m_2, C1, b2, g, R_a, K_m ,L_a

%vars:
%x(1) - theta1
%x(2) - theta2
%x(3) - i
%x(4) - omega1
%x(5) - omega2


dx = [x(4);
      x(5);
      -(K_m*x(4) - u + R_a*x(3))/L_a;
      (L1*L2*m_2*sin(x(2))*x(5)^2 + 2*L1*L2*m_2*x(4)*sin(x(2))*x(5) + K_m*x(3) + L2*g*m_2*sin(x(1) + x(2)) + L1*g*m_2*sin(x(1)) + C1*L1*g*m_1*sin(x(1)))/(m_1*C1^2*L1^2 - m_2*L1^2*cos(x(2))^2 + m_2*L1^2) + ((L2 + L1*cos(x(2)))*(L1*L2*m_2*sin(x(2))*x(4)^2 + b2*x(5) - L2*g*m_2*sin(x(1) + x(2))))/(L2*m_1*C1^2*L1^2 - L2*m_2*L1^2*cos(x(2))^2 + L2*m_2*L1^2);
      - ((L2 + L1*cos(x(2)))*(L1*L2*m_2*sin(x(2))*x(5)^2 + 2*L1*L2*m_2*x(4)*sin(x(2))*x(5) + K_m*x(3) + L2*g*m_2*sin(x(1) + x(2)) + L1*g*m_2*sin(x(1)) + C1*L1*g*m_1*sin(x(1))))/(L2*m_1*C1^2*L1^2 - L2*m_2*L1^2*cos(x(2))^2 + L2*m_2*L1^2) - ((L1*L2*m_2*sin(x(2))*x(4)^2 + b2*x(5) - L2*g*m_2*sin(x(1) + x(2)))*(m_1*C1^2*L1^2 + m_2*L1^2 + 2*m_2*cos(x(2))*L1*L2 + m_2*L2^2))/(L2*m_2*(L2*m_1*C1^2*L1^2 - L2*m_2*L1^2*cos(x(2))^2 + L2*m_2*L1^2))];

y = [x(1); x(2)];
end