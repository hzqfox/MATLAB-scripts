
function getDist2(CC,Cor)

% DEFAULT_TYPE = 'fast';
% if nargin < 3
%     type = DEFAULT_TYPE;
% end
% 
% switch type
%     case 'fast';
%         seg_All = (mask~=0);
%         CC_All = bwconncomp(seg_All,26);            %get connect component of segmentations
% %         Area_All = bwarea(seg_All);                 %get surface area of segmentations
%         Vol_All = regionprops(CC_All,'Area');       %get volume of segmentations
%         Cent_All = regionprops(CC_All,'Centroid');  %get centroid of segmentations
%  %       output = struct('object',CC_All,'area',Area_All,'volume',Vol_All,'centre',Cent_All);
%         output = struct('object',CC_All,'volume',Vol_All,'centre',Cent_All);
%         MakeMyVar('CC_segAll',output);
%         
%         return;
%         
%     case 'accurate';   %get distance measure from minimum distance of
       %get connect component of segmentations    
 
    %Show result from pre-defined stacks in base Workspace   
    TF = true;   
    if evalin('base','exist(''rawStack'',''var'')')
        DEFAULT_STACK = evalin('base','rawStack');
	else
        TF = false;
    end
    
    if evalin('base','exist(''Overlay_marked'',''var'')')
        DEFAULT_COLOR_STACK = evalin('base','Overlay_marked');
    elseif evalin('base','exist(''Overlay'',''var'')')
        DEFAULT_COLOR_STACK = evalin('base','Overlay');
    elseif evalin('base','exist(''rawStack'',''var'')')
        DEFAULT_COLOR_STACK = DEFAULT_STACK;
    end
    
    %INPUT ARGUMENT CONTROL:
    %if not specified otherwise, DO distance analysis on CC_segII and XYZ             
    if nargin == 0;
        CC = evalin('base','CC_segAll');
        Cor = evalin('base','XYZ');
    %if not specified otherwise, DO distance analysis on XYZ with 1st user
    %input
    elseif nargin == 1;
        Cor = evalin('base','XYZ');
    end
    
    %get pixel list from CC
    PixelList = regionprops(CC.object,'PixelList');
    
    splitFactor = 2;
    
    numOfCor = length(Cor);   
       
	for index = 1:length(PixelList);
        distMatrix(index,:)= min(pdist2(PixelList(index).PixelList,Cor(:,[2,3,4]))); %#ok<AGROW>
	end
    
    M = cell2mat(arrayfun(@(i) sort(distMatrix(:, i)), 1:size(distMatrix, 2), 'uni', false));
	hFig = figure('Name','Distance Matrix log Plot','Visible','off','NumberTitle','off');
	%figure(hFig),imagesc([0 500],[0 50],log(M));
    figure(hFig),imagesc(log(M));
    set(gcf,'Position', [350, 500, 1200, 500]);
    xlabel('Objects ID'); ylabel('Object''s distance to segmentation objects - sorted');
    %zoom yon; zoom(4);
    
    distMatrixSorted = sort(reshape(distMatrix,[],1));
    threshold1 = ceil(distMatrixSorted(round(numOfCor*splitFactor)));
    %NumPair = length(find(distMatrix<threshold1));
    %disp(['Distance first threshold calculated as ',num2str(threshold1),' pixels (split factor:',num2str(splitFactor),')']);
   
    pairFound(:,1) = distMatrix(distMatrix < threshold1);
    [pairFound(:,2), pairFound(:,3)]=find(distMatrix < threshold1);
    
    
    pairDistSorted = sort(pairFound(:,1));
    [~,maxIndex] = max(diff(pairDistSorted));
    threshold2 = ceil(pairDistSorted(maxIndex));
    NumClosePair = length(find(distMatrix<threshold2));
    if length(find(distMatrix<threshold2))>numOfCor
         error('ErrorTAG:TagName', strcat ('extreme-close pair found more than ground truth object number.', ...
                '\nThis means current segmentation result is not proper for further analysis!') );
    else
        disp(['close-pair distance threshold calculated as ',num2str(threshold2),' pixels (extreme-close pair found:',num2str(NumClosePair),')']);
    end
       

        %get false negative segmentations
        %[minDist(:,1),minDist(:,2)] = (min(distMatrix));
        %minDist = permute(minDist,[2,1]);
        %get out
%         outLiner = minDist((minDist<(mean(minDist)-std(minDist)))|(minDist>(mean(minDist)+std(minDist))));
%         [~,index]=ismember(outLiner,minDist);
%         outLiner(:,2)=index;

        MakeMyVar('DistanceThreshold',threshold2);
        MakeMyVar('distMatrix',distMatrix);
        
        %MakeMyVar('minDist',minDist);
%         return;

    %get sorted pairFound-matrix, and truncate it at threshold2
    pF = sortrows(pairFound,1);
 	pFt = pF(1:NumClosePair,:);
    
    MakeMyVar('pairFound',pF);
    
    %exam if there is non-unique extreme-close pair (two objects spatially
    %too close that can cause this, and therefore better to be verified).
    nonUniquePair = (length(pFt))-(length(unique(pFt(:,2))));
    if  nonUniquePair~=0
        while (1)
            prompt = ([num2str(nonUniquePair),' extreme-close pairs are not unique, verify them now?(y/n)']);
            str = input(prompt,'s'); 
            if (str=='n');
                disp('You can verify non-unique extreme-close pair later, but keep in mind of it before store them');
                break;              
            else
                if TF
                    VerifyClosePair(pFt);
                    break;
                else
                    disp('Can not verify non-unique close pair without image stack. Load image stack first.');
                    break;
                end
            end
        end
    end

    
	%exam if there is false-negative segmentation (identified in Ground-Truth but not in segmentation, better to be verified).
    freqXYZ = tabulate(pFt(:,3));
    fnXYZ = length(find(freqXYZ(:,2)==0));
    numOfFN = max(pFt(:,3));     %get missing FN pairs in the end;    
    fnXYZ = fnXYZ + numOfCor - numOfFN;
    if fnXYZ>0
            prompt = ([num2str(fnXYZ),' possible false-negative segmentation detected, verify them now or not?(y/n)']);
            str = input(prompt,'s'); 
            if (str=='n');
                disp('You can verify false-negative segmentation later, but keep in mind of its existence');
            else                            
                if TF
                    VerifyFalseNegativePair(freqXYZ);
                else
                    disp('Can not verify false-negative segmentation without image stack. Load image stack first.');
                end              
            end
    end
    
    
    [n, bin]=histc(pF(1:maxIndex,3),unique(pF(1:maxIndex,3)));
    multiple = find(n>1);
    index = find(ismember(bin,multiple));
    
	if  ~isempty(index)
        while (1)
            prompt = ([num2str(nonUniquePair),' split object found, verify them now?(y/n)']);
            str = input(prompt,'s'); 
            if (str=='n');
                disp('You can verify split object later, but keep in mind of it before store them');
                break;              
            else
                if TF
                    VerifySplitObject (pF, index);
                    return;
                else
                    disp('Can not verify split object without image stack. Load image stack first.');
                    return;
                end
            end
        end
	end   
    
    
    

    function VerifyClosePair(pF)
 
        table = tabulate(pF(:,2));
        repeatElement = table(table(:,2)>1);
        
        for j = 1:length(repeatElement)            
            %display CC centroid with rawStack
            substack(CC.centre(repeatElement(j)).Centroid, DEFAULT_COLOR_STACK, 'big');
            set(gcf,'Position', [600, 600, 500, 400]);
            %get number of close-pair
            indices = find(pF(:,2)==repeatElement(j));
            Num_ClosePair = length(indices);
            for k = 1:Num_ClosePair
                XYZNum = pF(indices(k),3);
                disp(['Verifying the non-unique extreme-close pair number ',num2str(j),'. Pair info(CC#:', num2str(repeatElement(j)),'; XYZ#:',num2str(XYZNum),')']);
                    substack(Cor(XYZNum,[2,3,4]), DEFAULT_STACK, 'big');
                    set(gcf,'Position', [((1750-550*Num_ClosePair)/2+550*(k-1)), 100, 500, 400]);
            end            
            prompt = 'Continue to the next?(y/n)';
            str = input(prompt,'s');
            if (str=='n');
                return;
            else
                continue;
            end            
        end       
        disp('Verifying non-unique extreme-close pair terminated. Make sure you have saved the verified pair info.');           
    end
    
    %close all;

    function VerifyFalseNegativePair(fq)
    
        FN = fq(fq(:,2)==0);
        MakeMyVar('FN',FN);
        
        figure;
        for i = 1:length(FN)           
            %display XYZ centroid with rawStack
            disp(['Verifying false-negative segmentation number ',num2str(i),'. Object info(XYZ#:',num2str(FN(i)),')']);
%             substack(Cor(FN(i),[2,3,4]), DEFAULT_COLOR_STACK, 'big');
%             substack(Cor(FN(i),[2,3,4]), DEFAULT_STACK, 'big');   
            stackViewer2(Cor(FN(i),[2,3,4]), 'big');
            prompt = strcat ('Type the number of object in the left panel if there is a segmentation object for this synapse,', ...
                    '\nOr hit "Enter" if it is a true false-negative (missing) segmentation:', ...
                    '\nOtherwise type "n" if you want to terminate verifying the false-negative segmentations:') ;
            str = input(prompt,'s');
                if (str=='n');
                    return;
                elseif (isnumeric(str))
                    disp('input is number');
                else
                    continue;
                end  
        end
        
        %numOfFN = max(pFt(:,3);
        if (numOfFN < numOfCor)
            for i = numOfFN+1:numOfCor
                %display XYZ centroid with rawStack
                disp(['Verifying false-negative detection number ',num2str(i),'. Object info(XYZ#:',num2str(i),')']);
                substack(Cor(i,[2,3,4]), DEFAULT_COLOR_STACK, 'big');
                substack(Cor(i,[2,3,4]), DEFAULT_STACK, 'big');           
                prompt = 'Continue to the next?(y/n)';
                str = input(prompt,'s');
                if (str=='n');
                    return;
                else
                    continue;
                end  
            end
        end
                   
        disp('Verifying false-negative detection terminated. pairs have been saved into global variable "FN".');
            
    end

	function VerifySplitObject (pF, index)
        
        %CCsplit = pF(index,2)
        XYZsplit = unique(sort(pF(index,3)));
        
        %figure;
        for k = 1:length(XYZsplit)            
            %display CC centroid with rawStack
            %XYZNum = pF(index(k),3);
                %disp(['Verifying the split object number ',num2str(k),'. Pair info(CC#:', num2str(index),'; XYZ#:',num2str(XYZNum),')']);
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


	end

function MakeMyVar(VarName,VarValue)
assignin('base',VarName,VarValue)
end
