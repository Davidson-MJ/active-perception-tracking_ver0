% rejTrials_trackingv1%

% certain bad trials (identified in figure folder).
% look at 'TrialHeadYPeaks', to see if the tracking dropped out on any
% trials. Or if participants were not walking smoothly.


% step in to reject particular ppant+trial combos.
badtrials=[];
switch subjID
    %%%%tracking ver 1 (2 walk speeds, 2 target speeds).
    case 'AF_R_2022-03-14-11-04'
    badtrials=[124,147];
    case 'AW_R_2022-03-10-03-01'
        badtrials = [];
    case 'EG_R_2022-03-14-01-00'
        badtrials =[];
    case 'HB_R_2022-03-10-01-06'
        badtrials = [23,24,25,28,54,56,58,60];
    case 'JA_R_2022-03-15-02-12'
        badtrials= [106,117];
    case 'JB_R_2022-03-11-02-00'
        badtrials = [];
    case 'JC_R_2022-03-10-10-49'
        badtrials =[];
    case 'JT_R_2022-03-17-12-59'
        badtrials=[146];
    case  'KG_R_2022-03-10-02-05'
        badtrials=[142];
    case 'KW_R_2022-03-17-02-58'
        badtrials=[45];
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