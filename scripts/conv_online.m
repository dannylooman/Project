function y = conv_online(u)
persistent c1 c2 corr prev
        
if isempty(c1)
    c1 = 1;
    c2 = 1;
    corr = 0;
    prev = zeros(5,1);
    return
end

if u-prev(1) > 1 || c1 > 1                        % when detecting a jump bigger than 1
    if (prev(c1) - u < -5.6)                      % check if we jumped at least 5.6 in value
        corr = corr - 2*pi;                             % if yes correct with 2 pi
        c1 = 1;                                         % reset counter
    else
        c1 = c1+1;                                      % if jump is smaller than 5.6 increment counter
        if c1 > 5                                       % if in 5 samples we have not made a sufficiently big jump, reset counter
            c1 = 1;
        end
    end
elseif u-prev(1) < -1 || c2 > 1
    if (prev(c2) - u > 5.6)
        corr = corr + 2*pi;
        c2 = 1;
    else
        c2 = c2+1;
        if c2 > 5
            c2 = 1;
        end
    end
end
prev(2:4)=prev(1:3);
prev(1)=u;
y=u+corr;
