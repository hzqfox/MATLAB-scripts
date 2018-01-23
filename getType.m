%
%%
function  getType(CC)

    %INPUT ARGUMENT CONTROL:
    %get default segmentation in case no input specified
	if evalin('base','exist(''CC_store'',''var'')')
        DEFAULT_CC = evalin('base','CC_store');
        CCname = 'CC_store';
    elseif evalin('base','exist(''CC_segII'',''var'')')
        DEFAULT_CC = evalin('base','CC_segII');
        CCname = 'CC_segII';
        fprintf ([' No stored segmentation found.', ...
                       '\n CC_segII will be used if there''s no input segmentation specified.', ... 
                       '\n Be aware normally CC_segII contains only the raw segmentation.']);
	end       
    %check input argument
    
    if evalin('base','exist(''DistanceThreshold'',''var'')')
        Threshold = evalin('base','DistanceThreshold');
    else
        Threshold = 4;
        fprintf ([' Distance Threshold not found in workspace.', ...
                       '\n 4-pixels will be used as distance threshold.', ... 
                       '\n A better distance threshold can be calculated and created by running getDist2(CC_store).']);
    end       
    
    
    if nargin ~= 0
        CCname = inputname(1);
    else
        if exist('DEFAULT_CC','var')
            CC = DEFAULT_CC;
        else
            error('ErrorTAG:TagName', strcat (' No pre-defined segmentation found in Workspace.', ...
                  '\n Specify input segmentation to be classified, or load a meaningful segmentation in the Workspace.') );
        end
    end
	%display segmentation being classified
	disp(['Classify exc/inh synapse type within segmentation ',CCname,' .']); 
    
    
    %GET ASY AND SYM COORDINATES:
	xFile = evalin('base','Coordinates_File');    
    XYZ_Asy = xlsread(xFile,4);
    XYZ_Sym = xlsread(xFile,6);
    
	PixelList = regionprops(CC.object,'PixelList');
        
    %numOfAsy = length(XYZ_Asy);
    distMatAsy = double(zeros(length(PixelList),length(XYZ_Asy)));
	for i = 1:length(PixelList);
        distMatAsy(i,:)= min(pdist2(PixelList(i).PixelList,XYZ_Asy(:,[2,3,4])));
	end
% 	M = cell2mat(arrayfun(@(i) sort(distMatAsy(:, i)), 1:size(distMatAsy, 2), 'uni', false));
% 	hFig = figure('Name','Distance Matrix of Asymmetric Synapse log Plot','Visible','off','NumberTitle','off');
% 	figure(hFig),imagesc(log(M));
%     xlabel('Objects ID'); ylabel('Object''s distance to segmentation objects - sorted');
    
	%numOfSym = length(XYZ_Sym); 
    distMatSym = double(zeros(length(PixelList),length(XYZ_Sym)));
	for i = 1:length(PixelList);
        distMatSym(i,:)= min(pdist2(PixelList(i).PixelList,XYZ_Sym(:,[2,3,4])));
	end
% 	N = cell2mat(arrayfun(@(i) sort(distMatSym(:, i)), 1:size(distMatSym, 2), 'uni', false));
% 	hFig = figure('Name','Distance Matrix of Symmetric Synapse log Plot','Visible','off','NumberTitle','off');
% 	figure(hFig),imagesc(log(N));
%     xlabel('Objects ID'); ylabel('Object''s distance to segmentation objects - sorted');
    
%    CC1 = struct('object',object1,'volume',CC2.volume(num),'centre',CC2.centre(num),'box',CC2.box(num));


    %ThresholdAsy = getThreshold2(distMatAsy);
    %ThresholdSym = getThreshold2(distMatSym);
    ThresholdAsy = Threshold;
    ThresholdSym = Threshold;
	%NumClosePair = length(find(distMatrix<threshold2));
    
	pairFoundAsy(:,1) = distMatAsy(distMatAsy < ThresholdAsy);
    [pairFoundAsy(:,2), pairFoundAsy(:,3)]=find(distMatAsy < ThresholdAsy);
    pairFoundAsy = sortrows(pairFoundAsy,1);
    
	pairFoundSym(:,1) = distMatSym(distMatSym < ThresholdSym);
    [pairFoundSym(:,2), pairFoundSym(:,3)]=find(distMatSym < ThresholdSym);
    pairFoundSym = sortrows(pairFoundSym,1);
 
    
	CC_store = evalin('base','CC_store'); 
    evalin('base',['clear ','CC_store']);
    
    for i = 1:length(pairFoundAsy)
        store(CC_store,pairFoundAsy(i,2));
    end    
	CC_Asy = evalin('base','CC_store');   
    MakeMyVar('CC_Asy',CC_Asy);
    evalin('base',['clear ','CC_store']);
    
        
	for i = 1:length(pairFoundSym)
        store(CC_store,pairFoundSym(i,2));
	end   
	CC_Sym = evalin('base','CC_store');   
    MakeMyVar('CC_Sym',CC_Sym);
    evalin('base',['clear ','CC_store']);

    MakeMyVar('CC_store',CC_store);
    %evalin('base','clear(''CC_store'',''var'')')

    MakeMyVar('XYZ_Asy',XYZ_Asy);
    MakeMyVar('XYZ_Sym',XYZ_Sym);
    MakeMyVar('distMatAsy',distMatAsy);
	MakeMyVar('distMatSym',distMatSym);
    MakeMyVar('pairFoundAsy',pairFoundAsy);
    MakeMyVar('pairFoundSym',pairFoundSym);
    
% 	MakeMyVar('CC_Asy',CC_Asy);
% 	MakeMyVar('CC_Sym',CC_Sym);
    
    
end

function threshold = getThreshold2(distMatrix, splitFactor)

	%INPUT ARGUMENT CONTROL:
    DEFAULT_SPLITFACTOR = 2;
    if nargin < 2
        splitFactor = DEFAULT_SPLITFACTOR;
    end
    
	distMatrixSorted = sort(reshape(distMatrix,[],1));
    InitThreshold1 = ceil(distMatrixSorted(round(length(distMatrix(1,:))*splitFactor)));
    %NumPair = length(find(distMatrix<threshold1));
    %disp(['Distance first threshold calculated as ',num2str(InitThreshold1),' pixels (split factor:',num2str(splitFactor),')']);
   
%     pairFound(:,1) = distMatrix(distMatrix < InitThreshold1);
%     [pairFound(:,2), pairFound(:,3)]=find(distMatrix < InitThreshold1);
    
    
    %pairDistSorted = sort(pairFound(:,1));
    
    pairDistSorted = sort(distMatrix(distMatrix < InitThreshold1));
    [~,maxIndex] = max(diff(pairDistSorted));
    threshold = ceil(pairDistSorted(maxIndex));


	if length(find(distMatrix<threshold))> length(distMatrix(1,:))
         error('ErrorTAG:TagName', strcat ('extreme-close pair found more than ground truth object number.', ...
                '\nThis means split factor is very likely larger than 2, segmentation result is not good enough for analysis...') );

	end  

end




%     function VerifyNonUniquePair(distMatrix, threshold)
%  
%         NumClosePair = length(find(distMatrix<threshold));
%       
%         pairFound(:,1) = distMatrix(distMatrix < threshold1);
%         [pairFound(:,2), pairFound(:,3)]=find(distMatrix < threshold1);
%     
% 
%         %get sorted pairFound-matrix, and truncate it at threshold2
%         pF = sortrows(pairFound,1);
%         pFt = pF([1:NumClosePair],:);
%     
%     %here
%     
%         table = tabulate(pF(:,2));
%         repeatElement = table(table(:,2)>1);
%         
%         for j = 1:length(repeatElement)            
%             %display CC centroid with rawStack
%             substack(CC.centre(repeatElement(j)).Centroid, DEFAULT_COLOR_STACK, 'big');
%             %get number of close-pair
%             indices = find(pF(:,2)==repeatElement(j));
%             for k = 1:length(indices)
%                 XYZNum = pF(indices(k),3);
%                 disp(['Verifying the non-unique extreme-close pair number ',num2str(j),'. Pair info(CC#:', num2str(repeatElement(j)),'; XYZ#:',num2str(XYZNum),')']);
%                     substack(Cor(XYZNum,[2,3,4]), DEFAULT_STACK, 'big');
%             end            
%             prompt = 'Continue to the next?(y/n)';
%             str = input(prompt,'s');
%             if (str=='n');
%                 return;
%             else
%                 continue;
%             end            
%         end       
%         disp('Verifying non-unique extreme-close pair terminated. Make sure you have saved the verified pair info.');           
%     end





% function CC_store = storeCC(CC_input, num)
% 
% 
% 
%     %check if the storage struct CC1 is empty, if not then add the new
%     %element in the end of each sub-field
%     if isequal(fieldnames(CC_store),fieldnames(CC_input))
% 
%         %check if the specified element has already been stored, if so then
%         %terminate the function run, and display message.
%         PIL1 = CC_store.object.PixelIdxList;
%         PIL2 = CC_input.object.PixelIdxList(num);
%         for i = 1:length(PIL1)
%             if isequal(PIL2,PIL1(i))
%                 disp(['Elemet number ',num2str(num),' from ',inputname(1),' is already stored into CC_store with entry number ',num2str(i),'.']);
%             return;
%             end
%         end
% 
%         %store the element into storage struct CC1(CC_storage)
%         lengthCC1 = length(CC_store.object.PixelIdxList);
%         CC_store.object.NumObjects = CC_store.object.NumObjects + 1;
%         CC_store.object.PixelIdxList{lengthCC1+1} = CC_input.object.PixelIdxList{num};
% %         CC1.object.OriIdx(lengthCC1+1,1) = inputname(1);
%  %       CC1.object1.OriIdx{lengthCC1+1,1} = [inputname(1),num2str(num)];
%         CC_store.object.OriIdx{lengthCC1+1,1} = inputname(1);
%         CC_store.object.OriIdx{lengthCC1+1,2} = num2str(num);
%         CC_store.volume(lengthCC1+1,1) = CC_input.volume(num);
%         CC_store.centre(lengthCC1+1,1) = CC_input.centre(num);
%         CC_store.box(lengthCC1+1,1) = CC_input.box(num);
%         
% 
%     %if the storage struct CC1 is empty, format the struct based on CC2,
%     %and store the element into the first entry
%     else
%         object1 = CC_input.object;
%         object1.NumObjects = 1;
%         object1.PixelIdxList(:) = [];
%         object1.PixelIdxList{1} = CC_input.object.PixelIdxList{num};
%         object1.OriIdx{1,1} = inputname(1);
%         object1.OriIdx{1,2} = num2str(num);
%         %object1.OriIdx(1,2) = num;
%         CC_store = struct('object',object1,'volume',CC_input.volume(num),'centre',CC_input.centre(num),'box',CC_input.box(num));
%     end
%     
%     %update the base workspace storage struct CC_store
% 	%return;
%         
% end







function MakeMyVar(VarName,VarValue)
assignin('base',VarName,VarValue);
end