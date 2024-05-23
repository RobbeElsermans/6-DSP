function [norm_data] = EMG_normalize(emg_data,mvc_data)
% EMG_NORMALIZE:    
%   Normalize the emg data compared to the mvc data
% INPUT:
%   emg_data:   EMG data (in milli-Volts)
%   mvc_data:   MVC data (in milli-Volts)
% OUTPUT:
%   norm_data:  Normalized EMG data

    norm_data = emg_data/max(mvc_data);
end

