%% ==========================
% CONDITION 1 - REAL EEG
% ===========================

%% Load CSV
T = readtable('C:\Users\hp\Documents\EEG_Actual_noVR\condition1.csv');
data = table2array(T);
data = data';

% Remove marker channel if present
if size(data,1)==15
    data = data(1:14,:);
end

%% Create EEGLAB Dataset
EEG = eeg_emptyset;
EEG.data = data;
EEG.nbchan = 14;
EEG.pnts = size(data,2);
EEG.trials = 1;
EEG.srate = 128;
EEG = eeg_checkset(EEG);

%% Channel Labels
channel_names = {'AF3','F7','F3','FC5','T7','P7','O1',...
                 'O2','P8','T8','FC6','F4','F8','AF4'};

for i = 1:14
    EEG.chanlocs(i).labels = channel_names{i};
end

%% Raw EEG Plot
figure;
plot(EEG.data(:,1:min(640,EEG.pnts))' + (0:13)*100);
title('Condition 1 Raw EEG');

%% ==========================
% Downsample (128 Hz → 20 Hz)
%% ==========================
EEG = pop_resample(EEG,20);

disp(['New Sampling Rate = ',num2str(EEG.srate),' Hz']);

%% Bandpass Filter
EEG = pop_eegfiltnew(EEG,0.5,9);

figure;
plot(EEG.data(:,1:min(100,EEG.pnts))' + (0:13)*100);
title('Condition 1 After Bandpass');

%% Optional Notch Filter
% Usually not required after downsampling to 20 Hz
% because 50 Hz cannot exist in a 20 Hz sampled signal.

%% Add Channel Locations
EEG = pop_chanedit(EEG,'lookup','standard_1005.elc');

%% Save Filtered Dataset
EEG = pop_saveset(EEG,...
    'filename','condition1_filtered_20Hz.set');

%% ICA
EEG = pop_runica(EEG,'extended',1);

%% Save ICA Dataset
EEG = pop_saveset(EEG,...
    'filename','condition1_ICA_20Hz.set');

%% ICLabel
EEG = pop_iclabel(EEG,'default');

%% Remove Artifact Components
EEG = pop_subcomp(EEG,[10 11 13 14],0);

%% Save Cleaned Dataset
EEG = pop_saveset(EEG,...
    'filename','condition1_cleaned_20Hz.set');

%% PSD
figure;
pop_spectopo(EEG,1,[0 EEG.xmax*1000],'EEG');
title('Condition 1 PSD');

%% Frequency Spectrum
[spec,freqs] = spectopo(EEG.data,0,EEG.srate);

%% Delta Band
delta_idx = freqs >= 0.5 & freqs <= 4;
delta_power = mean(spec(:,delta_idx),2);

figure;
topoplot(delta_power,EEG.chanlocs);
colorbar;
title('Condition 1 Delta Power');

%% Theta Band
theta_idx = freqs >= 4 & freqs <= 8;
theta_power = mean(spec(:,theta_idx),2);

figure;
topoplot(theta_power,EEG.chanlocs);
colorbar;
title('Condition 1 Theta Power');

%% Alpha Band (8–10 Hz only after downsampling)
alpha_idx = freqs >= 8 & freqs <= 10;
alpha_power = mean(spec(:,alpha_idx),2);

figure;
topoplot(alpha_power,EEG.chanlocs);
colorbar;
title('Condition 1 Alpha Power');

%% Save Features
features = table(delta_power,...
                 theta_power,...
                 alpha_power);

writetable(features,'condition1_features_20Hz.csv');