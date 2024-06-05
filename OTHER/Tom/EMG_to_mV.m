function [mV_data] = EMG_to_mV(emg_data)
% EMG_TO_MV:
%   Convert the emg data from a 12-bit range (4096) to a millivolt signal
% INPUT:
%   emg_data:   Data in 12-bit format
% OUTPUT:
%   mV_data:    Data in milli-Volts

    n = 12; VCC = 3; Gemg = 1000;
    DigTomV = @(adc) (((adc./2.^n - 1/2) .* VCC) ./ Gemg) * 1000;
    mV_data = DigTomV(emg_data);
end

