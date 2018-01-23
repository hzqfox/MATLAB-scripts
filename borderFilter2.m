%
%%
function  borderFilter2(CC)

    %INPUT ARGUMENT CONTROL:
    %Show result from pre-defined stacks in base Workspace 
    if evalin('base','exist(''Overlay_marked'',''var'')')
        DEFAULT_STACK = evalin('base','Overlay_marked');
    elseif evalin('base','exist(''Overlay'',''var'')')
        DEFAULT_STACK = evalin('base','Overlay');
    elseif evalin('base','exist(''rawStack'',''var'')')
        DEFAULT_STACK = evalin('base','rawStack');
    else
        sprintf (['There is no image stack available to display the border object.', ...
                  '\nIf you want to visualize them, load an image stack first, and re-run ''borderFilter'' function.']);
    end
    
    %Show result from pre-defined stacks in base Workspace 
    if evalin('base','exist(''dataRange'',''var'')')
        dataRange = evalin('base','dataRange');
    else
        sprintf (['Creating binary stack to distinguish data and margin areas, it will take several seconds.', ...
                  '\nIf you want to visualize the binary stack, you will find it in ''dataRange'' variable in the base Workspace.']);
        
        rawStack = evalin('base','rawStack');
        X = evalin('base','X'); Y = evalin('base','Y'); Z = evalin('base','Z');      
        se = strel('square',5);
        dataRange = false(Y,X,Z);
        
        for i = 1:Z
            dataRange(:,:,i) = im2bw(rawStack(:,:,i),0.9999);
            dataRange(:,:,i) = imerode(dataRange(:,:,i),se);
        end
        
        MakeMyVar ('dataRange',dataRange);
    end
    
    %get default segmentation in case no input specified
    TF = true;
	if evalin('base','exist(''CC_store'',''var'')')
        DEFAULT_CC = evalin('base','CC_store');
        CCname = 'CC_store';
    elseif evalin('base','exist(''CC_segAll'',''var'')')
        DEFAULT_CC = evalin('base','CC_segAll');
        CCname = 'CC_segAll';
    else
        TF = false;
	end
    
    %check input argument
    if nargin == 0
        if TF
            CC = DEFAULT_CC;
        else
            error('ErrorTAG:TagName', strcat (' No pre-defined segmentation found in Workspace.', ...
                  '\n Please specify input segmentation to be processed.') );
        end
    else
        CCname = inputname(1);
    end
	%display segmentation being classified
	disp(['Filter border object type within segmentation ',CCname,' .']); 
	%INPUT ARGUMENT CONTROL:   
    
    
    %get segmentation parameters
    %Xmin = double(0); Xmax = double(CC.object.ImageSize(2));
    %Ymin = double(0); Ymax = double(CC.object.ImageSize(1));
    Zmin = double(1); Zmax = double(CC.object.ImageSize(3));
    NumObj = CC.object.NumObjects;
	Box = CC.box;
    del = zeros(1,1);
    j = 1;
    
	for i = 1:NumObj
        %get bounding-box parameters of each object
        Box_Xmin = Box(i).BoundingBox(1) - 1.5;
        Box_Xmax = Box(i).BoundingBox(1) + Box(i).BoundingBox(4) + 0.5;
        Box_Ymin = Box(i).BoundingBox(2) - 1.5;
        Box_Ymax = Box(i).BoundingBox(2) + Box(i).BoundingBox(5) + 0.5;
        Box_Zmin = Box(i).BoundingBox(3) + 0.5;
        Box_Zmax = Box(i).BoundingBox(3) + Box(i).BoundingBox(6) - 0.5;
        %get boolean variable; true:it's a boundary object 
%         Xmin_TF = ~(Box_Xmin > Xmin);  
%         Xmax_TF = ~(Box_Xmax < Xmax); 
%         Ymin_TF = ~(Box_Ymin > Ymin);  
%         Ymax_TF = ~(Box_Ymax < Ymax); 
        Zmin_TF = ~(Box_Zmin > Zmin);  
        Zmax_TF = ~(Box_Zmax < Zmax); 

        LUF_TF = dataRange(Box_Ymin,Box_Xmin,Box_Zmin);
        LDF_TF = dataRange(Box_Ymax,Box_Xmin,Box_Zmin);
        LUB_TF = dataRange(Box_Ymin,Box_Xmin,Box_Zmax);
        LDB_TF = dataRange(Box_Ymax,Box_Xmin,Box_Zmax);
        RUF_TF = dataRange(Box_Ymin,Box_Xmax,Box_Zmin);
        RDF_TF = dataRange(Box_Ymax,Box_Xmax,Box_Zmin);
        RUB_TF = dataRange(Box_Ymin,Box_Xmax,Box_Zmax);
        RDB_TF = dataRange(Box_Ymax,Box_Xmax,Box_Zmax);
        
        touching_TF = false;
        touching = ' ';
        if (Zmin_TF || Zmax_TF)
            touching_TF = true;            
            %get the touching side information
            if Zmin_TF 
                touching = [touching,'Front '];
            end
            if Zmax_TF 
                touching = [touching,'Back '];
            end
                
        elseif (LUF_TF || LDF_TF || LUB_TF || LDB_TF || RUF_TF || RDF_TF || RUB_TF || RDB_TF)              
            touching_TF = true;           
            %get the touching side information
            if (LUF_TF || LDF_TF || LUB_TF || LDB_TF)
                touching = [touching,'Left '];
            elseif (RUF_TF || RDF_TF || RUB_TF || RDB_TF)
                touching = [touching,'Right '];
            end
            
            if (LUF_TF || LUB_TF || RUF_TF || RUB_TF)
                touching = [touching,'Up '];
            elseif (LDF_TF || LDB_TF || RDF_TF || RDB_TF)
                touching = [touching,'Down '];
            end
        end
           
        if touching_TF         
            disp(sprintf ([' Object number:', num2str(i), ' from segmentation ', CCname, ' is recongnized as a potential border object,', ...
                           '\n With the', touching, 'side touched the boundry of the stack.']));
            
            substack(CC.centre(i).Centroid, DEFAULT_STACK, 'big');
            
            prompt = (' Remove object from analysis or not?(y/n)');
            str = input(prompt,'s'); 
            if (str=='y');
                
                disp(' Object will be removed.');
                fprintf('\n'); 
                %deleteSeg ( CC , i );
                del= vertcat(del,i); j = j + 1;     
            else
                disp(' Object has been kept for further analysis.');
                fprintf('\n');
            end              
           
        end
        
    end
    
    del(1,:)=[];
    MakeMyVar ('del',del);
    disp(' IDs of Objects will be removed is now stored in global variable ''del''.');
%     if strcmp(CCname,'CC_store')
%         CC_store = evalin('base','CC_store');
%         for i = length(del) : -1 : 1
%             deleteSeg( CC_store , del(i));
%         end
%     end
    
end

function MakeMyVar(VarName,VarValue)
    assignin('base',VarName,VarValue);
end