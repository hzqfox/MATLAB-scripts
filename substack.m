%substack - Create a 3D-substack around given point within the input
%3D-stack. 
%Usage:
% substack ( point, stack ) 
% substack ( point, stack ) 
% substack ( point, stack, size )
% 
%   point:  1x3 numeric array [X,Y,Z] (spatial coordinates [X,Y,Z]);
%   stack:  3D image stack MxNxK (K slices of MxN images); 
%   stack:  4D image stack MxNxCxK (K slices of MxN images, with RGB color
%           channel C);
%   size:   string variable to specify the substack size:
%           'tiny'     - [64,64,32]; 
%           'small'    - [128,128,64];
%           'middle'   - [256,256,128]; 
%           'big'      - [384,384,192];
%            The default size is 'middle', if 3rd input left empty.
%
%Note: the point will be highlighted with a white circle in 3D stack, or a
%      green cross in 4D stack; The mark will propogate through 7 slides
%      with point-residue slides in the middle. the automatic generated
%      substack will have the point coordinates as title.
%
%Example:
%   --------
%       % Load image stack, get a spatical point
%       path = 'D:\iLastik_Data\stack_A1';
%       stack = stackLoader(path);
%       overlay(rawStack,segStack);
%       point = [512,512,256];
%   --------
%       % get tiny substack around point in rawStack
%            substack ( point, rawStack, 'tiny' ); 
%       % get big substack around point in overlay image
%            substack ( point, Overlay, 'big' ); 
%       % get regular substack around point in overlay image
%            substack ( point, Overlay );
%
% - Ziqiang Huang 2014.07.01
%%
function substack(point, stack, displaySize)

    %INPUT ARGUMENT CONTROL:
    %if not specified otherwise, display around centre of stack
    DEFAULT_POINT = [512,512,256]; 
    %if not specified otherwise, get available stack from base Workspace
	if evalin('base','exist(''Overlay_marked'',''var'')')
        DEFAULT_STACK = evalin('base','Overlay_marked');
    elseif evalin('base','exist(''Overlay'',''var'')')
        DEFAULT_STACK = evalin('base','Overlay');
    elseif evalin('base','exist(''rawStack'',''var'')')
        DEFAULT_STACK = evalin('base','rawStack');
    %else case: no stack pre-defined available from Workspace     
	end
    %if not specified otherwise, crop middle sized substack
    DEFAULT_SIZE = 'middle';
    
    %check input argument
    if nargin < 1
        point = DEFAULT_POINT;
        stack = DEFAULT_STACK;
        displaySize = DEFAULT_SIZE;
    elseif nargin < 2
        stack = DEFAULT_STACK;
        displaySize = DEFAULT_SIZE;
    elseif nargin <3
        displaySize = DEFAULT_SIZE;
    end

    
    %get output substack dimension from 3rd input
    switch displaySize;
        case 'tiny';
            [xD,yD,zD] = deal(64,64,32);
        case 'small';
            [xD,yD,zD] = deal(128,128,64);
        case 'middle';
            [xD,yD,zD] = deal(256,256,128);
        case 'big';
            [xD,yD,zD] = deal(384,384,192);
    end

    %get coordinate info from 1st input, translate into array index   
    [x,y,z]=getPoint(point,'round');
    strPoint = strcat('[X:',num2str(x),'; Y:',num2str(y),'; Z:',num2str(z),']');
    
    %validate relative position of substack, and do neccessary trim
	XD = size(stack,2);YD = size(stack,1);
	ZD = size(stack,ndims(stack));
        
    xOnset = x-xD/2;	yOnset = y-yD/2;	zOnset = z-zD/2;
    xOffset = x+xD/2-1;	yOffset = y+yD/2-1;	zOffset = z+zD/2-1;
     
    xOnset = max(xOnset,1); xOffset = min(xOffset,XD);
    yOnset = max(yOnset,1); yOffset = min(yOffset,YD);
    zOnset = max(zOnset,1); zOffset = min(zOffset,ZD);
 
    %validate stack dimension, and crop substack accordingly
    if ndims(stack) <3; %#ok<ISMAT>
        error('The 2nd input should be an image stack, and should has at least 3 dimensions');
    elseif ndims(stack) ==3;
        %stack should be in gray-scale
        subStack=stack(yOnset:yOffset,xOnset:xOffset,zOnset:zOffset);
        %draw a white circle in substack to highlight ROI
        minD= min(xD,yD);
        for r = minD/6.3:0.5:minD/6;
        %for r = 41:0.5:42
            for th = 0:pi/200:2*pi;
                xunit = r * cos(th) + x - xOnset;
                yunit = r * sin(th) + y - yOnset;
                rXunit = round(xunit);
                rYunit = round(yunit);
                %subStack(rYunit,rXunit,max(z-zOnset-6,1):min(z-zOnset+6,zD))=255;
                if (rXunit>0) && (rYunit>0);
                    subStack(rYunit,rXunit,max(z-zOnset-3,1):min(z-zOnset+3,zD))=255;
                end
            end
        end
        %MakeMyVar('subStack',subStack);
        %implay(subStack);
        %set(findall(0,'tag','spcui_scope_framework'),'Name',strcat('[X:',num2str(x),'; Y: ',num2str(y),'; Z:',num2str(z),']'));
        
        %set handle of figure, to pass coordinate as figure title;
        hFig = figure('Name',strPoint,'Visible','off','NumberTitle','off');
        figure(hFig),stackViewer(subStack);
        return;
    elseif ndims(stack) ==4;
        %stack should has color channel, and by default use the 3rd array
        %for color storage, 4th array for Z-axis
        subStack=stack(yOnset:yOffset,xOnset:xOffset,:,zOnset:zOffset);
        %draw a green cross in substack to hightlight ROI
        subStack(y-yOnset-1:y-yOnset+1,:,2,max(z-zOnset-3,1):min(z-zOnset+3,zD))= 255;
        subStack(:,x-xOnset-1:x-xOnset+1,2,max(z-zOnset-3,1):min(z-zOnset+3,zD))= 255;
        %MakeMyVar('subStack',subStack);
%         handle = implay(subStack);
%         set(handle,'Name',strcat('[X:',num2str(x),'; Y: ',num2str(y),'; Z:',num2str(z),']'));
        %implay(subStack);
        hFig = figure('Name',strPoint,'Visible','off','NumberTitle','off');
        figure(hFig),stackViewer(subStack);
        return;
    else
        error('ErrorTAG:TagName', strcat ( 'The 2nd input as an image stack has more than 4 dimensions.', ...
              '\nTry to reduce it before apply this function.') );
    end
    
end