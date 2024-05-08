function [signalA, sigA_indexes, signalB, sigB_indexes] = alignByCorr(signalA,sigA_indexes, signalB,sigB_indexes, frame_size)
% doAlignByCorr  Aligns 2 signals with correlation with a given frame range
% and updates the indexes that are deleted or added.
% 
% signalA -> the first signal
% sigA_indexes -> the indexes of the first signal
% signalB -> the second signal
% sigB_indexes -> the indexes of the second signal
% frame_size -> the frame size being used in the correlation
%
% return aligned signalA and B with the indexes adjusted

%left side (beginning)
[ sigB_start, ~] = xcorr(signalA(1:frame_size), signalB(1:frame_size));
%shift the signal to the correct position
[~, max_start] = max(sigB_start);
max_start = floor((frame_size-max_start));

if max_start < 0
    signalA = signalA(abs(max_start): end-abs(max_start));
    sigA_indexes = sigA_indexes(abs(max_start): end-abs(max_start));
else
    signalB = signalB(abs(max_start): end-abs(max_start));
    sigB_indexes = sigB_indexes(abs(max_start): end-abs(max_start));
end

% right side (ending)
[sigB_end, ~] = xcorr(signalA(end-frame_size:end), signalB(end-frame_size:end));
[~, max_end] = max(sigB_end);
max_end = floor((frame_size-max_end));

if max_end < 0
    signalB = signalB(1: end-abs(max_end));
    sigB_indexes = sigB_indexes(1: end-abs(max_end));
else
    signalA = signalA(1: end-abs(max_end));
    sigA_indexes = sigA_indexes(1: end-abs(max_end));
end

end