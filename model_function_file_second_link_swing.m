function [dx, y] = model_function_file_second_link_swing(t, x, L2, m_2, b2, g, varargin)
% Subsitutions made from nonlinfun value
%
% Parameters: %L2, m_2, b2, g

%vars: x=
%x(1) - theta2
%x(2) - omega2


dx = [x(2);
      -b2/m*x(2)-g/L2*sin(x(1))];

y = [x(1); x(2)];
end