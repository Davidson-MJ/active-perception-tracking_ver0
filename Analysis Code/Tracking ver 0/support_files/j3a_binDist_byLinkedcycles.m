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
pfols= dir([pwd  filesep '*raw.mat']);
nsubs= length(pfols);
Fs = 90;
% Timevec = [1:500]*1/90;

nPrac=5; % trial indices for skipping (no peaks/ troughs).

resampSize = 200; % resample the gait cycle (DUAL CYCLE) to this many samps.
%%
for ippant = 1:nsubs
    cd([datadir filesep 'ProcessedData'])    %%load data from import job.
    
    load(pfols(ippant).name)
    savename = pfols(ippant).name;
    disp(['Preparing j3a ' savename]);
    
    %% Gait extraction.
    % Per trial, extract gait samples (trough to trough), normalize along x
    % axis, and store various metrics.
    
    TargetError_perTrialpergait_doubleGC =[];
    
    for itrial=nPrac+1:size(Head_posmatrix,2)
        
        trs = HeadPos(itrial).Y_gait_troughs;
        pks = HeadPos(itrial).Y_gait_peaks;
        Timevec = HeadPos(itrial).times;
        % plot gaits overlayed;
        nSteps = length(pks) -2;
        tmpPos = HeadPos(itrial).Y;
        tmpErr = squeeze(HandPos(itrial).dist2Targ);
        
        tmpErr_Ydim = squeeze(HandPos(itrial).Yerror);
        tmpErr_Xdim = squeeze(HandPos(itrial).Xerror);
        
        tmpErr_Zdim = squeeze(HandPos(itrial).Zerror);
        %preAllocate for easy storage
        gaitD=[]; %struct
        %     [gaitHeadY, gaitErr]= deal(zeros(length(trs), resampSize)); % we will normalize the vector lengths.
        [gaitHeadY, gaitErr, gaitErrX, gaitErrY,gaitErrZ]= deal([]); % we will normalize the vector lengths.
        
        for igait=1:length(pks)-2
            
            % now using 2 steps!
            gaitsamps =[trs(igait):trs(igait+2)];
            %% store HEAD data first:
            % head Y data this gait:
            gaitDtmp = tmpPos(gaitsamps);
            gaitD(igait).Head_Yraw = gaitDtmp;
            
            % normalize height between 0 and 1
            gaitDtmp_n = rescale(gaitDtmp);
            gaitD(igait).Head_Ynorm = gaitDtmp_n;
            %also resample along X vector:
            gaitD(igait).Head_Y_resampled = imresize(gaitDtmp_n', [1,200]);
            %also store in matrix for easy handling:
            gaitHeadY(igait,:) = imresize(gaitDtmp_n', [1,200]);
            
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
                    gaitD(igait).Hand_Targ_err_resampled = imresize(errtmp, [1,200]);
                    gaitErr(igait,:) = imresize(errtmp, [1,200]);
                elseif errsource==2 % Xdim error
                    gaitD(igait).Hand_Targ_errXdim = errtmp;
                    %resampled
                    gaitD(igait).Hand_Targ_errXdim_resampled = imresize(errtmp, [1,200]);
                    gaitErrX(igait,:) = imresize(errtmp, [1,200]);
                    
                elseif errsource==3 % Ydim error
                    gaitD(igait).Hand_Targ_errYdim = errtmp;
                    %resampled
                    gaitD(igait).Hand_Targ_errYdim_resampled = imresize(errtmp, [1,200]);
                    gaitErrY(igait,:) = imresize(errtmp, [1,200]);
                elseif errsource==4 %Zdim
                    gaitD(igait).Hand_Targ_errZdim = errtmp;
                    %resampled
                    gaitD(igait).Hand_Targ_errZdim_resampled = imresize(errtmp, [1,200]);
                    gaitErrZ(igait,:) = imresize(errtmp, [1,200]);
                end
                
            end
            
        end % gait in trial.
        TargetError_perTrialpergait_doubleGC(itrial).gaitError = gaitErr;
        TargetError_perTrialpergait_doubleGC(itrial).gaitErrorXdim = gaitErrX;
        TargetError_perTrialpergait_doubleGC(itrial).gaitErrorYdim = gaitErrY;
        TargetError_perTrialpergait_doubleGC(itrial).gaitErrorZdim = gaitErrZ;
         
        TargetError_perTrialpergait_doubleGC(itrial).gaitHeadY= gaitHeadY;
        
        % save this gait info per trial in structure as well.
        HandPos(itrial).DUALgaitData = gaitD;
        
    end %trial
    
    %% for all trials, compute the average error and head pos per time point
    ntrials = size(HeadPos,2);
    % plot average error over gait cycle, first averaging within trials.
    [PFX_err_doubleGC,PFX_errXdim_doubleGC, PFX_errYdim_doubleGC,PFX_errZdim_doubleGC, PFX_headY_doubleGC]= deal(zeros(ntrials,resampSize));
    [PFX_binnedVar_pertrialsteps_doubleGC]= deal(zeros(ntrials,18)); % also plot the binned variance
    PFX_allsteps_binnedErr_doubleGC=[];
    stepCount=1;
    for itrial= nPrac+1:size(TargetError_perTrialpergait_doubleGC,2)
        
        % omit first and last gaitcycle from each trial
        TrialError= TargetError_perTrialpergait_doubleGC(itrial).gaitError([3:(end-2)],:);
        TrialErrorXdim= TargetError_perTrialpergait_doubleGC(itrial).gaitErrorXdim([3:(end-2)],:);
        TrialErrorYdim= TargetError_perTrialpergait_doubleGC(itrial).gaitErrorYdim([3:(end-2)],:);
        TrialErrorZdim= TargetError_perTrialpergait_doubleGC(itrial).gaitErrorZdim([3:(end-2)],:);
        
        TrialY= TargetError_perTrialpergait_doubleGC(itrial).gaitHeadY([3:(end-2)],:);
        
        PFX_err_doubleGC(itrial,:) = mean(TrialError,1);
        
        PFX_errXdim_doubleGC(itrial,:) = mean(TrialErrorXdim,1);
        PFX_errYdim_doubleGC(itrial,:) = mean(TrialErrorYdim,1);
        PFX_errZdim_doubleGC(itrial,:) = mean(TrialErrorZdim,1);
        
        PFX_headY_doubleGC(itrial,:)= mean(TrialY,1);
        
        %may want to instead calculate variance across all steps in exp,
        %without sub averaging.
        
        PFX_allsteps_binnedErr_doubleGC = [PFX_allsteps_binnedErr_doubleGC; TrialError];
        
        
    end % trial
    %%
    %calculate binned variance across entire experiment.
    PFX_allsteps_binnedVar_doubleGC=[];
    for ibin= 1:18
        idx = [1:10] + (ibin-1)*10;
        tmp = PFX_allsteps_binnedErr_doubleGC(:,idx);
        PFX_allsteps_binnedVar_doubleGC(ibin) = mean(var(tmp));
    end

    %%
    disp(['saving targ error per stride cycle gait...' savename])
    
    save(savename, 'HandPos', 'TargetError_perTrialpergait_doubleGC',...
        'PFX_err_doubleGC', 'PFX_headY_doubleGC','PFX_errZdim_doubleGC', 'PFX_allsteps_binnedErr_doubleGC',...
        'PFX_allsteps_binnedVar_doubleGC', '-append');
end % subject

