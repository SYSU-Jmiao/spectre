function [Cout,current_eps]=outage_mi(snrdb,epsilon,Mt,Mr,L,pow_all,prec)
%
%
% compute outage mutual information of a block-memoryless MIMO Rayleigh fading
% channel
% snrdb: snr in dB
% epsilon: outage probability
% Mt: number of transmit antennas
% Mr: number of receive antennas
% L: number of time_frequency diversity branches
% prec: it controls the number of samples for the Monte Carlo simulation; Note nsamples=2^prec; One should have nsamples>> 100 x 1/epsilon
% pow_all: ``power allocation matrix''. A Mt-1 x L matrices containing the
% eigenvalues of the input covariance matrix Q_k/snr, k=1,...,L, apart from
% the last one, whose value is determined by the  power constraint
% tr(Q_k)/snr=1. For the case Mt=1, just pass a 1 x L all zero matrix 


%%%%%%%%%%%%%%%%%%%%%%%%
% SET-UP parameters
%%%%%%%%%%%%%%%%%%%%%%%%

K = 2^prec; % number of monte carlo simulations (it should be at least 100 x 1/epsilon)
rho = 10.^(snrdb/10); % SNR in linear scale
const=sqrt(0.5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate input covariance matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


D=zeros(Mt,Mt,L);

for k=1:L,
    
    D(1:Mt-1,1:Mt-1,k)=diag(pow_all(:,k));
    
    D(Mt,Mr,k)=1-sum(pow_all(:,k));
    
end

D=D*rho;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MONTECARLO: generation of samples of instantaneous mutual information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mi=zeros(1,K);

for ii=1:K,    
    H=(randn(Mt,Mr,L)+1i*randn(Mt,Mr,L))*const;
    for k=1:L
        mi(ii)=mi(ii)+log2(abs(det(eye(Mr)+(H(:,:,k)')*D(:,:,k)*H(:,:,k))));
    end
end

mi=mi/L;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computation outage capacity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mi=sort(mi,'ascend');

step=K/2;
index=step;

onevec=ones(K,1);

while(step>1),
    
   th=mi(index);
   
   current_eps=sum(mi<=th)/K;
   
   step=step/2;
   
   if current_eps> epsilon,
       
       index=index-step;
       
   else
       
       index=index+step;
       
   end
   
end

current_eps=sum(mi<=mi(index))/K;

if(current_eps<epsilon)
    index=index+1;
end
current_eps=sum(mi<=mi(index))/K;

Cout=mi(index);