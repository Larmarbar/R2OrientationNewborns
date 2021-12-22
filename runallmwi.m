function runallmwi(parameters, inipath, codepath, datapath, dataset)

% create pathnames from decaes parameters, dataset in inipath
outpath = sprintf('%s%s_%s',inipath, parameters,dataset);
outend = sprintf('%s_%s', parameters, dataset);
mkdir(outpath);
save(sprintf('%slog.mat', inipath),'parameters','inipath');

% get list of all patient folders in path
namelist = dirnonh(datapath);
numpat = length(namelist);

% Get paths to output data for each patient
outpaths = [];
V1paths = [];
WMmaskpaths = [];
brainmaskpaths = [];
for i=1:length(namelist)
    fullpath = sprintf('%s/%s',datapath, namelist{i})
   [V1data, WMmask, brainmaskpath] = MWIdecnew2(fullpath, outend, parameters, codepath, dataset);
    outpaths =  [outpaths, {sprintf('%s/%s/%s',datapath, namelist{i},parameters)}];
    V1paths = [V1paths, {sprintf('%s/%s/%s', datapath, namelist{i},V1data(4:end))}];
    WMmaskpaths = [WMmaskpaths, {sprintf('%s/%s/%s', datapath, namelist{i},WMmask(4:end))}];
    brainmaskpaths = [brainmaskpaths, {sprintf('%s/%s/%s', datapath, namelist{i},brainmaskpath(4:end))}];

    plotr2overview(parameters, fullpath, dataset);

end
for i=1:length(namelist)
    namelist{i}
end
cd(inipath);
numpat = length(namelist);
% 'save log and name'
save(sprintf('%slog.mat', inipath), 'outpath', 'outpaths', 'parameters', 'namelist', 'inipath','numpat');
save(sprintf('%snames.mat', inipath), 'namelist');
data.mask_path = brainmaskpaths;
data.wm_path = WMmaskpaths;
data.v1_path = V1paths;

save(sprintf('%sdata.mat',inipath),'data');
end