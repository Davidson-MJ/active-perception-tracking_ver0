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
        
    case 'KX_R_2022-03-11-11-17'
        badtrials = [104,158];

    case 'LW_R_2022-03-17-10-01'
        badtrials=[29];
    case 'MC_R_2022-03-15-01-07'
        badtrials= [83];
    case 'MD_R_2022-03-07-10-15'
        badtrials=[74];
    case 'MD_R_2022-03-11-12-08'
        badtrials =[105,108,140,148];
    case 'MT_R_2022-03-15-12-05'
        badtrials=[67,78,97,98];
    case 'NY_R_2022-03-11-10-01'
        badtrials=[39,47,75,112,144];
    case 'PH_R_2022-03-14-09-00'%(review), need accomodate hump, poor gait extraction
        badtrials= [164];
    case 'RZ_R_2022-03-17-11-05' % contains example of wrong hand (115)
        badtrials= [30,115,125,159];
    case 'SL_R_2022-03-15-03-06' % contains example of wrong hand (115)
        badtrials= [71,101,102,148:150];
    case 'ST_R_2022-03-14-02-12'
        badtrials=[47,49,103,129,166];
    case 'TV_R_2022-03-14-12-34' % (reject?) swappinghands / giving up on certain trials?
        badtrials=[39,50,60,66,68,72,79,80,88,89,96,98:100,102,109,110,114,...
            116,120,123,134,138,148,155,156,161,173:176];
%     case 'WC_R_2022-03-10-10-04' %(reject, only 91 trials)
%         badtrials=[36,43,55,84:90,91]
    case 'YW_R_2022-03-15-11-12' %(example of high freq artefact)
        badtrials =[25,68,91,101,108];
    case 'ZI_R_2022-03-15-10-03' % examples of perfectly phase + gait locked Error
        badtrials =[42,104];
    case 'ZL_L_2022-03-11-03-10'
        badtrials=[80];        
    case 'ZZ_R_2022-03-17-01-58' % (review), accomodate hump
        badtrials =[167];
        %%%%%%%%%%%
        %%%%%%%%%%% rejected:
        %%%%%%%%%%% 
      case 'WC_R_2022-03-10-10-04' %(reject?, only 91 trials)
        badtrials=[36,43,55,84:90,91];
        
end

    
%%
if ismember(itrial,badtrials)
    disp(['Skipping bad trial ' num2str(itrial) ' for ' subjID]);
    skip=1;
end
%%