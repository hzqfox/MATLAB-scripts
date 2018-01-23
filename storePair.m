%
function storePair(num)


	if ~evalin('base','exist(''pairFound'',''var'')')
        error(message(' distance-pair (default:pairFound) hasn''t been created in Workspace yet. Run getDist to create this parameter'));
	end

	TF = true;   
    if evalin('base','exist(''Overlay_marked'',''var'')')
        DEFAULT_COLOR_STACK = evalin('base','Overlay_marked');
    elseif evalin('base','exist(''Overlay'',''var'')')
        DEFAULT_COLOR_STACK = evalin('base','Overlay');
    else    
        TF = false;
    end
    
    CC_segII = evalin('base','CC_segII');
    pairFound = evalin('base','pairFound');
    pF = pairFound(1:num,:);
    XYZ = evalin('base','XYZ');

	for i = 1:num
        store(CC_segII,pF(i,2));	%if the first wrong pair you found is row 77
	end
    
% 	FP = double(zeros(1,1));
%     for j = 1:length(XYZ)
%         if ~ismember(j,pF(:,3))
%             FP = vertcat(FP,j); %#ok<AGROW>
%         end
%     end
%     FP(1,:)=[];
%     
% 	if ~isempty(FP)
%             prompt = ([num2str(length(FP)),' possible false-negative result detected, verify them now or not?(y/n)']);
%             str = input(prompt,'s'); 
%             if (str=='n');
%                 disp('You can verify false-negative segmentation later, but keep in mind of its existence');
%                 return;
%                 
%             else                            
%                 if TF
%                     VerifyFalseNegativePair(FP);
%                 else
%                     disp('There is no point to verify false-negative result without overlay image stack. Create overlay stack first.');
%                     return;
%                 end              
%             end
% 	end
% 
%    
%     %make up the new joint segmentation
%     MakeMyVar('FP',FP);
% 
% 
% 
% 
%     function VerifyFalseNegativePair(FP)
%     
%         
%         for k = 1:length(FP)           
%             %display XYZ centroid with rawStack
%             disp(['Verifying false-negative segmentation number ',num2str(k),'. Object info(XYZ#:',num2str(FP(k)),')']);
%             substack(XYZ(FP(k),[2,3,4]), DEFAULT_COLOR_STACK, 'big');           
%             prompt = 'Continue to the next?(y/n)';
%             str = input(prompt,'s');
%                 if (str=='n');
%                     return;
%                 else
%                     continue;
%                 end  
%         end
%                    
%         disp('Verifying false-postive detection terminated, candidates have been saved into global variable "FP".');
%             
%     end

end



function MakeMyVar(VarName,VarValue)
    assignin('base',VarName,VarValue);
end