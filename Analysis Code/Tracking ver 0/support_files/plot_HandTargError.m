function plot_HandTargError(dataIN, cfg)
% helper function to plot hand-target error relative to gait %
% j4_plotError_by_gaitcycle.m

GFX_headY = cfg.HeadData;

%4 conditions 1,2,3,4 = 
%1=wlkslow,targslow;
%2=wlkslow,targfast,
%3=wlknorm, targslow
%4=wlknorm, targfast,

usecolsWalk= {[0 0 .5], [0 0 .5], [0 .5 .5], [0 .5 .5]}; %slowslow fast fast
uselinesTarget= {'-', ':', '-', ':'}; %slow fast slow fast
useLeg = {['slow walk, slow target'], ['slow walk, fast target'], ['normal walk, slow target'],['normal walk, fast target']};
figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9 .9]);
nsubs = length(cfg.subjIDs);
xticks = [0,25,50,75,100;...
    0,50,100,150,200];
if strcmp(cfg.plotlevel, 'PFX')
    for ippant = 1:nsubs
        clf;
        
        psubj= cfg.subjIDs{ippant}(1:4); % print ppid.
        
        
        for nGaits_toPlot=1:2
            
            legp=[]; % for legend
            
            for itrialtype=1:4
                ppantData=[];
                if nGaits_toPlot==1
                    
                    ppantData(1,:)= GFX_headY(itrialtype, ippant).gc; 
                    
                    if strcmp(cfg.errortype, 'mean')
                    ppantData(2,:)= dataIN(itrialtype,ippant).err;
                    elseif strcmp(cfg.errortype, 'std')
                    ppantData(2,:)= dataIN(itrialtype,ippant).errSTD;
                    end
                                        
                else
                    ppantData(1,:)= GFX_headY(itrialtype,ippant).doubgc;
                    
                    if strcmp(cfg.errortype, 'mean')
                        ppantData(2,:)= dataIN(itrialtype,ippant).err_doubgc;
                    elseif strcmp(cfg.errortype, 'std')
                        ppantData(2,:)= dataIN(itrialtype,ippant).errSTD_doubgc;
                    end
                    
                                        
                end

                ylabels = {'norm Head height',[cfg.errortype  ' Hand-Targ error [m] ']};
                %%
                for iplotdata=1:2
                    subplot(2,2,iplotdata + 2*(nGaits_toPlot-1))
                    hold on;
%                     % if comparing variance, fast and slow targs need to be
%                     % on different axes:
%                     if iplotdata==2 && strcmp(cfg.errortype, 'std') && mod(itrialtype,2)==0
%                         yyaxis left
%                   
%                     elseif iplotdata==2 && strcmp(cfg.errortype, 'std') && mod(itrialtype,2)~=0
%                         yyaxis right
%                     end
                    
                      plot(1:size(ppantData,2), ppantData(iplotdata,:),'color', usecolsWalk{itrialtype},...
                        'linestyle', uselinesTarget{itrialtype},...
                        'linewidth', 3);
                    ylabel(ylabels{iplotdata});
                    
                    set(gca, 'xtick', xticks(nGaits_toPlot,:), ...
                        'XTickLabel', {'0' , '25' '50', '75', '100'},...
                        'fontsize', 25);
                    xlabel(' % gait cycle')
                    
                    title([psubj ], 'interpreter', 'none')
                    
                    
                    if iplotdata==1 && nGaits_toPlot==1 && itrialtype==4
                        
                        legend(legp, useLeg, 'location','south', 'fontsize', 15);
                    end
                end
            end % trialtype
           
        end % ngaits
        
        %% print
        cd([cfg.datadir filesep 'Figures' filesep 'Gait_handtargetError'])
        print('-dpng', [psubj ' error by trialtype']);
        %%
    end % ippant
    %%
elseif strcmp(cfg.plotlevel, 'GFX')
    %%
    
       clf;
        
        psubj= ['GFX N=' num2str(nsubs)];
        
        
        for nGaits_toPlot=1:2
            
            legp=zeros(1,4); % for legend per trialtypes.
            
            for itrialtype=1:4
                ppantData=[];
                for ippant = 1:nsubs
                    if nGaits_toPlot==1
                        
                        ppantData(ippant,1,:)= GFX_headY(itrialtype, ippant).gc;
                        
                        if strcmp(cfg.errortype, 'mean')
                            ppantData(ippant,2,:)= dataIN(itrialtype,ippant).err;
                        elseif strcmp(cfg.errortype, 'std')
                            ppantData(ippant,2,:)= dataIN(itrialtype,ippant).errSTD;
                        end
                               
                    else
                        ppantData(ippant,1,:)= GFX_headY(itrialtype,ippant).doubgc;
                       if strcmp(cfg.errortype, 'mean')
                            ppantData(ippant,2,:)= dataIN(itrialtype,ippant).err_doubgc;
                        elseif strcmp(cfg.errortype, 'std')
                            ppantData(ippant,2,:)= dataIN(itrialtype,ippant).errSTD_doubgc;
                        end
                               
                        
                    end
                end
                ylabels = {'norm Head height',[cfg.errortype  ' Hand-Targ error [m] ']};
                %%
                for iplotdata=1:2
                    subplot(2,2,iplotdata + 2*(nGaits_toPlot-1))
                    hold on;
                    
                    % for GFX, show mean and stE.
                    tmpD = squeeze(ppantData(:,iplotdata,:));
                    
                    meanP = nanmean(tmpD,1);
                    stEP = CousineauSEM(tmpD);
                    
                    %if comparing variance, fast and slow targs need to be
                    %on different axes:
                    if iplotdata==2 && strcmp(cfg.errortype, 'std') && mod(itrialtype,2)==0
                        yyaxis left
                  
                    elseif iplotdata==2 && strcmp(cfg.errortype, 'std') && mod(itrialtype,2)~=0
                        yyaxis right
                    end
                    
                    sh=shadedErrorBar(1:size(ppantData,3), meanP, stEP,...                                            
                   {'color', usecolsWalk{itrialtype},...
                        'linestyle', uselinesTarget{itrialtype},...
                        'linewidth', 3},1);
                    %add plot handles for legend:
                   if iplotdata==1
                       legp(itrialtype)=  sh.mainLine;
                   end
                    ylabel(ylabels{iplotdata});
                    
                    set(gca, 'xtick', xticks(nGaits_toPlot,:), ...
                        'XTickLabel', {'0' , '25' '50', '75', '100'},...
                        'fontsize', 15);
                    xlabel(' % gait cycle')
                    if nGaits_toPlot==1
                    title([psubj ], 'interpreter', 'none')
                    end
                    
                    if iplotdata==1 && nGaits_toPlot==1 && itrialtype==4
                        subplot(221); hold on
                        legend(legp, useLeg, 'location','south', 'fontsize', 15, 'autoupdate', 'off');
                    end
                end
            end % trialtype
           
        end % ngaits
        
        %% print
        cd([cfg.datadir filesep 'Figures' filesep 'Gait_handtargetError'])
        print('-dpng', [psubj ' error by trialtype (' cfg.errortype ')']);
    
    
    
    
    
    
    
    
end



end %function
%