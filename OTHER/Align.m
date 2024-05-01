function [signalB_new, distance] = Align(signalA, signalB)
%ALIGN Summary of this function goes here
%   Detailed explanation goes here

distance = finddelay(signalA, signalB);

if (distance == 0)
    signalB_new = signalB;
    return;
end

if (distance < 0)
    % base_sync_1k is behind emg_sync_1k
    % So bring base_sync_1k to the front
    % Calc the lagg again in a smaller area
    signalB_new = [zeros(1,abs(distance)), signalB(1:end-abs(distance))];
else
    signalB_new = [signalB(abs(distance):end) , zeros(1,abs(distance))];
end
distance = abs(distance);
end

