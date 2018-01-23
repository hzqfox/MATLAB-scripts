%%
%function to get missed synapse into pseudo segmentation struct
function CC_FN = getFNSynapse(XYZ, CC, dT, X, Y, Z)
    
    %default synapse diameter is 40nm
    DEFAULT_DIAMETER = 40;
    DEFAULT_RADIUS = DEFAULT_DIAMETER / 2;
    if nargin == 6
        Threshold = dT; 
    elseif evalin('base','exist(''DistanceThreshold'',''var'')')
        Threshold = evalin('base','DistanceThreshold');
    else
        Threshold = getDistanceThreshold(CC, XYZ);        
    end       
    
    %timing function running duration
    disp('Extract missed synapse(s) of segmentation from coordinate file...');tic;
    
    
    if nargin == 6
        Xmin = 0.5; Xmax = X;
        Ymin = 0.5; Ymax = Y;
        Zmin = 0.5; Zmax = Z;
    else
        %get minimum and maximum X Y Z range    
        Xmin = 0.5; Xmax = evalin('base','X');
        Ymin = 0.5; Ymax = evalin('base','Y');
        Zmin = 0.5; Zmax = evalin('base','Z');
    end
    
	%get pixel list from CC
    PixelList = regionprops(CC.object,'PixelList');
    
	for index = 1:length(PixelList);
        distMatrix(index,:)= min(pdist2(PixelList(index).PixelList,XYZ(:,[2,3,4]))); %#ok<AGROW>
	end         
    distMatrixSorted = sort(distMatrix,1);
        
    FNidx = find(distMatrixSorted(1,:)>Threshold);
    
    %create the centre and bounding box of missed synapse(s)
	CC_FN = CC;
    CC_FN.object.NumObjects = length(FNidx);
    CC_FN.object.PixelIdxList = [];
    CC_FN.object.OriIdx = [];
    CC_FN.volume = [];
    CC_FN.centre = [];
    CC_FN.box = [];
    
    for i = 1 : length(FNidx)
        CC_FN.object.OriIdx{i,1} = 'XYZ';
        CC_FN.object.OriIdx{i,2} = num2str(FNidx(i));
        CC_FN.centre(i, 1).Centroid = XYZ(FNidx(i),2:4);
        CC_FN.box(i, 1).BoundingBox(1) = max(Xmin, XYZ(FNidx(i),2)-DEFAULT_RADIUS);
        CC_FN.box(i, 1).BoundingBox(2) = max(Ymin, XYZ(FNidx(i),3)-DEFAULT_RADIUS);
        CC_FN.box(i, 1).BoundingBox(3) = max(Zmin, XYZ(FNidx(i),4)-DEFAULT_RADIUS);
        CC_FN.box(i, 1).BoundingBox(4) = min(Xmax-XYZ(FNidx(i),2), DEFAULT_RADIUS)+ DEFAULT_RADIUS;
        CC_FN.box(i, 1).BoundingBox(5) = min(Ymax-XYZ(FNidx(i),3), DEFAULT_RADIUS)+ DEFAULT_RADIUS;
        CC_FN.box(i, 1).BoundingBox(6) = min(Zmax-XYZ(FNidx(i),4), DEFAULT_RADIUS)+ DEFAULT_RADIUS;
    end
    
    toc;
               
end
