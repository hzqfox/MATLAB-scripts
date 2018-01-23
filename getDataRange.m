function dataRange = getDataRange(rawStack)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 1
        if evalin('base','exist(''rawStack'',''var'')')
            rawStack = evalin('base','rawStack');
        elseif evalin('base','exist(''path'',''var'')')
            fileRaw = dir (fullfile(path,'*.tif'));
            fileFpath = strcat(path,'\',fileRaw.name);
            rawStack = fLoad(fileFpath);
        else
            rawStack = fLoad;
        end 
    end

	%timing function running duration
    tic;
    fprintf (['\nCreating binary stack to distinguish data and margin areas, it will take several seconds.', ...
              '\nIf you want to visualize the binary stack, you will find it in ''dataRange'' variable in the base Workspace.\n']);
         

    X = evalin('base','X'); Y = evalin('base','Y'); Z = evalin('base','Z');      
    se = strel('square',5);
    dataRange = false(Y,X,Z);

    for i = 1:Z
        dataRange(:,:,i) = im2bw(rawStack(:,:,i),0.9999);
        dataRange(:,:,i) = imerode(dataRange(:,:,i),se);
    end

    MakeMyVar ('dataRange',dataRange);
	toc;
    
end

