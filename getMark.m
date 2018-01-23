%
%%
function  getMark(CC,color,fontsize)

    DEFAULT_COLOR = 'black';
    
    DEFAULT_FONTSIZE = 13;
    if nargin < 2
        color = DEFAULT_COLOR;
        fontsize = DEFAULT_FONTSIZE;
    elseif nargin <3
        fontsize =DEFAULT_FONTSIZE;
    end

    
    if evalin('base','exist(''Overlay_marked'',''var'')')
        %path = evalin('base','DataPath');
        prompt = (sprintf (['Overlay stack has already been marked before, add new mark on top of it?(y/n)', ...
                            '\n (Note: It''s better to use a different color for the new mark)']));
        str = input(prompt,'s');
        if (str=='y');
            stack = evalin('base','Overlay_marked');
        else
            return;
        end
    else
        stack = evalin('base','Overlay');
    end       
	
    
    ZD = size(stack,ndims(stack));
    
    NumObj = CC.object.NumObjects;
    
    %h = waitbar(0,'Initializing waitbar...');
    
    for num = 1:NumObj
        
        
        centre = CC.centre(num).Centroid;
        x=round(centre(1));
        y=round(centre(2));
        z=round(centre(3));    
 
        zRange = CC.box(num).BoundingBox(6);
        sizeZ = ceil((zRange-1)/2); 
        zOn = max(z-sizeZ , 1);
        zOff = min(z+sizeZ, ZD);
        
        for i = zOn:zOff
            tempImg = insertText(stack(:,:,:,i),[x,y],num2str(num),'FontSize',fontsize,'TextColor',color,'BoxOpacity',0);
            stack(:,:,:,i) = tempImg;
        end

%              tempImg = insertText(stack(:,:,:,z),[x,y],num2str(num),'FontSize',fontsize,'TextColor',color,'BoxOpacity',0);
%              stack(:,:,:,z) = tempImg;
    end
    

    MakeMyVar('Overlay_marked',stack);
    stackViewer(stack);
	return;



end


function MakeMyVar(VarName,VarValue)
assignin('base',VarName,VarValue);
end