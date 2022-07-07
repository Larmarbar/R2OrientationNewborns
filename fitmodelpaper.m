function fitmodelpaper(theta, avgT2, stdavgT2, firstpoint, comp)
% R2 average value
avgsr2w = 1./avgT2;

avgsr2fit = 1./(avgT2(firstpoint:end));


grps2fit = theta(firstpoint:end);

% Error on R2 average
stdavgr2 = (1./avgT2.^2).*stdavgT2; 

stdavgr2fit = stdavgr2(firstpoint:end);

% Weights for R2 values
weightsmfit = 1./(stdavgr2fit.^2);

ANGLE_COLORS = zeros(3,3);
brm = brewermap(11,'RdYlBu');
brm2 = brewermap(11,'PiYG');
ANGLE_COLORS(1,:) = brm(1,:);
ANGLE_COLORS(2,:) = brm(10,:);
ANGLE_COLORS(3,:) = brm(9,:);


%%% try using unweighted fit as initialisation for weighted one, add nneg

modellist = ["dipoledipolesq","diffu"];%,"susc_diffu"];
save(sprintf('%s_avgR2.mat',comp), 'avgsr2w', 'stdavgr2','firstpoint','theta');
key = ["Model", "Fit parameters", "Fitparameters NL", "GOF R2, adj. R2", "mae"];
fitparam = {};
fitparamnl = {};
gofall = {};
mae = {};
fitaic = {};
fitaicc = {};
N = length(grps2fit);
logL = {};

legentry = {'Data'};
figure
x = linspace(0,90,100);
hold on


errorbar(theta, avgsr2w, stdavgr2, 'o','Color', 'black','MarkerFaceColor','black')

for i=1:length(modellist)
    [fitfunc, modelFunc, modelname,ini] = getmodel(modellist(i));
    modelshort = modellist(i);
    f = fittype(fitfunc); 
    if strcmp(modellist(i),'susc_diffu')
        ini = [0,0,0];
    else
        ini = [0,0];
    end
    nlm1 = fitnlm(grps2fit,avgsr2fit.',modelFunc,ini,'Weight', weightsmfit);

    if strcmp(modellist(i),'dipoledipolesq')
        legentry{end+1} = '$R_2=R_{2,i}+R_{2,a}(3\cos^2\theta-1)^2$';
        col = ANGLE_COLORS(1,:);
        width = 2;
        styl = '-';
    elseif strcmp(modellist(i),'susc_diffu')
        legentry{end+1} = '$R_2=R_{2,i}+R_{2,a}\sin^4\theta+ R_{2,b}\sin^2\theta$';
        col = ANGLE_COLORS(3,:);
        width = 2;
        styl = '--';
    elseif strcmp(modellist(i),'diffu')
        legentry{end+1} = '$R_2=R_{2,i}+R_{2,a}\sin^4\theta$';
        col = ANGLE_COLORS(2,:);
        width = 2;
        styl = '-';
    end
    
    fitnl = nlm1.Coefficients.Estimate;
    p = length(fitnl);
    yfnl = modelFunc(fitnl,x); 

%%% Plotting fit     
   
    plot(x,yfnl, 'LineWidth', width,'LineStyle',styl,'Color',col);
    predfnl = modelFunc(fitnl, grps2fit);

%%% Calculation of gof parameters    
    maefnl = calcmae(predfnl, avgsr2fit);
   
    adjR2 = nlm1.Rsquared.Adjusted;
    loglik = nlm1.LogLikelihood;
    fitparamnl{end+1} = fitnl;
    gofall{end+1} = adjR2;
    mae{end+1} = maefnl;
    fitaic{end+1} = -2*loglik+2*p;
    fitaicc{end+1} = fitaic{end}+(2*p^2+2*p)/(N-p-1);

    logL{end+1} = loglik;
    C(i).modelname = modellist(i);
    C(i).fitparamnl = fitnl;
    C(i).adjR2 = adjR2;
    C(i).maefnl = maefnl;
    C(i).logL = loglik;
    C(i).aicnlm = fitaic{end};
    C(i).aiccnlm = fitaicc{end};
    C(i).bicnlm = -2*loglik+p*log(N);
end

ax = gca;
ax.FontSize = 16;
xlim([0,90]);
xlabel('Angle (degree)','FontSize',16)

if strcmp(comp,'sgm');
    ylab = 'Myelin Water $R_2$ (Hz)';
elseif strcmp(comp,'mgm')
    ylab = 'Intra- and Extracellular Water $R_2$ (Hz)'
%     legend(legentry, 'Location', 'northeast','FontSize',16);

else
    ylab = '$R_2$'
end
set(0,'DefaultAxesFontName','Arial')
ylabel(ylab,'FontSize',16)

set(gca,'FontName','Arial');

filepref = "fit_all_";

figname = sprintf('%s_Avg_%s.fig',filepref,comp);

saveas(gcf, figname);

figname = sprintf('%s_Avg_%s.png',filepref,comp);
saveas(gcf, figname);

figname = sprintf('%s_Avg_%s.pdf',filepref,comp);
saveas(gcf, figname);

figname = sprintf('%s_Avg_%s.eps',filepref,comp);
saveas(gcf, figname);

save(sprintf('Fitdata_%s.mat',comp), 'C');
pwd

end