function [signalA_resampled, signalA_indexes] = resampleSignal(signalA, signalA_samp_freq, to_freq, pure)
% resampleSignal  Resample the signal by given sample rates.
% 
% signalA -> the signal to resample.
% signalA_samp_freq -> the sample rate of the given signalA.
% to_freq -> the sample rate that we want to archieve.
% pure -> boolean (1 or 0) to return the signalA_resampled as a value
% between -0.5 and 0.5 (endter pure = 0) or the pure signal (pure = 1).
%
% returns the resampled signal A and the sample indexes.

    [p,q] = rat(to_freq / signalA_samp_freq);

    signalA_resampled = resample(signalA,p, q);
    signalA_indexes = 1:length(signalA_resampled);

    if pure == 0
        tresh = (abs(max(signalA_resampled)) - abs(min(signalA_resampled)))/2;
        signalA_resampled(:) = (signalA_resampled(:)> tresh);
        signalA_resampled = double(signalA_resampled)-0.5;
    end
end