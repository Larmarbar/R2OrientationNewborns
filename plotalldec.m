function plotalldec()
pwd

load('log.mat');
numpat = length(namelist);
cd(outpath);
grpmpath = sprintf('%s/%s_T2starorien_%s_dec.mat',outpaths{1},namelist{1}, 'mgm');

load(grpmpath);


decpars = {'mgm','sgm','ggm','sfr'};
for i=1:length(decpars)
   plotonedec(numpat, namelist, decpars{i},outpaths,grps2) 
end


end