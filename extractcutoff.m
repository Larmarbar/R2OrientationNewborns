function cutoff = extractcutoff(params)
 cutoff = extractAfter(params,'MPWIN_');
 cutoff = extractAfter(params,'_');
end 
