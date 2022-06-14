function plot_HandTargError_forVSS(dataIN, cfg)
% helper function to plot hand-target error relative to gait %
% j4_plotError_by_gaitcycle.m

GFX_headY = cfg.HeadData;

%4 conditions 1,2,3,4 = 
%1=wlkslow,targslow;
%2=wlkslow,targfast,
%3=wlknorm, targslow
%4=wlknorm, targfast,

usecolsWalk= {[0 0 .5], [0 0 .5], [0 .5 .5], [0 .5 .5]}; %slowslow fast fast

useLeg = {['slow walk, slow target'], ['slow walk, fast target'], ['normal walk, slow target'],['normal walk, fast target']};
figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [.1 .1 .75 .9]);
nsubs = length(cfg.subjIDs);
xticks = [0,25,50,75,100;...
    0,50,100,150,200];

speedCols={[1, 171/255, 64/255], 'b'}; % "normal" yellow, blue

useDV= strcmp(cfg.errortype, 'mean'); % use the identifier belowL
DVidentifier= {'errSTD', 'err'};
useDV=useDV+1; % to index either err or errSTD when called below.

fntsize= 24; 
addshift= 1;
shiftAmounts = [0.23, 0.24]; % per speed (normal, slow)
xamounts = [1.15, 1.5]; % (normal, slow) %approx duration of double gait cycles per speed.
%%
if strcmp(cfg.plotlevel, 'GFX')
    %%
    
       clf;
        
        psubj= ['GFX N=' num2str(nsubs)];
        
        %collect head data to plot:
            gvarsH= {'gc' ,'doubgc'};
            gvarsD= {'' ,'_doubgc'};
            for nGaits_toPlot=2
                
                legp=zeros(1,2); % for legend per trialtypes.
                
                
                usetrials=[4,2]; % just 1 targ speed for now. (normal - fast)
                pspots= {1,[3,5],2,[4,6]};
                pc=1; % subplot counter.    
                for itrialtype=1:2 % each speed/targ combo?
                    
                    plotHead= [];
                    plotData=[];
                    
                    
                    
                    for ippant = 1:nsubs
                        
                        plotHead(ippant,:) = GFX_headY(usetrials(itrialtype), ippant).(gvarsH{nGaits_toPlot});
                        
                        plotData(ippant,:)= dataIN(usetrials(itrialtype),ippant).([DVidentifier{useDV} gvarsD{nGaits_toPlot}]);
                    end
                    ylabels = {'norm Head height',['Proximity to target [cm] ']};
                %%
                
                plotData_both= {plotHead, plotData};
                for iplotdata=1:2 % head and error
                        
                    subplot(3,2,pspots{pc})
                    
                    hold on;
                    
                    % for GFX, show mean and stE.
                    tmpD = plotData_both{iplotdata};
                    
                    tmpD= tmpD.* 100; % conver to cm.
                    meanP = nanmean(tmpD,1);
                    stEP = CousineauSEM(tmpD);
                    
                    
                    if addshift
                        xvec= linspace(0, xamounts(itrialtype), 200);
                        set(gca, 'xtick', [0 .25 .5 .75 1 1.25 1.5], 'xticklabels', ...
                            {num2str(0), num2str(.25), num2str(.5), num2str(.75), num2str(1),...
                            num2str(1.25), num2str(1.5)}, 'fontsize', 18);
                        xlabel(['Time (sec)'], 'fontsize', fntsize);
                        
                        xlim([0 1.5])
                        axis tight
                    else
                        xvec= 1:size(tmpD,2);
                        set(gca, 'xtick', xticks(nGaits_toPlot,:), ...
                        'XTickLabel', {'0' , '25' '50', '75', '100'},...
                        'fontsize', fntsize);
                    xlabel('Time as % of stride-cycle', 'fontsize', fntsize)
                    end
                    
                     if iplotdata==1
                        useColn= 'k';
%                         ylim([0 1]);
                        axis tight
                        
                        ylabel('Head height', 'fontsize', fntsize)
                        
%                         if addshift; xlim([0 1.5]); end
                        set(gca,'xtick', [])
                        xlabel('');
                        
                        %store patch vertices for later:
%                         patchX=[xvec;xvec];
%                         patchY=[zeros(1,200);meanP];
                        patchX=xvec;
                        patchY = meanP;
                    else
                        useColn= speedCols{itrialtype};
                     end
                    
                        
                    sh=shadedErrorBar(xvec, meanP, stEP,...                                            
                   {'color', useColn,...                        
                        'linewidth', 3},1);
                   
                    
                    %add plot handles for legend:
                   if iplotdata==1
                       legp(itrialtype)=  sh.mainLine; 
%                        axis off;
                    set(gca, 'ytick', []);
                    axis tight
%                        legend(sh.mainLine, 'Head height')


%%


                   else
                    ylabel({['Hand distance from target [cm]']}, 'fontsize', fntsize)
                   
                   
                  
                   end
                   
                   
                   
                    
                    if nGaits_toPlot==1
                    title([psubj ], 'interpreter', 'none')
                    end
                    
                    if iplotdata==1 && nGaits_toPlot==1 && itrialtype==4
                        subplot(221); hold on
                        legend(legp, useLeg, 'location','south', 'fontsize', 15, 'autoupdate', 'off');
                    end
                    
                    if iplotdata==2
%                         set(gca, 'ydir', 'reverse');
                    box on;
                    end
                  
                    
                    leg=[];
                    if addshift && iplotdata==2
                        %% replot with new x axis, and reduce alpha of previous plot:
                        cla;
                        xvec= linspace(0, xamounts(itrialtype), 200);
                      
                        newcol= [.8 .8 .8, .8];
                        
                        sh=shadedErrorBar(xvec, meanP, stEP,...                                            
                   {'color',  newcol,...                        
                        'linewidth', 3},1);                    
                    
                        xlim([0 1.5])
                        ylim([10 11.35])
                        leg(1)= sh.mainLine;
                        
%                         set(gca, 'xtick', [0 .25 .5 .75 1 1.25 1.5], 'xticklabels', ...
%                             {num2str(0), num2str(.25), num2str(.5), num2str(.75), num2str(1),...
%                             num2str(1.25), num2str(1.5)}, 'fontsize', 18);
                       
                        set(gca, 'xtick', [0  .5  1  1.5], 'xticklabels', ...
                            {num2str(0),  num2str(.5),  num2str(1),...
                             num2str(1.5)}, 'fontsize', fntsize);
                        
                        xlabel(['Time (sec)'], 'fontsize', fntsize);
                        ylabel({['Hand distance from target [cm]']}, 'fontsize', fntsize)

                        % %%now plot the shifted version
                        shiftInt= dsearchn([xvec]', [0 shiftAmounts(itrialtype)]');
                        shiftD= meanP;
                        shiftD= circshift(shiftD, -shiftInt(2));
                        hold on;
                        shiftE= stEP;
                        shiftE= circshift(shiftE, -shiftInt(2));
                        
                        sh=shadedErrorBar(xvec, shiftD, shiftE,...                                            
                   {'color',  useColn,...                        
                        'linewidth', 3},1);                    
                        leg(2)= sh.mainLine;
                        
%                        leg(2)= plot(xvec, shiftD, 'color', useColn, 'linew', 5 );
                       
%                        
                       legend(leg, {'instantaneous', 'RT shifted'}, 'fontsize', fntsize-2, 'Location', 'SouthWest')
%                          legend(leg, {'instantaneous'}, 'fontsize', 24)
%                         legend(leg, {'RT shifted'}, 'fontsize', 24)
                        axis tight;
%                         xlim([0 1.5])
%                         ylim([10.1 11.2])
                        


                    % add colours to top plot?
                   %return to subplot(
                   subplot(3,2,pspots{pc-1});
                   
                   % create patch elements:
                   
                   Cmap= cbrewer('div', 'RdYlGn', length(xvec));
                   Cmap(Cmap>1)=1;
                   Cmap(Cmap<0)=0;
                   Cmap= flipud(Cmap);
                   colormap(Cmap);
                   
                   %now, we want the colour (index in cmap), to be determined by the range in
                   %mP.
                   minR= min(shiftD);
                   maxR=max(shiftD);
                   dataR= linspace(minR, maxR, length(xvec));
                   %% now for each data point, find the appropriate index in colour space.
                   [a,~]=dsearchn( dataR', shiftD');
                   
%                    Cvertex=1:length(ptchX);
                   %%
                   % 
                   
                   for isamp=1:200
                       plot([xvec(isamp) xvec(isamp) ], [0 patchY(isamp)], 'color', Cmap(a(isamp),:), 'linew',2);
                   end
                   

                    end
                    
                    
                      pc=pc+1;
                    
                    
                end
            end % trialtype
           
%             legend('instantaneous', 'RT shifted');
        end % ngaits
        
        %% print
        cd([cfg.datadir filesep 'Figures' filesep 'Gait_handtargetError'])
        print('-dpng', [psubj ' error by trialtype (' cfg.errortype ') for VSS']);
    
    
    
    
    
    
    
    
end



end %function
%