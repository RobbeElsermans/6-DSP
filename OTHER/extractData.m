function [base, emg, blood, video] = extractData(base_path, emg_path, origin_emg_freq, blood_path, origin_blood_freq, video_path, origin_video_freq,poi,poi_tolerance, base_freq, frame_size, debug)
% extractData  This function will extact the data of emg, perfusion and
% video capture. It will use the base sync signal to align all data and cut
% the parts that doesn't align well, off.
%
% base_path -> the filepath of the base synchronization signal
% base_freq -> the base frequency that we want to archieve on all data (in Hz)
% emg_path -> the filepath of the emg data
% origin_emg_freq -> the original emg data sample rate (in Hz)
% blood_path -> the filepath of the perfusion data
% origin_blood_freq -> the original perfusion data sample rate (in Hz)
% video_path -> the filepath of the video data
% origin_video_freq -> the original video data sample rate (in Hz)
%
% returns a struct with the following structure
% .sync -> the synchronize signal of the dataset
% .data -> the data that is aligned with the synced (and also resampled if
% needed)
% .indexes -> the used indexes in the dataset. These indexes are referenced
% to the given base_freq sample rate


% if 1, this means that the sample rate is estimated and we must find the
% correct sample rate

    % import the data of base. This is our reference.
    [y,Fs] = audioread(base_path); % 8kHz sample 
    [base_sync_1k, base_indexes] = resampleSignal(y(:, 1)', Fs, base_freq, 0);
   
    % import the emg signal
    data = readmatrix(emg_path, 'Range', 4, 'Delimiter', '\t');
    emg_sync = data(:, 3)';
    [emg_sync_1k, emg_indexes] = resampleSignal(emg_sync, origin_emg_freq, base_freq, 0);

    if debug
        %draw correlate
        
        [correlation_emg, lag_emg] = xcorr(base_sync_1k, emg_sync_1k);
        correlation_emg = correlation_emg/max(correlation_emg); % normalize
        correlation_emg = 20.*log10(correlation_emg); % to dB

        figure
        plot(lag_emg, correlation_emg);
        xlabel('Lag');
        ylabel('Correlation in dB');
        ylim([-40 1]);
        xlim([2000 6000]);
        title('Cross-correlation emg before align');

        figure;
        
        subplot(1,2,1);
        subtitle("beginning of signal");
        hold on;
        plot(emg_sync_1k(1:frame_size)+0.6, "DisplayName","emg_before_align");
        plot(base_sync_1k(1:frame_size)-0.6, "DisplayName","sync_before_align");
        ylim([-1.2 1.2]);
        xlabel("samples");
        ylabel("value");
        hold off;

        subplot(1,2,2);
        subtitle("end of signal");
        hold on;
        plot(emg_sync_1k(end-frame_size:end)+0.6, "DisplayName","emg_before_align");
        plot(base_sync_1k(end-frame_size:end)-0.6, "DisplayName","sync_before_align");
        ylim([-1.2 1.2]);
        xlabel("samples");
        ylabel("value");
        hold off;
        sgtitle("sync and emg before align")
        
    end

    % do the aligning of the emg signal towards base signal.
    [base_sync_1k,~, emg_sync_1k, ~] = alignByCorr(base_sync_1k, base_indexes, emg_sync_1k, emg_indexes, frame_size);
    
    if debug
        [correlation_emg, lag_emg] = xcorr(base_sync_1k, emg_sync_1k);
        correlation_emg = correlation_emg/max(correlation_emg); % normalize
        correlation_emg = 20.*log10(correlation_emg); % to dB

        figure
        plot(lag_emg, correlation_emg);
        xlabel('Lag');
        ylabel('Correlation in dB');
        ylim([-40 1]);
        xlim([-1000 1000]);
        title('Cross-correlation emg after align');

        figure;
        subplot(1,2,1);
        subtitle("beginning of signal");
        hold on;
        plot(emg_sync_1k(1:frame_size)+0.6, "DisplayName","emg_before_align");
        plot(base_sync_1k(1:frame_size)-0.6, "DisplayName","sync_before_align");
        ylim([-1.2 1.2]);
        xlabel("samples");
        ylabel("value");
        hold off;

        subplot(1,2,2);
        subtitle("end of signal");
        hold on;
        plot(emg_sync_1k(end-frame_size:end)+0.6, "DisplayName","emg_before_align");
        plot(base_sync_1k(end-frame_size:end)-0.6, "DisplayName","sync_before_align");
        ylim([-1.2 1.2]);
        xlabel("samples");
        ylabel("value");
        hold off;
        sgtitle("sync and emg after align")
    end

    % estimate based on current samples
    [original_samp, ~, ~] = estimateSampleRate(base_sync_1k, emg_sync_1k, origin_emg_freq);

    %resample with correct

    if (debug)
        fprintf("The found EMG sample rate %f", original_samp);
    end

    origin_emg_freq = original_samp;

    % sample everything from the start with the accuired new sample rate of emg

    % import the data of base. This is our reference.
    [y,Fs] = audioread(base_path); % 8kHz sample 
    [base_sync_1k, base_indexes] = resampleSignal(y(:, 1)', Fs, base_freq, 0);
    
    % import the emg signal 
    data = readmatrix(emg_path, 'Range', 4, 'Delimiter', '\t');
    emg_sync = data(:, 3)';
    emg_data = data(:, 4:5)';
    [emg_sync_1k, emg_indexes] = resampleSignal(emg_sync, origin_emg_freq, base_freq, 0);    
    [emg_data_1k(1, :), ~] = resampleSignal(emg_data(1,:), origin_emg_freq, base_freq, 1);  
    [emg_data_1k(2, :), ~] = resampleSignal(emg_data(2,:), origin_emg_freq, base_freq, 1); 
    
    raw_blood_data = load(blood_path);
    blood_data = raw_blood_data.fullDataSet(:, 2:3)';
    blood_sync = raw_blood_data.fullDataSet(:, 1)';
    [blood_sync_1k, blood_indexes] = resampleSignal(blood_sync, origin_blood_freq, base_freq, 0);
    [blood_data_1k(1,:), ~] = resampleSignal(blood_data(1,:), origin_blood_freq, base_freq, 1);
    [blood_data_1k(2,:), ~] = resampleSignal(blood_data(2,:), origin_blood_freq, base_freq, 1);

    raw_video_data = load(video_path);
    video_capture_300 = double(QTMToBin(raw_video_data.elina3.Trajectories.Unidentified.Data, poi, poi_tolerance))';
    [video_sync_1k, video_indexes] = resampleSignal(video_capture_300, origin_video_freq, base_freq, 0);
    

    %allign signals
    [emg_sync_1k, lag_emg_1, emg_indexes] = Align(base_sync_1k, emg_sync_1k, emg_indexes);
    [blood_sync_1k, lag_blood_1, blood_indexes] = Align(base_sync_1k, blood_sync_1k, blood_indexes);
    [video_sync_1k, lag_video_1,video_indexes] = Align(base_sync_1k, video_sync_1k, video_indexes);
    
    temp =  max([lag_emg_1 lag_blood_1 lag_video_1]);
    start_delay = 1*(temp == 0)+temp*(temp ~= 0);
    
    %set everything to start at 1 point
    base_sync_1k = base_sync_1k(start_delay:end);
    base_indexes = base_indexes(start_delay:end);
    emg_sync_1k = emg_sync_1k(start_delay:end);
    emg_indexes = emg_indexes(start_delay:end);
    blood_sync_1k = blood_sync_1k(start_delay:end);
    blood_indexes = blood_indexes(start_delay: end);
    video_sync_1k = video_sync_1k(start_delay:end);
    video_indexes = video_indexes(start_delay: end);
    
    %Set everything to end at the same time
    end_delay = min([length(base_sync_1k) length(emg_sync_1k) length(blood_sync_1k) length(video_sync_1k)]);
    base_sync_1k = base_sync_1k(1:end_delay);
    base_indexes = base_indexes(1:end_delay);
    emg_sync_1k = emg_sync_1k(1:end_delay);
    emg_indexes = base_indexes(1:end_delay);
    blood_sync_1k = blood_sync_1k(1:end_delay);
    blood_indexes = base_indexes(1:end_delay);
    video_sync_1k = video_sync_1k(1:end_delay);
    video_indexes = base_indexes(1:end_delay);


    if debug
        [correlation_emg, lag_emg] = xcorr(base_sync_1k, emg_sync_1k);
        correlation_emg = correlation_emg/max(correlation_emg); % normalize
        correlation_emg = 20.*log10(correlation_emg); % to dB

        figure
        plot(lag_emg, correlation_emg);
        xlabel('Lag');
        ylabel('Correlation in dB');
        ylim([-40 1]);
        xlim([-1000 1000]);
        title('Cross-correlation emg after resample');
    end
    
    %assign to output values
    base.sync = base_sync_1k();
    emg.sync = emg_sync_1k();
    emg.data = emg_data_1k(:, emg_indexes(1): emg_indexes(end));
    emg.range = emg_indexes;
    
    blood.sync = blood_sync_1k;
    blood.data = blood_data_1k(:,emg_indexes(1): emg_indexes(end));
    emg.range = emg_indexes;
    
    video.sync = video_sync_1k;
    video.data = zeros(1, length(video_sync_1k));
    video.range = video_indexes;

end