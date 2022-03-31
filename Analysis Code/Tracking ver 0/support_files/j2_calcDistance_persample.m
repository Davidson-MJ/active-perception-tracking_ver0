%j2_calcDistance_persample

% Here we calculate the 3D distance between hand and target at each time
% point. Then store both trial level data, and cycle by cycle.

% This also outputs a trial-by-trial figure, overlaying head pos, and
% error, for each walk trajectory.
% Note the shading for gaits retained / excluded.

% can calculate distance bw 2 3D points using:
% 1) sqrt(sum((A - B) .^ 2))
% 2) norm(A-B)

cd([datadir filesep 'ProcessedData'])
pfols = dir([pwd filesep '*_summary_data.mat']);
nsubs= length(pfols);
%% show ppant numbers:
tr= table([1:length(pfols)]',{pfols(:).name}' );
disp(tr)
%%
for isub = 1:20%length(pfols)
    cd([datadir filesep 'ProcessedData'])
    %%load data from import job.
    load(pfols(isub).name, 'HeadPos', 'HandPos_L', 'HandPos_R', 'TargPos','subjID');
    savename = pfols(isub).name;
    disp(['Preparing j2 ' savename]);
    % Make sure to use the correct (dominant) hand for calculating error.
    % note that for some subjects, due to controller malfunction, the
    % labels had to be swapped (empty battery half way through).
    if strcmp(subjID(4), 'R')
        HandPos = HandPos_R;
        disp(['Using Right hand for ' subjID]);
    else
        HandPos = HandPos_L;
        disp(['Using LEFT hand for ' subjID]);
        error('check code');
    end
    %%
    Hand_Targ_dist = [];
    Hand_Targ_dist_alt = Hand_Targ_dist;
    for  itrial=1:size(HeadPos,2)
        data = HandPos(itrial).Y;
        for isamp = 1:length(data)
            %gather xyz coords.
            A = [HandPos(itrial).X(isamp), HandPos(itrial).Y(isamp), HandPos(itrial).Z(isamp)];
            B=  [TargPos(itrial).X(isamp), TargPos(itrial).Y(isamp), TargPos(itrial).Z(isamp)];
            
            Yerr = TargPos(itrial).Y(isamp) - HandPos(itrial).Y(isamp);
            Xerr = TargPos(itrial).X(isamp) - HandPos(itrial).X(isamp);
            Zerr = TargPos(itrial).Z(isamp) - HandPos(itrial).Z(isamp);
            %        Hand_Targ_dist(itrial,isamp) = sqrt(sum((A - B) .^ 2));
            %        Hand_Targ_dist(itrial,isamp) =norm(A-B);
            
            HandPos(itrial).dist2Targ(isamp) = norm(A-B);
            HandPos(itrial).Yerror(isamp) = abs(Yerr);
            HandPos(itrial).Xerror(isamp) = abs(Xerr);
            HandPos(itrial).Zerror(isamp) = abs(Zerr);
        end
    end % itrial
    
    
    save(savename, 'HandPos', '-append');
    
    
    
    % also plot error per trial in fig dir, for debugging purposes:
    figure(1); set(gcf, 'units', 'normalized', 'position', [0,0, .9, .9], 'color', 'w', 'visible', 'off');
    pcount=1; figcount=1;
    clf
    for itrial = 1:size(HeadPos,2)
        if HeadPos(itrial).isPrac
            continue
        end
        if itrial==16 || pcount ==16
            %print that figure, and reset trial count.
            pcount=1;
            cd([datadir filesep 'Figures' filesep 'Trial_headYpeaks'])
            print('-dpng', [subjID ' trialpeaks ' num2str(figcount) ' + Error' ]);
            figcount=figcount+1;
            clf;
            
        end
        subplot(5,3,pcount);
        Timevec = HeadPos(itrial).times;
        plotd= HeadPos(itrial).Y;
        plot(Timevec, plotd);
        hold on;
        %         plot(Timevec(locs_ptr), trialD(locs_ptr), ['or']);
        %         plot(Timevec(locs_trtr), trialD(locs_trtr), ['ob']);
        ylabel('Head position');
        xlabel('Time (s)');
        title(['Trial ' num2str(itrial)]);
        axis tight
        yyaxis right
        plot(Timevec, HandPos(itrial).dist2Targ, 'linew', 2);
        ylabel('raw Error')
        % show the window retained:
        if ~HeadPos(itrial).isStationary
            trs = HeadPos(itrial).Y_gait_troughs;
            maxE = max(HandPos(itrial).dist2Targ);
            xp = [0 0 Timevec(trs(3)) Timevec(trs(3))]; % show up to 4th trough, since that is excluded as start point.
            yp= [0 maxE maxE 0];
            patch(xp,yp, [.8 .8 .8], 'FaceAlpha', 0.5)
            xp2 = [Timevec(trs(end-2)), Timevec(trs(end-2)), Timevec(end), Timevec(end)];
            patch(xp2,yp, [.8 .8 .8], 'FaceAlpha', 0.5);
        end
        pcount=pcount+1;
    end
    
    cd([datadir filesep 'Figures' filesep 'Trial_headYpeaks'])
    print('-dpng', [subjID ' trialpeaks ' num2str(figcount) ' + Error' ]);
end % sub