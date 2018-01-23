function iLoad (ipath)

    if nargin < 1
        [FileName,PathName] =  uigetfile('*.tif','Select the FIBSEM image stack file','D:\Program Files\MATLAB\ImageProcessing\Synapse_Segmentation');
        ipath = strcat(PathName,FileName);
    end
    
    %timing function running duration
    disp('Loading segmentation image stack...');tic;
    
    TifLink = Tiff(ipath, 'r');
    InfoImage=imfinfo(ipath);
    
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);
    
    FinalImage=zeros(nImage,mImage,NumberImages,'uint8'); 
    for i=1:NumberImages
        TifLink.setDirectory(i);
        FinalImage(:,:,i)=TifLink.read();
    end
    TifLink.close();
    
    SegValue = unique(FinalImage);
    numChannels = length(SegValue);
    if (numChannels~=2)&&(numChannels~=3);
        disp('The segmentation channel is not correct, please recheck the input file');
        return;          
    elseif (numChannels==2);
    	fprintf (['\n The segmentation has 2 channels.', ...
                     '\n By default different value and corresponding meaning of channels are:', ...
                     '\n 0: background', ...
                     '\n 1: segmentation']);
    else
        fprintf ([' The segmentation has 3 channels.', ...
                     '\n By default different value and corresponding meaning of channels are:', ...
                     '\n 0: background', ...
                     '\n 1: false-postive segmentation', ...
                     '\n 2: segmentation\n']);
    end
    
    MakeMyVar('segPath',ipath);   
    MakeMyVar('segStack',FinalImage);
    MakeMyVar('segValue',SegValue);
    
    toc;
                  
end
