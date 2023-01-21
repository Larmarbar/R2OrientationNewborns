function data = plot_spectra_Jon_prep(data,patnum)

    function file = showfile(file)
        fprintf('Loading file: %s\n', file)
    end

    data.mask = niftiread_unzip(showfile(data.mask_path)); % load mask
    data.wm = niftiread_unzip(showfile(data.wm_path)); % load WM mask pev2
    data.v1 = niftiread_unzip(showfile(data.v1_path)); % load WM mask pev2
    data.dist = load(showfile(data.dist_path)); % T2 distribution

    % mask the images
    data.wm = double(data.wm) .* double(data.mask);	% WM mask
    data.wm(data.wm < 0.9)  = 0;
    data.wm(data.wm >= 0.9) = 1; %jd
    
    data.mask(data.mask < 0.9)  = 0;
    data.mask(data.mask >= 0.9) = 1; %jd
    data.dist = double(data.dist.dist) .* double(data.mask) .* data.wm;
    data.v1 = double(data.v1) .* double(data.mask);
    
    %select starting slice
    start_slice = 1; 
    data.wm = data.wm(:,:,start_slice:end);
    data.brain_mask = data.mask(:,:,start_slice:end);
    data.dist = data.dist(:,:,start_slice:end,:);
    data.v1 = data.v1(:,:,start_slice:end,:);

    % Calculation of T2 distribution mean over WM (%jd)
    %   - Previously, mean included many zero entries outside of the mask ('omitnan' does nothing; their are no NaNs)
    %   - This caused the mean to be biased, being smaller for distbns with smaller numbers of voxels, i.e. for lower angles
    %--------------------------------------------------------------------------

    flat_dist = reshape(data.dist, [], size(data.dist,4));
    flat_dist_WM = flat_dist(data.wm == 1, :);
    flat_dist_WM = flat_dist_WM(all(~isnan(flat_dist_WM), 2), :);
    data.dist_WM = mean(flat_dist_WM, 1);
    clear flat_dist flat_dist_WM

    % Calculation of Theta
    %--------------------------------------------------------------------------
    slice = 11; %16 or 12

%     lmargin = 25;
%     rmargin = 25;
%     tmargin = 10;
%     bmargin = 1;
    
    lmargin = 55;
    rmargin = 55;
    tmargin = 45;
    bmargin = 75;
    
    data.theta = data.v1(:,:,:,3);
    data.theta(data.theta == 0) = NaN;
    data.theta = acos(abs(data.theta))*180/pi;
    angslice = data.theta(lmargin:end-rmargin, bmargin:end-tmargin,slice);
    data.theta(data.wm(:) == 0) = NaN;

     
    fig = figure('Color',[0,0,0],'InvertHardcopy','off')
    set(fig,'Resize','off')
    set(fig, 'Position', [200,200,600,600]);
    set(gca,'Color','k');
    set(gca,'XColor','none', 'YColor','none');
    angslice = rot90(angslice);
    wmslice = rot90(data.wm(lmargin:end-rmargin, bmargin:end-tmargin));
    brainslice = rot90(data.brain_mask(lmargin:end-rmargin, bmargin:end-tmargin));
    Range = [0,90];
    set(gca,'Color','k');
    ha = axes('Parent',fig)

    imshow(angslice, Range,'Parent',ha);
    cb = colorbar;
    colormap(viridis)
    set(cb,'FontSize', 25);
   set(cb,'Location','southoutside');
   set(cb,'Position',[0.15,0.1,0.7,0.065]);    cb.Ticks = [0,45,90];
    cb.TickLabels{1}= ['\color{white}','0^{\circ}'];
    cb.TickLabels{2}= ['\color{white}','45^{\circ}'];
    cb.TickLabels{3}= ['\color{white}','90^{\circ}'];

    hold on
    white = 255*cat(3,ones(size(angslice)), ones(size(angslice)),ones(size(angslice)));
    black = cat(3,zeros(size(angslice)), zeros(size(angslice)),zeros(size(angslice)));
    overl1 = imshow(black);
    set(overl1, 'AlphaData', 0.65*(1-rot90(data.wm(lmargin:end-rmargin, bmargin:end-tmargin,slice))))
    overl2 = imshow(black);
    set(overl2, 'AlphaData', brainslice);
    hold off
 
    figname = sprintf('T2spectra/Angle_map_%d.fig',patnum);
    saveas(gcf, figname);
    
    figname = sprintf('T2spectra/Angle_map_%d.png',patnum);
    saveas(gcf, figname);
    
    
    
    for k1 = 1:9
        theta_mask = ~isnan(data.theta) & 10*(k1-1) <= data.theta & data.theta < 10*k1; %jd
        flat_dist = reshape(data.dist, [], size(data.dist,4));
        flat_dist_theta = flat_dist(theta_mask == 1, :);
        flat_dist_theta = flat_dist_theta(all(~isnan(flat_dist_theta), 2), :);
        data.dist_mean(k1,:) = mean(flat_dist_theta, 1);
        clear flat_dist flat_dist_theta
    end

end