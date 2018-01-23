ImageProcessing Scripts for iLastik Segmentations - Part 2


....................................
************************************
How to do the analysis with big stack

1, Make sure the working directory have only 1 '.tif' file, which is the original EM stack;
				        only 1 '.tiff' file, which is the segmentation result;
					only 1 '.xls' file, which is the excel file stores manually identified synapse coordinates;

2, Open the excel file, and the 'iLastik_Crop_info.txt' file;

	-Find the corresponding stack (e.g.: Substack 1, or 2 or 3), and get the correct X-onset, Y-onset and Z-onset;
	-In the excel file, choose the 1st worksheet (should be called A1_all etc), and then type Alt+F8;
	-This brings up the macro dialog window, choose 'GetiLastikStackCoordinates' macro and click 'Run';
	-The macro asked for the X Y and Z onset, type in them correctly according to 'iLastik_Crop_info.txt' file;
	-The new coordinates corresponding to iLastik stack should be created after the 1st worksheet. You can leave it there, the matlab script will automatically load these coordinates later;

3, Doing analysis in Matlab:


In Matlab: 
	1, follow the same proceduare as before (described in 'readme.txt') to do the following:
		stackLoader(path);	%path is the string variable to indicate the data folder (contain the tif, tiff, and xls file indicated above)
		getMark(CC_segII);	%create ID for the segmentations, this will take really long time, be patient;
		getMark(CC_segI,'white'); %also name those false-positive segmentations, this will take even longer, be patient;
		

	2, get pair-wise analysis of distance between segmentation and TrakEM manual identified synapse coordinates:
		getDist(CC_segII,XYZ);    % or getDist(CC_segII);
		
		NOTE1: there will be a new variable created in the base Workspace called 'pairFound'; Basically the second column is the ID from CC_segII,
                       and the third column is IDs from XYZ (manually identified coordinates from excel file); the first column is the inter-pair distance;
                NOTE2: You should use the Distance second threshold calculated from getDist (which display in the command window) to guide you. Verify the
                       first distance that is larger than this threshold and check if it's a correct pair, by using substack function show as follows:

                       substack(CC_segII.centre(30).Centroid,Overlay_marked,'big');	%if the 2nd column is number 30
		       substack(XYZ(70,[2,3,4]),Overlay_marked,'big');			%if the 3rd column is number 70

		       If the above two images are belongs to the same synapse, then you can move on to the next pair, until you found the first pair that
                       is not correct.
                       Once you found the first wrong-pair, you can basically store all the pairs (let's say 76 pairs) before this row right away by doing this:

                       storePair(76);	%store the founded pairs right away, depends on the user provided numbers

		NOTE3: This function will again ask user to verify potential false-negative results (previously with getDist, but maybe different candidates.
                       It's better if you are working with Overlay_marked created in the base Workspace. Then you can immediately get an overview with the 
                       false-negative results with the segmentation results (because many cases those false-negative are detected in false-positive channel, and
                       of course you can take those into analysis later)  


	3, CLEAN UP the segmentations:

		1, Basic segmentation structs operations: store & deleteSeg;

		store(CC_segII,3)	%this is to store the 3rd element of CC_segII into a new struct called CC_store;
		
		NOTE1: CC_store is very important for the analysis, because basically you can store those verified segmentation elements into it and only do analysis on it;
		       (e.g.: getSize(CC_store); getFD(CC_store); etc)
                       You already used it before when you do storePair(num);
		NOTE2: CC_store will be created the first time you store an element; and later stays in the base Workspace; When you run the command again it will keep adding
                       new element in the end of CC_store;
		NOTE3: If you are trying to store an element that already been stored before, the function will warn you about it and return the stored element ID in CC_store
                       to let you check. And therefore it won't store this element twice. Whenever this happens, it might because this element is a merged segmentation, which
                       means it is actually two synapses. And you need to split it later (and don't forget to delete it before you store the splitted result, note it down is
                       recommended).
		NOTE4: To delete an unwanted entry in CC_store (or any other CC structs), you should use 'deleteSeg' command, as following:

                	deleteSeg(CC_store,1);	%this command delete the 1 element of CC_store, it will ask for your confirmation before really delete the element;
		
		NOTE5: deleteSeg also works in different types as following: 
			deleteSeg(CC_store,1,'safe');	
			deleteSeg(CC_store,1,'fast');

			-'prompt' is the default (which means you don't need to type it), which will ask user for confirmation before delete operation;
			-'safe', which will store the deleted element in 'CC_deleted';
			-'fast', directly delete the element without any confirmation;

		NOTE6: If you want to delete multiple elements automatically with deleteSeg, you have to aware each time you deleted an element in the struct, all the
                       element IDs after the one you deleted are updated (which means -1); Therefore you should do the following to avoid mistakes:

                       1, create a 1-d array stores all the element IDs you want to delete:

				deleteID = [2;3;5;7;11;13;19];	%I want to delete element 2,3,5,7,11,13,19 of a given struct;

		       2, use the following batch deleting command with deleteSeg:

				deleteSeg(CC_store,deleteID,'fast');
				deleteSeg(CC_store,deleteID,'safe');

			 NOTE: The key point of this operation is (hidden in the script) first sort the element from max to min values (which means for
                               this example: 19;13;11;7;5;3;2). And then operate them in a loop to delete all the elements. In this way there won't be 
			       mistakes with updated ID.


		2, get rid of false-negative and false-positive segmentations:
			- Unfortunately till now (and probably also in the future) this part is highly rely on manual identification.
			- Good thing is we have already done most of this by doing 'getDist' and 'storePair(num)': Those false-positive segmentations are not
                          stored when you did "storePair(76);
                        - Before you checked those false-negative segmentations. Now it is the time to use this result. You can simply store the non-false-negative
                          result into CC_store by using store(CC_seg,num);

                   NOTE: It's not ideal that you have to consider also the split/merge problem at this stage. This means if you have already found some split/merge 
                         mistake together with false-negative result (e.g.: the missing synapse is consist of several segmentations from CC_segI, the false-positive channel)
                         There is not up-to-date automatic approach or better sequence of this problem. I suggest to always keep a form or piece of paper to note down the
                         information of those problematic segmentations: what are they, what needed to be done to them before proceed to analysis.      

		2, get rid of splitted segmentations:
			
			merge(CC_segII,2,4,5);
			
			NOTE1: The 'merge' function can merge several segmentation together linearly. 
			       You should provide the segmentation struct (CC_segII or CC_segI or CC_store), and which elements
                               you would like to merge together; Note it's currenly not working if you want to merge elements from
                               different structs (e.g.: CC_segI - 3 and CC_segI - 4);
			       So if you need to merge the above example, you will have to do the following alternatives:
			       		store(CC_segII,3);	%and check which is the element for this in CC_store, it should be the last, let's say 77
			       		store(CC_segI,4);	%following 77, it should be element 78
			       		merge(CC_store,75,76);  %in this way you get a new element in CC_merged, with the two element from two structs;
			       Don't forget to delete the temporary stored segmentations 77 and 78 in CC_store (sorry for this inconvenience...)

			 NOTE2: Some information is retrievable in CC_merged.object.OriIdx; However it's not always keep everything (e.g.: last manipulation you won't be
                                able to know which two you merged except CC_store 77, 78).      

		3, get rid of merged segmentations (THIS IS VERY TRICKY OPERATION, with some bugs):

			split(CC_segII,76);
			
			NOTE1: The 'split' function can split a segmentation into two segmentations, based on a user-defined separation plane.  
  
			NOTE2: You should strickly follow the following steps to get it properly done:

                              - You will be showed two images: a stack around the proposed segmentation object, and a 2-d image of the same object;
                              - You should first browse throught the stack, to get an idea how you will split it;
                              - Once you are ready, highlight the 2d image (It's very important, otherwise it won't work) by clicking on the title of it;
                              - Then type in the command window of matlab a slice number (the one you want to start, when browsing through the 3d stack): e.g: 87;
                              - The 2d image will be updated to the slice, and you will be provide a cross to working with, click onto the2d image to provide the
                                splitting points; You can click as much as you like, but try to do it precise, and keep thinking a little in 3d;
                              - Once you are done with this slice, hit 'Enter', and then type a new slice number in the command window: e.g: 91; KEEP THE 2D IMAGE
                                highlighted all the time, this is very important;
                              - Repeat last two steps until you are satisfied with the splitting points you provided; Then type 's' in the command window instead
                                a slice number to terminate this manual selection.
                              - A figure with the 3d distribution of your points will be showed, a fitting plane will be calculated. You will be asked to display
                                it or not. Type 'y' in the command window if you are satisfied with the points and want to see the plane;
                              - Then the fitting plane will be displayed onto the points; The figure will update, and you can zoom in, rotate to see if the 3d plane
                                looks reasonable (should go through most of the points you provided);
                              - If you satisfied with the plane, type 'y' in the command window; The function will split the segmentation base on this plane. The
                                splitted result will be stored in a new variable called 'CC_splited' in the workspace. Verify the splitting result by doing this:
 
                                substack(CC_splited.centre(1).Centroid,Overlay_marked,'big')
                                substack(CC_splited.centre(2).Centroid,Overlay_marked,'big')

 			 	This is to visualize the new centre of the two segmentation splitted, indicated by the green-cross;

                              - If it looks reasonable, then store them (or 1 of the two) into the CC_store;

			NOTE3: Once you finished with one, delete CC_splited in workspace to work on the next splitting (Because each time you can only split one segmentation).
                               You have to do this manually by right-click on the variable 'CC_splited', and choose delete;

		4, get rid of border segmentations (probably won't work very precise with whole stack, I need to think and work on this. before that, feel free to try):

			borderFilter(CC_store);
			
			NOTE1: This command will display all the border object one by one, for user to verify them;  
  
			NOTE2: The border information (which side is touching the border) will be displayed in the command window;
			-This part you need to make your own judgement on should you remove this object or not (because touching the border doesn't necessarily mean it 
                         is not complete; Also if you are doing analysis with parameters that won't affected by the border.
			-When iterating throught the border objects, you will be asked if this object you want to remove later. In the end you will be provided a list of 
                         the objects you want to delete, and stored in the variable called 'del' in base Workspace. If you are sure you want to delete them, you can use the
                         following command:
 
                         for i = length(del) : -1 : 1
				deleteSeg( CC_store, del(i), 'fast' );	% In this way you won't mis-delete unwanted elements;
			 end

	3, get feret diameter:

	 getFD(CC_store);
			
	NOTE1: The Feret diameter is the minimum bounding sphere of the 3d synapase (so it get rid of the pre/post synaptic density created volume differences; or it treat asymmetric and symmetric synapse more equal);
	
	NOTE2: It take quite long to run this command. But it won't need too much RAM. So you can do something else when let Matlab working on this.

NOTE: You should always save the key parameters in the workspace (e.g.:CC_store) to disk, and use that for analysis later.

NOTE: Don't forget the different pixel size in D1 and D2 stacks.

NOTE: In some case the huge stack (like those 800 or 1000 slices stack) won't work, then just skip it and leave it to me. There is not very convenient Matlab handling method for this right now. I will see how can we proceed (probably have to crop it again 400 by 400 slices or something like that).
