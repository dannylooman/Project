function [A,B,C,D] = system_4_states_linear(a, b, c, d, Ts, model_first_link, model_second_link)
% Subsitutions made from nonlinfun value
%
% Parameters: bottom left submatrice of A
% input: no input is applied 

a_sub = [0, 0; a, b];
A = [model_first_link.A, zeros(2); 
     a_sub, model_second_link.A];

A = [model_first_link.A, zeros(2);
     0 0 0 1;
     a, b, c, d];
     
B = [model_first_link.B; model_second_link.B];

C = eye(4);
 
D = zeros(4, 1);
end