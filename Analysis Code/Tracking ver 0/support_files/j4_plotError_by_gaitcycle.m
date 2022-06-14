%j4_plotError_by_gaitcycle;

% plot per ppant, plot across ppnts
%%%%%% TRACKING TASK version %%%%%%
%frame by frame first:
%Mac:
 datadir='/Users/matthewdavidson/Documents/GitHub/active-perception-tracking_ver0/Analysis Code/Tracking ver 0/Raw_data';
%mac-HD
% datadir = '/Volumes/WHITEHD_TB/Tracking ver 0/Raw_data';
 %PC:
% datadir='C:\Users\User\Documents\matt\GitHub\active-perception-tracking_ver0\Analysis Code\Tracking ver 0\Raw_data';
%PC-HD
% datadir = 'E:\Tracking ver 0\Raw_data';%%

cd([datadir filesep 'ProcessedData'])

pfols= dir([pwd  filesep '*PFX_data.mat']);
nsubs= length(pfols);

job.concatGFX=1;
%PFX:
job.plotPFX_gcycles=0; % single and dual gait cycles.
%GFX:
job.plotGFX_granderror = 0; %raincloud plots, grand mean per condition.
job.plotGFX_gcycles=0; % gaitcycles
job.plotGFX_gcycles_sepdimensions= 0; % splits error by source (X, Y, or Z dimension).

job.plotGFX_gcycles_forVSS=1; % diff colours, averaging targ conds.
%job.plotmeanerrror + stderror (collapsed across gaitcycle points). show
%condition differences. (n=20).

%%%%%%%%%%%%%%%%%%%%%%
%% concat across subjs
%%%%%%%%%%%%%%%%%%%%%%
if job.concatGFX
    %%
    %Structures for data:
    [GFX_error,GFX_headY] = deal([]); % we've resampled to 100 points.
    
    subjIDs={};
    for isub = 1:nsubs
        cd([datadir filesep 'ProcessedData'])
        %%load data from import job.
        load(pfols(isub).name);
        disp(['concat for ' subjID])
        %%
        for itrialtype = 1:4 %% save each condition separately.
        
            % per trial type, only store the relevant trials.
            usetrials= find(PFX_trialinfo.trialType == itrialtype);
            
            % take absolute, since we are interested in dist from target.
            %single gait cycle first            
        GFX_error(itrialtype,isub).err = nanmean(PFX_err(usetrials,:),1);
         GFX_error(itrialtype,isub).errSTD = nanmean(PFX_errSTD(usetrials,:),1);
        GFX_error(itrialtype,isub).errXdim = nanmean(PFX_errXdim(usetrials,:),1);           
        GFX_error(itrialtype,isub).errYdim = nanmean(PFX_errYdim(usetrials,:),1);            
        GFX_error(itrialtype,isub).errZdim = nanmean(PFX_errZdim(usetrials,:),1);    
        GFX_headY(itrialtype,isub).gc = nanmean(PFX_headY(usetrials,:),1);
        
        
        %double gait cycle:
        GFX_error(itrialtype,isub).err_doubgc= nanmean(PFX_err_doubleGC(usetrials,:),1); % mean distance over gaits
         GFX_error(itrialtype,isub).errSTD_doubgc = nanmean(PFX_errSTD_doubleGC(usetrials,:),1); % variance in distance over gaits (calc. within trial)
        GFX_error(itrialtype,isub).errXdim_doubgc= nanmean(PFX_errXdim_doubleGC(usetrials,:),1);
        GFX_error(itrialtype,isub).errYdim_doubgc= nanmean(PFX_errYdim_doubleGC(usetrials,:),1);
        GFX_error(itrialtype,isub).errZdim_doubgc= nanmean(PFX_errZdim_doubleGC(usetrials,:),1);
        
        GFX_headY(itrialtype,isub).doubgc = nanmean(PFX_headY_doubleGC(usetrials,:),1);
        
        %store trial description also:
        GFX_error(itrialtype,isub).trialType = itrialtype;
        GFX_error(itrialtype,isub).walkSpeed = PFX_trialinfo.walkSpeed(usetrials(1));
        GFX_error(itrialtype,isub).targetSpeed = PFX_trialinfo.targetSpeed(usetrials(1));
        
        
        
        %% also calculate binned versions (for variance data?).
        
        
        
       
        end
         subjIDs{isub} = subjID(1:4);
        
        
    end %ppant
    %%
    save('GFX_gaitcycle_error', 'GFX_error', 'GFX_headY', 'subjIDs');
    
else
    %%
    load('GFX_gaitcycle_error');
end % job concat

%%%%%%%%%%%%%%%%%%%%%%
%% print PFX
%%%%%%%%%%%%%%%%%%%%%%
%%
if job.plotPFX_gcycles
    %%
 %for each ppant, plot the distribution of targ onset positions:
 % pass in some details needed for accurate plots:
 cfg=[];
 cfg.subjIDs = subjIDs;
 cfg.errortype = 'std'; % 'mean' or 'STD'
 cfg.datadir= datadir; % for orienting to figures folder
 cfg.HeadData= GFX_headY; 
 cfg.plotlevel = 'PFX'; 
 % cycles through ppants, plots with correct labels.
 plot_HandTargError(GFX_error, cfg);

end
%%    
    

%%%%%%%%%%%%%%%%%%%%%%
%% print GroupFX
%%%%%%%%%%%%%%%%%%%%%%

if job.plotGFX_granderror
    %% raincloud plots, grand mean per condition.
    cfg=[];
     cfg.subjIDs = subjIDs;
    cfg.errortype = 'mean'; % std
    cfg.datadir= datadir; % for orienting to figures folder
%     cfg.HeadData= GFX_headY;
    cfg.plotlevel = 'GFX';
    
    plot_GrandMeanError(GFX_error, cfg);
end

if job.plotGFX_gcycles
    %%
    %for each ppant, plot the distribution of targ onset positions:
    % pass in some details needed for accurate plots:
    cfg=[];
    cfg.subjIDs = subjIDs;
    cfg.errortype = 'mean'; % 'mean' or 'std'
    cfg.datadir= datadir; % for orienting to figures folder
    cfg.HeadData= GFX_headY;
    cfg.plotlevel = 'GFX';
    % cycles through ppants, plots with correct labels.
    plot_HandTargError(GFX_error, cfg);
    
end

if job.plotGFX_gcycles_sepdimensions
    %%
    %for each ppant, plot the distribution of targ onset positions:
 % pass in some details needed for accurate plots:
 cfg=[];
 cfg.subjIDs = subjIDs;
 cfg.errortype = 'Separate'; % 'overlayed'
 cfg.datadir= datadir; % for orienting to figures folder
 cfg.HeadData= GFX_headY; 
 cfg.plotlevel = 'GFX'; 
 % cycles through ppants, plots with correct labels.
 plot_HandTargError_sepdimensions(GFX_error, cfg);

end

if job.plotGFX_gcycles_forVSS % diff colours, averaging targ conds.
%%
     %for each ppant, plot the distribution of targ onset positions:
    % pass in some details needeaid for accurate plots:
    cfg=[];
    cfg.subjIDs = subjIDs;
    cfg.errortype = 'mean'; % std
    cfg.datadir= datadir; % for orienting to figures folder
    cfg.HeadData= GFX_headY;
    cfg.plotlevel = 'GFX';
    % cycles through ppants, plots with correct labels.
    plot_HandTargError_forVSS(GFX_error, cfg);
end