%j1_split_bycycle

% Here we will identify the peaks in head position data, for later splitting
% walk trajectories into individual gait cycles.

cd([datadir filesep 'ProcessedData'])
Fs=90;
pfols = dir([pwd filesep '*summary_data.mat']);
nsubs= length(pfols);
%% show ppant numbers:
tr= table([1:length(pfols)]',{pfols(:).name}' );
disp(tr)
%%
% threshold between peaks for detection
pkduration = 0.3;  % min separation between troughs. (sec)
pk2tr = 0.15; %sec min duration between trough and peak retained.
pkdist= ceil(pkduration*Fs); % (in samples).
pkheight = 0.002; % (m)
%%
figure(1); clf;
set(gcf, 'units', 'normalized', 'position', [0,0, .9, .9], 'color', 'w', 'visible', 'off');
%%
for ippant = 1:10%11:20%nsubs
    cd([datadir filesep 'ProcessedData'])
   
%     pkdist = participantstepwidths(ippant);
    %%load data from import job.
    load(pfols(ippant).name);
    savename = pfols(ippant).name;
    disp(['Preparing j1 ' subjID]);
    
    %% visualize the peaks and troughs in the head (Y) position.
    %Head position on Y axis, smooth to remove erroneous peaks.
   
    pcount=1; % plot indexer
    figcount=1; %figure counter.
    %% Note that for nPractice trials, there won't be peaks and troughs, as the ppant was stationary.
    for  itrial=1:size(HeadPos,2)
        
        %trial data:
        trialD= [HeadPos(itrial).Y]';
        trialD_sm = smooth(trialD', 5); % small smoothing factor.

        Timevec  = HeadPos(itrial).times;
            
        %% if stationary trial, don't calculate pks and troughs:
        if  HeadPos(itrial).isStationary || HeadPos(itrial).isPrac
            % print pos data, no peak detection:
            
            figure(1);
            if itrial==16 || pcount ==16
                %print that figure, and reset trial count.
                pcount=1;
                 cd([datadir filesep 'Figures' filesep 'Trial_headYpeaks'])
                print('-dpng', [subjID ' trialpeaks ' num2str(figcount)]);
                figcount=figcount+1;
                clf;
                
            end
            subplot(5,3,pcount);
            plot(Timevec, trialD);
            hold on;
            ylabel('Head position');
            xlabel('Time (s)');
            title({['Trial ' num2str(itrial) ' (Stationary/Practice),'];...
                ['walk: ' num2str(HeadPos(itrial).walkSpeed) ', targ speed: ' num2str(HeadPos(itrial).targSpeed)]});
            axis tight
            pcount=pcount+1;
        
        else %% subj was walking, overlay pks and troughs with head pos:  
            
            %subj/trial specific gait adjustment:
            % we need to adjust the step length, to adjust on different walk speeds.
            % some ppants take shorter steps when walking slowly, or on
            % certain trials.
            
            if strcmp(subjID(1:4), 'AF_R') && HeadPos(itrial).walkSpeed==0.5
                pkdist= ceil(0.15*Fs); 
            else
                pkdist= ceil(pkduration*Fs); % (in samples).
            end
            
            
            %find local peaks.
            %Threshold peak finder using something reasonable. like 500ms
            % Turns out the troughs are much cleaner, so look for those,
            % then define peaks as max between them.
            
            %             [~, locs_p]= findpeaks(trialD_sm, 'MinPeakDistance',pkdist, 'MinPeakProminence', pkheight); %
            
            [~, locs_tr]= findpeaks(-trialD, 'MinPeakDistance',pkdist, 'MinPeakProminence', pkheight);
            
            % define peaks, as max between troughs (in unsmoothed data).
            locs_p2=zeros(1, size(locs_tr,1)-1);
            for ipk = 1:length(locs_tr)-1
                [m,i] = max(trialD(locs_tr(ipk): locs_tr(ipk+1)));
                
                nextrough = locs_tr(ipk+1);
                disttonext = nextrough- (locs_tr(ipk)+i);
                
                % only store the 'peak' if it is a true peak, arbitrarily
                % atleast 150 ms from the other troughs.
                if i >= ceil(pk2tr*Fs) && (disttonext >= ceil(pk2tr*Fs))
                    locs_p2(ipk) = i+locs_tr(ipk)-1;
                end
            end
           
            % remove the zeros (false peaks)
            locs_p2(locs_p2==0) =[]; 
            locs_ptr= locs_p2;

            %make sure no duplicates:
            locs_trtr= unique(locs_tr);
            
            % for stability, we want to start and end in a trough.
            if locs_trtr(1) > locs_ptr(1) % if trial starts with peak.
                %insert trough, using minimum before first peak
                [~, ftr ] = min(trialD(1:locs_ptr(1)));
                locs_trtr = [ ftr,  locs_trtr];
            end
            %if trial ends with peak, add trough after at local minimum
            if locs_ptr(end) > locs_trtr(end) % if trial ends with peak.
                %insert trough, using minimum after last peak
                [~, ftr ] = min(trialD(locs_ptr(end):end));
                locs_trtr = [locs_trtr, locs_ptr(end)-1+ftr];
            end
            
            % finally, make sure that troughs and peaks alternate, if not, use            
            
            %plot what we have so far:
            try subplot(5,3,pcount);
                
                plot(Timevec, trialD);
                hold on;
                plot(Timevec(locs_ptr), trialD(locs_ptr), ['ok']);
                plot(Timevec(locs_trtr), trialD(locs_trtr), ['ob'])
                
                
                if itrial==23
                    pause(.1);
                end
            catch
            end

            
%% Now loop through all, and ensure only a single trough between each peak.   
% store  acopy of troughs, to preserve indexing.
locs_trtrcopy = locs_trtr;
%now we can remove from locs_trtrcopy, when we find doubles in locs_trtr.
                for ipk = 1:length(locs_ptr)
                    %for each peak, check only one trough before hand
                    if ipk==1 % if first pk, should only be one trough before hand
                    pktmp= locs_ptr(ipk);
                    %earlier troughs:
                    earlyexist = find(locs_trtr< pktmp);
                    
                    else % subsequently, check there is only 1 trough in range.
                        pktmp= locs_ptr(ipk);
                        pktmpprev = locs_ptr(ipk-1);
                         %earlier troughs:
                         %%
                    A = find(locs_trtr<= pktmp); 
                    B= find(locs_trtr>=pktmpprev);
                    earlyexist = intersect(A,B);
                    end
                    
                    %% retain minimum as true trough.
                    if length(earlyexist)>1
                     
                        headpos = trialD(locs_trtr(earlyexist));
                       [val,idx] = min(headpos);
                          removeme= find(headpos~=val);
                           
                          % for all those to be removed, find their index
                          % in the copy, and remove (so as not to mess with
                          % locs_trtr array, used in this forloop.
                          for ir=1:length(removeme)
                              searchd= locs_trtr(earlyexist(removeme(ir)));
                              idx= find(locs_trtrcopy == searchd);
                              locs_trtrcopy(idx)=NaN;
                              
                              %for debugging, also plot which is being
                              %removed !
                               hold on;
                               plot(Timevec(searchd), trialD(searchd), ['xr']);
                              
                          end
%                            locs_trtr(earlyexist(removeme))=[]; 
                    end
                    
                    
                    %% check if this is the last peak, that there is only one trough remaining:
                    if ipk == length(locs_ptr)
                       % find troughs later than this peak.
                        pktmp= locs_ptr(ipk);
                          %later troughs:
                        laterexist = find(locs_trtr> pktmp);
                        
                        % if more than one trough remaining, retain only
                        % the minimum value as the true trough.                   
                        if length(laterexist)>1
                           headpos =  trialD(locs_trtr(laterexist));
                           [val,idx] = min(headpos);
                          removeme= find(headpos~=val);                           
                          for ir=1:length(removeme)
                              searchd= locs_trtr(laterexist(removeme(ir)));
                              idx= find(locs_trtrcopy == searchd);
                              locs_trtrcopy(idx)=NaN;
                              
                          end
                        end
                            
                    end
                    
                    
                end % for each gait
                
                locs_trtr= locs_trtrcopy(~isnan(locs_trtrcopy));
                
                %% now that we are sure peaks and troughs alternate in equal numbers, 
                % repair any damages, so that the peaks are the max point
                % between our troughs.
                locs_p2=[];
              for ipk = 1:length(locs_trtr)-1
                [m,i] = max(trialD(locs_trtr(ipk): locs_trtr(ipk+1)));
                
                nextrough = locs_trtr(ipk+1);
                disttonext = nextrough- (locs_trtr(ipk)+i);
                
                % only store the 'peak' if it is a true peak, arbitrarily
                % atleast 150 ms from the other troughs.
                if i >= ceil(pk2tr*Fs) && (disttonext >= ceil(pk2tr*Fs))
                    locs_p2(ipk) = i+locs_trtr(ipk)-1;
                end
              end
              %remove any false pks.
                locs_p2(locs_p2==0) =[]; 
                locs_ptr=locs_p2;
            %%
           
            
            %% now visualize final results.
            
            figure(1);
            if itrial==16 || pcount ==16
                %print that figure, and reset trial count.
                pcount=1;
                cd([datadir filesep 'Figures' filesep 'Trial_headYpeaks'])
                print('-dpng', [subjID ' trialpeaks ' num2str(figcount)]);
                figcount=figcount+1;
                clf;
                
            end
            subplot(5,3,pcount); cla;
            plot(Timevec, trialD);
            hold on;
            plot(Timevec(locs_ptr), trialD(locs_ptr), ['or']);
%             plot(Timevec(locs_p2), trialD(locs_p2), ['or']);
            
            plot(Timevec(locs_trtr), trialD(locs_trtr), ['ob']);
            ylabel('Head position');
            xlabel('Time (s)');           
            title1= ['Trial ' num2str(itrial) ','];           
            title({title1;...
                ['walk: ' num2str(HeadPos(itrial).walkSpeed) ', targ speed: ' num2str(HeadPos(itrial).targSpeed)]});
            axis tight
            pcount=pcount+1;
            
            %add these peaks and troughs to trial structure data.
            HeadPos(itrial).Y_gait_peaks = locs_ptr;
            HeadPos(itrial).Y_gait_troughs = locs_trtr;
            
           
        end
        %
    end %itrial.
    %%
    
    cd([datadir filesep 'Figures' filesep 'Trial_headYpeaks'])
    
    
    print('-dpng', [subjID ' trialpeaks ' num2str(figcount)]);
    clf;
    cd([datadir filesep 'ProcessedData']);
    save(savename, 'HeadPos', '-append');
end % isub
