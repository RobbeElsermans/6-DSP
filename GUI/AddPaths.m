function [] = AddPaths()
    switch true
        case ismac 
            disp('MAC')
        case isunix
            disp('Linux')
            addpath OTHER
            addpath DATASET/example
            addpath DATASET/real
        case ispc
            disp('Windows')
            addpath OTHER\
            addpath DATASET\example
            addpath DATASET\real
        otherwise
            warning('Platform not supported')
    end
end

