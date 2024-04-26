function [] = ShowSignals(signals)
    figure
    hold on
    plot(signals(1,:)+3.9);
    plot(signals(2,:)+2.8);
    plot(signals(3,:)+1.7);
    plot(signals(4,:)+0.6);
    ylim([0 4.5]);
    legend("base", "EMG", "blood", "video");
    hold off;
end

