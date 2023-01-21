% R2* mapping code -- based on Christian Denk's code
% created by Vanessa Wiggermann, 21st April 2015

%this code does not include background field corrections but rather accepts
%corrected magnitude images (corrected before running this code)

function [r2star] = calculate_R2star(mag,brain_mask,header)

    disp('+ Calculate R2* Map ...')
    gyro=42576;
    tic;
    r2star=zeros(size(brain_mask));
    %data.mag=reshape(mag,header.matrix(1),header.matrix(2),header.matrix(3),header.nechoes);
    data.mag = mag;
    if header.echotimes(1) == 0
        TE = header.echotimes(2:end);
    else
        TE = header.echotimes(2:end);
    end
    % Calculation of the R2* by linear fitting - Modified to linear
    % fitting July 6th
    indMask = find(brain_mask);
    Y = zeros(length(TE)-1, length(indMask));
    for k = 1:length(TE)
        slT = data.mag(:,:,:,k);
        Y(k, :) = slT(indMask);
    end
    % uses \ to solve TE*bt=log(Y)
    bt = [ones(size(TE))' TE']\log(Y);
 
    r2star(indMask) = -1000*bt(2, :);    
    
    
%     for sl=1:header.matrix(3)
%         for y=1:header.matrix(2) 
%             for x=1:header.matrix(1)   
%                     if brain_mask(x,y,sl) ~= 0 % && sl >= min(r2_slices) && sl <= max(r2_slices)
% 
%                         S=double(reshape(mag(x,y,sl,:),1,header.nechoes))';
%                         
%                         % fit first guess parameters
%                         paramEsts=[S(1)*1.2 0.025];
%                         % linear fit function
%                         linFUN = @(p) (p(1).*exp(-(TE(:).*p(2))))-S;
% 
%                         % call function and fit to single voxel time
%                         % evolution
%                         [fit,ssq,cnt] = LMFnlsq(linFUN,paramEsts);
%                         
%                         S0(x,y,sl)=fit(1);
%                         r2star(x,y,sl)=fit(2);
% 
%                     else
%                         S0(x,y,sl)=0;
%                         r2star(x,y,sl)=0;
% 
%                     end
% 
%             end
% 
%         end
%         disp(sl)
% 
%     end
%     r2star=r2star.*1000;

    timer_r2star=toc;
    disp(round(timer_r2star))
    disp('.... finished')

end