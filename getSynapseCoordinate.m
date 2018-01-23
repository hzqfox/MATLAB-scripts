function getSynapseCoordinate( path )


    if nargin == 0
        if evalin('base','exist(''path'',''var'')')
            path = evalin('base','path');
        else 
            path = uigetdir('Select the folder containing input data','D:\Program Files\MATLAB\ImageProcessing\Synapse_Segmentation');
        end
    end
    
    
    
    
end

