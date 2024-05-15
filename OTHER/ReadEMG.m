function [sync, muscle1, muscle2] = ReadEMG(filename_EMG, emg_sample_rate, base_sample_rate)
    % "column": ["index", "overbodig", "sync", "spier 1", "spier 2"]
    data = readmatrix(filename_EMG, 'Range', 4, 'Delimiter', '\t');
    sync = data(:, 3);
    muscle1 = data(:, 4);
    muscle2 = data(:, 5);
end

