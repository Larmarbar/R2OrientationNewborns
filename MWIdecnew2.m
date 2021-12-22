function [V1data, WMmask, brainmaskpath]=MWIdec(patfolder, outpath, parameters, codepath, dataset) 
 %%% 
 %% Create and load all nii files, run orientation dependence scipt on DTI and decaes output 
 %%%
 
 % Inside patient data folder create new folder for output of current 
 % analysis and change into the output folder
 cd(patfolder);
 str = pwd;
 [~,pname] = fileparts(str);
 mkdir(parameters);
 cd(parameters);
 
 %%% get location of decaes output .t2parts and t2maps 
 
 % set voxelsize for nii creation
 if strcmp(dataset,'twoweeks') || contains(dataset, 'baseline')
    % Read GRASE data first as name needed to get header
     if contains(dataset, 'baseline')
         subdir = 'BASELINE';
     else 
         subdir = '2WEEKS';
     end
     

   
     header.matrix = [240,240,32];
     grasn = sprintf('../%s/mergedGRASE_bet.nii.gz', subdir)
     grase = niftiread_unzip(grasn);

     grasebet = sprintf('../%s/mergedGRASE_bet_mask.nii.gz',subdir);

     gunzip(grasebet);
     brainmaskload = niftiread(grasebet(1:end-3));
     graseinfo = niftiinfo(grasn)
     decinfo = graseinfo;
     voxelsize = graseinfo.PixelDimensions(1:3); 

     decinfo.PixelDimensions = graseinfo.PixelDimensions(1:3); 
     decinfo.ImageSize = graseinfo.ImageSize(1:3);

     decinfo.Datatype = 'double';
     decinfo = rmfield(decinfo, 'Filename');
     decinfo = rmfield(decinfo, 'Filesize');

     decinfo = rmfield(decinfo, 'BitsPerPixel');
       
 elseif strcmp(dataset,'neon')
    load('../MWI_matlab.mat', 'hdr');
    voxelsize = hdr.voxelsize;
    grasn = dir(['../Series*T2W*'])
    grasn = sprintf('../%s/merged.nii', grasn.name)
    grase = niftiread(grasn);
    graseinfo = niftiinfo(grasn);
    voxelsize = graseinfo.PixelDimensions(1:3);
    header.matrix = [240,240,32];
    grasebet = '../GRASE_median_bet_mask.nii.gz';
    gunzip('../GRASE_median_bet_mask.nii.gz');
    brainmaskload = niftiread('../GRASE_median_bet_mask.nii');
     decinfo = graseinfo;

     decinfo.PixelDimensions = graseinfo.PixelDimensions(1:3); 
     decinfo.ImageSize = graseinfo.ImageSize(1:3);

     decinfo.Datatype = 'double';
     decinfo = rmfield(decinfo, 'Filename');
     decinfo = rmfield(decinfo, 'Filesize');

     decinfo = rmfield(decinfo, 'BitsPerPixel');
 end
 
 %%% get decaes output filenames 
 partsfile = dir('*t2parts.mat');
 partsfile = partsfile(1).name;
 mapfile = dir('*t2maps.mat');
 mapfile = mapfile(1).name;
 distfile = dir('*t2dist.mat');
 distfile = distfile(1).name;

 %%% Load T2parts and make nii 
 parts = load(partsfile); 
 
 %%% Load T2maps and save as nii 
 mapfile = dir('*t2maps.mat');
 mapfile = mapfile(1).name;
 MWImap = load(mapfile); 

 size(MWImap.ggm)
 niftiwrite(MWImap.ggm, 'GGM_dec', decinfo);
 niftiwrite(parts.mgm, 'MGM_dec', decinfo);
 niftiwrite(parts.sgm, 'SGM_dec', decinfo);
 niftiwrite(parts.sfr, 'SFR_dec', decinfo);

 
 %%% create and save nii for T2 distribution
 load(distfile);
 mkdir('distnii');
 cd('distnii');
 distsize = size(dist)
 for i=1:distsize(4)
     distnii = make_nii(dist(:,:,:,i), voxelsize);
     save_nii(distnii, sprintf('dist_%i_dec.nii',i));
 end
 cd('..');
 currpath = pwd;

 
 %%% Set Input Nii files for decaes, DTI and mask data 
 
  if strcmp(dataset, 'neon') 
      % set which GRASE echo etc was used for registration
    refgrase = 'GRASEmedian';
    GGMdata = 'GGM_dec.nii';
    MGMdata = 'MGM_dec.nii';
    SGMdata = 'SGM_dec.nii';
    SFRdata = 'SFR_dec.nii';
    
    V1data = sprintf('../dtifit_V1_to_%s.nii.gz',refgrase);
    FAdata = sprintf('../FA_to_%s.nii.gz',refgrase);
    RDdata = sprintf('../dtifit_RD_to_%s.nii.gz',refgrase);
    MDdata = sprintf('../dtifit_MD_to_%s.nii.gz',refgrase);
    L1data = sprintf('../dtifit_L1_to_%s.nii.gz',refgrase);
     
    WMmask = '../WM_mask_FA_fast.nii.gz';
    brainmaskpath = '../GRASE_median_bet_mask.nii.gz';

 elseif contains(dataset, 'baseline') | contains(dataset, 'twoweeks')
     % set which GRASE echo etc was used for registration
     
    refgrase = 'GRASE0';

    GGMdata = 'GGM_dec.nii';
    MGMdata = 'MGM_dec.nii';
    SGMdata = 'SGM_dec.nii';
    SFRdata = 'SFR_dec.nii';
     
    V1data = sprintf('../%s/dtifit_V1_to_%s.nii.gz', subdir, refgrase);
    FAdata = sprintf('../%s/dtifiteddy_FA_to_%s.nii.gz', subdir, refgrase);
    RDdata = sprintf('../%s/dtifiteddy_RD_to_%s.nii.gz', subdir, refgrase);
    MDdata = sprintf('../%s/dtifiteddy_MD_to_%s.nii.gz', subdir, refgrase);
    L1data = sprintf('../%s/dtifiteddy_L1_to_%s.nii.gz', subdir, refgrase);
    WMmask = sprintf('../%s/WM_mask_T1.nii.gz',subdir);
    brainmaskpath = sprintf('../%s/mergedGRASE_bet_mask.nii.gz',subdir);

 end
 
 %%% RUN ORIENTATION SCRIPT AND PLOT FOR DECAES OUTPUT...
runoronepar(V1data, WMmask, MGMdata, 'mgm', FAdata,pname);
runoronepar(V1data, WMmask, SGMdata, 'sgm', FAdata,pname);
runoronepar(V1data, WMmask, GGMdata, 'ggm', FAdata,pname);
runoronepar(V1data, WMmask, SFRdata, 'sfr', FAdata,pname);
close all 


end 