ImageProcessing Scripts for iLastik Segmentations


Environment requirement
************************************
Computer: more than 20GB RAM
MS-Office: Excel (with macro enabled)
Matlab: 2013 or higher version



How to setup running environment:
************************************
Data: 
	FIB-SEM stack: in 'tif' format (only one 'f'!!)
        segmentation stack: in 'tiff' format (two 'f's !!)
	coordinates of synapse identified: 'xls' format, data should be on second worksheet.
Matlab: 
	1, Put all the script in one folder, and put the three data files (described above) into
           a folder within the same folder as the scripts.
	2, start matlab, change "current folder" to the folder where the scripts stored. And
	   all the scripts should be already visible on the left side of the matlab panel.

	
How to run the scripts:
************************************

In Matlab: 
	1, create a string variable to indicate the data path, example:
		path = 'D:\iLastikAnalysis\Matlab_Scripts\data_A1';

	2, load the data into matlab base Workspace:
		stackLoader(path);

	      NOTE1: you can also run "stackLoader" without variable, in this case it loads the default 
                    data folder "data_A1" which in the same folder with the scripts.

              NOTE2: the stackLoader will ask if user want to create an overlay image stack while loading.
                     If you are sure you have enough RAM (normally more than 20G) available, you can type "y"
                     to create the overlayed image stack. And the overlay image stack will be created as "Overlay"
                     in the base Workspace. If you don't want to create it, type "n" to skip this step.
		     Be aware input are case-sensitive. The Overlay image stack will display segmentations as red
                     onto the EM stack, and false-positive segmentation will be displayed as blue.
 
              NOTE3: the stackLoader will then ask if user want to get the connected-component from
                     segmentation stack. It's recommend to type "y" here, since it's not memory-demanding and you
                     have to do it anyway before start analysing the segmentations. The connected-component are created
                     then as struct-type variables into base Workspace. "CC_segAll" contains all segmentations, "CC_segI"
		     contains false-positive segmentations, and "CC_segII" contains the positive segmentations.

	3, optional- create water-mark onto the "Overlay" image stack:
		getMark(CC_segII,'black');
		getMark(CC_segI,'white');

		NTOE: this is to display the segmentation ID number onto the image stack, to trace each segmentation
                      object. This may take relatively long time (1000 objects took around 10 minute on my 3.40GHz CPU 
		      and 32GB RAM machine) to get done (depends on how many objects you have in the connected-component
                      structure. you can play around with the font color by change the second input argument ('black',
                      'white','red','yellow' etc...). However 'black' and 'white' are recommended.

        4, get pair-wise analysis of distance between segmentation and TrakEM manual identified synapse coordinates:
		getDist(CC_segII,XYZ);    % or getDist(CC_segII);
		
		NOTE1: this function analyze the pair-wise distance between each connected-component and the manual
		      identified synapse coordinates. It calculate 2 threshold based on the distance: a 1st threshold 
		      that quite large, that beyond this distance (from a manual identified coordinates) it's quite 
                      impossible for any segmentation to be that identified synapse; And a 2nd threshold which is much
                      smaller, that most nicely-identified synapse should be within this distance (from a manual identified
		      coordinates).
		NOTE2: the getDist will display a heatmap to show the pair-wise distance measurement. X-axis will be the manual
		       identified synapse ID, and Y-axis are the segmentations, sorted ascending. Color code is close(blue)->
                       far(red). If segmentation is relatively good, you should see a blue line on top (one to one pair found), 
                       some are orange or red (possible false-negative pair to be verified), and some have more than one block blue
                       (possible split segmentation: one synapse, multiple segmentations).
          	NOTE3: the getDist function will analyze if there's extreme-close pair, which means one segmentations are
                      too close to two manual identification (this normally from a merged segmentation, which two synapses
                      are spatially so close that the segmentation recognize them as one). And if it find any of this case
	              it will ask user to verify them one by one, by type "y". It will display the manual synapse ID in matlab 
		      command window, and three substack for user to check. The one color stack are the segmentation (a green 
                      cross will hightlight the centre of the segmentation), and two black-white stacks are the two manual ID-ed 
                      synapses (a white circle will highlight the centre of the segmentation).

		NOTE4: the getDist function will then analyze the potential false-negative segmentations (missing synapse from 
                       segmentation). It make use of the two thresholds mentioned above, and display each time two image stacks
                       for the user to check: the color stack for user to see if there's any segmentation exist, and correct; and
                       the black-white stack of the original EM image to check if there's a synapse. When it finished, it will store
                       the false-negative pairs automatically into base Workspace with name "FN".

	5, get the volume measurement of the segmentation:
		getSize(CC_segII); 

		NTOE1: this function measures all the objects' volume from the segmentation, and display to user three plots:
		       A raw plot, just the size of each objects with objects' ID; A sorted plot, that size from small to big of
                       all objects; And a volume-step plot, that shows the volume differences between each two objected (small to
                       big sorted). The third plot can help you to find huge jump in size, that may need to take a look. 
		NTOE2: getSize also try to display the out-liner of the segmentation, based on volume measurement. It display the largest
                       object, and the biggest difference found in step of the object.
                       *(I haven't finished this function yet. Initially I wanted to display objects outlined by 1 standard deviation, but
                         all of them are just large synapses. And actually the small ones are more likely to be wrong segmentation, but they
                         are too many to be minority, and not easy to get rid of intuitively. I'm working on that...)

	6, optional- display arbitrary part of the stack:
		stackViewer(rawStack);
		stackViewer(Overlay);
		stackViewer(Overlay_marked);
		substack(XYZ(1,[2,3,4]),Overlay_marked,'big');
		substack(CC_segII.centre(23).Centroid,Overlay_marked,'small');
		substack([256,345,15],rawStack);

		NOTE1: the function "stackViewer" was written to display the 3D stacks, either original EM stack, or overlayed stack, or
		       marked stack. You just need to put the stack you want to display into the barricade. It shows you the slice number
		       and you can scroll with mouse to go through neighbour slices, or use the slider at bottom.
		NOTE2: the function "substack" was written to display a sub-stack around user defined ROI (with coordinates). The coordinates
		       from segmentation is extracted as CC_segII.centre(x).Centroid, play around with "x" to get different object of a 
                       segmentation. Coordinates from manual ID-ed synapse is extracted as XYZ(x,[2,3,4]), play around with "x" to get different
                       object from XYZ. You can also just define a point by [x,y,z], to indicate the ROI coordinates. The second input you can
	 	       choose which image stack you want to display the ROI, and third input you can choose the size of sub-stack ('big','middle'
		       ,'small','tiny').If you just give an coordinates, the function will try to display it with marked color stack, and in middle
                       size.
