%% ==========================================================
% EEG PREPROCESSING PIPELINE - PART 1
% Device : Emotiv EPOC X
% Sampling Rate : 128 Hz
% ==========================================================

clc;
clear;
close all;

%% Start EEGLAB
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

%% INPUT
inputFile = 'C:\Users\hp\Documents\MATLAB\EEG_Actual_VR\condition4_EEG.csv';

outputFolder = 'C:\Users\hp\Documents\MATLAB\Results_VR';

prefix = 'condition4';

if ~exist(outputFolder,'dir')
    mkdir(outputFolder);
end

%% ==========================================================
% READ EEG CHANNELS
%% ==========================================================

disp('Reading EEG channels...');

T = readtable(inputFile,'NumHeaderLines',1);

% Extract only the 14 EEG channels
data = T{:, { ...
    'EEG_AF3','EEG_F7','EEG_F3','EEG_FC5',...
    'EEG_T7','EEG_P7','EEG_O1','EEG_O2',...
    'EEG_P8','EEG_T8','EEG_FC6','EEG_F4',...
    'EEG_F8','EEG_AF4'}};

% Convert to double
data = double(data);

% Remove rows containing NaN (if any)
data = rmmissing(data);

% Convert to channels × samples
data = data';

disp('Data Size:')
disp(size(data))
EEG = eeg_emptyset;

EEG.data = data;
EEG.nbchan = size(data,1);   % Automatically = 14
EEG.pnts = size(data,2);
EEG.trials = 1;
EEG.srate = 128;

EEG = eeg_checkset(EEG);

disp(['Channels = ' num2str(EEG.nbchan)])
disp(['Samples  = ' num2str(EEG.pnts)])
%% ==========================================================
% CREATE EEGLAB DATASET
%% ==========================================================

EEG = eeg_emptyset;

EEG.data = data;
EEG.nbchan = 14;
EEG.pnts = size(data,2);
EEG.trials = 1;
EEG.srate = 128;

EEG = eeg_checkset(EEG);

%% ==========================================================
% CHANNEL LABELS
%% ==========================================================

labels = {'AF3','F7','F3','FC5',...
          'T7','P7','O1','O2',...
          'P8','T8','FC6','F4',...
          'F8','AF4'};

for i = 1:14
    EEG.chanlocs(i).labels = labels{i};
end

EEG = eeg_checkset(EEG);
pop_eegplot(EEG,1,1,1);
%% ==========================================================
% DISPLAY DATASET INFO
%% ==========================================================

disp(['Channels : ' num2str(EEG.nbchan)])
disp(['Samples  : ' num2str(EEG.pnts)])
disp(['Duration : ' num2str(EEG.pnts/EEG.srate) ' sec'])

%% ==========================================================
% STORE DATASET IN EEGLAB
%% ==========================================================

[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 1);

eeglab redraw;

%% ==========================================================
% SAVE RAW DATASET
%% ==========================================================

EEG.setname = prefix;

[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);

EEG = pop_saveset(EEG,...
    'filename',[prefix '_raw.set'],...
    'filepath',outputFolder);

eeglab redraw;
%% ==========================================================
% RAW EEG PLOT

plotEEGChannels(EEG,labels,'Raw EEG');
%% ==========================================================
% BANDPASS FILTER (0.5–45 Hz)
%% ==========================================================

disp('Applying Bandpass Filter (0.5–45 Hz)...');

EEG = pop_eegfiltnew(EEG,0.5,45);

plotEEGChannels(EEG,labels,'After Bandpass Filter');

saveas(gcf,fullfile(outputFolder,[prefix '_Bandpass.png']));

%% ==========================================================
% 50 Hz NOTCH FILTER
%% ==========================================================

disp('Applying 50 Hz Notch Filter...');

EEG = pop_eegfiltnew(EEG,48,52,[],1);

plotEEGChannels(EEG,labels,'After Notch Filter');
saveas(gcf,fullfile(outputFolder,[prefix '_Notch.png']));

%% ==========================================================
% AVERAGE REFERENCE
%% ==========================================================

disp('Applying Average Reference...');

EEG = pop_reref(EEG,[]);

plotEEGChannels(EEG,labels,'Average Referenced EEG');
saveas(gcf,fullfile(outputFolder,[prefix '_AverageReference.png']));

%% ==========================================================
% SAVE FILTERED DATASET
%% ==========================================================

EEG.setname = [prefix '_filtered'];

[ALLEEG,EEG,CURRENTSET] = eeg_store(ALLEEG,EEG,CURRENTSET);

EEG = pop_saveset(EEG,...
    'filename',[prefix '_filtered.set'],...
    'filepath',outputFolder);

disp('Filtering Completed Successfully');

%% ==========================================================
% SAVE FILTERED DATASET
%% ==========================================================

EEG = pop_saveset(EEG,...
    'filename',[prefix '_filtered.set'],...
    'filepath',outputFolder);

disp('PART 1 COMPLETED SUCCESSFULLY');
%% ==========================================================
% LOAD CHANNEL LOCATIONS  <-- ADD THIS BLOCK HERE
%% ==========================================================

disp('Loading channel locations...');

eeglabPath = fileparts(which('eeglab.m'));

locFile = fullfile(eeglabPath,...
    'plugins','dipfit','standard_BEM','elec','standard_1005.elc');

EEG = pop_chanedit(EEG,'lookup',locFile);

EEG = eeg_checkset(EEG);


%% ==========================================================
% RUN ICA
%% ==========================================================

disp('Running ICA...');

EEG = pop_runica(EEG,...
    'icatype','runica',...
    'extended',1,...
    'interrupt','on');

EEG = eeg_checkset(EEG);

disp('ICA completed.');


%% ==========================================================
% VERIFY CHANNEL LOCATIONS
%% ==========================================================

for i = 1:length(EEG.chanlocs)
    fprintf('%s  X=%6.2f  Y=%6.2f  Z=%6.2f\n',...
        EEG.chanlocs(i).labels,...
        EEG.chanlocs(i).X,...
        EEG.chanlocs(i).Y,...
        EEG.chanlocs(i).Z);
end

%% ==========================================================
% RUN ICLABEL
%% ==========================================================

disp('Running ICLabel...');

EEG = iclabel(EEG);

disp('ICLabel completed.');
%% ==========================================================
% DISPLAY COMPONENTS
%% ==========================================================

pop_viewprops(EEG,0,1:size(EEG.icaweights,1),{}, {},1);

disp('Inspect the components.');
disp('Close the Viewprops window after inspection.');

uiwait(msgbox('Inspect ICs and close the Viewprops window to continue'));

%% ==========================================================
% COMPONENT PROBABILITIES
%% ==========================================================

disp('ICLabel Probabilities');

disp(array2table(EEG.etc.ic_classification.ICLabel.classifications,...
    'VariableNames',{'Brain','Muscle','Eye','Heart','LineNoise','ChannelNoise','Other'}));

%% ==========================================================
% REMOVE COMPONENTS
%% ==========================================================

answer = inputdlg(...
    'Enter IC numbers to remove (example: [1 3 6])',...
    'Artifact Removal',1,{'[]'});

if ~isempty(answer)

    badICs = str2num(answer{1});

    if ~isempty(badICs)

        EEG = pop_subcomp(EEG,badICs,0);

        disp('Selected ICs removed.');

    end

end
plotEEGChannels(EEG,labels,'Clean EEG');
%% ==========================================================
% SAVE CLEAN DATASET
%% ==========================================================

EEG.setname = [prefix '_clean'];

[ALLEEG,EEG,CURRENTSET] = eeg_store(ALLEEG,EEG,CURRENTSET);

EEG = pop_saveset(EEG,...
    'filename',[prefix '_clean.set'],...
    'filepath',outputFolder);

disp('Clean EEG dataset saved.');
%% ==========================================================
% PSD ANALYSIS
%% ==========================================================

disp('Computing Power Spectral Density...');

figure;

spectopo(EEG.data,0,EEG.srate,'electrodes','on');

title('Power Spectral Density');

saveas(gcf,...
    fullfile(outputFolder,[prefix '_PSD.png']));


%% ==========================================================
% BAND POWER USING FFT (No Signal Processing Toolbox Required)
%% ==========================================================

disp('Extracting Band Powers...');

% Frequency bands
bands = {
    'Delta', 0.5, 4;
    'Theta', 4, 8;
    'Alpha', 8, 13;
    'Beta' ,13,30;
    'Gamma',30,45};

bandPower = zeros(EEG.nbchan,length(bands));

N = EEG.pnts;
Fs = EEG.srate;

freq = (0:N-1)*(Fs/N);

for ch = 1:EEG.nbchan

    signal = EEG.data(ch,:);

    % FFT
    Y = fft(signal);

    % Power Spectrum
    P = abs(Y).^2/N;

    % Positive frequencies only
    P = P(1:floor(N/2));
    f = freq(1:floor(N/2));

    for b = 1:length(bands)

        low = bands{b,2};
        high = bands{b,3};

        idx = (f >= low) & (f <= high);

        bandPower(ch,b) = sum(P(idx));

    end

end

disp('Band powers computed successfully.');
%% ==========================================================
% TOPOGRAPHIC MAPS
%% ==========================================================

disp('Generating Topographic Maps...');

bandNames = {'Delta','Theta','Alpha','Beta','Gamma'};

for b = 1:5

    figure;

    topoplot(bandPower(:,b),EEG.chanlocs,...
        'electrodes','labels');

    colorbar;

    title([bandNames{b} ' Power']);

    saveas(gcf,...
        fullfile(outputFolder,...
        [prefix '_' bandNames{b} '_Topomap.png']));

end

disp('Topographic maps saved successfully.');

%% ==========================================================
% FEATURE TABLE
%% ==========================================================

channelNames = {EEG.chanlocs.labels}';

FeatureTable = table(channelNames,...
    bandPower(:,1),...
    bandPower(:,2),...
    bandPower(:,3),...
    bandPower(:,4),...
    bandPower(:,5),...
    'VariableNames',...
    {'Channel','Delta','Theta','Alpha','Beta','Gamma'});
%% ==========================================================
% SAVE FEATURES
%% ==========================================================

writetable(FeatureTable,...
    fullfile(outputFolder,...
    [prefix '_BandPower.csv']));

disp('Band Power CSV Saved.');
%% ==========================================================
% BAR GRAPH
%% ==========================================================

figure;

bar(bandPower);

xlabel('Channels');
xticks(1:14)
xticklabels(labels)
xtickangle(45)

ylabel('Power');

legend({'Delta','Theta','Alpha','Beta','Gamma'});

title('Band Power Distribution');

grid on;

saveas(gcf,...
    fullfile(outputFolder,...
    [prefix '_BandPower.png']));
%% ==========================================================
% STATISTICAL FEATURES
%% ==========================================================

disp('Extracting Statistical Features...');

meanFeat     = mean(EEG.data,2);
stdFeat      = std(EEG.data,0,2);
varFeat      = var(EEG.data,0,2);
rmsFeat      = rms(EEG.data,2);
maxFeat      = max(EEG.data,[],2);
minFeat      = min(EEG.data,[],2);
rangeFeat = maxFeat - minFeat;
medianFeat   = median(EEG.data,2);
%% ==========================================================
% FEATURE TABLE
%% ==========================================================

channelNames = {EEG.chanlocs.labels}';

FeatureTable = table(...
    channelNames,...
    meanFeat,...
    stdFeat,...
    varFeat,...
    rmsFeat,...
    maxFeat,...
    minFeat,...
    rangeFeat,...
    medianFeat,...
    bandPower(:,1),...
    bandPower(:,2),...
    bandPower(:,3),...
    bandPower(:,4),...
    bandPower(:,5),...
    'VariableNames',{...
    'Channel',...
    'Mean',...
    'Std',...
    'Variance',...
    'RMS',...
    'Maximum',...
    'Minimum',...
    'Range',...
    'Median',...
    'Delta',...
    'Theta',...
    'Alpha',...
    'Beta',...
    'Gamma'});
%% ==========================================================
% SAVE FEATURES
%% ==========================================================

writetable(FeatureTable,...
    fullfile(outputFolder,...
    [prefix '_Features.csv']));

disp('Feature CSV Saved Successfully.');
%% ===========================================
% Downsampling using M-th Decimation Method
% ===========================================

originalFs = EEG.srate;      % 128 Hz
targetFs   = 20;

%% Mean and Variance Before Downsampling
mean_before = mean(EEG.data,2);
var_before  = var(EEG.data,0,2);

%% PSD Before Downsampling
figure;
pop_spectopo(EEG,1,[0 EEG.xmax*1000],'EEG');
title('PSD Before Downsampling');

%% Anti-Aliasing Low-Pass Filter
% Cutoff below Nyquist frequency of target sampling rate
EEG = pop_eegfiltnew(EEG,[],9);

%% M-th Decimation

M = floor(originalFs/targetFs);      % M = 6

data_down = EEG.data(:,1:M:end);

EEG_down = EEG;
EEG_down.data = data_down;
EEG_down.srate = originalFs/M;
EEG_down.pnts = size(data_down,2);

%% Mean and Variance After Downsampling

mean_after = mean(EEG_down.data,2);
var_after  = var(EEG_down.data,0,2);

%% PSD After Downsampling

figure;
pop_spectopo(EEG_down,1,[0 EEG_down.xmax*1000],'EEG');
title('PSD After Downsampling');

%% Comparison Table
figure

subplot(2,1,1)

bar([mean_before mean_after])
xticks(1:14)
xticklabels(labels)
xtickangle(45)

legend('Before','After')

title('Mean Comparison')

subplot(2,1,2)

bar([var_before var_after])
xticks(1:14)
xticklabels(labels)
xtickangle(45)

legend('Before','After')

title('Variance Comparison')
%% Comparison Table

channelNames = string({EEG.chanlocs.labels})';

comparison = table(...
    channelNames,...
    mean_before,...
    mean_after,...
    var_before,...
    var_after,...
    'VariableNames',...
    {'Channel','Mean_Before','Mean_After',...
     'Variance_Before','Variance_After'});

disp(comparison);

writetable(comparison,...
    fullfile(outputFolder,[prefix '_Downsampling_Statistics.csv']));

%% Save Downsampled Dataset

EEG_down = pop_saveset(EEG_down,...
    'filename',[prefix '_20Hz.set'],...
    'filepath',outputFolder);

%% Export Downsampled CSV

writematrix(EEG_down.data',...
    fullfile(outputFolder,[prefix '_20Hz.csv']));

disp('Downsampling Completed Successfully');