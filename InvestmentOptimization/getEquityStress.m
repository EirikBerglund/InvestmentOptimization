function [ MKTeq ] = getEquityStress( x,P,SCRLevels )
%GETEQUITYSTRESS Returns the calculation of Solvency II equity stress
%   Follows the procedure given in the Solvency II standard formula
%   Assumes asset 0 riskless, asset 1 equity group one and asset 2 and 3
%   in equity group two.

% Convert units invested to dollars invested
for i=1:size(x,1)
    x(i) = x(i)*P(i);
end

if x(2)>0
    MKTeqI(1) = x(2)*SCRLevels(1);
else 
    MKTeqI(1)=0;
end

%A2 invested
if x(3) > 0 && x(4) > 0
    x2 = x(3)+x(4);
elseif x(3) > 0
    x2 = x(3);
elseif x(4) > 0
    x2 = x(4);
else
    x2 = 0;
end

MKTeqI(2) =x2*SCRLevels(2);

% Directly inputting the correlation matrix
MKTeq=sqrt(MKTeqI(1)^2+MKTeqI(2)^2 + 2*0.75*MKTeqI(1)*MKTeqI(2));

end

