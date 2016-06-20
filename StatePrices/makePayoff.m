function [R,P,ind_param,syst_r] = makePayoff(N,M,varargin)
%MAKEPAYOFF Generates the assets payoff, price and return matrices
%   Takes the state-asset space and fills the payoff, price and return 
%   matrix. By default the last asset will be risk free with a return of 
%   0.01. The following parameters are available:
%       Required
%   N - Number of assets in the economy
%   M - Number of states possible. May be lower than N. 
%       Optional
%   'distribution' - By default normal (normal return distribution).
%       None other possible
%   'volatility' - By default medium. None other possible. 
%   'price' - By default 1 (all assets have initial price 1).
%   'rfRate' - By default 0.01

%% Read data

optionsMap = containers.Map({'distribution','volatility',...
    'riskFree','price','rfRate'},...
    {'lognormal','medium','on',1,0.01});

for i=1:size(varargin,2)
    if mod(i,2)==0
        %Value
        optionsMap(varargin{i-1})=varargin{i};
    end
end

%% Parameters
% syst_mu and syst_sigma is the mean and standard deviation of 
% the systematic risk process used later. 
syst_mu = 0.04;
syst_sigma = 0.15;

R=zeros(M,N);
P=ones(M,1)*optionsMap('price');
r=zeros(M,N);
%% Create systematic risk vector
% * Length M
% * Normally Distributed
% Reference http://se.mathworks.com/help/stats/normrnd.html
syst_r = syst_sigma.*randn(M,1)+syst_mu;

%% Make individual asset distribution parameter array
% To generate different asset payoffs, we need parameters
% to the assets distribution. The assets returns will be normal by 
% default. 
%
% Now using rand() function, which returns uniformally distributed
% random numbers. 
% Reference: http://se.mathworks.com/help/matlab/ref/rand.html
ind_param = zeros(N,2);
meanRangeFactor=0.1;
stdDevRangeFactor=0.2;
for i =1:N
    ind_param(i,1) = meanRangeFactor*rand(1,1);
    ind_param(i,2) = stdDevRangeFactor*sqrt(ind_param(i,1)*80);
end
%% Make return matrix
% The payoff of the asset is a combination of the state (systematic risk)
% and the assets own risk, given its expected value/volatility combination.
% To assure completeness there is a check if the matrix's rank is equal
% to the number of states. If N < M, the market cannot be complete, but 
% a payoff matrix is returned. 
stop=0;
count=0;
while(~stop)
    for n=1:N
            r(:,n)=syst_r+(ind_param(n,2).*randn(M,1)+ind_param(n,1));
    end
    % If the risk free option is not given (or given as default value
    % 'on'), the last asset in the payoff matrix will be the riskless. 
    if strcmp(optionsMap('riskFree'),'on')
        r(:,N) = ones(M,1)*optionsMap('rfRate');
        P(N)=1/(optionsMap('rfRate')+1);
    end
    
    % Check if rank is satisfactory. Just a precautionary measure as 
    % it will nearly always be the case that the investor may choose
    % end of period wealth as he wants. 
    if rank(r)==M
        stop=1;
    elseif M > N
        stop=1;
    elseif count>20
        % If correct rank not found
        r
        P
        error('Rank equal to M not found in return matrix');
    elseif ~optionsMap('rfRate')
        % If risk free rate is set to zero, rank will be one less but we
        % care about the payoff rank in reality. 
        tmp = r;
        tmp(:,N)=1;
        if rank(tmp)==M
            stop=1;
        end
    end
    count=count+1;
end

%% Make Payoff Matrix
% Prices are given in the P-matrix, so payoff is given by
for n=1:N
    %r(:,n)=max(-1,r(:,n));
    R(:,n) = (r(:,n)+1)*P(n);
end


