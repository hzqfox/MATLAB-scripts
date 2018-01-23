%Stereological Analysis with FIBSEM stack Ziqiang
%%
function [box, Csort, cornerSort, C] = getCorner(slice, dataRange, debug)

    % Define default parameters:
    % If not specified otherwise, find dataRange automatically,
    % and use default slice number.
    DEFAULT_SLICE = 11;  %default slice number is 11;
    DEFAULT_MODE = 1;   %default mode is debug
    
    if nargin < 3
        debug = DEFAULT_MODE;
    end

	% INPUT ARGUMENT CONTROL:    
    % if not specified otherwise, get default parameters:
    if nargin < 2
        if evalin('base','exist(''dataRange'',''var'')')
            dataRange = evalin('base','dataRange');
        else
            if evalin('base','exist(''rawStack'',''var'')')
                rawStack = evalin('base','rawStack');               
            else
                rawStack = fLoad;
            end
            dataRange = getDataRange(rawStack);
        end
        
        if nargin < 1
            slice = DEFAULT_SLICE;
        end            
    end
       
    %timing function running duration
    fprintf (['\nExtracting coordinates of 4 corners of data region of ', num2str(slice), ' slices,'...
              '\nthat equal-distance seperated with each other within the FIBSEM stack...\n']);tic;
  
    if slice > 0      
        C = double(zeros(8,2,slice));
    else
        C = double(zeros(8,2,1));
    end
    [Y,X,Z] = size(dataRange);
    Yt = Y/2; Xt = X/2;
    

    %get the box for the last slice
    if slice > 0
        C_intermediate = corner(dataRange(:,:,Z),8,'QualityLevel',0.15,'SensitivityFactor',0.1);
        C(1:length(C_intermediate),:,slice) = C_intermediate;
    else
        C_intermediate = corner(dataRange(:,:,Z),8,'QualityLevel',0.15,'SensitivityFactor',0.1);
        C(1:length(C_intermediate),:,1) = C_intermediate;
    end    
    
    %if slice number is 0, then return the last slice    
    if slice > 0
        %get the box for the 1st slice
        C_intermediate = corner(dataRange(:,:,1),8,'QualityLevel',0.15,'SensitivityFactor',0.1);
        C(1:length(C_intermediate),:,1) = C_intermediate;

        %factor = Z/(slice-1)
        increment = round(Z/(slice-1));
        %get the boxes for all the slices in the middle        
        for i = 2:slice-1

            C_intermediate = corner(dataRange(:,:,((i-1)*increment+1)),8,'QualityLevel',0.15,'SensitivityFactor',0.1);
            C(1:length(C_intermediate),:,i) = C_intermediate;

        end
    end
    
    if length(size(C)) <3
        [Csort, cornerSort] = sortCorner(C, Yt, Xt, 1);
    else
        [Csort, cornerSort] = sortCorner(C, Yt, Xt, slice);
    end

    [box, boxTF] = getMaxBox (Csort, Yt, Xt);
    
    %validate maximum inscribed cuboid coordinates
    boxTF_GroundTruth = [true,true;false,true;true,false;false,false];
    if isequal(boxTF,boxTF_GroundTruth)
        if debug == 1
            prompt = '\nVerify maximum inscribe box now?(y/n)';
            str = input(prompt,'s');
            if ~strcmp(str, 'n')
                verifyBox (box, dataRange);
            end
            toc;
            return;
        else
            return;
        end
    else
        C = boxTF-boxTF_GroundTruth;
        [row, col] = find(C~=0);
        fprintf (['\n some corner coordinate doesn''t seem to be right...', ...
                  '\n Please verify the following corner(s):\n']);
        for i = 1:length(row)
            fprintf ([' row:', num2str(row(i)), ' column:', num2str(col(i)),';\n']);
        end
        
        toc;
        return;                
    end 
    
end


function [Csort, cornerSort] = sortCorner(C, Yt, Xt, slice)

    Csort = C;
%     corner = [1;2;3;4];
    cornerSort = uint8(ones(4,slice));
    %cornerSort = corner;
    
    for i = 1:slice
        
        Xmin = find(C(:,1,i) < Xt & C(:,1,i) >0 );
        Ymin = find(C(:,2,i) < Yt & C(:,2,i) >0 );
        Xmax = find(C(:,1,i) > Xt);
        Ymax = find(C(:,2,i) > Yt);
        
        corner1 = intersect(Xmin,Ymin);
        corner2 = intersect(Xmax,Ymin);
        corner3 = intersect(Xmin,Ymax);
        corner4 = intersect(Xmax,Ymax);
        
%         cornerX = ismember(corner,Xmin);
%         cornerY = ismember(corner,Ymin);
        
        cornerSort(:,i) = [corner1(1);corner2(1);corner3(1);corner4(1)];
        
%         for j = 1:4
%             if cornerX(j)
%                 if cornerY(j)
%                     cornerSort(1,i)=j;
%                 else
%                     cornerSort(3,i)=j;
%                 end
%             else
%                 if cornerY(j)
%                     cornerSort(2,i)=j;
%                 else
%                     cornerSort(4,i)=j;
%                 end
%             end
%         end
        
        for k = 1:4
             Csort(k,:,i) = C(cornerSort(k,i),:,i);
        end
                                                 
    end
    
%     for i = 1:slice
%         for k = 1:4
%              Csort(k,:,i) = C(uint8(cornerSort(k,i)),:,i);
%         end
%     end

    %Csort;
    %Csort = C;
end

function [box, boxTF] = getMaxBox (Csort, Yt, Xt)

    boxt = double(zeros(4,2));
    boxt(:,1) = Xt; boxt(:,2) = Yt;
    
    box = double(zeros(4,2));
    box(1,1) = max(Csort(1,1,:)); box(1,2) = max(Csort(1,2,:));
    box(2,1) = min(Csort(2,1,:)); box(2,2) = max(Csort(2,2,:));
    box(3,1) = max(Csort(3,1,:)); box(3,2) = min(Csort(3,2,:));
    box(4,1) = min(Csort(4,1,:)); box(4,2) = min(Csort(4,2,:));

    boxTF = box<boxt;
        
end

function verifyBox (box, dataRange)

    Xmin = max(box(1,1),box(3,1));
    Xmax = min(box(2,1),box(4,1));
    Ymin = max(box(1,2),box(2,2));
    Ymax = min(box(3,2),box(4,2)); 
    
    dataRange(Ymin:Ymin+10,Xmin:Xmax,:)=1;
    dataRange(Ymax-10:Ymax,Xmin:Xmax,:)=1;
    dataRange(Ymin:Ymax,Xmin:Xmin+10,:)=1;
    dataRange(Ymin:Ymax,Xmax-10:Xmax,:)=1;
    
    figure,stackViewer(dataRange);


end