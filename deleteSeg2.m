%
%%
function  deleteSeg2( CC_store , num)


    %INPUT ARGUMENT CONTROL:
    %check if the storage struct has already exist
    
	if evalin('base','exist(''Overlay_marked'',''var'')')
        DEFAULT_COLOR_STACK = evalin('base','Overlay_marked');
    elseif evalin('base','exist(''Overlay'',''var'')')
        DEFAULT_COLOR_STACK = evalin('base','Overlay');
    elseif evalin('base','exist(''rawStack'',''var'')')
        DEFAULT_COLOR_STACK = DEFAULT_STACK;
	end
    
    
    
    CCname = inputname(1); 
    if nargin < 2 
        %check if the storage struct has already exist
        if evalin('base','exist(''CC_store'',''var'')')
            CC_store = evalin('base','CC_store');
            CCname = 'CC_store';
            disp(' Without specifying the segmentation, storage segmentation in base workspace will be loaded by default.');
        %if not, then create a new storage struct in the base workspace
        else
             error('ErrorTAG:TagName', strcat (' Specify (with the 1st input) from which segmentation the delete operation should be performed.'));
        end
    end
    
    num = sort(num);
    
    for i = length(num):-1:1
    
        deleteSeg( CC_store , num(i), 'fast' )
        
    end
        
end