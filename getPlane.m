%
%%
function [A,B,C,D] = getPlane(varargin)

    %INPUT ARGUMENT CONTROL:
    %if input objects is less than 2, quit (impossible to add). consider 0 object            
    if nargin < 3
        if nargin == 1
            p = varargin{1};
            if length(p(1,:)) == 3
                if length(p(:,1)) == 3
                    disp(' Only 3 points are provided, therefore a plane containing these three points will be returned.');
                    [A,B,C,D] = get3(p(1,:),p(2,:),p(3,:));
                elseif length(p(:,2)) > 3
                    disp([' Calculating best fitting plane with ', num2str(length(p(:,2))), ' points using linear Least-Square fitting agorithm.']);
                    [A,B,C,D] = getMany(p);
                else
                    error('ErrorTAG:TagName', strcat (' Provide at least 3 points to determine the best fitting plane.'));
                end
            else
                error('ErrorTAG:TagName', strcat (' Provide proper coordinates of points to determine the best fitting plane.'));
            end
        else
            error('ErrorTAG:TagName', strcat (' Provide at least 3 points to determine the best fitting plane.'));
        end
    elseif nargin == 3
        disp(' Only 3 points are provided, therefore a plane containing these three points will be returned.');
        [A,B,C,D] = get3(varargin{1},varargin{2},varargin{3});
    else
        disp([' Calculating best fitting plane with ', num2str(nargin), ' points using linear Least-Square fitting agorithm.']);
        p = double(zeros(nargin,4));
        for i = 1:nargin
            p(i,:) = varargin{i};
        end
        [A,B,C,D] = getMany(p);
    end
    
	%check if the storage struct has already exist

end  
 
function [A,B,C,D] = get3(p1,p2,p3)

    p0 = double(ones(3,1));
%     p1_x = p1(1); p1_y = p1(2); p1_z = p1(3);
%     p2_x = p2(1); p2_y = p2(2); p2_z = p2(3);
%     p3_x = p3(1); p3_y = p3(2); p3_z = p3(3);
     
    P = vertcat(p1,p2,p3);
    D = det (P);
    %check collinear
    if (D==0)
        A = det(horzcat(p0,P(:,2),P(:,3)));
        B = det(horzcat(P(:,1),p0,P(:,3)));
        C = det(horzcat(P(:,1),P(:,2),p0));
    else
        A = -det(horzcat(p0,P(:,2),P(:,3)))/D;
        B = -det(horzcat(P(:,1),p0,P(:,3)))/D;
        C = -det(horzcat(P(:,1),P(:,2),p0))/D;
        D = 1;
    end
    
    plane = horzcat(A,B,C,D);
    MakeMyVar('plane',plane)
end

function [A,B,C,D] = getMany(p)

    G = double(zeros(length(p),4));
    for i = 1:length(p)
        G(i,[1,2,3]) = p(i,:);
    end
    G(:,4) = double(ones(length(p),1));
    
    [~ , ~, v ] = svd(G,0);
    
    plane = v(:,4);
    [A,B,C,D] = deal(plane);
    plane = permute(plane,[2,1]);
    MakeMyVar('plane',plane);
end

function MakeMyVar(VarName,VarValue)
assignin('base',VarName,VarValue);
end