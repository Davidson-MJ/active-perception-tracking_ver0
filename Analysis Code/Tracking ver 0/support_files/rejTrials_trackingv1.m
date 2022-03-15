% rejTrials_trackingv1%

% certain bad trials (identified in figure folder).
% look at 'TrialHeadYPeaks', to see if the tracking dropped out on any
% trials. Or if participants were not walking smoothly.


% step in to reject particular ppant+trial combos.
badtrials=[];
switch subjID
    %%%%tracking ver 1 (2 walk speeds, 2 target speeds).
    case 'MD_R_2022-03-07-10-15'
        badtrials = [74,;
   
        %%%%%%%%%%% 
        %%%%%%%%%%% rejected:
        %%%%%%%%%%% 
    %case %
end

    
%%
if ismember(itrial,badtrials)
    disp(['Skipping bad trial ' num2str(itrial) ' for ' subjID]);
    skip=1;
end
%%