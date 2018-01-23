
function getSize( CC , stack )

	%INPUT ARGUMENT CONTROL:
    %Show result from pre-defined stacks in base Workspace 
    TF = true;   
    if evalin('base','exist(''Overlay_marked'',''var'')')
        DEFAULT_STACK = evalin('base','Overlay_marked');
    elseif evalin('base','exist(''Overlay'',''var'')')
        DEFAULT_STACK = evalin('base','Overlay');
    elseif evalin('base','exist(''rawStack'',''var'')')
        DEFAULT_STACK = evalin('base','rawStack');
    else
        TF = false;
        DEFAULT_STACK = NaN;
    end

    if nargin < 1;
        CC = evalin('base','CC_segAll');
        stack = DEFAULT_STACK;
    elseif nargin < 2;
        stack = DEFAULT_STACK;
    end

    %timing function running duration
    disp('Calculating synapse volume...');tic;
    
	DataPath = evalin('base','DataPath');
    %if not specified otherwise, voxel size is 5nm*5nm*10nm = 250 nm^3
    %sampleD1 and D2 (901 and 909) are 3.85nm*3.85nm*10nm = 148.225 nm^3
    if strcmp (DataPath(end-1), 'D')
        voxelSize = 148.225; %unit = 'nm^3';    
    else
        voxelSize = 250; %unit = 'nm^3'; 
    end
        
    %get number of objects in CC
    numOfObj = CC.object.NumObjects; %#ok<NASGU>
    %get volume of each object
    Volume = voxelSize * cell2mat(permute(struct2cell(CC.volume),[2,1]));
    
    
    %get the volume of each object within structure 'CC', and store it with
    %object ID into a 2D-array 'ObjVol', the 2nd dimension is ID number.
	[ObjVol(:,1),ObjVol(:,2)]=sort(Volume);    
    
    %display the large outliners
%     volOV = (ObjVol(:,1));
%     meanOV = mean(volOV);    stdOV = std(volOV);
    if nargin ==0
        CCname = 'CC_segAll';
    else
        CCname = inputname(1);
    end
    
    %if possible, display potential outliner object to verify them
    %(not yetfully implemented...
    %     outLinerOV = ObjVol;
    %     outLinerOV(:,1) = volOV(volOV<(meanOV-stdOV) | volOV>meanOV+stdOV);
    %     outLinerOV(:,2) = volOV((find(volOV<(meanOV-stdOV) | volOV>meanOV+stdOV)),2);    
    %outLiner = ObjVol((ObjVol(:,1)<(mean(ObjVol(:,1))-std(ObjVol(:,1))))|(ObjVol(:,1)>(mean(ObjVol(:,1))+std(ObjVol(:,1)))));
    
	if TF
        disp(['Verify the largest object from ',CCname,' .']); 
        substack(CC.centre(ObjVol(end,2)).Centroid,stack,'big');
        
        disp(['Verify the maximum step difference from ',CCname,' .']); 
        [~,maxIndex] = max(diff(ObjVol(:,1)));
        substack(CC.centre(ObjVol(maxIndex+1,2)).Centroid,stack,'big');
        
    else
        fprintf (['Potential outliner objects are not verified, no image stack available to display them.', ...
                       '\nIf you want to verify them, load an image stack first, and re-run ''getSize'' function.']);
	end             
    
    %display the object volume plot
    %raw volume plot
    figName= strcat(CCname,' volume plot - sorted');
    hFig = figure('Name',figName,'Visible','off','NumberTitle','off');
    figure(hFig),bar(ObjVol(:,1)); 
    grid on; xlabel('Objects'); ylabel('Object''s Volume (nm^{3})');
    %size sorted volume plot
    figName= strcat(CCname,' volume plot - unsorted');
    hFig = figure('Name',figName,'Visible','off','NumberTitle','off');
    figure(hFig),bar(Volume); 
    grid on; xlabel('Object ID'); ylabel('Object''s Volume (nm^{3})');
    %volume step plot (1st order differential of sorted volume)       
    figName= strcat(CCname,' volume difference plot - sorted');
    hFig = figure('Name',figName,'Visible','off','NumberTitle','off');
    figure(hFig),plot(diff(ObjVol(:,1))); 
    grid on; xlabel('Objects'); ylabel('Object''s Volume difference(nm^{3})');
    % 	figure(hFig),barh(log(ObjVol(:,1))); 
    %   grid on; ylabel('Object ID'); xlabel('Object''s Volume (nm^{3})');
    
    %make base Workspace variable "ObjVol" to store the volume measurement
    MakeMyVar('ObjVol',ObjVol);
    
    toc;
    
end
        
function MakeMyVar(VarName,VarValue)
assignin('base',VarName,VarValue);
end