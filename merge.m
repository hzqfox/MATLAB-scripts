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
% - Ziqiang Huang 2014.08.06
%%
function  merge(CC,varargin)

    %INPUT ARGUMENT CONTROL:
    %if input objects is less than 2, quit (impossible to add). consider 0 object            
    if nargin < 3;
        error('ErrorTAG:TagName', strcat (' Provide at least 2 candidates to merge.')); 
    end
    
	%check if the storage struct has already exist

    
    %iterate input objects to get their information
    element = double(zeros(nargin-1));
	for i = 1:nargin-1
        if isnumeric(varargin{i})
            element(i) = varargin{i};      
        else
            error('ErrorTAG:TagName', strcat (' Provide only numeric ID number of merge candidates.'));
        end       
	end
    element = sort(element);    %get ascending order of input
    
    
    %check whether merge segmentation (CC_merged) has already created in base workspace
	if evalin('base','exist(''CC_merged'',''var'')')
        CC_m = evalin('base','CC_merged');
        %get merge segmentation information
        length_CC_m = length(CC_m.object.PixelIdxList);
        
        %add one more object for joint segmentation
        CC_m.object.NumObjects = CC_m.object.NumObjects + 1;
             
        %re-calculate the pixel-index-list of joint segmentations 
        m_PIL = CC.object.PixelIdxList{element(1)};
        for i = 2 : length(element)
            m_PIL =  vertcat(m_PIL, CC.object.PixelIdxList{element(i)}); %#ok<AGROW>
        end
        CC_m.object.PixelIdxList{length_CC_m + 1} = m_PIL;
         
        %get the segmentation information
        CC_m.object.OriIdx{length_CC_m + 1, 1} = inputname(1);
        CC_m.object.OriIdx{length_CC_m + 1, 2} = num2str(element(1));
        for i = 2 : length(element)
            CC_m.object.OriIdx{length_CC_m + 1, 2} = strcat (CC_m.object.OriIdx{length_CC_m + 1, 2},',',num2str(element(i)));
        end
        
        %re-calculate the volume of joint segmentations
        m_volume = double(zeros);
        for i = 1 : length(element)
            m_volume = m_volume + CC.volume(element(i)).Area;
        end
        CC_m.volume(length_CC_m + 1, 1).Area = m_volume;
        
        %re-calculate the centre of joint segmentations
        m_centre = double(zeros(length(element),3));
        for i = 1 : length(element)
            m_centre(i,:) = CC.centre(element(i)).Centroid;
        end
        CC_m.centre(length_CC_m + 1, 1).Centroid = mean( m_centre , 1);
        
        
        %re-calculate the bounding box of joint segmentations
        m_box = double(zeros(length(element),6));
        for i = 1 : length(element)
            m_box(i,:) = CC.box(element(i)).BoundingBox;
        end
        CC_m.box(length_CC_m + 1, 1).BoundingBox(1) = min(m_box(:,1));
        CC_m.box(length_CC_m + 1, 1).BoundingBox(2) = min(m_box(:,2));
        CC_m.box(length_CC_m + 1, 1).BoundingBox(3) = min(m_box(:,3));
        CC_m.box(length_CC_m + 1, 1).BoundingBox(4) = max(m_box(:,1)+m_box(:,4)) - CC_m.box(length_CC_m + 1, 1).BoundingBox(1);
        CC_m.box(length_CC_m + 1, 1).BoundingBox(5) = max(m_box(:,2)+m_box(:,5)) - CC_m.box(length_CC_m + 1, 1).BoundingBox(2);
        CC_m.box(length_CC_m + 1, 1).BoundingBox(6) = max(m_box(:,3)+m_box(:,6)) - CC_m.box(length_CC_m + 1, 1).BoundingBox(3);
        
        %update merge segmentation, to add the new joint segmentation
        MakeMyVar('CC_merged',CC_m);

    
    else    %merge segmentation (CC_merged) has not been created in base workspace     
        fprintf ([' Segmentation storage struct (default:CC_merged) can not be found in Workspace.', ...
                       '\n A new storage struct (CC_merged) will be created to save the merge result.\n']);
        CC_m = struct;
        
        %add one more object for joint segmentation
        CC_m.object.Connectivity = CC.object.Connectivity;
        CC_m.object.ImageSize = CC.object.ImageSize;
        CC_m.object.NumObjects = 1;
        
        %re-calculate the pixel-index-list of joint segmentations 
        m_PIL = CC.object.PixelIdxList{element(1)};
        for i = 2 : length(element)
            m_PIL =  vertcat(m_PIL, CC.object.PixelIdxList{element(i)}); %#ok<AGROW>
        end
        CC_m.object.PixelIdxList{1} = m_PIL;
        
        %get the segmentation information
        CC_m.object.OriIdx{1, 1} = inputname(1);
        CC_m.object.OriIdx{1, 2} = num2str(element(1));
        for i = 2 : length(element)
            CC_m.object.OriIdx{1, 2} = strcat (CC_m.object.OriIdx{1, 2},',',num2str(element(i)));
        end
        
        %re-calculate the volume of joint segmentations
        m_volume = double(zeros);
        for i = 1 : length(element)
            m_volume = m_volume + CC.volume(element(i)).Area;
        end
        CC_m.volume(1, 1).Area = m_volume;
        
        %re-calculate the centre of joint segmentations
        m_centre = double(zeros(length(element),3));
        for i = 1 : length(element)
            m_centre(i,:) = CC.centre(element(i)).Centroid;
        end
        CC_m.centre(1, 1).Centroid = mean( m_centre, 1 );
        
        
        %re-calculate the bounding box of joint segmentations
        m_box = double(zeros(length(element),6));
        for i = 1 : length(element)
            m_box(i,:) = CC.box(element(i)).BoundingBox;
        end
        CC_m.box(1, 1).BoundingBox(1) = min(m_box(:,1));
        CC_m.box(1, 1).BoundingBox(2) = min(m_box(:,2));
        CC_m.box(1, 1).BoundingBox(3) = min(m_box(:,3));
        CC_m.box(1, 1).BoundingBox(4) = max(m_box(:,1)+m_box(:,4)) - CC_m.box(1, 1).BoundingBox(1);
        CC_m.box(1, 1).BoundingBox(5) = max(m_box(:,2)+m_box(:,5)) - CC_m.box(1, 1).BoundingBox(2);
        CC_m.box(1, 1).BoundingBox(6) = max(m_box(:,3)+m_box(:,6)) - CC_m.box(1, 1).BoundingBox(3);
        
        %make up the new joint segmentation
        MakeMyVar('CC_merged',CC_m);
        
	end   
    
    
end

function MakeMyVar(VarName,VarValue)
    assignin('base',VarName,VarValue);
end