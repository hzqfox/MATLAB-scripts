% stackLoader - Load tiff EM image stack, segmentation stack and ground
% truth info. 
%Usage:
%  stackLoader(path)
%
%    path:  string variable specifying the directory path where the data
%    file stored.
%
%Note: the EM image stack should be in 'tif' format, and segmentation stack
%      should be in 'tiff' format. The two stacks also strickly required to
%      be of same dimension (eg:1024x1024x512). Currently ground truth only
%      available for excel format, and this function read from the 2nd
%      worksheet.
%      
%      While loading, a message will prompt to notify user the segmentation
%      stack information.
%
%      This function currently load all data and info into MATLAB Workspace
%      and making use of tifflib library of MATLAB to speed up data-reading
%      process.
%
%Example:
%   --------
%       path = 'D:\iLastik_Data\stack_A1';
%       stackLoader(path);
% 
% - Ziqiang Huang 2014.07.01
%%

function stackLoader (path)
%load FIB stack, synapse coordinates and segmentation data

%listing = dir(path);

    if nargin == 0
        if evalin('base','exist(''path'',''var'')')
            path = evalin('base','path');
        else 
            path = uigetdir('Select the folder containing input data','D:\Program Files\MATLAB\ImageProcessing\Synapse_Segmentation');
        end
    end

    fileSeg = dir (fullfile(path,'*.tiff'));
    fileRaw = dir (fullfile(path,'*.tif'));
    fileXls = dir (fullfile(path,'*.xls'));

    MakeMyVar('DataPath',path);
    fileIpath = strcat(path,'\',fileSeg.name);
    fileFpath = strcat(path,'\',fileRaw.name);
    fileXpath = strcat(path,'\',fileXls.name);

	iLoad(fileIpath);
    fLoad(fileFpath);
    xLoad(fileXpath);


    while (1)
        prompt = '\nGet overlay image stack now?(y/n)';
        str = input(prompt,'s');
        if (str=='y')
            overlay;
            break;
        else
            disp('overlay image stack is not created. You can manually create it later with overlay(rawStack,segStack) command.');
            break;
        end
    end

    while (1)
        prompt = 'Get connected-component now?(y/n)';
        str = input(prompt,'s');
        if (str=='y')
            getCC;
            break;
        else
            disp('connected-component is not generated. You can manually generate it later with getCC(segStack) command.');
            break;
        end
    end


end 