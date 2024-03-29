function avgonedec(decpar,numpat,numbins,namelist,outpath,outpaths,parameters)

%%% Create matrix each for all devalues, voxel numbers and weights based on
%%% standard error of the mean (1/sem^2)
statall = zeros(numpat,numbins);
numallvox = zeros(numpat, numbins);
weightsem = zeros(numpat, numbins);

for i =1:numpat    
    pname = namelist{i};   
    decpath = sprintf('%s/%s_T2starorien_%s_dec.mat', outpaths{i}, pname,decpar);
    load(decpath);
    statall(i,:) = statarray;
    numallvox(i,:) = numvox;
    weightsem(i,:) = 1./sem.^2;
end


grpmpath = sprintf('%s/%s_T2starorien_%s_dec.mat',outpaths{1},namelist{1}, decpar);
load(grpmpath);

binwidth = (grps2(2)-grps2(1))/2;

directavg = mean(statall,1);

totnumvox = sum(numallvox,1);

edges = [grps2;92.5]-2.5;

semavg = 1./sqrt(sum(weightsem,1));

avgwsem = sum(statall.*weightsem,1)./sum(weightsem,1);
avgwvox = sum(statall.*numallvox,1)./sum(numallvox,1);
subjstd = std(statall,1);
if strcmp(decpar,'r2')
    subjstd = std(1./statall,1);
end

cd(outpath);

%% Plot histogram for voxel number for each bin over all subjects 
figure
hold on;
%title(sprintf('Average %s %s', decpar, parameters),'Interpreter', 'none');
histogram('BinEdges', edges.' ,'BinCounts',totnumvox);
sinamp = sum(totnumvox)*5/360*2*pi;
xlabel('Angle');
ylabel('#voxel');
figname = sprintf('/home/lbartels/Research/Analysis/histogram_voxelnum.png');
thetas = linspace(0,90,100);
plot(thetas, sinamp.*sin(thetas/360*2*pi), 'LineWidth',2,'Color', [0.6350 0.078 0.184]);
saveas(gcf, figname);
hold off;


if strcmp(decpar,'sfr') | contains(decpar, 'mgm') | contains(decpar, 'sgm') | contains(decpar, 'ggm')
    % patientwise and global average of each of the above parameters 
    patwise = sum(statall.*numallvox,2)./sum(numallvox,2);
    stdallpats = std(patwise);
    glob_av = sum(totnumvox.*avgwvox)./sum(totnumvox);
    % calculate anisotropy in each parameter for each patient & global average
    
    minpar = min(statall,[],2);
    maxpar = max(statall,[],2);
    
    if contains(decpar, 'mgm') | contains(decpar, 'sgm') | contains(decpar, 'ggm') 
        patwise = 1./patwise;
        glob_av = 1./glob_av;
        aniso = 1./minpar-1./maxpar;
        norm = 1./minpar+1./maxpar;
        relaniso = mean(aniso./norm);
        absaniso = aniso;
        mrelaniso = mean(relaniso);
        save(sprintf('patwise_avg_%s_dec.mat',decpar), 'minpar','maxpar','namelist', 'patwise','stdallpats','glob_av', 'aniso', 'absaniso','relaniso','mrelaniso');
    else 
        aniso = maxpar-minpar;
        norm = maxpar+minpar;
        maniso = mean(aniso);
        relaniso = aniso./norm;
        mrelaniso = mean(relaniso);
        save(sprintf('patwise_avg_%s_dec.mat',decpar), 'namelist', 'patwise','stdallpats','glob_av', 'aniso','maniso','relaniso','mrelaniso');
    end
    

end

% PLOT Averaged Parameter 

figure
hold on
if strcmp(decpar,'sfr')|strcmp(decpar,'r2')
    plot(grps2,directavg)
    errorbar(grps2,avgwsem,semavg)
    plot(grps2,avgwvox) 
else
    R2err = 1./avgwsem.^2.*semavg;
    plot(grps2,1./directavg)
    errorbar(grps2,1./avgwsem,R2err)
    plot(grps2,1./avgwvox)
end 
title(sprintf('Average %s %s', decpar, parameters),'Interpreter', 'none');
xlabel('Angle')
ylabel('R2')
hold off
leglist = {'Average','Average w SEM','Average w numvoxel'};
legend(leglist,'Interpreter', 'none', 'Location', 'southeast');
save(sprintf('avg_%s_dec.mat',decpar), 'directavg', 'avgwsem','avgwvox','semavg','totnumvox','grps2');
figname = sprintf('T2starorien_average_%s_dec_%i.png',decpar,numpat);
saveas(gcf, figname);


%%%
%%% Fitting 
%%%

if strcmp(decpar, 'sgm')| strcmp(decpar, 'mgm')|strcmp(decpar, 'ggm')|strcmp(decpar, 'r2')

    firstpoint = 1;
    if firstpoint > 1
        numexp = firstpoint-1;
        sprintf('Excluding %d from fit', numexp)
    end
    
    if sum(isnan(avgwsem))==0
        if strcmp(decpar, 'r2')
            fitmodel(grps2, 1./avgwvox, subjstd, totnumvox, firstpoint, decpar)
        else
            fitmodel(grps2, avgwvox, subjstd, totnumvox, firstpoint, decpar)
        end
        
    end
end


end