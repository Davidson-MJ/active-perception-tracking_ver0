% Tracking experiment (Var Walk and Targ Speeds)
%%  Import from csv. FramebyFrame, then summary data.

%%%%%% TRACKING TASK version %%%%%%
%frame by frame first:
%Mac:
%  datadir='/Users/matthewdavidson/Documents/GitHub/active-perception-tracking_ver0/Analysis Code/Tracking ver 0/Raw_data';
%mac-HD
% datadir = '/Volumes/WHITEHD_TB/Tracking ver 0/Raw_data';
 %PC:
datadir='C:\Users\User\Documents\matt\GitHub\active-perception-tracking_ver0\Analysis Code\Tracking ver 0\Raw_data';
%PC-HD
% datadir = 'E:\Tracking ver 0\Raw_data';%%


cd(datadir)
pfols = dir([pwd filesep '*framebyframe.csv']);
nsubs= length(pfols);
% show ppant numbers:

tr= table([1:length(pfols)]',{pfols(:).name}' );
disp(tr)
%% Per csv file, import and wrangle into Matlab Structures, and data matrices:
for ippant = 1:10
   %%
    cd(datadir)
   
    pfols = dir([pwd filesep '*framebyframe.csv']);
    %% load subject data as table/
    filename = pfols(ippant).name;
    %extract name&date from filename:
    ftmp = find(filename =='_');
    subjID = filename(1:ftmp(end)-1);
    
    
    savename = [subjID '_summary_data'];
    
    %query whether pos data job has been done (is in list of variables
    %saved)
%     cd('ProcessedData')
%     listOfVariables = who('-file', [savename '.mat']);
%     if ~ismember('HeadPos', listOfVariables)  
        % if not done, load and save frame x frame data.
    % simple extract of positions over time.
    
    %read table
    opts = detectImportOptions(filename,'NumHeaderLines',0);
    T = readtable(filename,opts);
    ppant = subjID(1:4);
    disp(['Preparing participant ' ppant]);
    
    % simple plot of target position over time.
    [TargPos, HeadPos, HandPos_L, HandPos_R] = deal([]);
    
    %% use logical indexing to find all relevant info (in cells)
    Data = T.position;
    objs = T.trackedObject;
    axes= T.axis;
    Trials =T.trial;
    
    Times =T.t;
    
    targ_rows = find(contains(objs, 'target'));
    head_rows = find(contains(objs, 'head'));
    hand_rowsL = find(contains(objs, 'effectorL'));    
    hand_rowsR = find(contains(objs, 'effectorR'));
    
    Xpos = find(contains(axes, 'x'));
    Ypos  = find(contains(axes, 'y'));
    Zpos = find(contains(axes, 'z'));
    
    handedness = subjID(4);
    %% now find the intersect of thse indices, to fill the data.
    hx = intersect(head_rows, Xpos);
    hy = intersect(head_rows, Ypos);
    hz = intersect(head_rows, Zpos);
    
    %Targ (XYZ)
    tx = intersect(targ_rows, Xpos);
    ty = intersect(targ_rows, Ypos);
    tz = intersect(targ_rows, Zpos);
    
    %hand (L) (XYZ)
    hn_Lx = intersect(hand_rowsL, Xpos);
    hn_Ly = intersect(hand_rowsL, Ypos);
    hn_Lz = intersect(hand_rowsL, Zpos);
    
    %hand (R) (XYZ)
    hn_Rx = intersect(hand_rowsR, Xpos);
    hn_Ry = intersect(hand_rowsR, Ypos);
    hn_Rz = intersect(hand_rowsR, Zpos);
    
    %% further store by trials (walking laps).
    vec_lengths=[];
    for itrial = 1:length(unique(Trials))
        
        trial_rows = find(Trials==itrial-1); % 0 index in Unity.
        
        %Head first (X Y Z)
        HeadPos(itrial).X = Data(intersect(hx, trial_rows));
        HeadPos(itrial).Y = Data(intersect(hy, trial_rows));
        HeadPos(itrial).Z = Data(intersect(hz, trial_rows));
        HeadPos(itrial).times = Times(intersect(hz, trial_rows));
        
        
        
        TargPos(itrial).X = Data(intersect(tx, trial_rows));
        TargPos(itrial).Y = Data(intersect(ty, trial_rows));
        TargPos(itrial).Z = Data(intersect(tz, trial_rows));
         TargPos(itrial).times = Times(intersect(tz, trial_rows));
      
         
        HandPos_L(itrial).X = Data(intersect(hn_Lx, trial_rows));
        HandPos_L(itrial).Y= Data(intersect(hn_Ly, trial_rows));
        HandPos_L(itrial).Z = Data(intersect(hn_Lz, trial_rows));
        HandPos_L(itrial).times = Times(intersect(hn_Lz, trial_rows));
        
        HandPos_R(itrial).X = Data(intersect(hn_Rx, trial_rows));
        HandPos_R(itrial).Y= Data(intersect(hn_Ry, trial_rows));
        HandPos_R(itrial).Z = Data(intersect(hn_Rz, trial_rows));
        HandPos_R(itrial).times = Times(intersect(hn_Rz, trial_rows));
        
%         disp([length(HeadPos(itrial).times); length(HandPos_R(itrial).times)])

        if length(HeadPos(itrial).times) ~= length(HandPos_R(itrial).times)
        disp(['debug ' subjID ' trial ' num2str(itrial)]);
        end
    end
    
    
    disp(['Saving position data split by trials... ' subjID]);
    rawFramedata_table = T;
    cd([datadir filesep 'ProcessedData'])
    
%     try save(savename, 'TargPos', 'HeadPos', 'HandPos_L', 'HandPos_R', 'subjID', 'ppant', '-append');
%     catch
        save(savename, 'TargPos', 'HeadPos', 'HandPos_L', 'HandPos_R','subjID', 'ppant');
%     end


%%
%% ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ now summary data

cd(datadir)
pfols = dir([pwd filesep '*trialsummary.csv']);
nsubs= length(pfols);
%
filename = pfols(ippant).name;

%extract name&date from filename:
ftmp = find(filename =='_');
subjID = filename(1:ftmp(end)-1);
%read table
opts = detectImportOptions(filename,'NumHeaderLines',0);
T = readtable(filename,opts);
rawSummary_table = T;
disp(['Preparing participant ' T.participant{1} ]);


savename = [subjID '_summary_data'];
practIndex = find(T.isPrac ==1);
npracTrials = (T.trial(practIndex(end)) +1);
disp([subjID ' has ' num2str(npracTrials) ' practice trials']);
alltrials = unique(T.trial);
trial_TargetSummary=[];

for itrial = 1:length(alltrials)
    %store in easier to wrangle format
      thistrial= alltrials(itrial);
    trial_TargetSummary(itrial).trialID= thistrial;    
    trial_TargetSummary(itrial).isPrac= T.isPrac(itrial);
    trial_TargetSummary(itrial).isStationary= T.isStationary(itrial);

    %% also add to previous data (didn't have prac/stat info)
    HeadPos(itrial).isPrac = T.isPrac(itrial);
    HeadPos(itrial).isStationary = T.isStationary(itrial);
    TargPos(itrial).isPrac = T.isPrac(itrial);
    TargPos(itrial).isStationary= T.isStationary(itrial);
    %% reclassify trialtype to understand mor eeasily:
    %1 = slow walk, slow target
    %2 = slow walk, fast target
    %3 = normal walk, slow target
    %4 = normal walk, fast target
    ttype = T.trialType(itrial);
    trial_TargetSummary(itrial).trialType= ttype;
    
    HeadPos(itrial).trialType = ttype;
    TargPos(itrial).trialType= ttype;
    walkSpeed=0;
   
    if ttype == 1 || ttype == 2
        walkSpeed= 0.5; %half speed trials.
    elseif ttype==3 || ttype==4
        walkSpeed=1;
    end
    if ttype>0 && mod(ttype,2)==0 % even numbs.
        targSpeed = 2;
    elseif  mod(T.trialType(itrial),2)~=0 || ttype==0
        targSpeed=1;
    end

    
    trial_TargetSummary(itrial).walkSpeed=walkSpeed;
    trial_TargetSummary(itrial).targSpeed=targSpeed;
    HeadPos(itrial).walkSpeed = walkSpeed;
    HeadPos(itrial).targSpeed = targSpeed;
    TargPos(itrial).walkSpeed = walkSpeed;
       TargPos(itrial).targSpeed = targSpeed;
end


%save for later analysis per gait-cycle:
disp(['Saving trial summary data ... ' subjID]);
rawdata_table = T;
cd('ProcessedData')
save(savename, 'trial_TargetSummary',...
    'rawdata_table', 'subjID','rawSummary_table', 'HeadPos', 'TargPos','-append');


end % participant
