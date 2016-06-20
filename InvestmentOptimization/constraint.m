function [ c,ceq ] = constraint(x,P,W0, MKTo,SCRLevels, X, ...
    ConstantRiskless,MultiPeriod)
%CONSTRAINT Markes up constraints for an investment optimization
%   Regular budget constraint at time one given in constraint 1. 
%   Constraint 3-4 denotes bounds on riskless investment.
%   Constraint 2 is the Solvency II constraint (comment out for regular
%   optimization). 
%   Constraints 5-8 are hardcoded budget constraints in multiperiod
%   problem.

% Budget
c(1) = x(1:4)'*P-W0;

% Solvency calculations
MKTeq = getEquityStress(x(1:4),P,SCRLevels);
c(2) = MKTeq + MKTo - W0;

if ConstantRiskless 
    c(3) = x(1)-1;
    c(4) = -x(1);
end

% Time two constraints
if MultiPeriod
    c(5) = x(5:8)'*P-X(1,:)*x(1:4);
    c(6) = x(9:12)'*P-X(2,:)*x(1:4);
    c(7) = x(13:16)'*P-X(3,:)*x(1:4);
    c(8) = x(17:20)'*P-X(4,:)*x(1:4);
end

% No equality Constraints
ceq = [];

end

