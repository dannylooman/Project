function [A,B,C,D] = dc_motor_model(J, K, L, R, Ts)
A = [0, 1, 0; 
     0, 0, K/J; 
     0, -K/L, -R/L];
B = [0; 0; 1/L];

C = [1, 0, 0;
     0, 1, 0];
 
D = [0; 0];
end 

