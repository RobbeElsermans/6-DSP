function [filtered_data] = EMG_filter(emg_data)
% EMG_FILTER:
%   Filters the EMG data from any picked up noise during measurements.
%   It filters data from 10Hz to 250Hz
% INPUT:
%   emg_data:   EMG data (in milli-Volts)
% OUTPUT:
%   filtered_data:  Filtered EMG data (in milli-Volts)

    f_sample = 1000;
    f_low = 10;     % Lower cutoff frequency
    f_high = 250;   % Upper cutoff frequency
    freq_range = [f_low/(f_sample/2), f_high/(f_sample/2)];
    filter_order = 3;

    [b, a] = butter(filter_order, freq_range, 'bandpass');
    filtered_data = filtfilt(b, a, emg_data);
end

