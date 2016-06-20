%% License
%{
The MIT License (MIT)

Copyright (c) 2016 EirikBerglund

Permission is hereby granted, free of charge, to any person obtaining a 
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the 
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
DEALINGS IN THE SOFTWARE.
%}
%% About
%   This is an optimization script written as part of a thesis at the
%   Norwegian School of Economics (2016). It optimizes an investment 
%   decision made in a complete market with a discrete statespace.
%
%   This program is specific to an Solvency II model. It can be set
%   non-binding by setting MKT_o to zero or commenting out the constraints
%   in 'constraint.m'
%
%   The program provides functionality for one period optimization for
%   any number of states/assets as long as they are equal. Multiperiod
%   optimization is supported in the case of four assets, four states
%   and i.i.d returns. 
%
%   Section Description
%       Program Specific
%           Tasks performed prior to executing commands
%       Economic Data
%           Information about the economic setting
%       Agent Data
%           Information concerning the investor, risk aversion and initial
%           wealth
%       Total Return and Pure Securities
%           Calculation of these entities. Assumes complete market.
%       Objective function and constraints
%           Can be found in 'objective.m' and 'constraint.m'
%       Optimization
%           Setup using the fmincon solver with the 'interior-point'
%           algorithm.
%       Output
%           Makes a result table and writes to specified file.

%% Program Specific
clear;

% File containing the optimization results
outputFileName = 'out.txt';

% If debug=1 - Optimization will not run
debug = 0;

%% Economic Data

%{
%   Configuration of the economic setting. Can be adjusted from 
%   one optimization to another.
%}

% M = States, N = Assets. Code only supports N=M
M = 4;
N = 4;

% Equal to 1 if it is multiperiod model - zero for one period
MultiPeriod = 1;

% Number of states compared to single period
mFactor = 5;

% Zero if investor can adjust investment in riskless (asset 0)
ConstantRiskless = 0;

% Probability Distribution (uniform)
pi = ones(M,1)*(1/M);

% Payoffs : Columns-Assets, Rows-States
X = [1 2 2 0;...
    1 1 2 5;...
    1 3 3 3;...
    1 3 5 2];

% Asset prices
P = [0.99;2.1;2.72;2.2];

% Stress factor of the equity Solvency calculation
SCRLevels = [0.39;0.49];

%% Agent data

%{
%   Specifics of agent. Power utility is assumed. This section is adjusted
%   from one optimization to another. 
%}

% Relative risk aversion coefficient in Power Utility (x^(1-gamma)/1-gamma)
gamma = 2;

% Initial wealth
W0 = 10;

% Exogenous capital requirement (M_o)
MKTo = 0;

%% Total return and pure securities

%{
%   Calculations based on the economic data. These are standard
%   calculations and should not be changed. They do assume a complete
%   market. 
%}
R = [sum(X(:,1)/(P(1)*M));sum(X(:,2)/(P(2)*M));...
    sum(X(:,3))/(P(3)*M);sum(X(:,4)/(P(4)*M))];

pure = eye(M);

p = zeros(M,1);

for m=1:M
   b = linsolve(X,pure(:,m));
   p(m) = b'*P;
end

%% Objective function and constraints

% Objective resides in objective.m
f = @(x) objective(x,X,gamma,MultiPeriod);
% Constraints can be found in constraint.m
g = @(x) constraint(x,P,W0,MKTo,SCRLevels,X,...
    ConstantRiskless,MultiPeriod);

%% Optimize

%{
%   Optimization is done in this section. One could alter the optimizer 
%   or the optimization algorithm.
%}

% Choosing the algorithm for optimization
options = optimoptions(@fmincon,'Algorithm','interior-point');

% Initial investment allocation uniform with sum 1. Worth noting that
% x is a vector of units invested in each asset. 
x0 = ones(N*mFactor,1)./(N*mFactor);

% This is not run if debug is true. Actual optimization. Optimal investment
% is stored in prevRes.
if ~debug 
    [x,fval,exitflag,output] = fmincon(f,x0,[],[],[],[],[],[],...
        g,options);
    prevRes = x;
else
    % If no optimization, must set these properties to debug rest of 
    % procedure.
    fval = 4;
    prevRes = [
    0.9972;
    2.9200;
   -0.0000;
    0.6997;
   -7.8398;
    3.8371;
    1.2288;
    1.4491;
   -8.5476;
    4.2176;
    1.2974;
    1.5825;
  -13.5914;
    6.6797;
    2.1067;
    2.5188;
  -12.9352;
    6.3712;
    1.9594;
    2.3822];
end

%% Output

%{
%   Makes some alterations of the results, unites them in a table
%   and writes to a specific file provided in the top section. 
%   Alterations may be done here if specific calculations are required.
%}

% Result table contains
%   FinalWealth: Final value of portfolio in the final states
%   Invested: Dollar invested in each asset
%   Utility: The expected utility of optimal asset allocation. 
%   Assets:  Number of assets
%   States: Number of states
%   P: Asset prices
%   p: Pure security Prices
%   pi: Probability distribution (uniform)
%   MKT_o: Exogenous Solvency II capital requirement
%   InitialWealth: W0
%   RiskAversion: Risk aversion coefficient gamma
%   X: Dollar payoff of assets
%   R: Total return of assets
%   SCRLevels: Stress factor of equity groups in the Solvency II regulation
%   prevRes: Optimal investment decision (units invested)
%   Riskless: Investment in riskless bond each period (asset 0)
%   Risky: Investment in risky assets each period (asset 1-3)
%   RiskyAllocation: Allocation of risky investment each period

if MultiPeriod
    FinalWealth = zeros(20,1);
    FinalWealth(1:4) = X*prevRes(5:8);
    FinalWealth(5:8) = X*prevRes(9:12);
    FinalWealth(9:12) = X*prevRes(13:16);
    FinalWealth(13:16) = X*prevRes(17:20);
  
    Invested = zeros(N*mFactor,1);
    
    for i=1:(N*mFactor)
        if i>4
            if mod(i,4)==0
                Invested(i) = prevRes(i)*P(4);
            else
                Invested(i) = prevRes(i)*P(mod(i,4));
            end
        else
            Invested(i) = prevRes(i)*P(i);
        end
    end
    
    Assets = repmat(N,M*mFactor,1);
    States = repmat(M,M*mFactor,1);
    InitialWealth = repmat(W0,M*mFactor,1);
    RiskAversion = repmat(gamma,M*mFactor,1);
    SCRLevelsTwice = repmat(SCRLevels,2*mFactor,1);
    Utility = repmat(fval,M*mFactor,1);
    MKT_o = repmat(MKTo,M*mFactor,1);
    
    Prep = repmat(P,mFactor,1);
    prep = repmat(p,mFactor,1);
    pirep = repmat(p,mFactor,1);
    risklessRep = repmat(ConstantRiskless, M*mFactor,1);
    Xrep = repmat(X,mFactor,1);
    Rrep = repmat(R,mFactor,1);
    
    % Calculating asset proportions
    riskless = [Invested(1);...
        Invested(5);...
        Invested(9);...
        Invested(13);...
        Invested(17)];
    riskless = repmat(riskless, M,1);
    riskless(6:20) = 0;
    
    risky = zeros(20,1);
    risky(1) = sum(Invested(2:4));
    for i = 2:(M+1)
        risky(i) = sum(Invested((2+(i-1)*4):((i-1)*4+4)));
    end
    
    riskyAllocation = zeros(20,1);
    for i=1:(M+1)
        tmpSum = sum(Invested((i-1)*4+2:(i-1)*4+4));
        riskyAllocation((i-1)*4+2) = Invested((i-1)*4+2)/tmpSum;
        riskyAllocation((i-1)*4+3) = Invested((i-1)*4+3)/tmpSum;
        riskyAllocation((i-1)*4+4) = Invested((i-1)*4+4)/tmpSum;
    end
    
else
    FinalWealth = X*prevRes;
    
    Invested = zeros(N,1);
    
    for i=1:N
        Invested(i) = x(i)*P(i);
    end
    
    Assets = repmat(N,M,1);
    States = repmat(M,M,1);
    InitialWealth = repmat(W0,M,1);
    RiskAversion = repmat(gamma,M,1);
    SCRLevelsTwice = repmat(SCRLevels,2,1);
    Utility = repmat(fval,M,1);
    MKT_o = repmat(MKTo,M,1);
    
    Prep = P;
    prep = p;
    pirep = pi;
    risklessRep = repmat(ConstantRiskless, M,1);
    Xrep = X;
    Rrep = R;
end

final = table(Utility,Assets,States,Prep,prep,pirep,MKT_o,InitialWealth,...
    RiskAversion,Xrep,Rrep,SCRLevelsTwice,prevRes,Invested,FinalWealth,...
    riskless,risky,riskyAllocation);

writetable(final,outputFileName);


