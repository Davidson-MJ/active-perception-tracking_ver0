% j3_binDist_bycycle
% here we will bin average distance (error), between
% target and hand, by the gait cycle points.

% to better visualuze error, we will concat 2 successive cycles.

% a little tricky, as gait cycle duration varies.

% First take: resample time vector of each gait to 100 points, then average across
% gaits.


% clear all; close all;
% datadir = 'C:\Users\vrlab\Documents\Matt\Projects\Output\walking_Ver0';
cd([datadir filesep 'ProcessedData'])
pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);
Fs = 90;

resampSize = 200; % resample the gait cycle (DUAL CYCLE) to this many samps.
%%
for ippant = 10:11%:nsubs
    cd([datadir filesep 'ProcessedData'])    %%load data from import job.
    
    load(pfols(ippant).name, 'HeadPos', 'subjID','HandPos', 'trial_TargetSummary')
    savename = pfols(ippant).name;
    disp(['Preparing j3a ' savename]);
    
    %% Gait extraction.
    % Per trial, extract gait samples (trough to trough), normalize along x
    % axis, and store various metrics.
    
    
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
     
       
        % quick classification:
        if mod(itrial,2)~=0 % odd numbers
            % Then descending on X, (i.e. first trajectory), more positive z values
            % are left side of the body.
            walkDir= 'IN';
        elseif mod(itrial,2)==0 % even numbers
            % ascending (the return trajectory), pos z values are RHS
            walkDir= 'OUT';
        end
        
        trs = HeadPos(itrial).Y_gait_troughs;
        pks = HeadPos(itrial).Y_gait_peaks;
        trialTime = HeadPos(itrial).times;
        % plot gaits overlayed;
      
        tmpPos = HeadPos(itrial).Y;
        tmpErr = squeeze(HandPos(itrial).dist2Targ);
        
        tmpErr_Ydim = squeeze(HandPos(itrial).Yerror);
        tmpErr_Xdim = squeeze(HandPos(itrial).Xerror);
        
        tmpErr_Zdim = squeeze(HandPos(itrial).Zerror);
        %preAllocate for easy storage
        gaitD=[]; %struct
        
        [gaitHeadY, gaitErr, gaitErrX, gaitErrY,gaitErrZ]= deal([]); % we will normalize the vector lengths.
        
         for igait=1:length(pks)-2
            
            % now using 2 steps!
            gaitsamps =[trs(igait):trs(igait+2)-1]; % trough to frame before returning to ground.
            gaitTimes = trialTime(gaitsamps);
            
            % head Y data this gait:
            gaitDtmp = tmpPos(gaitsamps);
            
            %head sway (z) this gait:
            ftis = trial_TargetSummary(itrial).gaitData(igait).peak;
            if strcmp(ftis, 'LR')
                gaitD(igait).peak = 'LRL';
            else %Right ft starts
            
                gaitD(igait).peak = 'RLR';
            end
            % normalize height between 0 and 1
            gaitDtmp_n = rescale(gaitDtmp);
            
            % store key data in matrix for easy handling:
            gaitHeadY(igait,:) = imresize(gaitDtmp_n', [1,resampSize]);
            
            %also store head Y info:
            gaitD(igait).Head_Yraw = gaitDtmp;
            gaitD(igait).Head_Ynorm = gaitDtmp_n;
            gaitD(igait).Head_Y_resampled = imresize(gaitDtmp_n', [1,resampSize]);
            gaitD(igait).gaitsamps = gaitsamps;
            gaitD(igait).gaitTimes = gaitTimes;
            gaitD(igait).gaitTimes_strt_fin = [gaitTimes(1) gaitTimes(end)];
            
          
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
                    gaitD(igait).Hand_Targ_err_resampled = imresize(errtmp, [1,resampSize]);
                    gaitErr(igait,:) = imresize(errtmp, [1,resampSize]);
                elseif errsource==2 % Xdim error
                    gaitD(igait).Hand_Targ_errXdim = errtmp;
                    %resampled
                    gaitD(igait).Hand_Targ_errXdim_resampled = imresize(errtmp, [1,resampSize]);
                    gaitErrX(igait,:) = imresize(errtmp, [1,resampSize]);
                    
                elseif errsource==3 % Ydim error
                    gaitD(igait).Hand_Targ_errYdim = errtmp;
                    %resampled
                    gaitD(igait).Hand_Targ_errYdim_resampled = imresize(errtmp, [1,resampSize]);
                    gaitErrY(igait,:) = imresize(errtmp, [1,resampSize]);
                elseif errsource==4 %Zdim
                    gaitD(igait).Hand_Targ_errZdim = errtmp;
                    %resampled
                    gaitD(igait).Hand_Targ_errZdim_resampled = imresize(errtmp, [1,resampSize]);
                    gaitErrZ(igait,:) = imresize(errtmp, [1,200]);
                end
                
            end
            
        end % gait in trial.
        trial_targetSummary(itrial).gaitError_doubGC = gaitErr;
        trial_targetSummary(itrial).gaitErrorXdim_doubGC = gaitErrX;
        trial_targetSummary(itrial).gaitErrorYdim_doubGC = gaitErrY;
        trial_targetSummary(itrial).gaitErrorZdim_doubGC = gaitErrZ;
         
        trial_targetSummary(itrial).gaitHeadY_doubGC= gaitHeadY;
        

        % save this gait info per trial in structure as well.
        HandPos(itrial).gaitData_doubGC = gaitD;
        
    end %trial
    
    %% for all trials, compute the average error and head pos per time point
    ntrials = size(HeadPos,2);
    % plot average error over gait cycle, first averaging within trials.
    [PFX_err_doubleGC,...
    PFX_errXdim_doubleGC,...
    PFX_errYdim_doubleGC,...
    PFX_errZdim_doubleGC, ...
    PFX_headY_doubleGC,PFX_errSTD_doubleGC]= deal(nan(ntrials,resampSize));
       
    stepCount=1;
    [trialIdx,walkSpeed, targetSpeed,trialType]=deal(NaN);
    
    PFX_trialinfo = table(trialIdx, walkSpeed,targetSpeed,trialType);
    
    for itrial= 1:size(HeadPos,2)
         if HeadPos(itrial).isPrac || HeadPos(itrial).isStationary
            continue
        end
        %% subj specific trial rejection
        skip=0;
        rejTrials_trackingv1; %toggles 'skip' based on bad trial ID
        if skip==1
            continue
        end
        
        % omit first and last gaitcycles from each trial
        TrialError= trial_targetSummary(itrial).gaitError_doubGC([3:(end-2)],:);
        TrialErrorXdim= trial_targetSummary(itrial).gaitErrorXdim_doubGC([3:(end-2)],:);
        TrialErrorYdim= trial_targetSummary(itrial).gaitErrorYdim_doubGC([3:(end-2)],:);
        TrialErrorZdim= trial_targetSummary(itrial).gaitErrorZdim_doubGC([3:(end-2)],:);
        
        TrialY= trial_targetSummary(itrial).gaitHeadY_doubGC([3:(end-2)],:);
        
        PFX_err_doubleGC(itrial,:) = mean(TrialError,1);
        PFX_errSTD_doubleGC(itrial,:) = std(TrialError);
        
        PFX_errXdim_doubleGC(itrial,:) = mean(TrialErrorXdim,1);
        PFX_errYdim_doubleGC(itrial,:) = mean(TrialErrorYdim,1);
        PFX_errZdim_doubleGC(itrial,:) = mean(TrialErrorZdim,1);
        
        PFX_headY_doubleGC(itrial,:)= mean(TrialY,1);
        
        % also store data in table for easy access:
        PFX_trialinfo.trialIdx(itrial) = itrial;
        PFX_trialinfo.walkSpeed(itrial) = HeadPos(itrial).walkSpeed;
        PFX_trialinfo.targetSpeed(itrial) = HeadPos(itrial).targSpeed;
        PFX_trialinfo.trialType(itrial) = HeadPos(itrial).trialType;
        
    end % trial
    %%
    

    %%
    disp(['saving targ error per stride cycle gait...' savename])
    PFX_trialinfo_doubgc = PFX_trialinfo;
     save(pfols(ippant).name, ...
        'HeadPos','trial_TargetSummary', '-append');
    
    savename2= [subjID '_PFX_data'];
    save(savename2, ...
        'PFX_trialinfo_doubgc','PFX_err_doubleGC', 'PFX_errSTD_doubleGC','PFX_headY_doubleGC','PFX_errZdim_doubleGC', ...
        'PFX_errXdim_doubleGC', 'PFX_errYdim_doubleGC', '-append');
end % subject

