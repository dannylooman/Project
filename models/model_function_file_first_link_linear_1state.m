function [A,B,C,D] = model_function_file_first_link_linear_1state(c, K1, Ts)
% Subsitutions made from nonlinfun value
%
% Parameters: %L2, m2, b2, g, c2
% input: no input is applied 

%vars: x=
%x(1) - theta2
%x(2) - theta2_dot

A = [c];
     
B = [K1];

C = [1];
 
D = [0];
%theta''*m2*L2^2 = -b2*theta' - g*m*L2*sin(theta)
end