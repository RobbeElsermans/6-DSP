function [signalA,signalB, distance] = Align(signalA,signalB)
%ALIGN Summary of this function goes here
%   Detailed explanation goes here

distance = finddelay(signalA, signalB);

if (distance < 0)
    % base_sync_1k is behind emg_sync_1k
    % So bring base_sync_1k to the front
    % Calc the lagg again in a smaller area
    signalA = signalA(abs(distance):end);
else
    signalB = signalB(abs(distance):end);
end

end

