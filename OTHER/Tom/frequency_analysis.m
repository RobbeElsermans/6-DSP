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

% The EMG data
filename_EMG = 'opensignals_000780589b3a_2023-12-19_11-12-23.txt';
emg_sample_rate = 1000;
data = readmatrix(filename_EMG, 'Range', 4, 'Delimiter', '\t');
emg_sync = data(:, 3);
emg_sync_1k = SigConToBin(emg_sync, emg_sample_rate,base_sample_rate);
emg_sync_1k = double(emg_sync_1k)-0.5;

% Align the signals with the base wave
[base_sync_1k, emg_sync_1k, lag_emg_1] = Align(base_sync_1k, emg_sync_1k);
full_lag = 1*(lag_emg_1 == 0)+lag_emg_1*(lag_emg_1 ~= 0);
    
% Get point range
base_sync_1k_range = base_sync_1k(abs(full_lag)-10:abs(full_lag)+display_points);
emg_sync_1k_range = emg_sync_1k(abs(full_lag)-10:abs(full_lag)+display_points);

subplot(2,2,1)
plot(emg_sync_1k_range)
xlim([0 display_points])

subplot(2,2,2)
plot(emg_sync_1k_range)
xlim([0 display_points])

subplot(2,2,3)
fft(base_sync_1k_range)

subplot(2,2,4)
fft(emg_sync_1k_range)