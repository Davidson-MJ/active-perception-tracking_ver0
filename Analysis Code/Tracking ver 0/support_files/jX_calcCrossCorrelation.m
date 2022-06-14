% jX_calcCrossCorrelation%


% compute the cross-correlation (lag) between hand and target. 
% per participant, per condition.

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
pfols = dir([pwd filesep '*_summary_data.mat']);
nsubs= length(pfols);
%% show ppant numbers:
tr= table([1:length(pfols)]',{pfols(:).name}' );
disp(tr)
GFX_autocorrelation=[];
%%
for isub = 1:nsubs
    cd([datadir filesep 'ProcessedData'])
    %%load data from import job.
    load(pfols(isub).name, 'HeadPos', 'HandPos_L', 'HandPos_R', 'TargPos','subjID');
    savename = pfols(isub).name;
    disp(['Preparing j2 ' savename]);
    % Make sure to use the correct (dominant) hand for calculating error.
    % note that for some subjects, due to controller malfunction, the
    % labels had to be swapped (empty battery half way through).
        HandPos = HandPos_R;
    if strcmp(subjID(4), 'R')
        disp(['Using Right hand for ' subjID]);
    else
%         HandPos = HandPos_R;
        disp(['Using Right hand for ' subjID '-Lhanded']);

    end
    %%
    Hand_Targ_crosscorr = [];
    trialTypes=[]; % keep track of which trialtypes per gait stored.
    keept=1;
    for  itrial=1:size(HeadPos,2)
        
        %% skip bad trials:
        if HeadPos(itrial).isPrac || HeadPos(itrial).isStationary
            continue
        end
         % subj specific trial rejection
        skip=0;
        rejTrials_trackingv1; %toggles 'skip' based on bad trial ID               
        if skip==1
            continue
        end
        
        % continue: ->
        
        
        
        %compute the cross correlation between our 2 dims of interest (Y
        %% and 'X');
        maxLength = 135; % +- approx 1 second
        %normalize both, to see if it improves crosscorr.
        A = TargPos(itrial).Y;
        B= HandPos(itrial).Y;
        C = TargPos(itrial).Z;
        D= HandPos(itrial).Z;
        nrmA= A- mean(A); % remove DC offset.
        nrmB= B- mean(B);
        nrmC= C- mean(C);
        nrmD= D- mean(D);
        
        %%
        [cY, lagsY]= xcorr(nrmA, nrmB, maxLength, 'normalized');
        
        [cZ, lagsZ]= xcorr(nrmC, nrmD, maxLength, 'normalized');
        
%store and average ppant effects (averaging crosscorr for dims)
        Hand_Targ_crosscorr(keept,1,:) = cY;
        Hand_Targ_crosscorr(keept,2,:) = cZ;
        Hand_Targ_crosscorr(keept,3,:) = (cY+cZ)/2;
        trialTypes(keept) = HeadPos(itrial).trialType;
        
        keept=keept+1;
        disp([ 'fin trial ' num2str(itrial) ' ' subjID]);
    end % itrial
    
    
    %%
    %convert to seconds.
    xvec = lagsY.*1/90; % approx unity framerate.
%     
%     
    %%

    %save autocorrelation per type.
    PFX_autocorrelation=[];
    for itype=1:4
       indt = find(trialTypes==itype);
       PFX_autocorrelation(itype,:) = squeeze(nanmean(Hand_Targ_crosscorr(indt,3,:),1));        
    end
    save(savename, 'PFX_autocorrelation', '-append');
%     
%     % any diff based on trialtype?
%%
% clf;
%     useCol = {'b', 'r', 'b','k'};
%     
% 
%     for idim= 1:4
%         
%         plot(xvec, squeeze(PFX_autocorrelation(idim,:)), 'color', useCol{idim});
%     hold on;
%     end
%     
    % store group effects while we are here.
    GFX_autocorrelation(isub,:,:)=PFX_autocorrelation;
end % sub

%% plot GFX
%4 conditions 1,2,3,4 = 
%1=wlkslow,targslow;
%2=wlkslow,targfast,
%3=wlknorm, targslow
%4=wlknorm, targfast,


speedCols={'b', [1, 171/255, 64/255]}; % "normal" yellow
usecolsWalk= {speedCols{1},speedCols{1},...
    speedCols{2}, speedCols{2}}; %slowslow fast fast

useLeg = {['slow walk, slow target'], ['slow walk, fast target'], ['normal walk, slow target'],['normal walk, fast target']};
%%
clf

 subplot(1,2,1);
 %plot each seprately.
 for id=1:4
     usedata= squeeze(GFX_autocorrelation(:, id,:));
     mP = mean(usedata,1);
     stE= CousineauSEM(usedata);
     
     shadedErrorBar(xvec, mP, stE, {'color', usecolsWalk{id}, 'linew', 2},1);
      hold on;
      
 end
 xlim([xvec(1) xvec(end)]);
 ylim([0 1])
 ylabel('Correlation coefficient [\itr\rm]');
 xlabel('Time lag (sec)')

 hold on;
      plot([0 0 ], ylim, 'k:');
 set(gca,'fontsize', 20);
 %%
%  subplot(1,2,2);
clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0.1 .1 .35 .8])
 %plot combining walk target speeds
 meanOver= [1,2; 3,4];
 subplot(2,1,2)
 pleg=[];
 for id=1:2
     
     usedata= squeeze(mean(GFX_autocorrelation(:, meanOver(id,:),:),2));
     mP = mean(usedata,1);
     stE= CousineauSEM(usedata);
     
     shadedErrorBar(xvec, mP, stE, {'color', speedCols{id}, 'linew', 2},1);
      hold on; % add peak
      [mx, i] = max(mP);
      pleg(id)=plot([xvec(i) xvec(i)], [0 mP(i)], 'color', speedCols{id}, 'linew', 2, 'linest', '-.');
      
      pkat(id) = xvec(i);
 end
 legend([pleg], {['Peak at ' sprintf('%.2f', pkat(1)) ' s'], ['Peak at ' sprintf('%.2f',pkat(2)) ' s']}, 'autoupdate' ,'off');
 
 xlim([-1.5 1.5]);
 ylim([0 1])
%  a=get(gca)
 ylabel('Correlation coefficient [\itr\rm]');
 xlabel('Time lag (sec)')

 hold on;
      plot([0 0 ], ylim, 'k-', 'linew', 2);
 set(gca,'fontsize', 22);
 %
 
 
 %Also plot example trial.
 subplot(211); cla
 usetrial=150;
 Hts = HandPos_R(usetrial).Y;
 Tts = TargPos(usetrial).Y;
 Timevec= TargPos(usetrial).times;
 plot(Timevec, Tts, 'k', 'linew', 3); hold on;
 plot(Timevec, Hts, 'b', 'linew', 3); shg;
 
 ylabel('Height [m]');
 xlabel('Trial time [sec]');
 set(gca, 'fontsize', 22)
 legend('Target position', 'Hand position', 'Location', 'SouthEast');
 %%
%  tightfig