%
%%
function  getFD(CC)


	%voxelSize = 250; unit = 'nm^3';
    
    %timing function running duration
    disp('Calculating synapse feret diameter...');tic;
    
    PLT = regionprops(CC.object,'PixelList');
     
    DataPath = evalin('base','DataPath');
    
    if strcmp (DataPath(end-1), 'D')
        % apply anisotropic factor "2.5974" for sample 901 and 909
        for i = 1:length(PLT)
            PLT(i).PixelList(:,3) =  2.5974 * (PLT(i).PixelList(:,3));
        end
    else
        % apply anisotropic factor "2"
        for i = 1:length(PLT)
         PLT(i).PixelList(:,3) = 2 * (PLT(i).PixelList(:,3));
        end
    
    end
    
    
    
    FeretDiameterMatrix = zeros(length(PLT));
	for i = 1:length(PLT);
        [~,FeretDiameterMatrix(i)] = minboundsphere(PLT(i).PixelList);
	end
    
    MakeMyVar('ObjFeretDiameter',FeretDiameterMatrix);
    toc;

end


function MakeMyVar(VarName,VarValue)
    assignin('base',VarName,VarValue);
end