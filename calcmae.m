function mae = calcmae(pred, ydata)
%%% calculate mean absolute error 
diff = ydata - pred';
diff = abs(diff);
mae = mean(diff);
end