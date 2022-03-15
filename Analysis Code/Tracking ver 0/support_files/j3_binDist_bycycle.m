% j3_binDist_bycycle
% here we will bin average distance (error), between
% target and hand, by the gait cycle points.

% a little tricky, as gait cycle duration varies.

% First take: resample time vector of each gait to 100 points, then average across
% gaits.


% clear all; close all;
cd([datadir filesep 'ProcessedData'])
pfols= dir([pwd  filesep '*raw.mat']);
nsubs= length(pfols);
%show ppant list:
tr= table([1:length(pfols)]',{pfols(:).name}' );
disp(tr)
%%
for ippant = 1:nsubs
    cd([datadir filesep 'ProcessedData'])    %%load data from import job.
    load(pfols(ippant).name, ...
        'HeadPos', 'trial_TargetSummary', 'subjID');
    savename = pfols(ippant).name;
    disp(['Preparing j3 ' savename]);
    
    %% Gait extraction.
    % Per trial, extract gait samples (trough to trough), normalize along x
    % axis, and store various metrics.
    
    TargetError_perTrialpergait =[];
    
    for itrial=1:size(HeadPos,2)
        if HeadPos(itrial).isPrac || HeadPos(itrial).isStationary
            continue
        end
         %% subj specific trial rejection
        skip=0;
        rejTrials_trackingv1; %toggles 'skip' based on bad trial ID               
        if skip==1
            continue
        end
        trs = HeadPos(itrial).Y_gait_troughs;
        pks = HeadPos(itrial).Y_gait_peaks;
        trialTime = HeadPos(itrial).times;
        
        % Head position data:
        tmpPos=  squeeze(HeadPos(itrial).Y);
        tmpSway = squeeze(HeadPos(itrial).Z);
        tmpwalkDir = squeeze(HeadPos(itrial).X);
        
        % quick classification:
        if mod(itrial,2)~=0 % odd numbers (walking toward bldng)
            % Then descending on X, (i.e. first trajectory), more positive z values
            % are left side of the body.
            walkDir= 'IN';
        elseif mod(itrial,2) ==0
            % ascending (the return trajectory), pos z values are RHS
            walkDir= 'OUT';
        end
            
        % plot gaits overlayed;
       
        tmpPos = HeadPos(itrial).Y;
        tmpErr = squeeze(HandPos(itrial).dist2Targ);
        
        tmpErr_Ydim = squeeze(HandPos(itrial).Yerror);
        tmpErr_Xdim = squeeze(HandPos(itrial).Xerror);
        tmpErr_Zdim = squeeze(HandPos(itrial).Zerror);
        
        %preAllocate for easy storage
        gaitD=[]; %struct
        [gaitHeadY, gaitErr, gaitErrX, gaitErrY, gaitErrZ]= deal(zeros(length(pks), 100)); % we will normalize the vector lengths.
        gaitType= {}; % we'll store the foot centred at each peak.
        
        for igait=1:length(pks)
            gaitsamps =[trs(igait):trs(igait+1)-1];% from trough to frame before next trough.
%             
            gaitTimes = HeadPos(itrial).times(gaitsamps);
            % head Y data this gait:
            gaitDtmp = tmpPos(gaitsamps);
            
            %head sway (z) this gait:
            gaitZtmp = tmpSway(gaitsamps);
            
            %which foot starts this gait??
            %% debug plot to sanity check.
            % not I can animate a single trial, with script.
            % plotj2_singletrial_walkgif.m
%             clf; subplot(211); plot(tmpSway);
%             hold on;
%             plot(trs(igait), tmpSway(trs(igait),1), 'color','b', 'marker','o');
%             plot(trs(igait+1), tmpSway(trs(igait+1),1), 'color','k', 'marker','o');
%             if strcmp(walkDir, 'OUT') 
%                 set(gca, 'ydir', 'reverse')
%             end
%             subplot(212); plot(tmpPos);
%             hold on;
%             plot(trs(igait), tmpPos(trs(igait),1), 'color','b', 'marker','o');
%             plot(trs(igait+1), tmpPos(trs(igait+1),1), 'color','k', 'marker','o');
            %%
            % is the z value increasing or decreasing? (sway direction)
            at_trough = tmpSway(trs(igait));
            post_trough = mean(tmpSway(trs(igait):trs(igait)+5));
            
            if at_trough>post_trough% head was closer to the wall, now swinging toward stairwell
                if strcmp(walkDir, 'IN') 
                    gaitD(igait).peak= 'RL'; % shifting weight to right foot.
                else % reverse orintation, increasing numbers swinging to the RHS
                    gaitD(igait).peak= 'LR';
                end
            else % head trough, this step, is closer to the stairs than next step
                 if strcmp(walkDir, 'IN') 
                    % then swinging to the LHS of the body (pushing off
                    % right foot at the previous pk.
                    gaitD(igait).peak= 'LR';
                else % reverse orintation, increasing numbers swinging to the RHS
                    gaitD(igait).peak= 'RL';
                 end
            end
                
            % normalize height between 0 and 1
            gaitDtmp_n = rescale(gaitDtmp);
            
            
            % store data in matrix for easy handling:
            gaitHeadY(igait,:) = imresize(gaitDtmp_n', [1,100]);
            
            
            %also store head Y info:
            gaitD(igait).Head_Yraw = gaitDtmp;
            gaitD(igait).Head_Ynorm = gaitDtmp_n;
            gaitD(igait).Head_Y_resampled = imresize(gaitDtmp_n', [1,100]);
            gaitD(igait).gaitsamps = gaitsamps;
            gaitD(igait).gaitTimes = gaitTimes;
            gaitD(igait).gaitTimes_strt_fin = [gaitTimes(1) gaitTimes(end)];
            % other cycle info:
            %height
            gaitD(igait).tr2pk = tmpPos(pks(igait)) - tmpPos(trs(igait));
            gaitD(igait).pk2tr = tmpPos(pks(igait)) - tmpPos(trs(igait+1));
            
            %dist
            gaitD(igait).tr2pk_dur = length(trs(igait):pks(igait));
            gaitD(igait).pk2tr_dur = length(pks(igait):trs(igait+1));
            
            %height ./ dist
            risespeed = tmpPos(pks(igait)) - tmpPos(trs(igait)) / length(trs(igait):pks(igait));
            fallspeed = tmpPos(pks(igait)) - tmpPos(trs(igait+1)) / length(pks(igait):trs(igait+1));
            
            gaitD(igait).risespeed = risespeed;
            gaitD(igait).fallspeed = fallspeed;
            
            %% Store Error (hand-targ) next"
            for errsource = 1:4
                switch errsource
                    case 1
                        errD = tmpErr; % euclidean (3D)
                    case 2
                        errD = tmpErr_Xdim;
                    case 3
                        errD = tmpErr_Ydim;
                    case 4
                        errD = tmpErr_Zdim;
                        
                end
                
                %error (hand-targ) this gait:
                errtmp = errD(gaitsamps);
                
                if errsource==1 % 3D error
                    gaitD(igait).Hand_Targ_err = errtmp;
                    %resampled
                    gaitD(igait).Hand_Targ_err_resampled = imresize(errtmp, [1,100]);
                    gaitErr(igait,:) = imresize(errtmp, [1,100]);
                elseif errsource==2 % Xdim error
                    gaitD(igait).Hand_Targ_errXdim = errtmp;
                    %resampled
                    gaitD(igait).Hand_Targ_errXdim_resampled = imresize(errtmp, [1,100]);
                    gaitErrX(igait,:) = imresize(errtmp, [1,100]);
                    
                elseif errsource==3 % Ydim error
                    gaitD(igait).Hand_Targ_errYdim = errtmp;
                    %resampled
                    gaitD(igait).Hand_Targ_errYdim_resampled = imresize(errtmp, [1,100]);
                    gaitErrY(igait,:) = imresize(errtmp, [1,100]);
                elseif errsource==4 %Zdim
                    gaitD(igait).Hand_Targ_errZdim = errtmp;
                    %resampled
                    gaitD(igait).Hand_Targ_errZdim_resampled = imresize(errtmp, [1,100]);
                    gaitErrZ(igait,:) = imresize(errtmp, [1,100]);
                end
                
            end
            
         
        end % gait in trial.
        TargetError_perTrialpergait(itrial).gaitError = gaitErr;
        TargetError_perTrialpergait(itrial).gaitErrorXdim = gaitErrX;
        TargetError_perTrialpergait(itrial).gaitErrorYdim = gaitErrY;
        TargetError_perTrialpergait(itrial).gaitErrorZdim = gaitErrZ;
        
        TargetError_perTrialpergait(itrial).gaitHeadY= gaitHeadY;
        
        % save this gait info per trial in structure as well.
        HeadPos(itrial).gaitData = gaitD;
        
    end %trial
    
    %% for all trials, compute the average error and head pos per time point
    expindx= [HeadPos(:).isPrac];
    nprac= length(find(expindx>0));
    
    ntrials = size(HeadPos,2) - nprac;
    
    % plot average error over gait cycle, first averaging within trials.
    [PFX_err,PFX_errXdim, PFX_errYdim,PFX_errZdim, PFX_headY,PFX_headZ]= deal(zeros(ntrials,100));
%     
%     [PFX_pertrial_binnedVar]= deal(zeros(ntrials,9)); % also plot the binned variance
%     
%     PFX_allsteps_binnedErr=[];
    
    for itrial= 1:size(HeadPos,2)
        if HeadPos(itrial).isPrac ||  HeadPos(itrial).isStationary
            continue
        end
        
         %% subj specific trial rejection
        skip=0;
        rejTrials_trackingv1; %toggles 'skip' based on bad trial ID               
        if skip==1
            continue
        end
        
         
         nGaits = length(trial_TargetSummary(itrial).gaitData);
        allgaits = 1:nGaits;
       % omit first and last gaitcycles from each trial?
       usegaits = allgaits(3:end-2);
        
        %data of interest is the resampled gait (1:100) with a position of
        %the targ (now classified as correct or no).
        TrialY= trial_TargetSummary(itrial).gaitHeadY(usegaits,:);       
        
        % omit first 2 and last 2 gaitcycle from each trial
        TrialError= TargetError_perTrialpergait(itrial).gaitError(usegaits,:);
        TrialErrorXdim= TargetError_perTrialpergait(itrial).gaitErrorXdim(usegaits,:);
        TrialErrorYdim= TargetError_perTrialpergait(itrial).gaitErrorYdim(usegaits,:);
        TrialErrorZdim= TargetError_perTrialpergait(itrial).gaitErrorZdim(usegaits,:);
        
        
        PFX_err(itrial,:) = mean(TrialError,1);
        PFX_errXdim(itrial,:) = mean(TrialErrorXdim,1);
        PFX_errYdim(itrial,:) = mean(TrialErrorYdim,1);
        PFX_errZdim(itrial,:) = mean(TrialErrorZdim,1);
        PFX_headY(itrial,:)= mean(TrialY,1);
        
%         PFX_allsteps_binnedErr = [PFX_allsteps_binnedErr; TrialError];
        
        
    end % all trials
    
    %% visualize ppant error (debugging)
    % clf
    % plot(mean(PFX_err,1));
    % yyaxis right
    % xvec = linspace(1,100,9);
    % plot(xvec, mean(PFX_binnedVar,1), 'k');
    % hold on;
    % plot(xvec, PFX_binnedVartotal);
    %%
    disp(['saving targ error per gait...' savename])
    save(savename, 'HeadPos', 'TargetError_perTrialpergait',...
        'PFX_err', 'PFX_errXdim','PFX_errYdim','PFX_errZdim','PFX_headY', 'PFX_allsteps_binnedErr',...
        '-append');
end % subject

