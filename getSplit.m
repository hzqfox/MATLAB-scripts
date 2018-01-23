%Coordinate Analysis Ziqiang
%%
	function getSplit (index, pF)
 
    %IMAGE STACK CONTROL:
    %If not specified otherwise, DO split object verification with
    %Overlay_marked
	TF = true;   
    if evalin('base','exist(''Overlay_marked'',''var'')')
        DEFAULT_COLOR_STACK = evalin('base','Overlay_marked');
    elseif evalin('base','exist(''Overlay'',''var'')')
        DEFAULT_COLOR_STACK = evalin('base','Overlay');
    elseif evalin('base','exist(''rawStack'',''var'')')
        DEFAULT_COLOR_STACK = DEFAULT_STACK;
    else
        TF = false;
    end
    
	if ~TF
        disp('Can not verify split object without image stack. Load image stack first.');
        return;
    end
    
    Cor = evalin('base','XYZ');
    
    %INPUT ARGUMENT CONTROL:
    %if not specified otherwise, DO split object verification on pairFound and DistanceThreshold             
    if nargin == 0;
        pF = evalin('base','pairFound');
        threshold = evalin('base','DistanceThreshold');
        index = find(pF(:,1)>threshold,1)-1;
    %if not specified otherwise, DO split object verification on pairFound
    elseif nargin == 1;
        pF = evalin('base','pairFound');
    end
    
    [n, bin]=histc(pF(1:index,3),unique(pF(1:index,3)));
    multiple = find(n>1);
	idx = ismember(bin,multiple);
    %CCsplit = pF(idx,2)
    XYZsplit = unique(sort(pF(idx,3)));

    %figure;
    for k = 1:length(XYZsplit)            
        %display CC centroid with rawStack
        %XYZNum = pF(index(k),3);
            disp(['Verifying the split object number ',num2str(k),'. Pair info(XYZ#:',num2str(XYZsplit(k)),')']);
            substack(Cor(XYZsplit(k),[2,3,4]), DEFAULT_COLOR_STACK, 'big');
            %set(gcf,'Position', [((1750-550*Num_ClosePair)/2+550*(k-1)), 100, 500, 400]);           
        prompt = 'Continue to the next?(y/n)';
        str = input(prompt,'s');
        if (str=='n');
            return;
        else
            continue;
        end            
    end        

    disp('Verifying split object terminated. Make sure you have saved the verified split pair info.');
            
end



function MakeMyVar(VarName,VarValue)
    assignin('base',VarName,VarValue);
end