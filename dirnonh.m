function namelist = dirnonh(folder)

%returns all folders in a given directory 
fullist = dir(folder);
fullist = fullist([fullist(:).isdir]);
lenlist = length(fullist);
namelist = [];
for i=1:lenlist
    name = fullist(i).name;
    if name ~= '.' & ~startsWith(name, '__');
       namelist = [namelist ; {name}];
    end
end
end

        
        
