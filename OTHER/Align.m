function [signalB_new, distance, sigB_indexes] = Align(signalA, signalB, sigB_indexes)
%ALIGN Summary of this function goes here
%   Detailed explanation goes here

distance = finddelay(signalA, signalB);

if (distance == 0)
    signalB_new = signalB;
    return;
end

if (distance < 0)
    % signalB is behind signalA
    % So bring signalB to the front by 
    signalB_new = [zeros(1,abs(distance)), signalB(1:end)];
    sigB_indexes =  [zeros(1,abs(distance)), sigB_indexes(1:end)];
else
    signalB_new = [signalB(abs(distance):end) , zeros(1,abs(distance))];
    sigB_indexes = [sigB_indexes(abs(distance):end) , zeros(1,abs(distance))];
end
distance = abs(distance);
end

