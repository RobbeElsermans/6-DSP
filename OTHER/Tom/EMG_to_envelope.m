function [envelope] = EMG_to_envelope(emg_data)
% EMG_TO_ENVELOPE:
%   Create and envelope for the EMG data
% INPUT:
%   emg_data:   EMG data (in milli-Volts)
% OUTPUT:
%   envelope:   Envelope of the EMG data

    f_sample = 1000;
    f_high = 250;   % Upper cutoff frequency
    filter_order = 3;

    [b_lp, a_lp] = butter(filter_order, f_high/(f_sample/2), 'low');
    rectified_data = abs(emg_data);    % Full-Wave Rectification
    envelope = filtfilt(b_lp, a_lp, rectified_data);
end

