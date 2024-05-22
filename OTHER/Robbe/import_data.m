%% Will import the data that is aligned
clc, clear, close all;
addpath OTHER
addpath DATASET

sync_file = 'pianosync.wav';
% sample rate is in the wav itself
emg_file = 'opensignals_000780589b3a_2023-12-19_11-12-23.txt';
emg_sample_rate = 1000;
perfusion_file = "perfusion_and_sync_19-Dec-2023-11_15_20.mat";
perfusion_sample_rate = 1000;
video_file = "elina3_nogapfilling.mat";
video_sample_rate = 300;
poi = [637.1 457.7 193.6];
poi_tolerance = [10 10 10];

base_sample_rate = 1000;
frame_size = 5001;

% Gives struct with
% .sync
% .data
% .indexes relative to sampled frequency

[base, emg, blood, video] = extractData( ...
    sync_file, ...
    emg_file, emg_sample_rate, ...
    perfusion_file, perfusion_sample_rate, ...
    video_file, video_sample_rate, poi, poi_tolerance, ...
    base_sample_rate, frame_size, 1);

display_points = 5000;


figure;
hold on
plot(base.sync(1:display_points)+3.3);
plot(emg.sync(1:display_points)+2.2);
plot(blood.sync(1:display_points)+1.1);
plot(video.sync(1:display_points));

% now do something with the data!

title("1kHz signals");
ylim([-1 4]);
legend("base", "EMG", "perfusion", "video");
xlabel("samples at 1kHz");
ylabel("sync value");
hold off;

% to debug. Maybe change when in app?