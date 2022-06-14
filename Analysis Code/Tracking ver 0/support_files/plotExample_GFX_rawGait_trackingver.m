%plotExample_GFX_rawGait_trackingver
% quick plot, mean raw head pos, both experiments.
%% Tracking version.

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

cd([datadir filesep 'ProcessedData']);

allpfols = dir([pwd filesep '*summary_data.mat']);
  figure(1);  set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0.1 0.1 .75 1]);
  
  
  
%4 conditions 1,2,3,4 =
%1=wlkslow,targslow;
%2=wlkslow,targfast,
%3=wlknorm, targslow
%4=wlknorm, targfast,

%% wrangle data across subjs:
[GFX_rawHeadY,GFX_rawHeadY_doubGC]=deal(nan(length(allpfols),4,1000));
for ippant = 1:length(allpfols)
    load(allpfols(ippant).name, 'PFX_headYraw_doubGC', 'HeadPos', 'gaitTypes_doubGC')
    trialTime = HeadPos(10).times;
    
    PFX_headYraw_doubGC(PFX_headYraw_doubGC==0)=nan;% sanity check:
    
    % save per speed: !
    for itrialtype=1:4       
       % doubGC onl (VSS sprint)
       usetrials = find( gaitTypes_doubGC == itrialtype);
       limitY = PFX_headYraw_doubGC(usetrials,:);       
       GFX_rawHeadY_doubGC(ippant,itrialtype,1:size(limitY,2)) = nanmean(limitY,1);
    end
    disp([ 'finished concatenating raw gaits for ppant ' num2str(ippant)]);
end
%% 
figure(1);clf; 
usecols= {'b', 'b', [1, 171/255, 64/255],[1, 171/255, 64/255]}; % "normal" yellow
lg=[];
useData  ={GFX_rawHeadY, GFX_rawHeadY_doubGC};
for iGait=2%1:2
    figure(1);
    if iGait==1
    subplot(2,2,1);
    else
        subplot(2,2,2);
    end
for itrialtype=[1,3]
    figure(1); hold on;
%     subplot(2,2,itrialtype);
   pData=squeeze(useData{iGait}(:,itrialtype,1:length(trialTime)));
   mP = squeeze(mean(pData,1));
   stE= CousineauSEM(pData);
%    sh=shadedErrorBar(trialTime, mP, stE, {'color',usecols{itrialtype}}, 1);
%  sh.mainLine.LineWidth = 3;
%    lg(itrialtype) = sh.mainLine;
lg(itrialtype)= plot(trialTime , mP,    'color',usecols{itrialtype}, 'linew', 3);

   axis tight
xlim([0 1.5])   
ylim([1.5 1.55])
   set(gca,'fontsize', 20);
%    hold on
%    figure(2); subplot(2,2,itrialtype);
%    plot(trialTime, pData')
%    ylim([1 2])
%    set(gca,'fontsize', 20);
end
%%
xlabel(['Time (sec)']);
ylabel('Head Height (m)');
legend([lg(1) lg(3)], {'slow walking speed', 'normal walking speed'});
% ylim([1.54 1.59]);
shg
set(gca,'fontsize', 20);
set(gcf,'color', 'w')
end
shg
%%
legend([lg], {'slow walk', 'normal walk'})
ylabel('Head Height [m]');
xlabel('Time (sec)');
set(gca,'fontsize', 20);
% % 
% % plot(trialTime, squeeze(mean(GFX_rawHeadY(:,1,1:length(trialTime)),1)), 'b', 'linew', 4); hold on
% % plot(trialTime, squeeze(mean(GFX_rawHeadY(:,2,1:length(trialTime)),1)), 'r', 'linew', 4);
%  %% this function moved to a separate job list:
%     %remove zeros from raw data for plotting
%     PFX_headYraw(PFX_headYraw==0)=nan;% sanity check:
%     clf;
%     usexvec=trialTime(1:size(PFX_headYraw,2));
%    %plot both overlayed, then separately:
%    spdsare={'Slow-pace', 'Normal-pace'};
% pkcols= {'r', 'm'};   
% trcols= {'b', 'k'};
%    
%    % first plot all head Y traces:
%    subplot(131);
%    plot(usexvec,PFX_headYraw', 'color', [.8 .8 .8]);
%    [pkleg,trleg]=deal([]);
%    %next: add the colours/markers to identify pks and troughs.
%    for ispeed=1:2
%        
%        usetrials = find( gaitspeeds == ispeed);
%        limitY = PFX_headYraw(usetrials,:);
%        
%        % now separate plots:
%        iploc = [1, ispeed+1];
%        for isub= 1:length(iploc)
%            subplot(1,3,iploc(isub));           
%            
%            if isub~=1 % on first subplot, skip this andjust add the markers:
%            plot(usexvec, limitY','color', [.8 .8 .8])
%            end
%            
%            hold on;           
%            % add  points for peaks:
%            allX = allpks_point(usetrials);
%            % use linear indexing to extract the correct points, per trial
%            trialindx= 1:size(limitY);           
%            idx = sub2ind(size(limitY), [trialindx], [allX]);
%            allY = limitY(idx);
%            hold on;
%            pk=plot(usexvec(allX), allY, 'ro');
%            pk.Color = pkcols{ispeed};
%            pkleg(ispeed)= pk;
%            %% and troughs
%            allX= allEndtrs_point(usetrials);
%            idx = sub2ind(size(limitY), [trialindx], [allX]);
%            allY = limitY(idx);
%            tr=plot(usexvec(allX), allY, 'ro');
%            tr.Color= trcols{ispeed};
%            trleg(ispeed)= tr;
%            if isub==1
%             title(['All single gaits (raw)']);
%             useyl=get(gca, 'ylim');
%            else
%                title([spdsare{ispeed} ' single gaits (raw)']);
%            end
%            set(gca, 'fontsize', 15); shg
%            
%            xlim([0 1]);
%            ylim(useyl)
%            xlabel('Time (sec)');
%            ylabel('Head Height (m)')
%        end
%    end