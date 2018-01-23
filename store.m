function store(CC2, num)

    %check if the storage struct has already exist
    if evalin('base','exist(''CC_store'',''var'')')
        CC1 = evalin('base','CC_store');
    %if not, then create a new storage struct in the base workspace
    else
        CC1 = struct;
    end

    %check if the element number specified, if not then copy the whole
    %struct into storage
%     if nargin < 2
%         CC1 = CC2;
%         MakeMyVar('CC_store',CC1);
%         return;
%     end

    %check if the storage struct CC1 is empty, if not then add the new
    %element in the end of each sub-field
    if isequal(fieldnames(CC1),fieldnames(CC2))


        %check if the specified element has already been stored, if so then
        %terminate the function run, and display message.
        PIL1 = CC1.object.PixelIdxList;
        PIL2 = CC2.object.PixelIdxList(num);
        for i = 1:length(PIL1)
            if isequal(PIL2,PIL1(i))
                disp(['Elemet number ',num2str(num),' from ',inputname(1),' is already stored into CC_store with entry number ',num2str(i),'.']);
            return;
            end
        end

        %store the element into storage struct CC1(CC_storage)
        lengthCC1 = length(CC1.object.PixelIdxList);
        CC1.object.NumObjects = CC1.object.NumObjects + 1;
        CC1.object.PixelIdxList{lengthCC1+1} = CC2.object.PixelIdxList{num};
%         CC1.object.OriIdx(lengthCC1+1,1) = inputname(1);
 %       CC1.object1.OriIdx{lengthCC1+1,1} = [inputname(1),num2str(num)];
        CC1.object.OriIdx{lengthCC1+1,1} = inputname(1);
        CC1.object.OriIdx{lengthCC1+1,2} = num2str(num);
        CC1.volume(lengthCC1+1,1) = CC2.volume(num);
        CC1.centre(lengthCC1+1,1) = CC2.centre(num);
        CC1.box(lengthCC1+1,1) = CC2.box(num);
        

    %if the storage struct CC1 is empty, format the struct based on CC2,
    %and store the element into the first entry
    else
        object1 = CC2.object;
        object1.NumObjects = 1;
        object1.PixelIdxList(:) = [];
        object1.PixelIdxList{1} = CC2.object.PixelIdxList{num};
        object1.OriIdx{1,1} = inputname(1);
        object1.OriIdx{1,2} = num2str(num);
        %object1.OriIdx(1,2) = num;
        CC1 = struct('object',object1,'volume',CC2.volume(num),'centre',CC2.centre(num),'box',CC2.box(num));
    end
    
    %update the base workspace storage struct CC_store
	MakeMyVar('CC_store',CC1);
	return;
        
end

function MakeMyVar(VarName,VarValue)
	assignin('base',VarName,VarValue)
end
