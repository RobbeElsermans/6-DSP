%% Run EMG_fix_sample_Frequency.mlx before this one!

% Load or define your signals
signal1 = base_sync_1k; % Your first signal here
signal2 = emg_sync_1k; % Your second signal here

% Assuming signal1 is supposed to be at 1000kHz
expected_sample_rate = 1e3;  % 1kHz

% Use cross-correlation to find the delay between the signals
[corr_values, lags] = xcorr(signal1, signal2);
[max_corr, max_corr_index] = max(abs(corr_values));
delay_samples = lags(max_corr_index);

% Calculate the actual sampling rate of signal2 based on the delay of the
% samples
actual_sample_rate = expected_sample_rate * numel(signal2) / (numel(signal1) + delay_samples);

% Find a rational resampling factor
resampling_factor = actual_sample_rate / expected_sample_rate
[P, Q] = rat(resampling_factor);

% Resample signal2 to match the sampling rate of signal1
resampled_signal2 = resample(signal2, P, Q);

% Now signal1 and resampled_signal2 should have the same sampling rate

% Plot the original and resampled signals (optional)
% Time axes
time_signal1 = (0:length(signal1)-1) / expected_sample_rate;
time_resampled_signal2 = (0:length(resampled_signal2)-1) / expected_sample_rate;

figure;
hold on
plot(time_signal1, signal1, "DisplayName","base");
plot(time_resampled_signal2, resampled_signal2, "DisplayName","emg");
xlabel('Time (s)');
ylabel('Amplitude');
xlim([1 2])
hold off
