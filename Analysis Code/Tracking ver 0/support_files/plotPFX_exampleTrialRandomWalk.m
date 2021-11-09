%plot example trial random walk.

% plot PFX error sources

% for each participant, plot the absolute (euclidean) error, as well as the
% error on Y and X dim.

%j4_plotError_by_gaitcycle;

% plot per ppant, plot across ppnts

cd([datadir filesep 'ProcessedData'])

pfols= dir([pwd  filesep '*raw.mat']);
nsubs= length(pfols);


job.plotRW_example3=0; % whole trial RW trajectory for 3 random trials.

job.plotRW_gaitError=1; % split by gait, with colour showing error.
load('GFX_gaitcycle_error');

%%%%%%%%%%%%%%%%%%%%%%
%% print PFX
%%%%%%%%%%%%%%%%%%%%%%
if job.plotRW_example3 %%
    for isub = 1%:nsubs
        cd([datadir filesep 'ProcessedData'])
        %% load data from import job.
        load(pfols(isub).name);
        %%
        clf
        % 3 random trials.
        usetrials=randi(size(TargPos,2),[1,3]);
        %
        for itrial= 1:3
            
            nsamps = length(TargPos(usetrials(itrial)).X);
            deltax = TargPos(usetrials(itrial)).Z;
            %align to zero.
            deltax= deltax - deltax(1); % remove start point.
            deltay = TargPos(usetrials(itrial)).Y;
            deltay= deltay-deltay(1); % same for Y
            xy = zeros(nsamps,2);
            
            subplot(1,3,itrial);
            title(['Sphere trajectory  trial ' num2str(usetrial)])
            for isamp = 1: nsamps
                % Walk in the x direction.
                xy(isamp, 1) = xy(isamp, 1) + deltax(isamp);
                % Walk in the y direction.
                xy(isamp, 2) = xy(isamp, 2) + deltay(isamp);
                % Now plot the walk so far.
                xCoords = xy(1:isamp, 1);
                yCoords = xy(1:isamp, 2);
                plot(xCoords, yCoords, 'b-', 'LineWidth', 2);
                hold on;
                %             textLabel = sprintf('%d', step);
                %             text(xCoords(end), yCoords(end), textLabel, 'fontSize', 10);
                xlim([-.25 0.25])
                ylim([-.25 .25])
                % ylim([1.1 1.5])
                % axis tight;
                axis square;
            end
            %
            % Mark the first point in red.
            hold on;
            plot(xy(1,1), xy(1,2), 'ro', 'LineWidth', 2, 'MarkerSize', 10);
            %         textLabel = '1';
            %         text(xy(1,1), xy(1,2), textLabel, 'fontSize', 10);
            grid on;
            
            % Mark the last point in red.
            plot(xCoords(end), yCoords(end), 'rx', 'LineWidth', 2, 'MarkerSize', 10);
            %         title('Random Walk', 'FontSize', 10);
            xlabel('X', 'FontSize', 10);
            ylabel('Y', 'FontSize', 10);
            
            % Enlarge figure to full screen.
            %         set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
            
            % Calculate the distance from the origin.
            distanceFromOrigin = hypot(xCoords(end), yCoords(end));
        end
    end %ppant
end
%%

if job.plotRW_gaitError==1 % split by gait, with colour showing error.
    for isub = 1%:nsubs
        cd([datadir filesep 'ProcessedData'])
        %% load data from import job.
        load(pfols(isub).name);
        %%
        clf
        % 3 random trials.
        for itrial=10:20
            usetrial=itrial;
            %randi(size(TargPos,2),[1,1]);
            gaitdtmp= HandPos(usetrial).gaitData;
            nGaits = size(gaitdtmp,2);
            gaitcount=1;
            
            %note true origin for correcting RW trajs:
            orX = TargPos(usetrial).Z(1);
            orY = TargPos(usetrial).Y(1);
            greygaits = [1,2, (nGaits-2):nGaits];
            
            %pre-extract the err for all 'good' gaits. We'll use the range to
            %set a within-trial scale of error variation.
            allerr = [gaitdtmp(3:end-2).Hand_Targ_err];
            errscale = linspace(min(allerr), max(allerr), 10);
            % now select a 10 point color bar.
            errcol = flipud(cbrewer('seq', 'YlOrBr',50));
            errcol(errcol>1) = 1; % weird bug, one value >1
            for usegaits = 1:nGaits
                usesamps = gaitdtmp(usegaits).gaitsamps;
                errpersamp = gaitdtmp(usegaits).Hand_Targ_err;
                
                nsamps = length(usesamps);
                deltax = TargPos(usetrial).Z(usesamps);
                %align to zero.
                deltax= deltax -orX; % remove start point.
                deltay = TargPos(usetrial).Y(usesamps);
                deltay= deltay-orY; % same for Y
                xy = zeros(nsamps,2);
                
                deltaErr =HandPos(usetrial).dist2Targ(usesamps);
                
                for isamp = 1:2:nsamps
                    
                    % Walk in the x direction.
                    xy(isamp, 1) = xy(isamp, 1) + deltax(isamp);
                    % Walk in the y direction.
                    xy(isamp, 2) = xy(isamp, 2) + deltay(isamp);
                    % Now plot the walk so far.
                    xCoords = xy(1:isamp, 1);
                    yCoords = xy(1:isamp, 2);
                    % plot the first and last steps in grey (discounted from analysis)
                    
                    if ismember(usegaits,greygaits)
                        usecol= [0,0,0];%[.6 .6 .6];
                        useA=1;
                    else
                        % assign color based on error!
                        %                     usecol='b';
                        sampE = deltaErr(isamp);
                        % find nearest point in cbar:
                        cid= dsearchn(errscale', sampE');
                        usecol = errcol(cid,:);
                        useA=1;
                    end
                   ph=plot(xCoords, yCoords, 'color', usecol, 'marker','o',...
                        'linestyle', 'none', 'LineWidth', 1);
                    hold on;
                    
                end
                %
                % Mark the first point in red.
                hold on;
                %
                % Calculate the distance from the origin.
                distanceFromOrigin = hypot(xCoords(end), yCoords(end));
                gaitcount=gaitcount+1;
                
            end
        end
        xlim([-.3 0.3])
        ylim([-.3 .3])
        
        axis square;
        grid on;
        
        xlabel('X', 'FontSize', 10);
        ylabel('Y', 'FontSize', 10);
        colormap(flipud(errcol));
        colorbar
        title(['Sphere trajectory  trial ' num2str(usetrial) ]);%
    end
    
end