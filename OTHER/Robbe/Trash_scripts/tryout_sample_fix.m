%% Wat doet deze code:
% 1) Eerst laden we de data in.
% 2) We correleren de data in het begin om het begin mooi te starten. We
% kappen dus de data hier af.
% 3) We correleren de data op het einde om het einde mooi te laten stoppen.
% We kappen dus de data hier af.
% 4) We correleren de data opnieuw en we gebruiken de lag tussen de data om
% de Hoeveelheid lag te bepalen tussen de 2 signalen.
% 5) Doordat de signalen in het begin en einde gealinieerd zijn, kunnen we
% deze delen door elkaar (+ de hoeveelheid lag) om de effectieve sample
% rate te vinden.
% 6) Deze factor gebruiken we om de P en Q te bepalen (up and down
% samplings).
% 7) Met P en Q waardes, resamplen we het signaal.
% 8) Doordat we gaan interpoleren, krijgen we het fenomeen genaamd picket
% fencing die we dus gaan wegwerken door boolaanse logica om er terug
% zuiver 1 en 0 van te maken (en daarna dc wegwerken).

clc, clear, close all;

frame_size = 5001;
show_plots = 1;

%% 1)

filename_base = 'pianosync.wav';
[y,Fs] = audioread(filename_base); % 8kHz sample
base_sync_1k = SigConToBin(y(:, 1)', Fs, 1000);
base_sync_1k_base = double(base_sync_1k)-0.5;
base_sync_1k = base_sync_1k_base;
base_indexes = 1:length(base_sync_1k);

filename_EMG = 'opensignals_000780589b3a_2023-12-19_11-12-23.txt';
data = readmatrix(filename_EMG, 'Range', 4, 'Delimiter', '\t');
emg_sample_rate = 1000;
emg_sync_1k = ReadEMG(data, emg_sample_rate, 1000);
emg_indexes = 1:length(emg_sync_1k);

%% 2)

[ emg_corr_start, ~] = xcorr(base_sync_1k(1:frame_size), emg_sync_1k(1:frame_size));
%shift the signal to the correct position
[~, max_start] = max(emg_corr_start);
max_start = floor((frame_size-max_start));

if max_start < 0
    base_sync_1k = base_sync_1k(abs(max_start): end);
    base_indexes = base_indexes(abs(max_start): end);
else
    emg_sync_1k = emg_sync_1k(abs(max_start): end);
    emg_indexes = emg_indexes(abs(max_start): end);
end

if(show_plots)

    figure
    hold on
    title("emg")
    plot(emg_corr_start, "DisplayName","emgStart")
    xlabel("samples"); ylabel("mag");
    legend()
    hold off;

    figure;
    subplot(1,2,1);
    title("start")
    hold on;
    plot(emg_sync_1k(1:1000) +0.6, "r");
    plot(base_sync_1k(1:1000) - 0.6, "g");
    hold off;
    
    subplot(1,2,2);
    title("end")
    hold on;
    plot(emg_sync_1k(end-1000:end) +0.6, "r");
    plot(base_sync_1k(end-1000:end) - 0.6, "g");
    hold off;

    figure
    hold on
    title("full signal")
    plot(emg_sync_1k, "DisplayName","emg_sig")
    plot(base_sync_1k, "DisplayName","base_sig")
    xlabel("samples"); ylabel("value");
    legend()
    hold off;
end

%% 3)

[emg_corr_end, ~] = xcorr(base_sync_1k(end-frame_size:end), emg_sync_1k(end-frame_size:end));
[~, max_end] = max(emg_corr_end);
max_end = floor((frame_size-max_end));

if max_end < 0
    emg_sync_1k = emg_sync_1k(1: end-abs(max_end));
    emg_indexes = emg_indexes(1: end-abs(max_end));
else
    base_sync_1k = base_sync_1k(1: end-abs(max_end));
    base_indexes = base_indexes(1: end-abs(max_end));
end

if(show_plots)

    figure
    hold on
    title("emg")
    plot(emg_corr_end, "DisplayName","emgEnd")
    xlabel("samples"); ylabel("mag");
    legend()
    hold off;

    figure;
    subplot(1,2,1);
    title("start")
    hold on;
    plot(emg_sync_1k(1:1000) +0.6, "r");
    plot(base_sync_1k(1:1000) - 0.6, "g");
    hold off;
    
    subplot(1,2,2);
    title("end")
    hold on;
    plot(emg_sync_1k(end-1000:end) +0.6, "r");
    plot(base_sync_1k(end-1000:end) - 0.6, "g");
    hold off;

    figure
    hold on
    title("full signal")
    plot(emg_sync_1k, "DisplayName","emg_sig")
    plot(base_sync_1k, "DisplayName","base_sig")
    xlabel("samples"); ylabel("value");
    legend()
    hold off;

    figure
    hold on
    title("emg")
    plot(emg_corr_start, "DisplayName","emgStart")
    plot(emg_corr_end, "DisplayName","emgEnd")
    xline(frame_size);
    xlabel("samples"); ylabel("mag");
    legend()
    hold off;

end
%% 4) 

% % Load or define your signals
 signal1 = base_sync_1k; % Your first signal here
 signal2 = emg_sync_1k; % Your second signal here
% 
% % Assuming signal1 is supposed to be at 1000kHz
expected_sample_rate = 1e3;  % 1kHz

% Use cross-correlation to find the delay between the signals
[corr_values, lags] = xcorr(signal1, signal2);
[max_corr, max_corr_index] = max(abs(corr_values));
delay_samples = lags(max_corr_index);

%% 5)
% Calculate the actual sampling rate of signal2 based on the delay of the
% samples
actual_sample_rate = expected_sample_rate * numel(signal2) / (numel(signal1));
%% 6)
% Find a rational resampling factor
resampling_factor = expected_sample_rate/actual_sample_rate;
[P, Q] = rat(resampling_factor);

%% 7)
% Resample signal2 to match the sampling rate of signal1

disp("before resample");
disp("base_indexes " + string(mat2str([base_indexes(1), base_indexes(end)])));
disp("emg_indexes " + string(mat2str([emg_indexes(1), emg_indexes(end)])));

resampled_signal2 = resample(signal2, P, Q);

% Now signal1 and resampled_signal2 should have the same sampling rate

% Plot the original and resampled signals (optional)
% Time axes
time_signal1 = (1:length(signal1))/expected_sample_rate;
time_resampled_signal2 = (1:length(resampled_signal2))/expected_sample_rate;

if(show_plots)

    figure
    hold on
    title("full signal")
    plot(signal2, "DisplayName","emg_sig")
    plot(signal1, "DisplayName","base_sig")
    xlabel("samples"); ylabel("value");
    ylim([-1 1])
    legend()
    hold off;

    figure;
    hold on
    plot(time_signal1, signal1, "DisplayName","base");
    plot(time_resampled_signal2, resampled_signal2, "DisplayName","emg");
    xlabel('Time (s)');
    ylabel('Amplitude');
    ylim([-1 1])
    hold off
end

%% 8)

%Maak terug zuiver
tresh = (abs(max(resampled_signal2)) - abs(min(resampled_signal2)))/2;
resampled_signal2(:) = (resampled_signal2(:)> tresh);

if(show_plots)
    figure;
    subplot(1,2,1);
    title("start")
    hold on;
    plot(signal1(1:1000) +0.6, "r");
    plot(resampled_signal2(1:1000), "g");
    hold off;
    
    subplot(1,2,2);
    title("end")
    hold on;
    plot(signal1(end-1000:end) +0.6, "r");
    plot(resampled_signal2(end-1000:end), "g");
    hold off;
end

disp("After resample");
disp("base_indexes " + string(mat2str([base_indexes(1), base_indexes(end)])));
disp("emg_indexes " + string(mat2str([emg_indexes(1), emg_indexes(end)])));
disp("actual_sample_rate " + actual_sample_rate);
disp("P " + P);
disp("Q " + Q);

