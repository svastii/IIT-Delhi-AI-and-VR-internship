clc;
clear;
close all;

folder = 'C:\Users\hp\Documents\MATLAB\Results_NoVR';

T1 = readtable(fullfile(folder,'condition1_BandPower.csv'));
T2 = readtable(fullfile(folder,'condition2_BandPower.csv'));
T3 = readtable(fullfile(folder,'condition3_BandPower.csv'));

T1.Condition = repmat("Condition1",height(T1),1);
T2.Condition = repmat("Condition2",height(T2),1);
T3.Condition = repmat("Condition3",height(T3),1);

FinalTable = [T1;T2;T3];

writetable(FinalTable,...
    fullfile(folder,'NoVR_BandPower_Final.csv'));

disp('Band Power Files Merged Successfully');