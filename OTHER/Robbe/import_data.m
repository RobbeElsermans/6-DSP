%% to debug. Maybe change when in app?
clc, clear, close all;
addpath OTHER
addpath DATASET

[base, emg, blood, video] = extractData( ...
    'pianosync.wav', 1000, ...
    'opensignals_000780589b3a_2023-12-19_11-12-23.txt', 1000, ...
    "perfusion_and_sync_19-Dec-2023-11_15_20.mat", 1000, ...
    "elina3_nogapfilling.mat", 300);

display_points = 5000;

hold on
plot(base.sync(1:display_points)+3.3);
plot(emg.sync(1:display_points)+2.2);
plot(blood.sync(1:display_points)+1.1);
plot(video.sync(1:display_points));

% now do something with the data!


title("1kHz signals");
ylim([-1 4]);
legend("base", "EMG", "blood", "video");
hold off;

% to debug. Maybe change when in app?

function [base, emg, blood, video] = extractData(base_path, base_freq, emg_path, origin_emg_freq, blood_path, origin_blood_freq, video_path, origin_video_freq)
% extractData  This function will extact the data of emg, perfusion and
% video capture. It will use the base sync signal to align all data and cut
% the parts that doesn't align well, off.
%
% base_path -> the filepath of the base synchronization signal
% base_freq -> the base frequency that we want to archieve on all data (in Hz)
% emg_path -> the filepath of the emg data
% origin_emg_freq -> the original emg data sample rate (in Hz)
% blood_path -> the filepath of the perfusion data
% origin_blood_freq -> the original perfusion data sample rate (in Hz)
% video_path -> the filepath of the video data
% origin_video_freq -> the original video data sample rate (in Hz)
%
% returns a struct with the following structure
% .sync -> the synchronize signal of the dataset
% .data -> the data that is aligned with the synced (and also resampled if
% needed)
% .indexes -> the used indexes in the dataset. These indexes are referenced
% to the given base_freq sample rate


% if 1, this means that the sample rate is estimated and we must find the
% correct sample rate

    % import the data of base. This is our reference.
    [y,Fs] = audioread(base_path); % 8kHz sample 
    [base_sync_1k, base_indexes] = resampleSignal(y(:, 1)', Fs, base_freq, 0);
   
    % import the emg signal
    data = readmatrix(emg_path, 'Range', 4, 'Delimiter', '\t');
    emg_sync = data(:, 3)';
    [emg_sync_1k, emg_indexes] = resampleSignal(emg_sync, origin_emg_freq, base_freq, 0);

    % do the aligning of the emg signal towards base signal.
    [base_sync_1k,~, emg_sync_1k, ~] = doAlignByCorr(base_sync_1k,base_indexes, emg_sync_1k, emg_indexes, 5001);
    
    % estimate based on current samples
    [original_samp, P, Q] = estimateSampleRate(base_sync_1k, emg_sync_1k, origin_emg_freq);
    
    % emg_sync_1k = resample(emg_sync_1k, P, Q);
    % tresh = (abs(max(emg_sync_1k)) - abs(min(emg_sync_1k)))/2;
    % emg_sync_1k(:) = (emg_sync_1k(:)> tresh);
    % emg_sync_1k = double(emg_sync_1k)-0.5;

    %resample with correct
    origin_emg_freq = original_samp;


% sample everything from the start with the accuired new sample rate of emg

    % import the data of base. This is our reference.
    [y,Fs] = audioread(base_path); % 8kHz sample 
    [base_sync_1k, base_indexes] = resampleSignal(y(:, 1)', Fs, base_freq, 0);

    % import the emg signal 
    data = readmatrix(emg_path, 'Range', 4, 'Delimiter', '\t');
    emg_sync = data(:, 3)';
    emg_data = data(:, 4:5)';
    [emg_sync_1k, emg_indexes] = resampleSignal(emg_sync, origin_emg_freq, base_freq, 0);    
    [emg_data_1k(1, :), ~] = resampleSignal(emg_data(1,:), origin_emg_freq, base_freq, 1);  
    [emg_data_1k(2, :), ~] = resampleSignal(emg_data(2,:), origin_emg_freq, base_freq, 1); 


    raw_blood_data = load(blood_path);
    blood_data = raw_blood_data.fullDataSet(:, 2:3)';
    blood_sync = raw_blood_data.fullDataSet(:, 1)';
    [blood_sync_1k, blood_indexes] = resampleSignal(blood_sync, origin_blood_freq, base_freq, 0);
    [blood_data_1k(1,:), ~] = resampleSignal(blood_data(1,:), origin_blood_freq, base_freq, 1);
    [blood_data_1k(2,:), ~] = resampleSignal(blood_data(2,:), origin_blood_freq, base_freq, 1);


    raw_video_data = load(video_path);
    poi = [637.1 457.7 193.6];
    tolerance_poi = [10 10 10];
    video_capture_300 = double(QTMToBin(raw_video_data.elina3.Trajectories.Unidentified.Data, poi, tolerance_poi))';
    [video_sync_1k, video_indexes] = resampleSignal(video_capture_300, origin_video_freq, base_freq, 0);
    

%allign signals
[emg_sync_1k, lag_emg_1, emg_indexes] = Align(base_sync_1k, emg_sync_1k, emg_indexes);
[blood_sync_1k, lag_blood_1, blood_indexes] = Align(base_sync_1k, blood_sync_1k, blood_indexes);
[video_sync_1k, lag_video_1,video_indexes] = Align(base_sync_1k, video_sync_1k, video_indexes);

temp =  max([lag_emg_1, lag_blood_1 lag_video_1]);
start_delay = 1*(temp == 0)+temp*(temp ~= 0);
%set everything to start at 1 point
base_sync_1k = base_sync_1k(start_delay:end);
base_indexes = base_indexes(start_delay:end);
emg_sync_1k = emg_sync_1k(start_delay:end);
emg_indexes = emg_indexes(start_delay:end);
blood_sync_1k = blood_sync_1k(start_delay:end);
blood_indexes = blood_indexes(start_delay: end);
video_sync_1k = video_sync_1k(start_delay:end);
video_indexes = video_indexes(start_delay: end);

%Set everything to end at the same time
end_delay = min([length(base_sync_1k) length(emg_sync_1k) length(blood_sync_1k) length(video_sync_1k)]);
base_sync_1k = base_sync_1k(1:end_delay);
base_indexes = base_indexes(1:end_delay);
emg_sync_1k = emg_sync_1k(1:end_delay);
emg_indexes = base_indexes(1:end_delay);
blood_sync_1k = blood_sync_1k(1:end_delay);
blood_indexes = base_indexes(1:end_delay);
video_sync_1k = video_sync_1k(1:end_delay);
video_indexes = base_indexes(1:end_delay);

%assign to output values
base.sync = base_sync_1k();
emg.sync = emg_sync_1k();
emg.data = emg_data_1k(:, emg_indexes(1): emg_indexes(end));
emg.range = emg_indexes

blood.sync = blood_sync_1k;
blood.data = blood_data_1k(:,emg_indexes(1): emg_indexes(end));
emg.range = emg_indexes

video.sync = video_sync_1k;
video.data = zeros(1, length(video_sync_1k));

end

function [signalA, sigA_indexes, signalB, sigB_indexes] = doAlignByCorr(signalA,sigA_indexes, signalB,sigB_indexes, frame_size)
% doAlignByCorr  Aligns 2 signals with correlation with a given frame range
% and updates the indexes that are deleted or added.
% 
% signalA -> the first signal
% sigA_indexes -> the indexes of the first signal
% signalB -> the second signal
% sigB_indexes -> the indexes of the second signal
% frame_size -> the frame size being used in the correlation
%
% return aligned signalA and B with the indexes adjusted



%left side (beginning)
[ sigB_start, ~] = xcorr(signalA(1:frame_size), signalB(1:frame_size));
%shift the signal to the correct position
[~, max_start] = max(sigB_start);
max_start = floor((frame_size-max_start));

if max_start < 0
    signalA = signalA(abs(max_start): end-abs(max_start));
    sigA_indexes = sigA_indexes(abs(max_start): end-abs(max_start));
else
    signalB = signalB(abs(max_start): end-abs(max_start));
    sigB_indexes = sigB_indexes(abs(max_start): end-abs(max_start));
end

% right side (ending)
[sigB_end, ~] = xcorr(signalA(end-frame_size:end), signalB(end-frame_size:end));
[~, max_end] = max(sigB_end);
max_end = floor((frame_size-max_end));

if max_end < 0
    signalB = signalB(1: end-abs(max_end));
    sigB_indexes = sigB_indexes(1: end-abs(max_end));
else
    signalA = signalA(1: end-abs(max_end));
    sigA_indexes = sigA_indexes(1: end-abs(max_end));
end

end

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
    [corr_values, lags] = xcorr(signalA, signalB);
    [max_corr, max_corr_index] = max(abs(corr_values));
    delay_samples = lags(max_corr_index);

    estimate_sample_rate = signalB_sample_rate * numel(signalB) / numel(signalA);
    resampling_factor = estimate_sample_rate / signalB_sample_rate;
    [P, Q] = rat(resampling_factor);
end


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