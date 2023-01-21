function plotonedec(numpat, namelist, decpar,outpaths,grps2)

figure 
hold on
if strcmp(decpar,'sfr') | strcmp(decpar,'fa') | strcmp(decpar,'rd') | strcmp(decpar,'md') | strcmp(decpar,'l1') | strcmp(decpar,'r2')| contains(decpar,'r2star')| strcmp(decpar,'qsm')| strcmp(decpar,'t1')| strcmp(decpar,'t2')  
    for i =1:numpat
        name = namelist{i};
        flpath = sprintf('%s/%s_T2starorien_%s_dec.mat', outpaths{i}, name, decpar);
        load(flpath);
        R2err = sem;
        errorbar(grps2,statarray,R2err,'o');
    end
else
    for i =1:numpat
        name = namelist{i};
        flpath = sprintf('%s/%s_T2starorien_%s_dec.mat', outpaths{i}, name,decpar);
        load(flpath);
        R2err = 1./statarray.^2.*sem;
        errorbar(grps2,1./statarray,R2err,'-');
    end
end
hold off
ax = gca;
ax.FontSize = 16;
xlim([0,90]);
xlabel('Angle (degree)','FontSize',16)
%ylabel(sprintf('Intra/extracellular R2',decpar))
%title(sprintf('%s all patients',decpar))
if strcmp(decpar,'sgm');
    ylab = 'Myelin Water $R_2$ (Hz)';
elseif strcmp(decpar,'mgm')
    ylab = 'Intra- and Extracellular Water $R_2$ (Hz)'
elseif strcmp(decpar,'r2')
    ylab = '$R_2$ (Hz)'
else
    ylab = '$R_2$'
end

set(0,'DefaultAxesFontName','Arial')
ylabel(ylab,'FontSize',16)

set(gca,'FontName','Arial');
%legend(namelist,'Interpreter', 'none',  'Location', 'southeast');
figname = sprintf('All_R2starorien_%s_dec.png',decpar);
saveas(gcf, figname);
hold off

end