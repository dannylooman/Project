function [dx, y] = model_function_file_second_link_nonlin(t, x, u, L2, m2, b2, g, c2, varargin)
% Subsitutions made from nonlinfun value
%
% Parameters: %L2, m2, b2, g, c2
% u - input placeholder

%vars: x=
%x(1) - theta2
%x(2) - omega2


dx = [x(2);
      -b2/m2*x(2)-g/L2*sin(x(1))-c2*sign(chop_down(x(2)))];

y = [x(1); x(2)];
end