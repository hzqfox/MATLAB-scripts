%stackViewer - 3D image stack viewer
%Usage:
% stackViewer ( stack ) 
%
%   stack:  
%   3D image stack MxNxK (K slices of MxN images); stack:  4D image stack
%   MxNxCxK (K slices of MxN images, with RGB color
%           channel C);
%   size:   string variable to specify the substack size:
%           'tiny'     - [64,64,32]; 'small'    - [128,128,64]; 'middle'
%           - [256,256,128]; 'big'      - [384,384,192];
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
%   --------
%       % view raw EM image stack
%            stackViewer ( rawStack ); 
%       % view segmentation overlayed stack
%            stackViewer ( Overlay ); 

%
% - Ziqiang Huang 2014.07.01
%%
function stackViewer2(point, displaySize)

    %INPUT ARGUMENT CONTROL:
    %if not specified otherwise, display around centre of stack
    DEFAULT_POINT = [512,512,256]; 
    %if not specified otherwise, get available stack from base Workspace
	if evalin('base','exist(''Overlay_marked'',''var'')')
        stack_color = evalin('base','Overlay_marked');
    elseif evalin('base','exist(''Overlay'',''var'')')
        stack_color = evalin('base','Overlay');
    %else case: no color stack pre-defined available from Workspace   
    else
        error('ErrorTAG:TagName', 'No overlay image stack to display!' );
	end
    
    if evalin('base','exist(''rawStack'',''var'')')
        stack_raw = evalin('base','rawStack');
    %else case: no EM stack pre-defined available from Workspace     
	else
        error('ErrorTAG:TagName', 'No EM image stack to display!' );
    end
    
    %if not specified otherwise, crop middle sized substack
    DEFAULT_SIZE = 'middle';
    
	%check input argument
    if nargin < 1
        point = DEFAULT_POINT;
        displaySize = DEFAULT_SIZE;
    elseif nargin < 2
        displaySize = DEFAULT_SIZE;
    end

	%get output substack dimension from 3rd input
    switch displaySize
        case 'tiny'
            [xD,yD,zD] = deal(64,64,32);
        case 'small'
            [xD,yD,zD] = deal(128,128,64);
        case 'middle'
            [xD,yD,zD] = deal(256,256,128);
        case 'big'
            [xD,yD,zD] = deal(384,384,192);
    end
    
    %get coordinate info from 1st input, translate into array index   
    [x,y,z]=getPoint(point,'round');
    strPoint = strcat('[X:',num2str(x),'; Y:',num2str(y),'; Z:',num2str(z),']');
        
    %validate relative position of substack, and do neccessary trim
	XD = size(stack_raw,2);YD = size(stack_raw,1);
	ZD = size(stack_raw,ndims(stack_raw));
        
    xOnset = x-xD/2;	yOnset = y-yD/2;	zOnset = z-zD/2;
    xOffset = x+xD/2-1;	yOffset = y+yD/2-1;	zOffset = z+zD/2-1;
     
    xOnset = max(xOnset,1); xOffset = min(xOffset,XD);
    yOnset = max(yOnset,1); yOffset = min(yOffset,YD);
    zOnset = max(zOnset,1); zOffset = min(zOffset,ZD);
    
    %validate stack dimension, and crop substack accordingly
   
    %mark gray stack
    subStack_raw = stack_raw(yOnset:yOffset,xOnset:xOffset,zOnset:zOffset);
    subStack_raw = permute(subStack_raw, [1,2,4,3]);        
    %draw a white circle in substack to highlight ROI
    minD= min(xD,yD);
    for r = minD/6.3:0.5:minD/6
    %for r = 41:0.5:42
        for th = 0:pi/200:2*pi
            xunit = r * cos(th) + x - xOnset;
            yunit = r * sin(th) + y - yOnset;
            rXunit = round(xunit);
            rYunit = round(yunit);
            %subStack(rYunit,rXunit,max(z-zOnset-6,1):min(z-zOnset+6,zD))=255;
            if (rXunit>0) && (rYunit>0)
                subStack_raw(rYunit,rXunit,:,max(z-zOnset-3,1):min(z-zOnset+3,zD))=255;
            end
        end
    end       
    %mark color stack
    subStack_color=stack_color(yOnset:yOffset,xOnset:xOffset,:,zOnset:zOffset);
    %draw a green cross in substack to hightlight ROI
    subStack_color(y-yOnset-1:y-yOnset+1,:,2,max(z-zOnset-3,1):min(z-zOnset+3,zD))= 255;
    subStack_color(:,x-xOnset-1:x-xOnset+1,2,max(z-zOnset-3,1):min(z-zOnset+3,zD))= 255;
    
    %get number of slices, and centre slice to display
    NumOfSlices = size(subStack_raw,ndims(subStack_raw));  
    S = round(NumOfSlices/2);
    %S = max(0,(z-zOnset));

    global InitialCoord;
    DEFAULT_FONTSIZE = 9;
    
    %create figure with multiple subimage, name it with coordinate
    set(gcf,'Name',strPoint,'NumberTitle','off','Position', [550, 300, 750, 500]);
    %set(hFig, 'Position', [x y width height])
    axes('position',[0,0.2,1,0.77]), subplot(1,2,1); handle_color = imshow(subStack_color(:,:,:,S));
    subplot(1,2,2); handle_raw = imshow(subStack_raw(:,:,:,S));

    %define figure, slider and text position
    FigPos = get(gcf,'Position');
    S_Pos = [50 45 uint16(FigPos(3)-100)+1 20];
    Stxt_Pos = [50 65 uint16(FigPos(3)-100)+1 15];

    %image stack dimension control
    if NumOfSlices > 1
        shand = uicontrol('Style', 'slider','Min',1,'Max',NumOfSlices,'Value',S,'SliderStep',[1/(NumOfSlices-1) 10/(NumOfSlices-1)],'Position', S_Pos,'Callback', {@SliceSlider, subStack_color});
        stxthand = uicontrol('Style', 'text','Position', Stxt_Pos,'String',sprintf('Slice# %d / %d',S, NumOfSlices), 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', DEFAULT_FONTSIZE);
    else
        stxthand = uicontrol('Style', 'text','Position', Stxt_Pos,'String','2D image', 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', DEFAULT_FONTSIZE);
    end

    %define mouse action functions
    set(gcf, 'WindowScrollWheelFcn', @mouseScroll);
    set(gcf, 'ButtonDownFcn', @mouseClick);
    set(get(gca,'Children'),'ButtonDownFcn', @mouseClick);
    set(gcf,'WindowButtonUpFcn', @mouseRelease)
    set(gcf,'ResizeFcn', @figureResized)


    % Figure resize callback function
    function figureResized(object, eventdata)
        FigPos = get(gcf,'Position');
        S_Pos = [50 45 uint16(FigPos(3)-100)+1 20];
        Stxt_Pos = [50 65 uint16(FigPos(3)-100)+1 15];

        if NumOfSlices > 1
            set(shand,'Position', S_Pos);
        end
        set(stxthand,'Position', Stxt_Pos);

    end

    % Slice slider callback function
    function SliceSlider (hObj,event, subStack_color)
        S = round(get(hObj,'Value'));
            %set(handle_raw,'cdata',subStack_raw(:,:,:,S));
            subplot(1,2,2); handle_raw = imshow(subStack_raw(:,:,:,S));
            set(handle_color,'cdata',subStack_color(:,:,:,S));

        %caxis([Rmin Rmax])
        if NumOfSlices > 1
            set(stxthand, 'String', sprintf('Slice# %d / %d',S, NumOfSlices));
        else
            set(stxthand, 'String', '2D image');
        end
    end

    % Mouse scroll wheel callback function
    function mouseScroll (object, eventdata)

        % Control direction and range of mouse wheel scroll
        UPDN = eventdata.VerticalScrollCount;
        S = S + UPDN;        
        S=max(S,1);
        S=min(S,NumOfSlices);

        if NumOfSlices > 1
            set(shand,'Value',S);
            set(stxthand, 'String', sprintf('Slice# %d / %d',S, NumOfSlices));
        else
            set(stxthand, 'String', '2D image');
        end
        
        %set(handle_raw,'cdata',subStack_raw(:,:,:,S));
        subplot(1,2,2); handle_raw = imshow(subStack_raw(:,:,:,S));
        set(handle_color,'cdata',subStack_color(:,:,:,S));

        end

    % Mouse click callback function
    function mouseClick (object, eventdata)
        MouseStat = get(gcbf, 'SelectionType');
        if (MouseStat(1) == 'a')        %   RIGHT CLICK
            InitialCoord = get(0,'PointerLocation');
            set(gcf, 'WindowButtonMotionFcn', @WinLevAdj);
        end
    end

    % Mouse button released callback function
    function mouseRelease (object,eventdata)
        set(gcf, 'WindowButtonMotionFcn', '')
    end

end