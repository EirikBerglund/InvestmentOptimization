function [ P p ] = makeADPrices( R,pi, Rf )
%MAKEADPRICES Calculates state prices
%   Bases calculation on aggregate supply and probability distribution
M = size(R,1);
N = size(R,2);

as = sum(R,2);

SUM_P = 1/Rf;

p = zeros(M,1);

p(1) = 1;
for m=2:M
    p(m) = (pi(m)/pi(m-1))*(as(m-1)/as(m))*p(m-1);
end

% Normalize
p = p./sum(p);
p = p.*(SUM_P/1);

P = zeros(N,1);
for n=1:N
    P(n) = p'*R(:,n);
end


end

