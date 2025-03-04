%% PERSONALIZED_HANN: Creates a modified Hann window with customizable transition regions
%
% This function generates a window function that combines properties of a Hann window
% with logistic transition functions, allowing for more customizable tapering
% at the edges.
%
% Syntax:
%   w = personalized_hann(N, alpha)
%
% Inputs:
%   N     - Length of the window (integer)
%   alpha - Steepness parameter for the logistic transition (positive scalar)
%           Higher values create sharper transitions
%
% Outputs:
%   w     - Column vector of length N containing the window values
%
% Description:
%   The function creates a modified window that:
%   1. Uses a standard Hann window as a base function
%   2. Applies logistic transitions at the edges
%   3. Splits the window into two regions (0 to N/2 and N/2 to N-1)
%   4. Constructs a piecewise function by combining the Hann window with 
%      logistic functions using weighted averaging
%
% The transition sharpness is controlled by:
%   - The fraction parameter n (fixed at 8), meaning transition occurs at of window length
%   - The alpha parameter, which controls steepness of the logistic functions
%
% Component functions:
%   p(x)  - Standard Hann window: (1 - cos(2πx/(N-1))) * 0.5
%   ka(x) - Logistic function for left side: 1/(1 + exp(-α(x - (N-1)/n)))
%   sa(x) - Symmetric version of ka for right side
%   r(x)  - First half blend: (ka(x) + p(x))/2
%   t(x)  - Second half blend: (sa(x) + p(x))/2
%
% Example:
%   % Create a 256-point personalized Hann window with moderate transition
%   win = personalized_hann(256, 0.5);
%   
%   % Plot the window
%   figure;
%   plot(win);
%   title('Personalized Hann Window');
%   xlabel('Sample number');
%   ylabel('Amplitude');
%
% See also:
%   HANN, HAMMING, BLACKMAN, WINDOW
%
% Notes:
%   - For alpha = 0, the function approaches a standard Hann window
%   - As alpha increases, transitions become sharper


function w = personalized_hann(N, alpha)

    n = 8; % The fraction of the lenght where its starting to grow. (1/n)

    % Define x range from 0 to N-1 (to include all indices properly)
    x = linspace(0, N-1, N)';  % Generate points in the range [0, N-1]
    % Define the piecewise functions for p(x), ka(x), sa(x), r(x), and t(x)
    p = @(x, alpha) (1 - cos(2*pi*x/(N-1))) * 0.5;  % Hann window function
    ka = @(x, alpha) 1 ./ (1 + exp(-alpha*(x - (N-1)/n)));  % Logistic-like function
    r = @(x, alpha) (ka(x, alpha) + p(x, alpha)) * 0.5;
    sa = @(x, alpha) ka(-x + (N-1), alpha);  % Symmetric version of ka
    t = @(x, alpha) (sa(x, alpha) + p(x, alpha)) * 0.5;

    % Compute r(x) and t(x) over their respective intervals
    vr = zeros(size(x));  % For 0 <= x <= N/2
    vt = zeros(size(x));  % For N/2 < x <= N

    % Calculate r(x) for 0 <= x <= N/2 and t(x) for N/2 < x <= N
    for i = 1:length(x)
        if x(i) <= (N-1)/2
            % Calculate r(x)
            vr(i) = r(x(i), alpha);
        else
            % Calculate t(x)
            vt(i) = t(x(i), alpha);
        end
    end

    % Create the piecewise function w(x)
    w = zeros(size(x));
    w(x <= (N-1)/2) = vr(x <= (N-1)/2);
    w(x > (N-1)/2) = vt(x > (N-1)/2);

    % Return the result
end
