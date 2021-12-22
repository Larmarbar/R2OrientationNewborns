function avgalldecnew2(inipath)

cd(inipath);
load('log.mat');


numpat = length(namelist);    
mgpath = sprintf('%s/%s_T2starorien_mgm_dec.mat', outpaths{1}, namelist{1});
load(mgpath, 'statarray');

sizestatarray = size(statarray);
numbins = sizestatarray(1);

decpars = {'mgm','sgm','ggm','sfr'};
for i=1:length(decpars)
   avgonedec(decpars{i},numpat,numbins,namelist,outpath,outpaths,parameters); 
   close all;
end

close all
end