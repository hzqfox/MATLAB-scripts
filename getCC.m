
function getCC(mask,type)

    DEFAULT_TYPE = 'debug';
    if nargin == 0
        mask = evalin('base','segStack');
        type = DEFAULT_TYPE;
    elseif nargin == 1
        type = DEFAULT_TYPE;
    end

    %timing function running duration
    disp('Calculating connected-component from segmentation file...');tic;
    
    switch type
        case 'all';     %get all segmentations regardless positive or false-positive
            seg_All = (mask~=0);
            CC_All = bwconncomp(seg_All,26);            %get connect component of segmentations
    %         Area_All = bwarea(seg_All);                 %get surface area of segmentations
            Vol_All = regionprops(CC_All,'Area');       %get volume of segmentations
            Cent_All = regionprops(CC_All,'Centroid');  %get centroid of segmentations
            Box_All = regionprops(CC_All,'BoundingBox');
     %       output = struct('object',CC_All,'area',Area_All,'volume',Vol_All,'centre',Cent_All);
            output = struct('object',CC_All,'volume',Vol_All,'centre',Cent_All,'box',Box_All);
            MakeMyVar('CC_segAll',output);     
            
            toc;
            return;
            


    %     case 'smart';   %get 2 segmentations: positive, false-positive
    %       %get connect component of segmentations    
    %         seg_I = (mask==1);
    %         seg_II = (mask==2);
    %         
    %         
    %         %get connect component of segmentations
    %         CC_I = bwconncomp(seg_I,26);
    %         CC_II = bwconncomp(seg_II,26);
    % 
    %         %get volume of segmentations
    %         Vol_I = regionprops(CC_I,'Area');
    %         Vol_II = regionprops(CC_II,'Area');
    % 
    %         %get centroid of segmentations
    %         Cent_I = regionprops(CC_I,'Centroid');
    %         Cent_II = regionprops(CC_II,'Centroid');
    % 
    %         output_I = struct('object',CC_I,'volume',Vol_I,'centre',Cent_I);
    %         output_II = struct('object',CC_II,'volume',Vol_II,'centre',Cent_II);
    %         output_seg = struct('seg1',output_I,'seg2',output_II);
    %         MakeMyVar('CC_seg',output_seg);
    %         
    %         return;



        case 'debug';   %get 3 segmentations: all, positive, false-positive
           %get connect component of segmentations    
            seg_All = (mask~=0);
            seg_I = (mask==1);
            seg_II = (mask==2);

            %get connect component of segmentations
            CC_All = bwconncomp(seg_All,26);
            CC_I = bwconncomp(seg_I,26);
            CC_II = bwconncomp(seg_II,26);

    %         %get surface area of segmentations
    %         Area_All = bwarea(seg_All);
    %         Area_I = bwarea(seg_All);
    %         Area_II = bwarea(seg_All);

            %get volume of segmentations
            Vol_All = regionprops(CC_All,'Area');
            Vol_I = regionprops(CC_I,'Area');
            Vol_II = regionprops(CC_II,'Area');

            %get centroid of segmentations
            Cent_All = regionprops(CC_All,'Centroid');
            Cent_I = regionprops(CC_I,'Centroid');
            Cent_II = regionprops(CC_II,'Centroid');

            %get bounding-box of segmentations
            Box_All = regionprops(CC_All,'BoundingBox');
            Box_I = regionprops(CC_I,'BoundingBox');
            Box_II = regionprops(CC_II,'BoundingBox');

    %         %get bounding-box of segmentations
    %         Perimeter_All = regionprops(CC_All,'Perimeter');
    %         Perimeter_I = regionprops(CC_I,'Perimeter');
    %         Perimeter_II = regionprops(CC_II,'Perimeter');

    %         output_All = struct('object',CC_All,'area',Area_All,'volume',Vol_All,'centre',Cent_All);
    %         output_I = struct('object',CC_I,'area',Area_I,'volume',Vol_I,'centre',Cent_I);
    %         output_II = struct('object',CC_II,'area',Area_II,'volume',Vol_II,'centre',Cent_II);
            output_All = struct('object',CC_All,'volume',Vol_All,'centre',Cent_All,'box',Box_All);
            output_I = struct('object',CC_I,'volume',Vol_I,'centre',Cent_I,'box',Box_I);
            output_II = struct('object',CC_II,'volume',Vol_II,'centre',Cent_II,'box',Box_II);
            MakeMyVar('CC_segAll',output_All);
            MakeMyVar('CC_segI',output_I);
            MakeMyVar('CC_segII',output_II);

            toc;
            return;

        case 'seperate';    %get segmentations: with denoted positive or false-positive with number 2 or 1;
            seg_All = (mask~=0);
            CC_All = bwconncomp(seg_All,26);            %get connect component of segmentations
    %         Area_All = bwarea(seg_All);                 %get surface area of segmentations
            Vol_All = regionprops(CC_All,'Area');       %get volume of segmentations
            Cent_All = regionprops(CC_All,'Centroid');  %get centroid of segmentations
     %       output = struct('object',CC_All,'area',Area_All,'volume',Vol_All,'centre',Cent_All);
            output = struct('object',CC_All,'volume',Vol_All,'centre',Cent_All);
            MakeMyVar('CC_segAll',output);     
            
            toc;
            return;

    end
    
end