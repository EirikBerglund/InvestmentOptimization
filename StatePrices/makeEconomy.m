function Economy = makeEconomy(N,M,varargin)
%% Takes market dimensions and returns market characteristics

%% Read data

optionsMap = containers.Map({'write'},...
    {0});

for i=1:size(varargin,2)
    if mod(i,2)==0
        %Value
        optionsMap(varargin{i-1})=varargin{i};
    end
end


%% Making payoff matrix
[R,P,ind_par,smr] = makePayoff(N,M);

%% Making probability vector
pi = makeProbabilities(M);

%% Setting the asset and state prices
[P p] = makeADPrices(R,pi,1.01);

%% Combining
Economy = [P,p,pi,R,sum(R,2)];

if optionsMap('write')
    writeEconomy(Economy);
end

end