
function findPair(CC,Cor);

% DEFAULT_TYPE = 'all';
% if nargin < 3
%     type = DEFAULT_TYPE;
% end
% 
% switch type
%     case 'all';
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
%     case 'debug';   %get 3 segmentations: all, positive, false-positive
       %get connect component of segmentations    
        
       sizeRaw = size(Cor,1);
       sizeSeg = size(CC.centre(:,1),1);
       
       rawCor=Cor;
       segCor = double(zeros(sizeSeg,3));
       
       for i = 1:sizeSeg
            segCor(i,:,:)=CC.centre(i).Centroid;
       end     
       
       distMatrix=pdist2(segCor,rawCor(:,[2,3,4]));
       
       
       
%         output_All = struct('object',CC_All,'area',Area_All,'volume',Vol_All,'centre',Cent_All);
%         output_I = struct('object',CC_I,'area',Area_I,'volume',Vol_I,'centre',Cent_I);
%         output_II = struct('object',CC_II,'area',Area_II,'volume',Vol_II,'centre',Cent_II);

        %get false negative segmentations
        minDist = permute(min(distMatrix),[2,1]);
        outLiner = minDist((minDist<(mean(minDist)-std(minDist)))|(minDist>(mean(minDist)+std(minDist))));
        [~,index]=ismember(outLiner,minDist);
        outLiner(:,2)=index;


        MakeMyVar('distMatrix',distMatrix);
        MakeMyVar('outLiner',outLiner);
        MakeMyVar('minDist',minDist);
%         return;
% end

end

function MakeMyVar(VarName,VarValue)
assignin('base',VarName,VarValue)
end