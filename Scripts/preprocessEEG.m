function preprocessEEG(inputFile, outputFolder, prefix)

% ==========================================================
% REAL EEG PREPROCESSING PIPELINE
% Device : Emotiv EPOC X
% Channels : 14
% Sampling Rate : 128 Hz
% ==========================================================

fprintf('\n=========================================\n');
fprintf('Processing : %s\n',prefix);
fprintf('=========================================\n');

%% Create Output Folder

if ~exist(outputFolder,'dir')
    mkdir(outputFolder);
end

%% --------------------------------------------------------
% READ CSV
%% --------------------------------------------------------

disp('Reading EEG CSV...');

T = readtable(inputFile);

data = table2array(T);

data = data';

% Remove marker channel if present

if size(data,1)==15
    data = data(1:14,:);
end

%% --------------------------------------------------------
% CREATE EEGLAB DATASET
%% --------------------------------------------------------

EEG = eeg_emptyset;

EEG.data = data;
EEG.nbchan = 14;
EEG.pnts = size(data,2);
EEG.trials = 1;
EEG.srate = 128;

EEG = eeg_checkset(EEG);

%% --------------------------------------------------------
% CHANNEL LABELS
%% --------------------------------------------------------

channel_names = {...
'AF3','F7','F3','FC5','T7','P7','O1',...
'O2','P8','T8','FC6','F4','F8','AF4'};

EEG.chanlocs = struct([]);

for i = 1:14

    EEG.chanlocs(i).labels = channel_names{i};

end

EEG = eeg_checkset(EEG);

disp('Channel labels assigned.');

%% --------------------------------------------------------
% LOAD CHANNEL LOCATIONS
%% --------------------------------------------------------

disp('Loading standard channel locations...');

eeglabPath = fileparts(which('eeglab.m'));

locFile = fullfile(eeglabPath,...
    'plugins',...
    'dipfit',...
    'standard_BEM',...
    'elec',...
    'standard_1005.elc');

if exist(locFile,'file')

    EEG = pop_chanedit(EEG,...
        'lookup',locFile);

    disp('Standard electrode positions loaded.');

else

    warning('standard_1005.elc not found.');
    warning('Topoplots may not display correctly.');

end

%% --------------------------------------------------------
% RAW EEG PLOT
%% --------------------------------------------------------

figure;
hold on;

offset = 100;
labels = {'AF3','F7','F3','FC5','T7','P7','O1','O2','P8','T8','FC6','F4','F8','AF4'};

for ch = 1:14
    plot(EEG.data(ch,1:640) + (14-ch)*offset,'LineWidth',1);
end

yticks((0:13)*offset);
yticklabels(flip(labels));   % AF4 at top, AF3 at bottom

ylim([-50 1350]);
set(gca,'YDir','normal');

xlabel('Samples');
ylabel('Channels');
title('Raw EEG');
grid on;
box on;
%% --------------------------------------------------------
% SAVE RAW DATASET
%% --------------------------------------------------------

EEG = pop_saveset(EEG,...
'filename',[prefix '_raw.set'],...
'filepath',outputFolder);

disp('Raw dataset saved.');

%% --------------------------------------------------------
% BANDPASS FILTER
%% --------------------------------------------------------

disp('Applying Bandpass Filter (0.5-45 Hz)...');

EEG = pop_eegfiltnew(EEG,...
0.5,...
45);

figure('Name',[prefix ' Bandpass']);

plot(EEG.data(:,1:min(640,EEG.pnts))'+(0:13)*100);

xlabel('Samples');

ylabel('Amplitude');

title([prefix ' After Bandpass']);

grid on;

saveas(gcf,...
fullfile(outputFolder,...
[prefix '_Bandpass.png']));

%% --------------------------------------------------------
% NOTCH FILTER
%% --------------------------------------------------------

disp('Applying 50 Hz Notch Filter...');

EEG = pop_eegfiltnew(EEG,...
48,...
52,...
[],...
1);

figure('Name',[prefix ' Notch']);

plot(EEG.data(:,1:min(640,EEG.pnts))'+(0:13)*100);

xlabel('Samples');

ylabel('Amplitude');

title([prefix ' After Notch']);

grid on;

saveas(gcf,...
fullfile(outputFolder,...
[prefix '_Notch.png']));

%% --------------------------------------------------------
% SAVE FILTERED DATASET
%% --------------------------------------------------------

EEG = pop_saveset(EEG,...
'filename',[prefix '_filtered.set'],...
'filepath',outputFolder);

disp('Filtering completed.');

%% ========================================================
%% PART 2
%% ICA
%% ICLabel
%% Artifact Rejection
%% Save Cleaned Dataset
%% ========================================================