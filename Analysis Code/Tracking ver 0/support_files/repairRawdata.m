% Script to repair multiple CSVs recorded in raw data.

%PC:
datadir='C:\Users\User\Documents\matt\GitHub\active-perception-tracking_ver0\Analysis Code\Tracking ver 0\Raw_data';

cd(datadir)
%%
pfols = dir([pwd filesep '*framebyframe.csv']);
nsubs= length(pfols);
% show ppant numbers:
%%
tr= table([1:length(pfols)]',{pfols(:).name}' );
%
disp(tr)

%% repair those with multiple entries.
%% Per csv file, import and wrangle into Matlab Structures, and data matrices:
combineppants =[22,23];
icount=1;
%%
for ippant = combineppants
   %%
    cd(datadir)
   
    pfols = dir([pwd filesep '*framebyframe.csv']);
    %% load subject data as table/
    filename = pfols(ippant).name;
    %extract name&date from filename:
    ftmp = find(filename =='_');
    subjID = filename(1:ftmp(end)-1);
    %read table
    opts = detectImportOptions(filename,'NumHeaderLines',0);
    T = readtable(filename,opts);
    ppant = T.participant{1};
    disp(['Preparing participant ' ppant]);
    %%
    Tindex = unique(T.trial);
    
%%
disp(Tindex)

if icount==1
    T1frame = T;
elseif icount==2
    T2frame= T;
end

%% do the same for trial summary data
pfols = dir([pwd filesep '*trialsummary.csv']);
    %% load subject data as table/
    filename = pfols(ippant).name;
    %extract name&date from filename:
    ftmp = find(filename =='_');
    subjID = filename(1:ftmp(end)-1);
    %read table
    opts = detectImportOptions(filename,'NumHeaderLines',0);
    T = readtable(filename,opts);
    ppant = T.participant{1};
    %%
    Tindex = unique(T.trial);
    
if icount==1
    T1summary= T;
elseif icount==2
    T2summary= T;
end
icount=icount+1;

%%
end
%% combine tables;
T3= [T1frame;T2frame];
fixindex = size(T1frame,1);
prevTrialmax = max(T1frame.trial);
%create array for new trial index:
oldindex = T3.trial(fixindex+1:size(T3,1));
newindex = oldindex + prevTrialmax+1;
%%
T3.trial(fixindex+1:size(T3,1)) = newindex;

%%
writetable(T3, [subjID '_newframe.csv']);
%% now for summary data
T3= [T1summary;T2summary];
fixindex = size(T1summary,1);
prevTrialmax = max(T1summary.trial);
%create array for new trial index:
oldindex = T3.trial(fixindex+1:size(T3,1));
newindex = oldindex + prevTrialmax+1;
%%
T3.trial(fixindex+1:size(T3,1)) = newindex;
%%
writetable(T3, [subjID '_newsummary.csv']);