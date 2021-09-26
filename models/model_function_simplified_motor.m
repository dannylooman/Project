function [dx, y] = model_function_simplified_motor(t, x, U, L1, L2, m2, b2, g, c, dt, varargin)
% Subsitutions made from nonlinfun value
%
% Parameters: %L1, L2, m_2, b2, g, c
persistent up
        
if isempty(up)
    up = U;
end
%vars:
%x(1) - theta1
%x(2) - theta2
%x(3) - omega1
%x(4) - omega2

dx = [c*U;          % x'(1)=x(3)=c*U
      x(4);         % x'(2)=x(4)
      c*(U-up)/dt;  % x'(3)=dx(1)/dt=c*(U-U_prev)/dt
      -b2/m2*x(4) + g/L2*sin(x(1)+x(2)) - c*(U-up)/dt - L1/L2*sin(x(2))*(c*U)^2 - L1/L2*cos(x(2))*c*(U-up)/dt];

up = U;
y = [x(1); x(2); x(3); x(4)];
end