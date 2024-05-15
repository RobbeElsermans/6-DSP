function [estimate_sample_rate, P, Q] = estimateSampleRate(signalA, signalB, signalB_sample_rate)
% estimateSampleRate  Estimate the correct sample rate on given base signal, other signal and the signal rate of signal B
% 
% signalA -> the base signal where we will base ourselve on.
% signalB -> the signal that is wrongly sampled and where we want to find
% the rate of.
% signalB_sample_rate -> the signalB sample rate that is being used.
%
% We assume that signalA and signalB are aligned at the beginning and at
% the end.
%
% returns the estimate_sample_rate, the P and Q values

    % Use cross-correlation to find the delay between the signals
    % [corr_values, lags] = xcorr(signalA, signalB);
    % [max_corr, max_corr_index] = max(abs(corr_values));
    % delay_samples = lags(max_corr_index);

    estimate_sample_rate = signalB_sample_rate * numel(signalB) / numel(signalA);
    resampling_factor = estimate_sample_rate / signalB_sample_rate;
    [P, Q] = rat(resampling_factor);
end