% rejTrials_trackingv1%

% certain bad trials (identified in figure folder).
% look at 'TrialHeadYPeaks', to see if the tracking dropped out on any
% trials. Or if participants were not walking smoothly.


% step in to reject particular ppant+trial combos.
badtrials=[];
switch subjID
    %%%%tracking ver 1 (2 walk speeds, 2 target speeds).
    case 'AF_R_2022-03-14-11-04'
    badtrials=[109,124,147];
    case 'AW_R_2022-03-10-03-01'
        badtrials = [85, 95];
    case 'EG_R_2022-03-14-01-00'
        badtrials =[141];
    case 'HB_R_2022-03-10-01-06' % (reject?) very difficult to extract gaits.
        badtrials = [23:32];
    case 'JA_R_2022-03-15-02-12'
        badtrials= [30,43, 90, 106,112,117,125,126,141,144:146, 167];
    case 'JB_R_2022-03-11-02-00'
        badtrials = [41,75];
    case 'JC_R_2022-03-10-10-49'
        badtrials =[16,24,43:45,90,101:119,167,174,];
    case 'JT_R_2022-03-17-12-59' % (review), need accomodate hump in gait cycle (removes peaks).
        badtrials=[21:22, 34,43,53,77,79,111,113,114,145,146,173,177,178,171,180];
    case  'KG_R_2022-03-10-02-05' % (reject?) appears to swap hands on some trials?
        badtrials=[69,85,86,109,111,121,125,128,129,130,133,135,...
            137,139,141,142,147,149,155,159];
    case 'KW_R_2022-03-17-02-58' % (review), need to improve gait extraction
        badtrials=[22,33, 45,76, 79,92,93];
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