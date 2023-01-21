 function [fitfun, modelFunc, modelname, ini] = getmodel(model)
%%% get function, initial parameters for fit of model
    
% dipole-dipole interaction Magic Angle model
if strcmp(model, 'dipoledipolesq')
    fitfun = 'a+b*(3*(cos(x/360*2*pi)).^2-1).^2'; 
    modelFunc = @(a,x) a(1)+a(2)*(3*(cos(x/360*2*pi)).^2-1).^2;
    modelname = "Dipole-dipole model";
    ini = [0,0];
% Knight Model including a diffusion and a grad interaction term
elseif strcmp(model, 'susc_diffu')
    fitfun = 'a+b*(sin(x/360*2*pi)).^2+c*(sin(x/360*2*pi)).^4';
    modelFunc = @(a,x) a(1)+a(2).*(sin(x/360*2*pi)).^2+a(3).*(sin(x/360*2*pi)).^4;
    modelname = "Knight model";
    ini = [0,0,0];
% only the grad interaction term (from Knight model)    
elseif strcmp(model, 'susc')
    fitfun = 'a+b*sin(x/360*2*pi).^2';
    modelFunc = @(a,x) a(1)+a(2).*(sin(x./360*2*pi)).^2;
    modelname = "MagnSusc";
    ini = [0,0];
% only diffusion model (should dominate) from Knight model    
elseif strcmp(model, 'diffu')
    fitfun = 'a+b*sin(x/360*2*pi).^4';
    modelFunc = @(a,x) a(1)+a(2)*(sin(x/360*2*pi)).^4;
    modelname = "Diffusion model";
    ini = [0,0];

elseif strcmp(model, 'linear')
    fitfun = 'a-b*x';
    modelFunc = @(a,x) a(1)-a(2)*x;
    modelname = "linear";
    ini = [0];    

elseif strcmp(model, 'combined')
    fitfun = 'a+b*sin(x/360*2*pi).^4+c*(3*(cos(x/360*2*pi)).^2-1).^2';
    modelFunc = @(a,x) a(1)+a(2)*(sin(x/360*2*pi)).^4+a(3)*(3*(cos(x/360*2*pi)).^2-1).^2;
    modelname = "Combined model";
    ini = [0,0,0];

end

