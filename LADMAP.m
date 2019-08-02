function [S,E] = LADMAP(X,D,lambda, beta)
% This routine solves the following nuclear-norm optimization problem,
% which is more general than "lrr.m"
% min |Z|_*+lambda*|E|_2,1
% s.t., X = DS+E
% inputs:
%        X -- D*N data matrix, D is the data dimension, and N is the number
%             of data vectors.
%        D -- D*M matrix of a dictionary, M is the size of the dictionary

if nargin<3
    lambda = 1;
end

maxIter = 1e6;
[d,n] = size(X);
m = size(D,2);
mu = 0.01;
max_mu = 10^10;
rho = 1.1;
epsilon2 = 10^-2;
Eta = (norm(D,2))^2;

XF = norm(X, 'fro');

%% Initializing optimization variables
% intialize
J = zeros(m,n);
S = zeros(m,n);
E = sparse(d,n);

Y1 = zeros(d,n);
Y2 = zeros(m,n);

condition = 1;

%% Start main loop
iter = 0;
disp(['initial,rank=' num2str(rank(S))]);
%while iter < maxIter
while condition >= epsilon2 && iter < maxIter
    iter = iter + 1;
    St = S;
    Jt = J;
    Et = E;
    
    %update S
    temp = S+(D'*(X-D*S-E+Y1/mu)-(S-J+Y2/mu))/Eta;
    [U,sigma,V] = svd(temp,'econ');
    sigma = soft_threshold(sigma, 1/mu*Eta);       %soft threshold
    S = U*sigma*V';
    
    %udpate J
    temp = S+Y2/mu;
    J = soft_threshold(temp, beta/mu);
    
    %update E
    temp = X-D*S+Y1/mu;
    E = solve_l1l2(temp,lambda/mu);
    
    %update Y1,Y2
    Y1 = Y1 + mu*(X-D*S-E);
    Y2 = Y2 + mu*(S-J);
    
    %ÅÐ¶ÏÊÇ·ñÍË³ö
    dSF = norm(S-St, 'fro');
    dJF = norm(J-Jt, 'fro');
    dEF = norm(E-Et, 'fro');

    temp = max(sqrt(Eta)*dSF, dJF);
    temp = max(temp, dEF);
    condition = mu*temp/XF;
    if condition <= epsilon2
        mu = min(max_mu,mu*rho);
    else
        mu = min(max_mu,mu*1);
    end
    
    
    %if iter==1 || mod(iter,50)==0 
        

        img = zeros(n,1);
        for i = 1:n
            img(i) =  sqrt(sum(E(:, i).^2));
        end
        img = reshape(img', sqrt(n), sqrt(n), 1);
        figure; imagesc(img); title(['iter=' num2str(iter) 'Results']); axis image;
            colorbar;
        saveas(gcf,['iter=' num2str(iter) 'Results'],'jpg')       
    %end
end

function [E] = solve_l1l2(W,lambda)
n = size(W,2);
E = W;
for i=1:n
    E(:,i) = solve_l2(W(:,i),lambda);
end

function [x] = solve_l2(w,lambda)
% min lambda |x|_2 + |x-w|_2^2
nw = norm(w);
if nw>lambda
    x = (nw-lambda)*w/nw;
else
    x = zeros(length(w),1);
end


function [X]=soft_threshold(b,lambda)
% soft threshold
%
% argmin 1/2||X-b||_{2}^2+\lambda||X||_{1}
%
X=sign(b).*max(abs(b) - lambda,0);
