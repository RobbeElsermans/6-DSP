function signal_bin_1k = SigConToBin(signal,originalFs, desiredFs)
%SignalConverter Converts a signal to a given sample rate and binarize it
%from 0 to 1.


% source: https://nl.mathworks.com/help/signal/ug/resampling-uniformly-sampled-signals.html
[p,q] = rat(desiredFs / originalFs)

signal_1k = resample(signal,p, q);

tresh = (abs(max(signal_1k)) - abs(min(signal_1k)))/2;
signal_bin_1k(:) = (signal_1k(:)> tresh);

end