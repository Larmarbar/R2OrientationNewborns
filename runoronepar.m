function runoronepar(V1data, WMmask, decdata, decname,FA, subjectname)

%%% Run orientation script 
[statarray,orientation,grps2,stdv,numvox,sem,indx] = r2starorienmac(V1data,WMmask,decdata,FA);

%%% save matfile
matname = sprintf('%s_T2starorien_%s_dec.mat',subjectname,decname);
save(matname, 'statarray','orientation','stdv','numvox','sem', 'grps2','indx');

%%% create plot w/ error bars
R2err = 1./statarray.^2.*sem;
figure
errorbar(grps2, 1./statarray, R2err)
xlabel('Angle')
ylabel('R2')
title(sprintf('%s', decname))
figname = sprintf('%s_T2starorien_%s_dec.png',subjectname, decname);
saveas(gcf, figname);
