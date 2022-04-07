function plot_HandTargError_sepdimensions(dataIN, cfg)
% helper function to plot hand-target error relative to gait %
% multiple subplots, to show the effect within specific dimension (XYZ)
%called from j4_plotError_by_gaitcycle.m

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
                    ppantData(2,:)= dataIN(itrialtype,ippant).err;
                                        
                else
                    ppantData(1,:)= GFX_headY(itrialtype,ippant).doubgc;
                    ppantData(2,:)= dataIN(itrialtype, ippant).err_doubgc;
                                        
                end
                ylabels = {'norm Head height', 'Hand-Targ error (m)'};
                %%
                for iplotdata=1:2
                    subplot(2,2,iplotdata + 2*(nGaits_toPlot-1))
                    hold on;
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
        

        
        for itrialtype=1:4
        pcounter=1; % reset to overlay.
            for nGaits_toPlot=1:2
                
            legp=[]; % for legend
                headData=[];
                plotData=[];
                
                for ippant = 1:nsubs
                    if nGaits_toPlot==1
                        
                        headData(ippant,:)= GFX_headY(itrialtype, ippant).gc;
                        
                        plotData(ippant,1,:)= dataIN(itrialtype,ippant).errXdim;
                          plotData(ippant,2,:)= dataIN(itrialtype,ippant).errYdim;
                            plotData(ippant,3,:)= dataIN(itrialtype,ippant).errZdim;
                        
                    else
                        headData(ippant,:)= GFX_headY(itrialtype,ippant).doubgc;
                        plotData(ippant,1,:)= dataIN(itrialtype, ippant).errXdim_doubgc;
                        plotData(ippant,2,:)= dataIN(itrialtype, ippant).errYdim_doubgc;
                        plotData(ippant,3,:)= dataIN(itrialtype, ippant).errZdim_doubgc;
                        
                        
                    end
                end
                
                ylabels = {'norm Head height', 'Hand-Targ error (m)'};
                %%
               % plot head, overlay XYZ daat
                    subplot(2,4,pcounter)
                    hold on;
                    %plot Head data.                  
                    meanP = nanmean(headData,1);
                    stEP = CousineauSEM(headData);
%                     yyaxis left
                    sh=shadedErrorBar(1:size(headData,2), meanP, stEP,...                                            
                   {'color',usecolsWalk{itrialtype},...
                        'linestyle', uselinesTarget{itrialtype},...
                        'linewidth', 1});
                   ylabel('Head position');
                   
                    title([psubj ], 'interpreter', 'none')
                    set(gca,'fontsize', 15)
                    pcounter=pcounter+1;
                    %% now overlay error (xyz)
                    titler={'anterior-posterior (x)', 'vertical (y)', 'medio-lateral (z)'};
                    for idim= 1:3
                        tmp = squeeze(plotData(:,idim,:));
                        meanP = nanmean(tmp,1);
                        stEP = CousineauSEM(tmp);
                        subplot(2,4,pcounter)
                         hold on;
                        sh=shadedErrorBar(1:size(headData,2), meanP, stEP,...
                            {'color',usecolsWalk{itrialtype},...
                            'linestyle', uselinesTarget{itrialtype},...
                            'linewidth', 1});
                        
                        title(titler{idim});
                        set(gca, 'xtick', xticks(nGaits_toPlot,:), ...
                        'XTickLabel', {'0' , '25' '50', '75', '100'},...
                        'fontsize', 15);
                    xlabel(' % gait cycle')
                    
                    ylabel('Error [m]')
                        pcounter= pcounter+1;
                    end
                    %add plot handles for legend:
%                     legp= [legp, sh.mainLine];
                    
                    %%
                    
                    
                    
%                     if iplotdata==1 && nGaits_toPlot==1 && itrialtype==4
%                         
%                         legend(legp, useLeg, 'location','south', 'fontsize', 15);
%                     end
%             
%         pcounter=pcounter+1;
            end %nGaits
           
        end % trialtypes
        
        %% print
        cd([cfg.datadir filesep 'Figures' filesep 'Gait_handtargetError'])
        print('-dpng', [psubj ' error by trialtype']);
    
    
    
    
    
    
    
    
end



end %function
%