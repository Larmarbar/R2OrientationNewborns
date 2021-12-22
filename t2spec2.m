% parameters: statarray orientation grps2 stdv
function t2spec2(inipath, dataset)
startpath = pwd;
cd(inipath);
load('log.mat');
load('data.mat');
numpat = length(namelist)
cd(outpath);
mkdir('./histograms');
cd('histograms')


% Load T2maps data
distpaths = [];    
if strcmp(dataset,'neon')
    flpath =  sprintf('%s/merged.t2maps.mat', outpaths{1});
    for i = 1:numpat
        distpath = sprintf('%s/merged.t2dist.mat', outpaths{i});
        distpaths = [distpaths, {distpath}];
    end
        
        
    
elseif contains(dataset,'baseline')
    basepath = outpaths{1}(1:end);
    flpath =  sprintf('%s/*.t2maps.mat', basepath);
    flpath = dir(flpath);
    flpath = flpath(1).name;
    flpath = sprintf('%s/%s', basepath, flpath);
    for i = 1:numpat
        distpath = sprintf('%s/mergedGRASE.t2dist.mat', outpaths{i});
        distpaths = [distpaths, {distpath}];
    end
end
save('data.mat')
data.dist_path = distpaths;
save(sprintf('%sdata.mat',inipath),'data')

load(flpath, 't2times');
save(sprintf('%sdata.mat',inipath),'data','t2times')


alltotalt2 = zeros(numpat,length(t2times));
allmeant2 =  zeros(numpat,length(t2times));
alltotalt2mask = zeros(numpat,length(t2times));
allmeant2mask = zeros(numpat,length(t2times));
allnumwmvox = zeros(numpat,1);


for i =1:numpat
    name = namelist{i};
   
    flpath = sprintf('%s/distnii/dist_1_dec.nii', outpaths{i});
    niinfo = niftiinfo(flpath);
    niisize = niinfo.ImageSize;
    dist = zeros(niisize(1),niisize(2),niisize(3),length(t2times));
    numallvox = niisize(1)*niisize(2)*niisize(3);
    flpath = sprintf('%s/%s_T2starorien_%s_dec.mat', outpaths{i}, name, 'mgm');
    load(flpath, 'indx');
    indxsiz = size(indx);
    numwmvox = indxsiz(1);
    allnumwmvox(i)=numwmvox;
    distmask = zeros(numwmvox,length(t2times));
    for j=1:length(t2times) 
        niiname = sprintf('%s/distnii/dist_%i_dec.nii', outpaths{i},j);
        currt2 = niftiread_unzip(niiname);
        dist(:,:,:,j) = currt2;
        distmask(:,j) = currt2(indx);
    end    
    
    totalt2mask = squeeze(sum(distmask,'omitnan'));
    meant2mask = squeeze(mean(distmask,'omitnan'));
    
    totalt2 = squeeze(sum(dist,[1 2 3], 'omitnan'));
    meant2 = squeeze(mean(dist,[1 2 3], 'omitnan'));

    
    alltotalt2(i,:) = totalt2;
    alltotalt2mask(i,:) = totalt2mask;
    
    allmeant2(i,:) = meant2;
    allmeant2mask(i,:) = meant2mask;
    
    %% Plot amplitude over all voxels
    figure
    xlabel('T2')
    ylabel('Mean Amplitude')
    title('T2 spectrum')
    semilogx(t2times,meant2);
    hold on
    semilogx(t2times,meant2mask);
    legend('all voxels', 'WM voxels')
    title(sprintf('T2 spectrum for %s', namelist{i}),'Interpreter', 'none')
    figname = sprintf('%s_T2spec_dec.png',namelist{i});
    saveas(gcf, figname);
    hold off
    
    figure
    xlabel('T2')
    ylabel('Mean Amplitude')
    title('T2 spectrum')
    semilogx(t2times,meant2);
    hold on
    semilogx(t2times,meant2mask);
    xlim([0,0.4])
    legend('all voxels', 'WM voxels')

    title(sprintf('T2 spectrum for %s close up', namelist{i}),'Interpreter', 'none')
    figname = sprintf('%s_T2spec_dec_close.png',namelist{i});
    saveas(gcf, figname);
    hold off
    
end
close all



alltotalt2 = sum(alltotalt2);
allmeant2 = mean(allmeant2);
alltotalt2mask = sum(alltotalt2mask);
totalvoxnum = sum(allnumwmvox);
'allmeant2mask';
size(allmeant2mask);
'allnumwmvox';
size(allnumwmvox);
weightmaskmeant2 = sum(allmeant2mask.*allnumwmvox/totalvoxnum);

figure
title('Total T2 spectrum')
hold on
semilogx(t2times,weightmaskmeant2);
xlabel('T2')
ylabel('Total Amplitude')


figname = 'T2spec_dec.png';
saveas(gcf, figname);
hold off
figure
xlabel('T2')
ylabel('Total Amplitude')
title('T2 spectrum')
xlim([0,0.4])
semilogx(t2times,weightmaskmeant2);
hold on

hold off
figname = sprintf('T2spec_dec_close.png',namelist{i});
saveas(gcf, figname);

for i =1:numpat
    name = namelist{i};
    flpath = sprintf('%s/%s_T2starorien_%s_dec.mat', outpaths{i}, name, 'mgm');
    load(flpath);
    figure
    xlabel('T2')
    ylabel('# voxels')
    title('GGM WM T2 spectrum')
    edges= 2:2:90;
    histogram(orientation(:,4),edges);
    set(gca, 'xscale', 'log')
    xlabel('Angle')
    ylabel('# voxels')
    title(sprintf('GGM WM Angle spectrum for %s', namelist{i}),'Interpreter', 'none')
    figname = sprintf('%s_Anglespec_ggm_dec.png',namelist{i});
    saveas(gcf, figname);
end

cd(startpath);
end