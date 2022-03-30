%j4_plotError_by_gaitcycle;

% plot per ppant, plot across ppnts

cd([datadir filesep 'ProcessedData'])

pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);

job.concatGFX=1;
job.plotPFX=1; % single and dual gait cycles.
job.plotGFX=0; %

%%%%%%%%%%%%%%%%%%%%%%
%% concat across subjs
%%%%%%%%%%%%%%%%%%%%%%
if job.concatGFX
    
    %Structures for data:
    [GFX_error,GFX_headY] = deal([]); % we've resampled to 100 points.
    
    subjIDs={};
    for isub = 1:nsubs
        cd([datadir filesep 'ProcessedData'])
        %%load data from import job.
        load(pfols(isub).name);
        for itrialtype = 1:4 %% save each condition separately.
        
            % per trial type, only store the relevant trials.
            usetrials= find(PFX_trialinfo.trialType == itrialtype);
            
            
            %single gait cycle first
        GFX_error(itrialtype,isub).err = nanmean(PFX_err(usetrials,:),1);        
        GFX_headY(itrialtype,isub).gc = nanmean(PFX_headY(usetrials,:),1);
        
        
        %double gait cycle:
        GFX_error(itrialtype,isub).err_doubgc= nanmean(PFX_err_doubleGC(usetrials,:),1);
        GFX_headY(itrialtype,isub).doubgc = nanmean(PFX_headY_doubleGC(usetrials,:),1);
        
        %store trial description also:
        GFX_error(itrialtype,isub).trialType = itrialtype;
        GFX_error(itrialtype,isub).walkSpeed = PFX_trialinfo.walkSpeed(usetrials(1));
        GFX_error(itrialtype,isub).targetSpeed = PFX_trialinfo.targetSpeed(usetrials(1));
        
        
        subjIDs{isub} = ppant;
        end
        
        
        
    end %ppant
    save('GFX_gaitcycle_error', 'GFX_error', 'GFX_headY', 'subjIDs');
    
else
    load('GFX_gaitcycle_error');
end % job concat

%%%%%%%%%%%%%%%%%%%%%%
%% print PFX
%%%%%%%%%%%%%%%%%%%%%%
%%
if job.plotPFX
    
 %for each ppant, plot the distribution of targ onset positions:
 % pass in some details needed for accurate plots:
 cfg=[];
 cfg.subjIDs = subjIDs;
 cfg.errortype = 'All';
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
if job.plotGFX
    
    figure(1); clf;
    
    for iGC=1:2 % plot both gait cycle analyses (single and dual).
        if iGC==1
            headData = GFX_headY;
            errData = GFX_err;
            %
            varData = GFX_errVar;
        else
            headData = GFX_headY_dbGC;%
            errData= GFX_err_dbGC;
            varData = GFX_errVar_dbGC;
        end
        nsubs = size(headData,1);
        %% head pos and error
        plotpos= 1+(iGC-1)*2;
        subplot(2,2,plotpos)
        yyaxis left; % activate left Y axis for head pos.
        plot(1:size(headData,2), mean(headData,1), ['ko']);
        ylabel('norm Head height');
        hold on;
        yyaxis right;
        mP = squeeze(mean(errData,1));
        stE= CousineauSEM(errData);
        sh= shadedErrorBar(1:length(headData), mP, stE, 'r');
        %     plot(1:100, mean(GFX_err,1), 'linew', 2);
        ylabel('Hand-Targ Error (mm)');
        set(gca, 'xtick',[]);
        title(['GFX  nsubs = ' num2str(nsubs)])
        %% head pos and variance
        plotpos= 2+(iGC-1)*2;
        subplot(2,2,plotpos)
        yyaxis left;
        plot(1:size(headData,2), mean(headData,1), ['ko']);
        ylabel('norm Head height');
        hold on;
        
        yyaxis right;
        
        xvec = linspace(1,length(headData),9*iGC);
        bh=bar(xvec, mean(varData,1));
        stE = CousineauSEM(varData);
        hold on;
        errorbar(xvec, mean(varData,1), stE);
        bh.FaceAlpha= .2;
        ylabel('Hand-Targ Error Var (mm)');
        set(gca, 'xtick',[]);
        title(['GFX  nsubs = ' num2str(nsubs)])
        %%
        %print
        cd([datadir filesep 'Figures']);
        set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 .1 .6 .8]);
    end % both Gait cycles
    print('-dpng', ['GFX_gaiterror']);
end