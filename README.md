# R2OrientationNewborns
Analysis Code for study of R2 orientation dependence in brain MRI of human newborns


Matlab Analysis Code written for an analysis of pre-processed brain MRI data of datasets of newborns and adult subjects. 
The Code loops over folders corresponding to subjects. For each subject the R2 times obtained from a multi-exponential decomposition using the decaes tool (https://jondeuce.github.io/DECAES.jl/dev/) are binned according to the local fiber orientation angle to the main magnetic field of the scanner. Measurements of local fiber direction are obtained from DTI using the fsl dtifit tool (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide). 
The binned data is then averaged over all subjects. 

Starting point was code written by Alexander M. Weber  (doi:10.1002/nbm.4222)
The code for plotting the angle dependent T2 distributions was adapted based on work by Jon Doucette 
