addpath '../../DATASET'

%% .mat files
filename = 'elina3_nogapfilling.mat';
load(filename)
filename = 'perfusion_and_sync_19-Dec-2023-11_15_20.mat';
load(filename)

%% .wav files
% https://nl.mathworks.com/help/matlab/ref/audioread.html
filename = 'pianosync.wav';
[y,Fs] = audioread(filename);
%sound(y,Fs);

%% .csv files
filename = 'ECtest2.csv';
csv_table = readtable(filename, 'VariableNamingRule', 'preserve');
csv = csv_table{:,:};

%% .txt files
% https://nl.mathworks.com/help/matlab/ref/readmatrix.html#mw_242c5758-0d40-4b04-addc-3a5de11f672a_sep_btx_238-1-opts
filename = 'opensignals_000780589b3a_2023-12-19_11-12-23.txt';
txt = readmatrix(filename, 'Range', 4, 'Delimiter', '\t');

% https://nl.mathworks.com/help/matlab/ref/array2table.html#namevaluepairarguments
txt_table = array2table(txt,'VariableNames',{'nSeq','DI','CH1','CH2','CH3'});