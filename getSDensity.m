%Coordinate Analysis Ziqiang
%%
function density = getSDensity(path, CC, mode)

    % Define default parameters:
    % If not specified otherwise, voxel size is 5nm*5nm*10nm = 250 nm^3
    % !!!Be aware that some stacks have pixel size 3.85*3.85     
    % (e.g.:sample901 sample909)
    %voxelSize = [3.85 3.85 10]; unit1 = 'nm'; unit2 = 'nm^3'; unit3 = 'µm^3';
    

    DEFAULT_MODE = 'static';  %default partition mode is using fix-sized grid;

	% INPUT ARGUMENT CONTROL:    
    % if not specified otherwise, get default parameters:
    if nargin < 1
        if evalin('base','exist(''DataPath'',''var'')')
            path = evalin('base','DataPath');
        else
            path = uigetdir('Select the folder containing input data','D:\Program Files\MATLAB\ImageProcessing\Synapse_Segmentation');
        end
        CC = evalin('base','CC_store');
        mode = DEFAULT_MODE; 
    elseif nargin < 2        
        CC = evalin('base','CC_store');
        mode = DEFAULT_MODE;        
    elseif nargin < 3
        mode = DEFAULT_MODE;      
    end
    
    % If not specified otherwise, voxel size is 5nm*5nm*10nm = 250 nm^3
    % Sample D1 and D2 (901 and 909), voxel size is 3.85nm*3.85nm*10nm
	if strcmp (path(end-1), 'D')
        voxelSize = [3.85, 3.85, 10]; unit1 = 'nm'; unit2 = 'nm^3'; unit3 = 'µm^3';
    else
        voxelSize = [5, 5, 10]; unit1 = 'nm'; unit2 = 'nm^3'; unit3 = 'µm^3';
	end
    MakeMyVar('voxelSize',voxelSize);
    
    %timing function running duration
    disp('Calculate stereological density of synapse within FIBSEM stack');tic;
    
    %Get FIBSEM image stack, segmentation stack and coordinates
%    fileSeg = dir (fullfile(path,'*.tiff'));
    %fileRaw = dir (fullfile(path,'*.tif'));
    fileXls = dir (fullfile(path,'*.xls'));

    MakeMyVar('DataPath',path);
    %fileIpath = strcat(path,'\',fileSeg.name);
    %fileFpath = strcat(path,'\',fileRaw.name);
    fileXpath = strcat(path,'\',fileXls.name);
    
%     if evalin('base','exist(''segStack'',''var'')')
%         segStack = evalin('base','segStack');
%     else
%         MakeMyVar('Segmentation_File',fileIpath); 
%         segStack = iLoad(fileFpath);
%     end
    
    if evalin('base','exist(''XYZ'',''var'')')
        XYZ = evalin('base','XYZ');
    else
        MakeMyVar('Coordinates_File',fileXpath); 
        XYZ = xLoad (fileXpath);
    end
           
	%Get data range from rawStack 
    if evalin('base','exist(''dataRange'',''var'')')
        dataRange = evalin('base','dataRange');
	else
        if evalin('base','exist(''rawStack'',''var'')')
            rawStack = evalin('base','rawStack');               
        else
            rawStack = fLoad;
        end
        dataRange = getDataRange(rawStack);
    end
     
    
    %calculate maximum 3D dissector range based on data range
    if strcmp(path(end-1:end),'C2')
        maxInscribeBox = getCorner(4, dataRange(:,:,1:824), 0);
    else
        maxInscribeBox = getCorner(11, dataRange, 0);
    end
    MakeMyVar('maxInscribeBox',maxInscribeBox); 
    
    Xmin = max(maxInscribeBox(1,1),maxInscribeBox(3,1));
    Xmax = min(maxInscribeBox(2,1),maxInscribeBox(4,1));
    Ymin = max(maxInscribeBox(1,2),maxInscribeBox(2,2));
    Ymax = min(maxInscribeBox(3,2),maxInscribeBox(4,2));
    Zmin = 1;   Zmax = evalin('base','Z');
    dissectorRange = [Xmin, Xmax, Ymin, Ymax, Zmin, Zmax];
    MakeMyVar('dissectorRange',dissectorRange); 
    dissectorPhysicalRange = (Xmax-Xmin+1)*voxelSize(1) * (Ymax-Ymin+1)*voxelSize(2) * (Zmax-Zmin+1)*voxelSize(3);
            
    %get iLastik missed synapse from TrakEM2 coordinate file, and apply
    %pseudo bounding box to them        
    CC_FN = getFNSynapse(XYZ, CC);
    
    %get object number and their bounding boxes
    NumObj = length(CC.box)+length(CC_FN.box);    
	Box = vertcat(CC.box,CC_FN.box);
    
    fprintf(['Calculating stereological behavior of ', num2str(NumObj), ' objects with '...
             num2str(dissectorPhysicalRange/10^9), ' ', unit3, ' stereological volume.\n']);
    
    %select inclusion and exclusion boundry
    InAndExClusion = 0;
    numDissectorObj = double(getDensity(dissectorRange, Box, InAndExClusion));
    
    density = numDissectorObj*10/(dissectorPhysicalRange/10^9);
    
        
    

    toc;
    
end
