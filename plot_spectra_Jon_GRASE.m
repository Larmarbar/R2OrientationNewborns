function plot_spectra_Jon_GRASE(dataset, inipath)
PROCESS_AND_LOAD_DATA = true;

if PROCESS_AND_LOAD_DATA
cd(inipath);
load('log.mat');
if contains(dataset,'hockey')
    dataset = 'adult';
end

mkdir('T2spectra');
    load('data.mat');
    mask = {};
    dist = {};
    wm = {};
    v1 = {};
    for i=1:numpat
        mask{1,i} = data.mask_path{i}; 
        dist{1,i} = data.dist_path{i}; 
        wm{1,i} = data.wm_path{i}; 
        v1{1,i} = data.v1_path{i}; 
    end
    
    GRASE_files = struct('mask_path', mask, 'dist_path', dist, 'wm_path', wm, 'v1_path',v1);

    
for i=1:numel(GRASE_files)
        % Look at subset of subjects
        GRASE_file = GRASE_files(i) 

         for ii = 1:numel(GRASE_file)
             GRASE_data(ii) = plot_spectra_Jon_prep(GRASE_file(ii),i);
         end

        % load T2 times for distribution
        load(GRASE_file.dist_path, 't2times');
        T2_times_40 = t2times;

     % PROCESS_AND_LOAD_DATA
    BRAIN_files = struct('mask_path', mask, 'dist_path', dist, 'wm_path', mask, 'v1_path',v1);
    % 
    BRAIN_files = BRAIN_files(i); 

        for ii = 1:numel(BRAIN_files)
            GRASE_brain(ii) = plot_spectra_Jon_prep(BRAIN_files(ii),i+10);
        end


    normalize_per_subject = @(x) x ./ max(x, [], 2);
    average_per_subject = @(x) mean(x, 3); 
    normalize_cumsum_average_per_subject = @(x) normalize_per_subject(cumsum(average_per_subject(x), 2));

    grase_distribution_mean = average_per_subject(cat(3, GRASE_data.dist_mean));

    grase_distribution_cumsum = normalize_cumsum_average_per_subject(cat(3, GRASE_data.dist_mean));

    grase_distribution_WM = average_per_subject(cat(3, GRASE_data.dist_WM));


    brain_distribution_mean = average_per_subject(cat(3, GRASE_brain.dist_mean));

    brain_distribution_cumsum = normalize_cumsum_average_per_subject(cat(3, GRASE_brain.dist_mean));

    brain_distribution_WM = average_per_subject(cat(3, GRASE_brain.dist_WM));


    ANGLE_COLORS = jet(9); %jd
    NO_LEGEND = @(h) set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    grase_total_signal_per_angle = sum(grase_distribution_mean, 2);
    grase_relative_signal_per_angle = max(grase_total_signal_per_angle) ./ grase_total_signal_per_angle; % scale smaller signal bins up; this ensures t2 distbn differences aren't due to having smaller signals in different angle bins just by chance
    grase_scale_factor_per_angle = grase_relative_signal_per_angle ./ max(grase_distribution_mean(:)); % whole distbn scale factor to get final distbn units O(1)

    brain_total_signal_per_angle = sum(brain_distribution_mean, 2);
    brain_relative_signal_per_angle = max(brain_total_signal_per_angle) ./ brain_total_signal_per_angle; % scale smaller signal bins up; this ensures t2 distbn differences aren't due to having smaller signals in different angle bins just by chance
    brain_scale_factor_per_angle = brain_relative_signal_per_angle ./ max(brain_distribution_mean(:)); % whole distbn scale factor to get final distbn units O(1)


    %--------------------------------------------------------------------------
    % Plot global WM distribution of all sequences
    %--------------------------------------------------------------------------

    nIDs = 6; 
    alphabet = ('A':'Z').';
    chars = num2cell(alphabet(1:nIDs));
    charlbl = strcat('(',chars,')');


    figure(1)
    subplot(1,2,1)
    plot(T2_times_40',grase_distribution_WM./max(grase_distribution_WM),'-o','color',[0.64 0.08 0.18],'LineWidth',1,'MarkerSize',8) %jd
    hold on

    plot(T2_times_40',brain_distribution_WM./max(brain_distribution_WM),'-*','color',[0.44 0.28 0.18],'LineWidth',1,'MarkerSize',8)
    hold on
    set(gca, 'XScale', 'log')
    xlim([0.008 2])
    ylim([0 1.1])
    xlabel('$T_2$ times (s)','FontSize',16)
    ylabel('Intentsity','FontSize',16)
    hold on
    NO_LEGEND(plot([0.04, 0.04], ylim,'--','LineWidth',2,'Color','black'));
    hold on
    plot([0.025, 0.025], ylim,'--','LineWidth',2,'Color','black'); % one legend entry
    grid on
    hleg = legend('GRASE','$T_2$ cut-off');

    subplot(1,2,2)
    plot(T2_times_40',grase_distribution_WM./max(grase_distribution_WM),'-o','color',[0.64 0.08 0.18],'LineWidth',1,'MarkerSize',8) %jd
    hold on
    plot(T2_times_40',brain_distribution_WM./max(brain_distribution_WM),'-o','color',[0.64 0.08 0.18],'LineWidth',1,'MarkerSize',8)
    hold on

    
    set(gca, 'XScale', 'log')
    xlim([0.008 0.06])
    ylim([0 0.21])
    xlabel('$T_2$ times (s)','FontSize',16)
    ylabel('Intentsity','FontSize',16)
    hold on
    NO_LEGEND(plot([0.04, 0.04], ylim,'--','LineWidth',2,'Color','black'));
    hold on
    plot([0.025, 0.025], ylim,'--','LineWidth',2,'Color','black'); % one legend entry
    grid on
    hleg = legend('GRASE TR = 1073 ms','$T_2$ cut-off');
    
    set(gcf, 'Position', [100,100,700,400]);

    figname = sprintf('T2spectra/T2spec_%s_%d.png',dataset,i);
    saveas(gcf, figname);
    figname = sprintf('T2spectra/T2spec_%s_%d.fig',dataset,i);
    saveas(gcf, figname);

    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------


    h2 = figure(2)
    set(h2,'Resize','off')
    set(h2, 'Position', [1000,200,800,600]);
    set(h2,'color','w')
    subplot(2,1,1)
    hold on
    for ii = 1:9

        plot(T2_times_40',grase_distribution_mean(ii,:) .* grase_scale_factor_per_angle(ii),'-o','color',ANGLE_COLORS(ii,:), 'MarkerFaceColor',ANGLE_COLORS(ii,:),'LineWidth',1.5) %jd
    end
    set(gca, 'XScale', 'log')
    xlim([0.008 2])
    ylim([0 1.1])

    hold on
    plot([0.025, 0.025], ylim,'--','LineWidth',2,'Color','black');
    plot(T2_times_40',mean(grase_distribution_mean)./max(grase_distribution_mean(:)),'-','color','black','LineWidth',2,'MarkerSize',8)


    ax = gca;
    ax.FontSize = 16;
    xlabel('$T_2$ times (s)','FontSize',22)
    ylabel('Intentsity','FontSize',22)
    if contains(dataset, 'baseline')
        hleg = legend('0-10$^\circ$','10-20$^\circ$','20-30$^\circ$','30-40$^\circ$','40-50$^\circ$','50-60$^\circ$','60-70$^\circ$','70-80$^\circ$','80-90$^\circ$','$T_2$ cut-off','Mean WM'); set(hleg, 'FontSize', 16,'NumColumns',2);
    end
    grid on

    subplot(2,1,2)
    for ii = 1:9
        plot(T2_times_40',brain_distribution_mean(ii,:)./max(brain_distribution_mean(:)),'-o','color',ANGLE_COLORS(ii,:), 'MarkerFaceColor',ANGLE_COLORS(ii,:),'LineWidth',2) %jd
        hold on
    end
    set(gca, 'XScale', 'log')
    xlim([0.008 0.05])
    ylim([0 0.21])

    % Plot Cut off
    hold on
    plot([0.025, 0.025], ylim,'--','LineWidth',2,'Color','black');

    ax = gca;
    ax.FontSize = 16;

    xlabel('$T_2$ times (s)','FontSize',22)
    ylabel('Intentsity','FontSize',22)
    grid on

    hold on
    plot(T2_times_40',mean(grase_distribution_mean)./max(grase_distribution_mean(:)),'-','color','black','LineWidth',2,'MarkerSize',8)
    figname = sprintf('T2spectra/T2spec_angles_%s_%d.png',dataset,i);
    saveas(gcf, figname);
    figname = sprintf('T2spectra/T2spec_angles_%s_%d.fig',dataset,i);
    saveas(gcf, figname);
    figname = sprintf('T2spectra/T2spec_angles_%s_%d.svg',dataset,i);
    saveas(gcf, figname);
    figname = sprintf('T2spectra/T2spec_angles_%s_%d.eps',dataset,i);
    saveas(gcf, figname);
    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------


    fig3 = figure(3);
    subplot(2,1,1)
    for ii = 1:9
        plot(T2_times_40',grase_distribution_cumsum(ii,:),'-o','color',ANGLE_COLORS(ii,:)) %jd
        hold on
    end

    set(gca, 'XScale', 'log')
    xlim([0.008 2])
    ylim([0 1.1])

    % Plot Cut off
    hold on
    NO_LEGEND(plot([0.04, 0.04], ylim,'--','LineWidth',2,'Color','black'));
    hold on
    plot([0.025, 0.025], ylim,'--','LineWidth',2,'Color','black');

    hold on
    plot(T2_times_40',mean(grase_distribution_cumsum),'-','color','black','LineWidth',2,'MarkerSize',8)

    xlabel('$T_2$ times (s)','FontSize',16)
    ylabel('Intentsity','FontSize',16)
    hleg = legend('0-10$^\circ$','10-20$^\circ$','20-30$^\circ$','30-40$^\circ$','40-50$^\circ$','50-60$^\circ$','60-70$^\circ$','70-80$^\circ$','80-90$^\circ$','$T_2$ cut-off','Mean'); set(hleg, 'FontSize', 13);
    grid on

    subplot(2,1,2)
    for ii = 1:9
        plot(T2_times_40',grase_distribution_cumsum(ii,:),'-o','color',ANGLE_COLORS(ii,:)) %jd
        hold on
    end

    set(gca, 'XScale', 'log')
    xlim([0.008 0.05])
    ylim([0 0.21])

    % Plot Cut off
    hold on
    plot([0.04, 0.04], ylim,'--','LineWidth',2,'Color','black');
    hold on
    plot([0.025, 0.025], ylim,'--','LineWidth',2,'Color','black');

    xlabel('$T_2$ times (s)','FontSize',16)
    ylabel('Intentsity','FontSize',16)
    grid on

    hold on
    plot(T2_times_40',mean(grase_distribution_cumsum),'color','black','LineWidth',2,'MarkerSize',8)

    figname = sprintf('T2spectra/T2spec_cumulative_%s_%d.png',dataset,i);
    saveas(fig3, figname);

    figname = sprintf('T2spectra/T2spec_cumulative_%s_%d.fig',dataset,i);

    saveas(fig3, figname);
    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------


    markers = {'-+','-o','-*','-x','-v','-d','-^','-s','->'};
    
    close all;
end


end
