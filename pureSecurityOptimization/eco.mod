set S; 	#Sett med states/pure securities
set K;	#Sett med straffenivåer

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

# Risikoaversjon (foreløpig brukes bare log da)
param gamma = 0.4;

# Initiell peng
param W0 = 1000;

# Større enn lik må du se an om er nødvendig. Som regel optimalt uansett. 
var x {i in S} >= 1;		#Enheter av pure security i som er kjøpt

# Denne er grei å ha. 
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

# Setter at wealth state i må være større enn var_limit, ellers må limit i state i være 1
#subject to limit_constraint {i in S} : 
#	(1-Limit[i])*(x[i]-var_limit) >= 0 ;

# Dersom var_investor -> Kun 5 states som kan ha x_i mindre enn var_limit
# Dersom portfolio insurer -> INGEN states som kan ha x_i mindre enn var_limit
#subject to var_constraint :
#	sum{i in S} Limit[i]*var_investor <= 5*var_investor - 5*portfolio_insurer ;