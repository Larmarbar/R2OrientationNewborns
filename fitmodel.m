function fitmodel(theta, avgT2, stdavgT2, numvox, firstpoint, comp)
% R2 average value
avgsr2w = 1./avgT2;

avgsr2fit = 1./(avgT2(firstpoint:end));


grps2fit = theta(firstpoint:end);

% Error on R2 average, simple error propagation from T2 error

stdavgr2 = (1./avgT2.^2).*stdavgT2; 

stdavgr2fit = stdavgr2(firstpoint:end);

% Weights for R2 values
weightsmfit = 1./(stdavgr2fit.^2);

numvox = numvox(firstpoint:end)
% pause
weightsvoxfit = numvox/sum(numvox)


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

N = length(grps2fit);

legentry = {'Data'};
figure
x = linspace(0,90,100);
hold on

% Add data to plot
errorbar(theta, avgsr2w, stdavgr2, 'o','Color', 'black','MarkerFaceColor','black')

for i=1:length(modellist)
    [fitfunc, modelFunc, modelname,ini] = getmodel(modellist(i));
    modelshort = modellist(i);
    f = fittype(fitfunc); 
    if strcmp(modellist(i),'susc_diffu')
        lowb = [0,-Inf,0];
        ini = [0,0,0];
    else
        lowb = [0,0];
        ini = [0,0]
    end
    
%     if strcmp(modellist(i), 'dipoledipolesq')
%         star = [10,2]
%     end    dataset = 'neon' 

    
    [fit1,gof,fitinfo] = fit(grps2fit,avgsr2fit.',f,'Weight', weightsvoxfit, 'Lower', lowb);
    nlm1 = fitnlm(grps2fit,avgsr2fit.',modelFunc,ini,'Weight', weightsvoxfit);

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

    fitcoeff = coeffvalues(fit1);
    yf = modelFunc(fitcoeff,x);
    
%%% Plotting fit     
   
    plot(x,yf, 'LineWidth', width,'LineStyle',styl,'Color',col);
    predf = modelFunc(fitcoeff, grps2fit);
    predfnl = modelFunc(fitnl, grps2fit);
    
%%% Calculation of gof parameters    
    % first for regular fit function 
    maef = calcmae(predfnl, avgsr2fit);
    loglikfit = -N*log(gof.sse/N);
    fitaic = -2*loglikfit+2*p;
    fitaicc = fitaic+(2*p^2+2*p)/(N-p-1);

    
    % Then nonlinear fit function fitnlm
    logliknl = nlm1.LogLikelihood;
    aic_nl = -2*logliknl+2*p;
    aicc_nl = aic_nl+(2*p^2+2*p)/(N-p-1);
    
    C(i).modelname = modellist(i);
    
    C(i).fitparamf = fitcoeff;
    C(i).adjR2f = gof.adjrsquare;
    C(i).maef = maef;
    C(i).aic = fitaic;
    C(i).aicc = fitaicc;
    C(i).bic = -2*loglikfit+p*log(N);
    
    C(i).fitparamnl = fitnl;
    C(i).logLnlm = logliknl;
    C(i).aic_nl = aic_nl;
    C(i).aicc_nl = aicc_nl;
    C(i).bic_nl = -2*logliknl+p*log(N);

end

ax = gca;
ax.FontSize = 16;
xlim([0,90]);
xlabel('Angle (degree)','FontSize',16)

if strcmp(comp,'sgm');
    ylab = 'Myelin Water $R_2$ (Hz)';
%     ylim([81,98]);
elseif strcmp(comp,'mgm')
    ylab = 'Intra- and Extracellular Water $R_2$ (Hz)'
%     ylim([11.0,12.5]);
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