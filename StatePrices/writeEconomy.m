function succ = writeEconomy( eco )
succ =-1;

P = eco(:,1);
p = eco(:,2);
pi = eco(:,3);
R = eco(:,4:(size(eco,2)-1));
as = eco(:,size(eco,2));

%% Printing

w_Economy = table(P,p,pi,R,as);
writetable(w_Economy,'economy.dat');
type economy.dat

end

