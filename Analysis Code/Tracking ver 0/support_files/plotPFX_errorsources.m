% plot PFX error sources

% for each participant, plot the absolute (euclidean) error, as well as the
% error on Y and X dim.

%j4_plotError_by_gaitcycle;

% plot per ppant, plot across ppnts

cd([datadir filesep 'ProcessedData'])

pfols= dir([pwd  filesep '*raw.mat']);
nsubs= length(pfols);


job.plotErrorbyDimension=1; % single and dual gait cycles.

load('GFX_gaitcycle_error');

%%%%%%%%%%%%%%%%%%%%%%
%% print PFX
%%%%%%%%%%%%%%%%%%%%%%
if job.plotErrorbyDimension %% 
    for isub = 1:nsubs
        cd([datadir filesep 'ProcessedData'])
        %% load data from import job.
        load(pfols(isub).name);
        %%
        ntrials = size(HandPos,2);
        
        figure(iGC); clf;
        xlabs = {'gait cycle (%)', 'stride-cycle (%)'};
        xticks=[0,25,50,75,100;...
            0, 50, 100, 150, 200];
        cols = {'r','g', 'b', 'm'}
        nsteps = [size(PFX_allsteps_binnedErr,1), size(PFX_allsteps_binnedErr_doubleGC,1) ];
        for iGC=1:2 % plot both gait cycle analyses (single and dual).
           
            if iGC==1
                headData = PFX_headY;
                errData= zeros(3,size(PFX_err,1), size(PFX_err,2));
                errData(1,:,:) = PFX_err;
                errData(2,:,:)= PFX_errXdim;                
                errData(3,:,:)= PFX_errYdim;
                                
                errData(4,:,:)= PFX_errZdim;
            else
                headData = PFX_headY_doubleGC;                
                errData= zeros(3,size(PFX_err_doubleGC,1), size(PFX_err_doubleGC,2));               
                errData(1,:,:)= PFX_err_doubleGC;
                errData(2,:,:)= PFX_errXdim_doubleGC;                
                errData(3,:,:)= PFX_errYdim_doubleGC;
                errData(4,:,:)= PFX_errZdim_doubleGC;
            end
            
            
            %% plot head pos and mean Error
            errss = {'Euclidean', 'Xdim', 'Ydim', 'Zdim'};
           for ipl=1:4 % each error source:
               errtmp = squeeze(errData(ipl,:,:));
            plotpos= ipl+(iGC-1)*4;
            subplot(2,4,plotpos)            
            yyaxis left; % activate left Y axis for head pos.
            plot(1:size(headData,2), nanmean(headData,1), ['ko']);
            ylabel('norm Head height');
            set(gca,'YColor', 'k')
            xlabel(xlabs{iGC})
            hold on;
            yyaxis right;
            
            %add error:
            mp = squeeze(nanmean(errtmp,1));
            stp = std(errtmp,1)./sqrt(size(errtmp,1));
            shadedErrorBar(1:size(headData,2), mp,stp, ['r'],1);
            ylabel(['Hand-Targ Error [' errss{ipl} '] (m)']);
            set(gca,'YColor', cols{ipl})
            
            set(gca, 'xtick', xticks(iGC,:), 'XTickLabel', {'0' , '25' '50', '75', '100'});
            title(['partcipant ' num2str(isub) ', n(' num2str(nsteps(iGC)) ')'])
           end % errorsource.
            
        end % GC
        set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 .1 .6 .8]);
        
        cd([datadir filesep 'Figures']);
        
      print('-dpng', ['PFX_gaiterror_bysource_' subjID]);
    end %ppant
end
%%
