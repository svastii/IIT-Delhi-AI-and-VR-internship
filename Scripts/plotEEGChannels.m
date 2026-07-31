function plotEEGChannels(EEG,labels,plotTitle)

figure;
offset = 500;

hold on

for ch = 1:EEG.nbchan

    plot(EEG.data(ch,1:min(640,EEG.pnts)) + offset*(ch-1),...
        'LineWidth',1.2);

end

yticks(offset*(0:EEG.nbchan-1));
yticklabels(labels);

xlabel('Samples');
ylabel('Channels');
title(plotTitle);

grid on
box on
hold off

end