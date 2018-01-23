function FinalImage = fLoad (fpath)

    if nargin < 1
        [FileName,PathName] =  uigetfile('*.tif','Select the FIBSEM image stack file','D:\Program Files\MATLAB\ImageProcessing\Synapse_Segmentation');
        fpath = strcat(PathName,FileName);
    end
    
    %timing function running duration
    disp('Loading FIBSEM image stack...');tic;
    
    TifLink = Tiff(fpath, 'r');
    InfoImage=imfinfo(fpath);
    
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);
    
    FinalImage=zeros(nImage,mImage,NumberImages,'uint8'); 
    for i=1:NumberImages
        TifLink.setDirectory(i);
        FinalImage(:,:,i)=TifLink.read();
    end
    TifLink.close();
    
    
    
    MakeMyVar('rawPath',fpath);   
    MakeMyVar('X',mImage);
    MakeMyVar('Y',nImage);
    MakeMyVar('Z',NumberImages);
    MakeMyVar('rawStack',FinalImage);
    
    toc;
    
end