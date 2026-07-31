%% ==========================================================
% MERGE MULTIMODAL DATA
% EEG + Eye Tracking + Movement + Distraction
%% ==========================================================

clear;
clc;
close all;

eeglab;

%% Paths

baseFolder = 'YOUR_FOLDER_PATH';

EEG = pop_loadset('filename','condition5_20Hz.set',...
                  'filepath',baseFolder);

eyeFile = fullfile(baseFolder,'condition5_Eyetracking.csv');
moveFile = fullfile(baseFolder,'condition5_movement.csv');
distFile = fullfile(baseFolder,'condition5_Distractions.csv');

Eye = readtable(eyeFile);
Move = readtable(moveFile);
Dist = readtable(distFile);

%% ----------------------------------------------------------
% EEG
%% ----------------------------------------------------------

EEGdata = EEG.data';
N = size(EEGdata,1);

EEGTable = array2table(EEGdata,...
    'VariableNames',{EEG.chanlocs.labels});

EEGTable.Time = (0:N-1)'/EEG.srate;

%% ----------------------------------------------------------
% Eye Tracking
%% ----------------------------------------------------------

Eye.Time = Eye.("Time(ms)")/1000;

Eye = sortrows(Eye,"Time");

EyeSync = retime(table2timetable(Eye,...
    'RowTimes',seconds(Eye.Time)),...
    seconds(EEGTable.Time),...
    'nearest');

EyeSync = timetable2table(EyeSync);

%% ----------------------------------------------------------
% Movement
%% ----------------------------------------------------------

Move.Time = Move.("Time(ms)")/1000;

Move = sortrows(Move,"Time");

MoveSync = retime(table2timetable(Move,...
    'RowTimes',seconds(Move.Time)),...
    seconds(EEGTable.Time),...
    'nearest');

MoveSync = timetable2table(MoveSync);

%% ----------------------------------------------------------
% Distraction Labels
%% ----------------------------------------------------------

labels = zeros(N,1);

for i=1:height(Dist)

    t = Dist.timestamp(i);

    idx = find(EEGTable.Time>=t,1);

    if ~isempty(idx)

        labels(idx:end)=1;

    end

end

%% ----------------------------------------------------------
% Final Dataset
%% ----------------------------------------------------------

Final = [EEGTable ...
         EyeSync(:,2:end) ...
         MoveSync(:,2:end)];

Final.Distraction = labels;

%% Save

writetable(Final,...
    fullfile(baseFolder,...
    'condition5_Multimodal.csv'));

disp('Done!');