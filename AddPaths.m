function [] = AddPaths()
    switch true
        case ismac 
            disp('MAC')
        case isunix
            disp('Linux')
            addpath OTHER
            addpath DATASET/real
            addpath DATASET/example
        case ispc
            disp('Windows')
            addpath OTHER\
            addpath DATASET\
        otherwise
            warning('Platform not supported')
    end
end

