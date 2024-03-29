function plotr2overview(parameters, patfolder, dataset)
%%% Plots overlay of the V1, WM mask and output from decaes (r2starload)

 % Inside patient data folder create new folder for output of current 
 % analysis and change into the output folder
 cd(patfolder);
 str = pwd;
 [~,pname] = fileparts(str);
 mkdir(parameters);
 cd(parameters);
      
  if strcmp(dataset, 'neon') 
      lmargin = 55;%45%25;
      rmargin = 55;
      tmargin = 45;
      bmargin = 75;
      slice = 11;
      % set which GRASE echo etc was used for registration
     refgrase = 'GRASEmedian';
     GGMdata = 'GGM_dec.nii';
     MGMdata = 'MGM_dec.nii';
     SGMdata = 'SGM_dec.nii';
     SFRdata = 'SFR_dec.nii';
     
     V1data = sprintf('../dtifit_V1_to_%s.nii.gz',refgrase);
     FAdata = sprintf('../FA_to_%s.nii.gz',refgrase);
     
     WMmask = '../WM_mask_FA_thr15_edit.nii.gz';
     brainmask = niftiread_unzip('../GRASE_median_bet_mask.nii.gz');

 elseif contains(dataset, 'baseline') | contains(dataset, 'twoweeks')
     rmargin = 25;%45%25;
     lmargin = 25;%45%25;
     bmargin = 1;%45%25;
     tmargin = 10;%45%25;
     slice = 10;

     % set which GRASE echo etc was used for registration
     if contains(dataset, 'baseline')
         subdir = 'BASELINE';
     else 
         subdir = '2WEEKS';
     end
     refgrase = 'GRASE0';

     GGMdata = 'GGM_dec.nii';
     MGMdata = 'MGM_dec.nii';
     SGMdata = 'SGM_dec.nii';
     SFRdata = 'SFR_dec.nii';
     
     T1data = sprintf('../%s/T1_to_%s.nii.gz', subdir, refgrase);
     
     V1data = sprintf('../%s/dtifit_V1_to_%s.nii.gz', subdir, refgrase);
     FAdata = sprintf('../%s/dtifiteddy_FA_to_%s.nii.gz', subdir, refgrase);
     
     WMmask = sprintf('../%s/WM_mask_T1.nii.gz',subdir);
     grasebet = sprintf('../%s/GRASE_e0_bet_mask.nii.gz',subdir);
     brainmask = niftiread_unzip(grasebet);
     %WMmask = brainmask;
  end


  

currdir = pwd;

%% select slice to be diplayed

v1load = niftiread_unzip(V1data);
v1slice = v1load(:,:,slice,:);
clear v1load;
FAload = niftiread_unzip(FAdata);
faslice = FAload(:,:,slice);
clear faload;

wmload = niftiread_unzip(WMmask);
wmslice = wmload(:,:,slice);
clear wmload;
mgmload = niftiread_unzip(MGMdata);
mgmslice = 1./mgmload(:,:,slice);
clear mgmload;
sgmload = niftiread_unzip(SGMdata);
sgmslice = 1./sgmload(:,:,slice);
clear sgmload;
mwfload = niftiread_unzip(SFRdata);
mwfslice = mwfload(:,:,slice);
clear mwfload;
brainslice = brainmask(:,:,slice);

%% set margins

sgmslice = rot90(sgmslice(lmargin:end-rmargin, bmargin:end-tmargin));
mgmslice = rot90(mgmslice(lmargin:end-rmargin, bmargin:end-tmargin));
mwfslice = rot90(mwfslice(lmargin:end-rmargin, bmargin:end-tmargin));
wmslice = rot90(wmslice(lmargin:end-rmargin, bmargin:end-tmargin));
v1slice = rot90(v1slice(lmargin:end-rmargin, bmargin:end-tmargin,:));
faslice = rot90(faslice(lmargin:end-rmargin, bmargin:end-tmargin));
brainslice = rot90(brainslice(lmargin:end-rmargin, bmargin:end-tmargin));
%wmslice = double(brainslice);

sgmslicewm = sgmslice .*wmslice;
mwfslicewm = mwfslice.*wmslice;
mwfslicebr = mwfslice.*double(brainslice);


%% Create Overlays  

nIDs = 6; 
alphabet = ('A':'Z').';
chars = num2cell(alphabet(1:nIDs));
charlbl = strcat('(',chars,')');
fntsz = 25;


close all
    
    h = figure('Color',[0,0,0],'InvertHardcopy','off');
    set(h,'Resize','off')
    set(h, 'Position', [200,200,600,600]);
    set(gca,'Color','k');
    set(gca,'XColor','none', 'YColor','none');

    ha = axes('Parent',h);
    max(mgmslice,[],'all');
    Range = [0,22];
    imshow(mgmslice, Range,'Parent',ha);
    colormap(h,inferno);
    cb = colorbar;
    
    cb.Ticks = Range;
    cb.TickLabels{1}= ['\color{white}','0 Hz'];
    cb.TickLabels{2}= ['\color{white}','22 Hz'];
    set(cb,'FontSize',fntsz);
    set(cb,'Location','southoutside');
    set(cb,'Position',[0.15,0.1,0.7,0.065]);
    axis off
    figname = 'MGM_map.png';
    saveas(gcf, figname);
    
    figname = 'MGM_map.svg';
    saveas(gcf, figname);
    
    
    h2 = figure('Color',[0,0,0],'InvertHardcopy','off')
    set(h2,'Resize','off')
    set(h2, 'Position', [200,200,600,600]);
    set(gca,'Color','k');
    set(gca,'XColor','none', 'YColor','none');
    Range = [40,125];
    ha = axes('Parent',h2)

    imshow(sgmslice, Range,'Parent',ha);
    cb = colorbar;
    colormap(h2,inferno);

    cb.Ticks = Range;
    cb.TickLabels{1}= ['\color{white}','40 Hz'];
    cb.TickLabels{2}= ['\color{white}','125 Hz'];
    set(cb,'FontSize', fntsz);
   set(cb,'Location','southoutside');
   set(cb,'Position',[0.15,0.1,0.7,0.065]);
   cb.Position

    hold on
    black = cat(3,zeros(size(sgmslice)), zeros(size(sgmslice)),zeros(size(sgmslice)));
    overl1 = imshow(black);
    set(overl1, 'AlphaData', 0.65*(1-wmslice))
    hold off

    figname = 'SGM_map.fig';
    saveas(gcf, figname);
    
    figname = 'SGM_map.png';
    saveas(gcf, figname);
    
    h3 = figure('Color',[0,0,0],'InvertHardcopy','off');
    set(h3,'Resize','off')
    set(h3, 'Position', [200,200,600,600]);
    set(gca,'Color','k');
    set(gca,'XColor','none', 'YColor','none');
    Range = [0,22];
    ha = axes('Parent',h3)

    imshow(mgmslice, Range,'Parent',ha);
    cb = colorbar;
    cb.Ticks = Range;
    cb.TickLabels{1}= ['\color{white}','0 Hz'];
    cb.TickLabels{2}= ['\color{white}','22 Hz'];
    colormap(h3,inferno);
   set(cb,'FontSize', fntsz);
   set(cb,'Location','southoutside');
   set(cb,'Position',[0.15,0.1,0.7,0.065]);
    hold on
    yellow = cat(3,ones(size(mgmslice)), ones(size(mgmslice)),zeros(size(mgmslice)));
    blue = cat(3,zeros(size(mgmslice)), ones(size(mgmslice)),ones(size(mgmslice)));
    green = cat(3,zeros(size(mgmslice)), ones(size(mgmslice)),zeros(size(mgmslice)));

    overl = imshow(blue);
    set(overl, 'AlphaData',wmslice)
    
    hold off
    
    figname = 'MGM_WM.fig';
    saveas(h3, figname);
    
    figname = 'MGM_WM.png';
    saveas(h3, figname);
    title('WM mask on MGM')

    h4 = figure('Color',[0,0,0],'InvertHardcopy','off');
    set(h4,'Resize','off')
    set(h4, 'Position', [200,200,600,600]);
    set(gca,'Color','k');
    set(gca,'XColor','none', 'YColor','none');
    Range = [0.0,0.2];
    ha = axes('Parent',h4)

    imshow(mwfslicebr, Range,'Parent',ha);
    cb = colorbar;
    cb.Ticks = Range;
    cb.TickLabels{1}= ['\color{white}','0 %'];
    cb.TickLabels{2}= ['\color{white}','20 %'];
    colormap(h4,winter);
   set(cb,'FontSize', fntsz);
   set(cb,'Location','southoutside');
   set(cb,'Position',[0.15,0.1,0.7,0.065]);     
    hold on

    black = cat(3,zeros(size(sgmslice)), zeros(size(sgmslice)),zeros(size(sgmslice)));
    white = cat(3,ones(size(sgmslice)), ones(size(sgmslice)),ones(size(sgmslice)));


    overl2 = imshow(black);
    set(overl2, 'AlphaData', 0.65*(~double(wmslice)));
    overl1 = imshow(black);
    set(overl1, 'AlphaData', ~double(brainslice))
    
    hold off
 

    figname = 'MWF_map.fig';
    saveas(gcf, figname);
    
    figname = 'MWf_map.png';
    saveas(gcf, figname);
    hold off

    h5 = figure('Color',[0,0,0],'InvertHardcopy','off')
    set(h5,'Resize','off')
    set(h5, 'Position', [200,200,600,600]);
    set(gca,'Color','k');
    set(gca,'XColor','none', 'YColor','none');
    Range = [0.0,1];
    ha = axes('Parent',h5)

    imshow(faslice, Range,'Parent',ha);

    cb = colorbar;
    cb.Ticks = Range;
    cb.TickLabels{1}= ['\color{white}','0'];
    cb.TickLabels{2}= ['\color{white}','1'];
   set(cb,'FontSize', fntsz);
   set(cb,'Location','southoutside');
   set(cb,'Position',[0.15,0.1,0.7,0.065]);

    figname = 'FA_map.fig';
    saveas(gcf, figname);
    
    figname = 'FA_map.png';
    saveas(gcf, figname);



end