function [statarray,orientation,grps2,stdv,numvox,sem,indx] = r2starorien(v1,wmmask,r2star,FA)

%% Unzip and read files 
v1load = niftiread_unzip(v1);
wmmaskload = niftiread_unzip(wmmask);
r2starload = niftiread_unzip(r2star);
FAload = niftiread_unzip(FA);

%% Adjust V1 shape 
v1size=size(v1load);

numvoxels = v1size(1)*v1size(2)*v1size(3);
newv1 = [reshape(v1load(:,:,:,1),numvoxels,1) reshape(v1load(:,:,:,2),numvoxels,1) reshape(v1load(:,:,:,3),numvoxels,1)];

%% Find indices of WM voxels from mask
indx=find(wmmaskload(:)>0.5);

%% Apply mask to V1 and R2(*), set B0 direction
anglemasked=[newv1(indx,1) newv1(indx,2) newv1(indx,3)];
b0=zeros(size(anglemasked));
b0(:,3)=1;  % set B0 along z direction 

if isfile('../BASELINE/B0_VoxelSpace.mat')
    load('../BASELINE/B0_VoxelSpace.mat');
    b0(:,1) = B0x;
    b0(:,2) = B0y;
    b0(:,3) = B0z;
end

    
R2masked = r2starload(indx);
numvoxels=length(indx); % #voxels in mask

tic

%% Calculate angle between V1 and B0
for a = 1:numvoxels
    anglev1b0(a) = atan2(norm(cross(anglemasked(a,:),b0(a,:))),dot(anglemasked(a,:),b0(a,:)));
end
toc

R2masked=R2masked';

orientation=[rad2deg(anglev1b0); R2masked];
orientation=orientation';

%% Bin data 
deginc = 5; %2 
edges = 0:deginc:180;
length(edges);
[~,bin]=histc(orientation(:,1),edges);
orientation(:,3)=bin*deginc;

%% Map angles >90 deg into 0-90 range 

for m=1:length(indx)
    if orientation(m,3) <= 90
        orientation(m,4) = orientation(m,3)-deginc/2;
    else
       orientation(m,4) = 180-orientation(m,3)+deginc/2;
    end
end


%% Group R2(*) data by corresponding angle bins 
% Also calculates stdev, numvox and sem for each bin
[statarray,grps,stdv,numvox,sem]=grpstats(orientation(:,2),orientation(:,4),{'mean','gname', 'std', 'numel', 'sem'});


grps2=str2double(grps);
err = sem;

%% Option to exclude bins with few voxels

firstpoint = 1; 
statarray = statarray(firstpoint:end);
grps2 = grps2(firstpoint:end) ;
stdv = stdv(firstpoint:end) ;
numvox = numvox(firstpoint:end);
sem = sem(firstpoint:end)

end
