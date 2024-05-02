function [corr_start, corr_end] = PlotCorrDrift(frame_size, base_sync_1k, sync_1k)
    % Correlate start:  First 1000 samples of the signals
    [corr_start, ~] = xcorr(base_sync_1k(1:frame_size), sync_1k(1:frame_size));

    % Correlate end:    Last 1000 samples of the signals
    [corr_end, ~] = xcorr(base_sync_1k(end - frame_size:end), sync_1k(end - frame_size:end));
    figure
    % Plot start and end correlations
    hold on;
    plot(corr_start, "DisplayName","Start")
    plot(corr_end, "DisplayName","Stop")
    hold off;
    xlabel("samples"); ylabel("mag");
    xlim([0, frame_size*2]);
    legend()
end

