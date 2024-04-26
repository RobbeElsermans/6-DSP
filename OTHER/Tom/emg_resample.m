clc, clear, close all;
addpath ../../OTHER
addpath ../../DATASET

base_sample_rate = 1000;
display_points = 1000;

% First load all the data (base_wave file)
filename_base = 'pianosync.wav';
[y,Fs] = audioread(filename_base); % 8kHz sample 
base_sync_1k = SigConToBin(y(:, 1)', Fs, base_sample_rate);
base_sync_1k = double(base_sync_1k)-0.5;

itterations = 100;
diff_per_itteration = 0.1;
base_sample_rate = 1000;
sampling_start = base_sample_rate - (round(itterations/2) - 1) * diff_per_itteration;
acc_per_itteration = zeros(1, itterations);
for i = 1:itterations

    % The EMG data
    filename_EMG = 'opensignals_000780589b3a_2023-12-19_11-12-23.txt';
    emg_sample_rate = sampling_start + diff_per_itteration*(i-1);
    data = readmatrix(filename_EMG, 'Range', 4, 'Delimiter', '\t');
    emg_sync = data(:, 3);
    emg_sync_1k = SigConToBin(emg_sync, emg_sample_rate,base_sample_rate);
    emg_sync_1k = double(emg_sync_1k)-0.5;
    
    % Convert to logical value
    % base_sync_1k_bin = logical(mod(base_sync_1k+0.5,2));
    % emg_sync_1k_bin = logical(mod(emg_sync_1k+0.5,2));
    
    % Overlap the signals
    [diff_sync_1k_bin, lag] = xcorr(base_sync_1k, emg_sync_1k);

    % Calculate accuracy
    % accuracy = sum(diff_sync_1k_bin,'all') / size(diff_sync_1k_bin, 2);
    % acc_per_itteration(1, i) = accuracy;
    accuracy = max(diff_sync_1k_bin)
    emg_sample_rate
    acc_per_itteration(1, i) = accuracy;

    % all the plottings
    % figure
    % subplot(3, 1, 1);
    % plot(base_sync_1k, 'r');
    % title("base sync 1kHz");
    % % ylim([-0.1 1.1]); xlim([0 display_points]);
    % 
    % subplot(3, 1, 2);
    % plot(emg_sync_1k, 'b');
    % title("EMC sync " + string(emg_sample_rate) + "Hz");
    % % ylim([-0.1 1.1]); xlim([0 display_points]);
    % 
    % subplot(3, 1, 3);
    % plot(diff_sync_1k_bin, 'k');
    % title("Difference");
    % % ylim([-0.1 1.1]); xlim([0 display_points]);

end

[max_acc,max_acc_index] = max(acc_per_itteration);
plot(acc_per_itteration);

fprintf('Frequency \t :%d \n', sampling_start + diff_per_itteration*(max_acc_index-1));
fprintf('Accuracy \t :%d%% \n', round(max_acc * 10000) / 100);
fprintf('Range \t\t :[%d, %d] \n', sampling_start, sampling_start+diff_per_itteration*(itterations-1));
fprintf('Step size \t :%d \n', diff_per_itteration);
