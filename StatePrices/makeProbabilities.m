function pi = makeProbabilities(M,varargin);

%% Read data

optionsMap = containers.Map({'distribution'},...
    {'uniform'});

for i=1:size(varargin,2)
    if mod(i,2)==0
        %Value
        optionsMap(varargin{i-1})=varargin{i};
    end
end

%% Generate probabilities
% Default case is the uniform distribution, with equal probability of
% each state. 
pi = ones(M,1)*(1/M);
for m = 1:M
    if strcmp(optionsMap('distribution'),'normal')
        pi(m) = abs(random('normal',(1/M),0.2*(1/M)));
    elseif strcmp(optionsMap('distribution'),'poisson')
        pi(m) = abs(random('Poisson',4));
    end
end
% Have now a vector of length "M" of "probabilities" collected from
% our preferred distribution. Now need to make sure it sums to 1.
pi = pi./sum(pi);



            