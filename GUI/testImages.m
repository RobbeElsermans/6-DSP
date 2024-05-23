% Example Data: Replace this with your actual array of matrices
% For illustration, we'll create a cell array of random binary matrices
numMatrices = 10; % Number of matrices
matrixSize = [10, 10]; % Size of each matrix
matrices = cell(1, numMatrices);
for i = 1:numMatrices
    matrices{i} = randi([0, 1], matrixSize);
end

% Create figure for animation
figure;

% Loop through each matrix and display it
for k = 1:numMatrices
    imagesc(matrices{k}); % Display matrix as an image
    colormap(gray); % Use gray colormap (0=black, 1=white)
    colorbar; % Display colorbar
    axis equal tight; % Make axes tight and equal for better visualization
    title(sprintf('Matrix %d', k)); % Display frame number
    pause(0.5); % Pause for 0.5 seconds between frames
end