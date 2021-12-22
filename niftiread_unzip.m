function [unziped] = niftiread_unzip(filename)
%% check if nifti with filename exists
%% returns loaded file, unzips first if file compressed (.gz)
if exist(filename, 'file') == 2 

    if contains(filename, 'gz')
        gunzip(filename);
        unziped = niftiread(filename(1:end-3));
        delete(filename(1:end-3));
    else 
        unziped = niftiread(filename);      
    end
    
else 
    fprintf('The file %s does not exist \n', filename);
end

end