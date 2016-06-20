function util = powerUtility(c,gamma)
%GETPOWERUTIL Summary of this function goes here
%   Detailed explanation goes here

if gamma==1
    util = log(c);
else
    util = (c^(1-gamma)-1)/(1-gamma);
end

end %Function

