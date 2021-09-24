function y = conv_online(u)
persistent corr prev
        
if isempty(corr)
    corr = 0;
    prev = 0;
end

if u-prev(1) > 5.8
    corr = corr - 2*pi;                
elseif u-prev(1) < -5.8
    corr = corr + 2*pi;
end
prev=u;
y=u+corr;
