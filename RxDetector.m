function [result] = RxDetector(X)
% Inputs
%   X  - 2D data matrix (p x N)
% Outputs
%   result - Detector output (1 x N)
%   sigma - Covariance matrix (p x p)
%   sigmaInv - Inverse of covariance matrix (p x p)

% Remove the data mean
[p, N] = size(X);
mMean = mean(X, 2);
B = X - repmat(mMean, 1, N);

% Compute covariance matrix of background
sigma = (B*B.')/(N-1);

sigmaInv = inv(sigma);

result = zeros(N, 1);
for i=1:N
    result(i) = B(:,i).'*sigmaInv*B(:,i);
end
result = abs(result);

return;