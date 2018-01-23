
function [x,y,z] = getPoint(point,type)

    DEFAULT_TYPE = 'default';
    if nargin < 2;
        type = DEFAULT_TYPE;
    end
 
    %if input is 1x1 struct with only one field stores point coordinates
    if isstruct(point) == 1;
        fn = fieldnames(point);
        xyz = getfield(point,fn{1});
        x= xyz(1);
        y= xyz(2);
        z= xyz(3);
	elseif length(point) == 3;
        x=point(1,1);
        y=point(1,2);
        z=point(1,3);
    else
        disp('The input coordinate can not be resolved, make sure input is X-Y-Z coordinate of a single point');
        return;
    end

	switch type
        case 'default';
            x = single(x);
            y = single(y);
            z = single(z);
        case 'round';     
            x = round(x);
            y = round(y);
            z = round(z);
	end

    disp(['Coordinate resolved as [X:',num2str(x),'; Y:',num2str(y),'; Z:',num2str(z),']']);

%     For debugging, to validate the input coordinate 
%     while (1)   
%         prompt = 'Verify whether it is correct or not.(y/n)';
%         str = input(prompt,'s'); 
%         if (str=='y');
%             return;             
%         elseif (str=='n');
%             error('The input coordinate can not be resolved, make sure input is X-Y-Z coordinate of a single point');  
%         else
%             disp('invalid input!');
%             continue;         
%         end
%     end
%     For debugging, to validate the input coordinate 


end