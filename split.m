%merge - Merge several connected-component into one
%pseudo-connected-component (for splited segmentations)
%
%Usage:
% merge ( CC, 1, 2 ) 
% merge ( CC, 1, 2, 3 ) 
%
%   CC:  connected component struct calculated from 3D binary image;
%
%
%Note: 
%
%Example:
%   --------
%       
%
%   --------
%
%
% - Ziqiang Huang 2014.08.13
%%
function  split(CC,num)

    %INPUT ARGUMENT CONTROL:
    %Show object with pre-defined stacks in base Workspace  
    if evalin('base','exist(''Overlay_marked'',''var'')')
        DEFAULT_STACK = evalin('base','Overlay_marked');
    elseif evalin('base','exist(''Overlay'',''var'')')
        DEFAULT_STACK = evalin('base','Overlay');
    elseif evalin('base','exist(''rawStack'',''var'')')
        DEFAULT_STACK = evalin('base','rawStack');
    else
        error(message('There is no image stack available to display the object.'));
    end
    
    substack(CC.centre(num).Centroid,DEFAULT_STACK,'big');
    XD = size(DEFAULT_STACK,2);YD = size(DEFAULT_STACK,1);
	ZD = size(DEFAULT_STACK,ndims(DEFAULT_STACK));
	[xD,yD,zD] = deal(384,384,192);    %display frame size
    [x,y,z]=getPoint(CC.centre(num).Centroid,'round');  %object centre coordinate
    
    %get sub-image onset and offset
	xOnset = x-xD/2;	yOnset = y-yD/2;	zOnset = z-zD/2;
    xOffset = x+xD/2-1;	yOffset = y+yD/2-1;	zOffset = z+zD/2-1;     
    xOnset = max(xOnset,1); xOffset = min(xOffset,XD);
    yOnset = max(yOnset,1); yOffset = min(yOffset,YD);
    zOnset = max(zOnset,1); zOffset = min(zOffset,ZD); %#ok<NASGU>
    
    
    %zMin = CC.box(num).BoundingBox(3) + 0.5;    %starting slice in original stack
    %zMax = CC.box(num).BoundingBox(3) + CC.box(num).BoundingBox(6) + 0.5;   %end slice in original stack
    zRange = CC.box(num).BoundingBox(6);   %object z-range
    zStart = max(z - (zRange/2), 1); zEnd = min(z + (zRange/2), 96);
%     z1 = round(zMin + zRange/4);
%     z2 = round(z1 + zRange/4);
%     z3 = round(z2 + zRange/4);
    fprintf ([' Choose at least three points from provided 2D images to determine the splitting plane.\n', ...
              ' Note:A flat plane will be calculated based on a Least Squares Fitting algorithm.\n', ...
              ' The more points selected the better the splitting plane is going to be.\n', ...
              ' It''s more precise to use points that are relatively far away from each other.\n',...
              ' When finished the manuall selection, type ''s'' to exit and get the result.)\n']);
	i = 1;
    figure,imshow(DEFAULT_STACK(yOnset:yOffset,xOnset:xOffset,:,zOnset+96));
    p = double(zeros(3,3));
    
	if ndims(DEFAULT_STACK) == 4; %stack should has color channel, and by default use the 3rd array
        
        while (1)
            prompt = (' Choose which slice for splitting point selection:');
            str = input(prompt,'s'); %get slice number from user
            numSlice = round(str2double(str));
            %if (numSlice >= zStart && numSlice <= zEnd);
            if (str~='s');
                zSlice = numSlice + zOnset;
                imshow(DEFAULT_STACK(yOnset:yOffset,xOnset:xOffset,:,zSlice));
                %refreshdata;
                [Xi,Yi,button] = ginput(); %get splitting points from user on the current slice
                if button == 1
                    %i = i + 1;  %Number counts of total points got from user
                    for j = 1:length(Xi)
                        p(i,1) = Xi(j) + xOnset; 
                        p(i,2) = Yi(j) + yOnset;
                        p(i,3) = zSlice;
                        i = i + 1;
                    end
                else
                    continue;
                end
            elseif (str=='s');
                if (i >= 3)
                    fprintf(' Points for splitting plane have been selected as:\n');
                    disp(p);
                    MakeMyVar('points',p);
                    [~,~,~,~] = getPlane(p);               
                    break;
                else
                    fprintf (' Choose at least three points for splitting plane selection!\n');
                    continue;
                end
            else
                sprintf ([' Slice number ', str, ' is not a valid slice containing object number ', num2str(num),'!']);
            end
        end
    else
        fprintf (' There''s no image stack in the base workspace to display the split candidate!\n');
        return;
	end
    
    
    %show the splitting points and plane, ask user to verify
	hFig = figure('Name','3D points fitting plane result','Visible','off','NumberTitle','off');
    figure(hFig),scatter3(p(:,1),p(:,2),p(:,3));
    prompt = ' Display the calculated fitting plane onto the points now?(y/n)';
 	str = input(prompt,'s');
	if (str=='y')
        plane = evalin('base','plane');
        A = plane(1); B=plane(2); C=plane(3); D=plane(4);
        [a,b] = meshgrid(xOnset:10:xOffset,yOnset:10:yOffset);
        c = (-A/C)*a + (-B/C)*b + (-D/C);
        hold on, mesh(a,b,c);
	end
    
    
	while (1)
        prompt = ' Is the splitting plane calculated looks reasonable to proceed?(y/n)';
        str = input(prompt,'s');
        if (str=='y')
            fprintf ([' Artificially splitting object ',num2str(num),' with user defined splitting plane.\n']);
            splitSeg( CC, num, A,B,C,D);
            break;
        else
            disp(' splitting operation is not performed. splitting function terminated');
            break;
        end
	end
      
end
    
    

     

function splitSeg(CC,num,A,B,C,D)

    if evalin('base','exist(''CC_splited'',''var'')')
        error(message(' Segmentation storage struct (default:CC_splited) has already been created in Workspace.'));
    end

    PLT = regionprops(CC.object,'PixelList');
    PLT = PLT(num).PixelList;
    result = double(zeros(length(PLT),1));
    for i = 1: length(PLT)
        result(i) = PLT(i,1)*A + PLT(i,2)*B + PLT(i,3)*C + D;
    end
    
    CC_s1 = find(result>0);
    %CC_s2 = find(result>=0);
   

    %CC_s = CC;

    %add one more object for joint segmentation
    CC_s.object.Connectivity = CC.object.Connectivity;
    CC_s.object.ImageSize = CC.object.ImageSize;
    CC_s.object.NumObjects = 2;
    CC_s.object.PixelIdxList = [];

    %this
    %re-calculate the pixel-index-list of joint segmentations 
    PIL = CC.object.PixelIdxList{num};
    PIL_1 = []; PIL_2 = [];
    
	for i = 1 : length(PIL)
        if ismember(i,CC_s1)
            PIL_1 =  vertcat(PIL_1, PIL(i));  %#ok<AGROW>
        else
            PIL_2 =  vertcat(PIL_2, PIL(i)); %#ok<AGROW>
        end
	end
    CC_s.object.PixelIdxList{1} = PIL_1;
    CC_s.object.PixelIdxList{2} = PIL_2;

    %get the segmentation information
    CC_s.object.OriIdx{1, 1} = inputname(1);
    CC_s.object.OriIdx{1, 2} = num;
    CC_s.object.OriIdx{1, 3} = [A,B,C,D];
    
    
    CC_s.volume = regionprops(CC_s.object,'Area');      %get volume of segmentations
    CC_s.centre = regionprops(CC_s.object,'Centroid');	%get centroid of segmentations
    CC_s.box = regionprops(CC_s.object,'BoundingBox');  %get bounding-box of segmentations 

    %make up the splited segmentations
    MakeMyVar('CC_splited',CC_s);
    
end


function MakeMyVar(VarName,VarValue)
    assignin('base',VarName,VarValue);
end