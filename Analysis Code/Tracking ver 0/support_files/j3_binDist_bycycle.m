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
Fs = 90;
nPractrials= 5;
%%
for ippant = 1:nsubs
    cd([datadir filesep 'ProcessedData'])    %%load data from import job.
    load(pfols(ippant).name);
    savename = pfols(ippant).name;
    disp(['Preparing j3 ' savename]);
    
    %% Gait extraction.
    % Per trial, extract gait samples (trough to trough), normalize along x
    % axis, and store various metrics.
    
    TargetError_perTrialpergait =[];
    
    for itrial=nPractrials+1:size(Head_posmatrix,2)
        
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
        [gaitHeadY, gaitErr, gaitErrX, gaitErrY, gaitErrZ]= deal(zeros(length(pks), 100)); % we will normalize the vector lengths.
        
        for igait=1:length(pks)
            gaitsamps =[trs(igait):trs(igait+1)];
            %% store HEAD data first:
            % head Y data this gait:
            
            gaitD(igait).gaitsamps = gaitsamps;
            
            gaitDtmp = tmpPos(gaitsamps);
            gaitD(igait).Head_Yraw = gaitDtmp;
            
            % normalize height between 0 and 1
            gaitDtmp_n = rescale(gaitDtmp);
            gaitD(igait).Head_Ynorm = gaitDtmp_n;
            %also resample along X vector:
            gaitD(igait).Head_Y_resampled = imresize(gaitDtmp_n', [1,100]);
            %also store in matrix for easy handling:
            gaitHeadY(igait,:) = imresize(gaitDtmp_n', [1,100]);
            
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
            
            %% Store other waveform shape metrics:
            % height:
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
            
        end % gait in trial.
        TargetError_perTrialpergait(itrial).gaitError = gaitErr;
        TargetError_perTrialpergait(itrial).gaitErrorXdim = gaitErrX;
        TargetError_perTrialpergait(itrial).gaitErrorYdim = gaitErrY;
        TargetError_perTrialpergait(itrial).gaitErrorZdim = gaitErrZ;
        
        TargetError_perTrialpergait(itrial).gaitHeadY= gaitHeadY;
        
        % save this gait info per trial in structure as well.
        HandPos(itrial).gaitData = gaitD;
        
    end %trial
    
    %% for all trials, compute the average error and head pos per time point
    ntrials = size(HeadPos,2);
    % plot average error over gait cycle, first averaging within trials.
    [PFX_err,PFX_errXdim, PFX_errYdim, PFX_headY,PFX_headZ]= deal(zeros(ntrials,100));
    
    [PFX_pertrial_binnedVar]= deal(zeros(ntrials,9)); % also plot the binned variance
    
    PFX_allsteps_binnedErr=[];
    
    stepCount=1;
    for itrial= nPractrials+1:size(TargetError_perTrialpergait,2)
        
        % omit first 2 and last 2 gaitcycle from each trial
        TrialError= TargetError_perTrialpergait(itrial).gaitError([3:(end-2)],:);
        TrialErrorXdim= TargetError_perTrialpergait(itrial).gaitErrorXdim([3:(end-2)],:);
        TrialErrorYdim= TargetError_perTrialpergait(itrial).gaitErrorYdim([3:(end-2)],:);
        TrialErrorZdim= TargetError_perTrialpergait(itrial).gaitErrorZdim([3:(end-2)],:);
        
        TrialY= TargetError_perTrialpergait(itrial).gaitHeadY([3:(end-2)],:);
        
        PFX_err(itrial,:) = mean(TrialError,1);
        PFX_errXdim(itrial,:) = mean(TrialErrorXdim,1);
        PFX_errYdim(itrial,:) = mean(TrialErrorYdim,1);
        PFX_errZdim(itrial,:) = mean(TrialErrorZdim,1);
        PFX_headY(itrial,:)= mean(TrialY,1);
        
        PFX_allsteps_binnedErr = [PFX_allsteps_binnedErr; TrialError];
        
        
    end % trial
    
    %calculate binned variance across entire experiment.
    PFX_allsteps_binnedVar=[];
    for ibin= 1:9
        idx = [1:10] + (ibin-1)*10;
        tmp = PFX_allsteps_binnedErr(:,idx);
        PFX_allsteps_binnedVar(ibin) = mean(var(tmp));
    end
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
    save(savename, 'HandPos', 'TargetError_perTrialpergait',...
        'PFX_err', 'PFX_errXdim','PFX_errYdim','PFX_errZdim','PFX_headY', 'PFX_allsteps_binnedErr',...
        'PFX_allsteps_binnedVar', '-append');
end % subject

