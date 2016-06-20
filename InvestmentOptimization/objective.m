function [ util ] = objective( x,X,gamma,MultiPeriod )
%OBJECTIVE Calculates expected utility for a power utility investor.

% Initialize util to zero
util = 0;

% Hardcoded for four states/assets
if MultiPeriod
    for m=1:4
        util = util + powerUtility(X(m,:)*x(5:8),gamma);
        util = util + powerUtility(X(m,:)*x(9:12),gamma);
        util = util + powerUtility(X(m,:)*x(13:16),gamma);
        util = util + powerUtility(X(m,:)*x(17:20),gamma);
    end
else 
    % This is generic, allowing for any number of assets/states
    % as long as they are equal.
    for m=1:size(x,1)
        util = util + powerUtility(X(m,:)*x,gamma);
    end
end
    

% Because fmincon solver minimizes and we want to maximize
util = -util;

end

