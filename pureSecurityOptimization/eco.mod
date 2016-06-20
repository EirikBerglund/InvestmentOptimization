set S; 	#Sett med states/pure securities
set K;	#Sett med straffeniv�er

# Har vi SCR Straff?
param restrict := 0;

# Er det var_investor eller Portfolio_insurer?
#param var_investor := 0;

# Er det portfolio insurer? 
#param portfolio_insurer := 0;

param Ck {j in K}; 		#Endret fra {i in K}

param fact {j in K};	#Endret fra {i in K}

param p {i in S};

param p2 {i in S};

param p3 {i in S};

# Denne kan endres for VaR innslag samt Portfolio Insurer innslag. Lavere verdi --> mer fritt.
#param var_limit := 88;

# Risikoaversjon (forel�pig brukes bare log da)
param gamma = 0.4;

# Initiell peng
param W0 = 1000;

# St�rre enn lik m� du se an om er n�dvendig. Som regel optimalt uansett. 
var x {i in S} >= 1;		#Enheter av pure security i som er kj�pt

# Denne er grei � ha. 
var SCR {i in S, j in K} >= 0;

# Hjelpevariabel for VaR og Portfolio Insurer
#var Limit {i in S} binary;

#Power utility:
maximize util : sum{i in S} ((x[i] - sum{j in K} (SCR[i,j]*fact[j]*restrict))^(1-gamma)-1)/(1-gamma);

#Eirik sin max:
#maximize util : sum{i in S} (log(x[i]- sum{j in K} (SCR[i,j]*fact[j]*restrict)));

subject to budget_constraint :
	sum{i in S} p[i]*x[i] <= W0;
	
subject to solvency_constraint {i in S, j in K} : 
	x[i]*restrict >= Ck[j]*restrict - SCR[i,j]
;

# DISSE TO ER FOR VaR og PortfolioInsurer!

# Setter at wealth state i m� v�re st�rre enn var_limit, ellers m� limit i state i v�re 1
#subject to limit_constraint {i in S} : 
#	(1-Limit[i])*(x[i]-var_limit) >= 0 ;

# Dersom var_investor -> Kun 5 states som kan ha x_i mindre enn var_limit
# Dersom portfolio insurer -> INGEN states som kan ha x_i mindre enn var_limit
#subject to var_constraint :
#	sum{i in S} Limit[i]*var_investor <= 5*var_investor - 5*portfolio_insurer ;