function [y_spikefree] = remove_spikes(y, smoothing_length)
%REMOVE_SPIKES Summary of this function goes here
%   y - inputsequence of data with spikes that needs to be removed
y_spikefree = y;

% Use as a thresshold the derivative
N = length(y);
tresshold_spike = diff(y);


% Check for spikes over input signal
index = [];
for i = 1:N-1
    if abs(tresshold_spike(i)) > 0.5
        index = [index i];       
    end
end

% if the end of the peak is in the dataset, length(index) must be even
for i = 1:1:length(index)
    x = [index(i)-smoothing_length, index(i)+smoothing_length];
    v = [y(index(i)-smoothing_length), y(index(i)+smoothing_length)];
    xq = index(i)-smoothing_length : index(i)+smoothing_length;
    y_spikefree(xq) = interp1(x, v, xq);
end


end

