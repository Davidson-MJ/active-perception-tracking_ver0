% Pilot_Analysis_Pipeline

addpath([pwd filesep 'support_files'])

%raw data dir;
datadir= 'C:\Users\vrlab\Documents\Matt\Projects\Output\walking_Ver0';
cd(datadir);

pfols= dir([pwd  filesep '*.csv']);
nsubs= length(pfols);
Fs = 90;

for ippant = 1:nsubs
    cd(datadir)
    %% import csv to matlab:   
    VR_import_plot;
    %% split trials into individual gait cycles
    j1_split_bycycle;
    
    %% calculate Target-Effector distance, all samples.
    j2_calcDistance_persample;
    
    %% sort distance per sample, into gait cycles.
    j3_binDist_bycycle; % single cycle
    j3a_binDist_byLinkedcycles % 2step cycle.
    
    disp(['Fin pipeline for ' subjID]);
    disp(num2str(ippant))
end
%% PLOTTING:
    j4_plotError_by_gaitcycle;
    
    
 