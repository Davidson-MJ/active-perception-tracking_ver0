%%  Import from csv and plot basics
datadir = 'C:\Users\User\Documents\matt\GitHub\active-perception-tracking_ver0\Analysis Code\Tracking ver 0\Raw_data';

cd(datadir)
pfols = dir([pwd filesep '*.csv']);
nsubs= length(pfols);
%% Per csv file, import and wrangle into Matlab Structures, and data matrices:
for ippant = 1:nsubs
   cd(datadir)
    filename = pfols(ippant).name;
    %extract name&date from filename:
    ftmp = find(filename =='_');
    subjID = filename(1:ftmp(end)-1);
    %read table
    opts = detectImportOptions(filename,'NumHeaderLines',0);
    T = readtable(filename,opts);
    ppant = T.participant{1};
    disp(['Preparing participant ' ppant]);
    
    savename = [subjID '_PositionData_raw'];
    
    % simple plot of target position over time.
    [TargPos, HeadPos, HandPos] = deal([]);
    
    %% use logical indexing to find all relevant info (in cells)
    Data = T.position;
    objs = T.trackedObject;
    axes= T.axis;
    Trials =T.trial;
    
    Times =T.t;
    
    targ_rows = find(contains(objs, 'target'));
    head_rows = find(contains(objs, 'head'));
    hand_rows = find(contains(objs, 'effector'));
    Xpos = find(contains(axes, 'x'));
    Ypos  = find(contains(axes, 'y'));
    Zpos = find(contains(axes, 'z'));
    
    %% now find the intersect of thse indices, to fill the data.
    hx = intersect(head_rows, Xpos);
    hy = intersect(head_rows, Ypos);
    hz = intersect(head_rows, Zpos);
    
    %Targ (XYZ)
    tx = intersect(targ_rows, Xpos);
    ty = intersect(targ_rows, Ypos);
    tz = intersect(targ_rows, Zpos);
    
    %hand (XYZ)
    hnx = intersect(hand_rows, Xpos);
    hny = intersect(hand_rows, Ypos);
    hnz = intersect(hand_rows, Zpos);
    
    %% further store by trials (walking laps).
    vec_lengths=[];
    for itrial = 1:length(unique(Trials))
        
        trial_rows = find(Trials==itrial);
        
        %Head first (X Y Z)
        HeadPos(itrial).X = Data(intersect(hx, trial_rows));
        HeadPos(itrial).Y = Data(intersect(hy, trial_rows));
        HeadPos(itrial).Z = Data(intersect(hz, trial_rows));
        HeadPos(itrial).times = Times(intersect(hz, trial_rows));
        
        TargPos(itrial).X = Data(intersect(tx, trial_rows));
        TargPos(itrial).Y = Data(intersect(ty, trial_rows));
        TargPos(itrial).Z = Data(intersect(tz, trial_rows));
         TargPos(itrial).times = Times(intersect(tz, trial_rows));
        
        HandPos(itrial).X = Data(intersect(hnx, trial_rows));
        HandPos(itrial).Y= Data(intersect(hny, trial_rows));
        HandPos(itrial).Z = Data(intersect(hnz, trial_rows));
        HandPos(itrial).times = Times(intersect(hnz, trial_rows));
        
    end
    
    
    disp(['Saving position data split by trials... ' subjID]);
    rawdata_table = T;
    cd('ProcessedData')
    save(savename, 'HandPos', 'TargPos', 'HeadPos', 'rawdata_table', 'subjID');
    


%%
%reaarramge into data matix for basic plotting.
nTrials = size(HandPos,2);
for iobj=1:3
    switch iobj
        case 1
            dataIN= HeadPos;
        case 2
            dataIN= HandPos;
        case 3
            dataIN= TargPos;
    end
    nMat= nan(3,nTrials,700); % very long vector. populate with different lengths of data.
    
    for itrial= 1:nTrials
        tmp = length(HeadPos(itrial).X);
        nMat(1,itrial,1:tmp) = dataIN(itrial).X;
        nMat(2,itrial,1:tmp) = dataIN(itrial).Y;
        nMat(3,itrial,1:tmp) = dataIN(itrial).Z;
        
    end
    
    
    % save appropr
    switch iobj
        case 1
            Head_posmatrix = nMat;
        case 2
            Hand_posmatrix= nMat;
        case 3
            Targ_posmatrix = nMat;
    end
    
    
end % iobj = 1:3
disp(['Saving data matrix for participant ' subjID ]);
save(savename, 'Head_posmatrix', 'Hand_posmatrix', 'Targ_posmatrix',  '-append');

end % participant
