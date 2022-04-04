function plot_GrandMeanError(dataIN, cfg)
% helper function to plot hand-target error per condition (using rainclouds) %
%

%4 conditions 1,2,3,4 =
%1=wlkslow,targslow;
%2=wlkslow,targfast,
%3=wlknorm, targslow
%4=wlknorm, targfast,

% usecolsWalk= {[0 0 .5], [0 0 .5], [0 .5 .5], [0 .5 .5]}; %slowslow fast fast

usecolsWalk= [0 0 .5; 0 .5 .5]; %slow fast 

uselinesTarget= {'-', ':', '-', ':'}; %slow fast slow fast
useLeg = {['slow walk, slow target'], ['slow walk, fast target'], ['normal walk, slow target'],['normal walk, fast target']};
figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .6 .6]);
nsubs = length(cfg.subjIDs);
xticks = [0,25,50,75,100;...
    0,50,100,150,200];

if strcmp(cfg.plotlevel, 'PFX')
    %%
elseif strcmp(cfg.plotlevel, 'GFX')
    %%
    
    clf;
    
    psubj= ['GFX N=' num2str(nsubs)];
    
    
    for nGaits_toPlot=1%:2
        
        ppantData=[];
        legp=zeros(1,4); % for legend per trialtypes.
        %collect data:
        for itrialtype=1:4
            
            for ippant = 1:nsubs
                usedata=[];
                if nGaits_toPlot==1
                    
                    if strcmp(cfg.errortype, 'mean')
                        usedata= dataIN(itrialtype,ippant).err;
                    elseif strcmp(cfg.errortype, 'std')
                        usedata= dataIN(itrialtype,ippant).errSTD;
                    end
                    
                else
                    
                    if strcmp(cfg.errortype, 'mean')
                        usedata= dataIN(itrialtype,ippant).err_doubgc;
                    elseif strcmp(cfg.errortype, 'std')
                        usedata= dataIN(itrialtype,ippant).errSTD_doubgc;
                    end
                    
                    
                end
                %store:
                
                ppantData(ippant,itrialtype)= mean(usedata);
                
            end % for all ppants
        end
        %% correct for within subj, comparisons.
        [~, newd] = CousineauSEM(ppantData);
        
        % convert to struct for raincloud plots:
        plotData=[];
        plotData{1} = newd(:,1); % slow walk, slow targ
        plotData{2} = newd(:,2); % slow walk, fast targ
        plotData{3} = newd(:,3); % norm walk, slow targ
        plotData{4} = newd(:,4); %norm walk, fast targ 
        %
        %                 ppantData};
%         figure(1);clf
%         hl=rm_raincloud(plotData', usecolsWalk(1:2,:));
%         % add details.
%         set(gca, 'yticklabels', {'fast', 'slow'})
%         
%         shg;
        
   
       %% hack a raincloud plot that best shows the data.
       % compare targets within walk speeds (slow walk one plot, normal
       % walk the next).
       subplot(121)      
       %slow walk slow target
    h= raincloud_plot(plotData{1}, 'color', usecolsWalk(1,:),...
        'box_on', 1,'box_dodge', 1, 'box_dodge_amount', .15,...
        'dot_dodge_amount', .15, 'alpha', .5);
      %adjust raindrops
      h{2}.SizeData= 100;
        h{2}.LineWidth= 1;    
      hold on;
       legp(1) = h{1}; % patch
      %slow walk, fast target, for comparison.
   h=  raincloud_plot(plotData{2}, 'color', usecolsWalk(1,:),...
        'box_on', 1,'box_dodge', 1, 'box_dodge_amount', .35,...
        'dot_dodge_amount', .35, 'alpha', .3);
    %tidy scatters:
    h{2}.SizeData= 100;
    h{2}.LineWidth= 1;
    h{2}.MarkerFaceAlpha=.3;
    %change patch outline:
     h{1}.LineStyle=':';
     
     legp(2) = h{1}; % patch
    axis tight
        view([90 -90]); axis ij;
        box off;
        xlim([.08 .12])
        ylimsR = get(gca, 'xlim');
        
    set(gca,'ytick', 0) % remove extra bits, label.
        set(gca,'yticklabel', 'Slow Walk', 'fontsize', 30);
        xlabel('mean Hand-Target error [m]')
        %% normal walk, slow target
        subplot(122);
         h= raincloud_plot(plotData{3}, 'color', usecolsWalk(2,:),...
        'box_on', 1,'box_dodge', 1, 'box_dodge_amount', .35,...
        'dot_dodge_amount', .35, 'alpha', .5);%, 'box_on', 1, 'color', [0.5 0.5 0.5])
      %adjust size of data points:
      h{2}.SizeData= 100;
    h{2}.LineWidth= 1;
      legp(3) = h{1}; % patch
    
    % normal walk , fast target
      hold on;
   h=  raincloud_plot(plotData{4}, 'color', usecolsWalk(2,:),...
        'box_on', 1,'box_dodge', 1, 'box_dodge_amount', .15,...
        'dot_dodge_amount', .15, 'alpha', .3);%, 'box_on', 1, 'color', [0.5 0.5 0.5])
     h{2}.SizeData= 100;
    h{2}.LineWidth= 1;
    h{1}.LineStyle=':';    
    h{2}.MarkerFaceAlpha=.3;
    axis tight
        view([90 -90]); 
        box off;
        xlim(ylimsR)
         legp(4) = h{1}; % patch
        set(gca,'ytick', 0) % remove extra bits, label.
        set(gca,'yticklabel', 'Normal Walk', 'fontsize', 30)
        
        %remove y axis, to look like one plot
       set(gca,'xtick', [], 'XColor', 'none');
%        axis off
        shg
        legend(legp, {'slow walk, slow target','slow walk, fast target','norm walk, slow target','norm walk, fast target'}, 'Location', 'NorthWest', 'fontsize',15)
        %%
        
    end % ngaits
    
    %% print
    cd([cfg.datadir filesep 'Figures' filesep 'Gait_handtargetError'])
    print('-dpng', [psubj ' grand error by trialtype (' cfg.errortype ')']);
    
    
    
    
    
    
    
    
end



end %function
%