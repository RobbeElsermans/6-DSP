%BINARIZE THE QTM ACTIVE MARKER SIGNAL

% the data to be exported out
% data = BinToQTM(elina3.Trajectories.Unidentified.Data, [637.1 457.7 193.6], [10 10 10]);

% plot (data(1:300))

function data = QTMToBin(all_data, active_marker_location, active_marker_tolerance)
    % unit mm
    unid = all_data;
    unid(isnan(unid)) = 0;

    unid_x = unid(:,1,:);
    unid_y = unid(:,2,:);
    unid_z = unid(:,3,:);

    unid_x_ActMarker_mask_hi = unid_x > (active_marker_location(1) - active_marker_tolerance);
    unid_x_ActMarker_mask_lo = unid_x < (active_marker_location(1) + active_marker_tolerance);
    unid_x_ActMarker_mask_complete = squeeze(unid_x_ActMarker_mask_lo .* unid_x_ActMarker_mask_hi);

    unid_y_ActMarker_mask_hi = unid_y > (active_marker_location(2) - active_marker_tolerance);
    unid_y_ActMarker_mask_lo = unid_y < (active_marker_location(2) + active_marker_tolerance);
    unid_y_ActMarker_mask_complete = squeeze(unid_y_ActMarker_mask_lo .* unid_y_ActMarker_mask_hi);

    unid_z_ActMarker_mask_hi = unid_z > (active_marker_location(3) - active_marker_tolerance);
    unid_z_ActMarker_mask_lo = unid_z < (active_marker_location(3) + active_marker_tolerance);
    unid_z_ActMarker_mask_complete = squeeze(unid_z_ActMarker_mask_lo .* unid_z_ActMarker_mask_hi);

    data = sum(unid_x_ActMarker_mask_complete .* unid_y_ActMarker_mask_complete .* unid_z_ActMarker_mask_complete)>0.5;
    data = data(1,:);
end