function [base_sig, new_sampled_sig, actual_sample_rate] = FindSampleFreq(base_sig, base_samp, wrong_sampled_sig)

signal1 = base_sig; % Your first signal here
signal2 = wrong_sampled_sig; % Your second signal here

% Assuming signal1 is supposed to be at base_samp
expected_sample_rate = base_samp;  % 1kHz

% Use cross-correlation to find the delay between the signals
[corr_values, lags] = xcorr(signal1, signal2);
[~, max_corr_index] = max(abs(corr_values));
delay_samples = lags(max_corr_index);

% Calculate the actual sampling rate of signal2 based on the delay of the
% samples
actual_sample_rate = expected_sample_rate * numel(signal2) / (numel(signal1) + delay_samples);

% Find a rational resampling factor
resampling_factor = expected_sample_rate/actual_sample_rate;
[P, Q] = rat(resampling_factor);

% Resample signal2 to match the sampling rate of signal1
new_sampled_sig = resample(signal2, P, Q);

% Now signal1 and resampled_signal2 should have the same sampling rate

% Plot the original and resampled signals (optional)
% Time axes
% time_signal1 = (0:length(signal1)-1) / expected_sample_rate;
% time_resampled_signal2 = (0:length(new_sampled_sig)-1) / expected_sample_rate;

%bring it back to -0.5 and 0.5
tresh = (abs(max(new_sampled_sig)) - abs(min(new_sampled_sig)))/2;
new_sampled_sig(:) = (new_sampled_sig(:)> tresh);

end