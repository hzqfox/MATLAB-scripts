function XYZ = xLoad (xpath)

    if nargin < 1
        [FileName,PathName] =  uigetfile('*.xls','Select the Excel file contains coordinates','D:\Program Files\MATLAB\ImageProcessing\Synapse_Segmentation');
        xpath = strcat(PathName,FileName);
    end
    
    %timing function running duration
    disp('Loading coordinates...');tic;
    
    XYZ = xlsread(xpath,2);
        
    MakeMyVar('XYZ',XYZ);
    
    toc;
    
end