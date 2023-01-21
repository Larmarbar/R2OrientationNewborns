parameterlist = {};
dataset = 'neon' 
% dataset = 'baseline_subset'

%Add parameters used in decaes to be analysed to parameterlist

parameterlist{end+1} = 'T2_8e-3_2.0_SPWin_8e-3_25e-3_MPWIN_25e-3_2.0';

% Set local datapath
if strcmp(dataset, 'neon')
    datapath = '/home/lbartels/Research/Data/neonates_healthy';
elseif strcmp(dataset, 'baseline_subset')
    datapath = '/home/lbartels/Research/Data/hockey_baseline_subset';
end

% add relevant paths 
inipath = '/home/lbartels/Research/Analysis/'; 
codepath = sprintf('%sCode', inipath); 

addpath codepath;
addpath inipath

for i=1:length(parameterlist)
    parameters = parameterlist{i}
    
%     Run orientation analysis for all patients
    runallmwi(parameters, inipath, codepath, datapath, dataset);
    
%     Average orientation dependencies over all patients
    avgalldecnew2(inipath) 
    
%     plot T2spectra and histograms
    t2spec2(inipath,dataset);
    close all
    plot_spectra_Jon_GRASE(dataset, inipath);
    
    % Show all patients in one plot for each parameter
     plotalldec()
     close all
end