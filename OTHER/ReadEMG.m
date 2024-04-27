function [emg_sync_1k] = ReadEMG(data, emg_sample_rate, base_sample_rate)
    emg_sample_rate
    emg_sync = data(:, 3);
    emg_sync_1k = SigConToBin(emg_sync,emg_sample_rate,base_sample_rate);
    emg_sync_1k = double(emg_sync_1k)-0.5;
end

