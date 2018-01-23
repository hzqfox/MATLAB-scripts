function [Coordinate, avgDist, sem] = getInterSynapseDist( filename )
%Calculate inter-synapse distance from serial-section SEM dataset &
%dissector notification result


    if nargin < 1
        [FileName,PathName] =  uigetfile('*.txt','Select the Excel file contains coordinates','D:\Program Files\MATLAB\ImageProcessing\Synapse_Segmentation');
        filename = strcat(PathName,FileName);
    end
    
    
    s = importdata(filename);
    XYZ = s.data(:,3:5);
    
    Z = unique(XYZ(:,3));
    refZ = min(Z);
    
    syn = XYZ((XYZ(:,3)==refZ),:);
    Coordinate = syn;
    
     distMatrix = pdist2(syn,syn);
%     close all;
%     figure,imagesc(distMatrix);
%     
    L = tril(distMatrix);
    distArray = (L(L~=0));
    
    avgDist = mean(distArray);
    sem = std(distArray)/sqrt(length(distArray));
%     
%     figure,hist(distArray);figure,boxplot(distArray);


end

