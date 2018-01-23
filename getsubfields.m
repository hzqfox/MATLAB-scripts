function getsubfields(obj, header)

names = fieldnames(obj);

for i = 1:length(names)
    if isfield(obj, names{i}) 
        subName = names{i};
        cmd = ['obj.' subName]; 
        if isstruct(eval(cmd)) 
            getsubfields(eval(cmd), [header '.' subName]);
        else
            if(isappdata(0,'structFields'))
                cellArray = getappdata(0,'structFields');
            else
                cellArray = cell(0);
            end 
            cellArray{end+1} = sprintf('%s.%s', header, names{i}); 
            setappdata(0,'structFields',cellArray);
            disp(eval(cmd));
        end
    end
end