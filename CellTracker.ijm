//INFO:  This program tracks all cells at the same time. It excludes cells on edges.

//The final excel files can be merged using the MergeFiles.exe program that you will find in the batchesAndMacros folder. 

path="C:\\Fiji.app\\Batches_and_Macros\\TrackAllObjects_Values_Setup.txt";
data=File.openAsString(path);
lines=split(data);
Dialog.create("Track all objects... ");
Dialog.addCheckbox("Batch Mode?",  lines[9]);
Dialog.addNumber("Particle Size:",  lines[0]);
Dialog.addNumber("Do cell speed every N=",  lines[6]);
Dialog.addNumber("Start from image no.",  1);
Dialog.addNumber("Number of images (set 0 for default)",  lines[7]);
Dialog.addCheckbox("Do Correlation to align images?",  lines[8]);
Dialog.addCheckbox("Use AutoThreshold?",  lines[1]);
Dialog.addNumber("else set Lower Threshold to:",  lines[2]);
Dialog.addNumber("else set Upper Threshold to:",  lines[3]);
Dialog.addCheckbox("Save values to a folder?",  lines[4]);
Dialog.addCheckbox("Preview threshold and cell boundaries?",  lines[5]);

Dialog.show();
batchMode=Dialog.getCheckbox();
particlesize=Dialog.getNumber();
N=Dialog.getNumber();
startfromimage=Dialog.getNumber();
numberImages=Dialog.getNumber();
doCorrelation=Dialog.getCheckbox();
autothreshold=Dialog.getCheckbox();
mythreshold=Dialog.getNumber();
mythresholdupper=Dialog.getNumber();
savetofolder=Dialog.getCheckbox();
previewThreshold=Dialog.getCheckbox();

//SAVE VALUES TO FILE:
f=File.open(path);
print(f,particlesize+" "+autothreshold+" "+mythreshold+" "+mythresholdupper+" "+savetofolder+" "+previewThreshold+" "+N+" "+numberImages+" "+doCorrelation+" "+batchMode); 
File.close(f);


if (batchMode==true){
	setBatchMode(true);	
}


if (previewThreshold==true){
	//run this to check for correct threshold value in first and last slices and a slice one third of the way:

	n=nSlices;
	currentslice=getSliceNumber();
	mywindow=getTitle();
	selectWindow(mywindow);
	setSlice(1);
	run("Duplicate...","title=Slice_1");
	setLocation(0,5);
	run("Duplicate...","title=Slice_1_thresholded");
	setLocation(980,5);
	//setThreshold(mythreshold, 255);
	if (autothreshold==true){setAutoThreshold("Triangle dark");}
	else{setThreshold(mythreshold, mythresholdupper);}
	run("Convert to Mask", "  black");
	run("Duplicate...","title=Slice_1_Outline");
	//setAutoThreshold("Triangle dark"); //for some reason I have to do this again after duplication!! I don't know why..
	setLocation(1960,5);
	//run("Watershed");
	//setAutoThreshold("Default dark");


	run("Analyze Particles...", "size="+particlesize+"-Infinity pixel circularity=0.00-1.00 show=Outlines exclude include in_situ"); //only does 1 image, not stack.
	
	//run("Analyze Particles...", "size=150-Infinity pixel circularity=0.00-1.00 show=Outlines exclude include in_situ"); //only does 1 image, not stack.
	
	
	waitForUser;
	selectWindow("Slice_1");
	close();
	selectWindow("Slice_1_thresholded");
	close();
	selectWindow("Slice_1_Outline");
	close();
	
	selectWindow(mywindow);
	setSlice(floor(n/2));
	run("Duplicate...","title=Slice_"+floor(n/2));
	setLocation(0,5);
	run("Duplicate...","title=Slice_"+floor(n/2)+"_thresholded");
	setLocation(980,5);
	//setThreshold(mythreshold, 255);
	if (autothreshold==true){setAutoThreshold("Triangle dark");}
	else{setThreshold(mythreshold, mythresholdupper);}
	run("Convert to Mask", "  black");
	run("Duplicate...","title=Slice_"+floor(n/2)+"_Outline");
	setLocation(1960,5);	
	run("Watershed");
	run("Analyze Particles...", "size="+particlesize+"-Infinity circularity=0.00-1.00 show=Outlines exclude include in_situ"); //only does 1 image, not stack.
	waitForUser;
	selectWindow("Slice_"+floor(n/2));
	close();
	selectWindow("Slice_"+floor(n/2)+"_thresholded");
	close();
	selectWindow("Slice_"+floor(n/2)+"_Outline");
	close();
	
	selectWindow(mywindow);
	setSlice(n);
	run("Duplicate...","title=Slice_"+n);
	setLocation(0,5);
	run("Duplicate...","title=Slice_"+n+"_thresholded");
	setLocation(980,5);
	//setThreshold(mythreshold, 255);
	if (autothreshold==true){setAutoThreshold("Triangle dark");}
	else{setThreshold(mythreshold, mythresholdupper);}
	run("Convert to Mask", "  black");
	run("Duplicate...","title=Slice_"+n+"_Outline");
	setLocation(1960,5);	
	run("Watershed");
	run("Analyze Particles...", "size="+particlesize+"-Infinity circularity=0.00-1.00 show=Outlines exclude include in_situ"); //only does 1 image, not stack.
	waitForUser;
	selectWindow("Slice_"+n);
	close();
	selectWindow("Slice_"+n+"_thresholded");
	close();
	selectWindow("Slice_"+n+"_Outline");
	close();
	showMessage("Now Starting Tracking...");	
}

//selectWindow(mywindow);
//splitTitle=split(getInfo("slice.label"),"_");
//Pos=splitTitle[2];
//dir="DIR";
scale=1;

if (savetofolder==true){

	path="C:\\Fiji.app\\Batches_and_Macros\\TrackAllObjects_Values.txt";
	data=File.openAsString(path);
	lines=split(data);
	/*showMessage(lines[0]);
	showMessage(lines[1]);
	showMessage(lines[2]);
	showMessage(lines[3]);
	showMessage(lines[4]);
	showMessage(lines[5]);
	showMessage(lines[6]);
	showMessage(lines[7]);
	showMessage(lines[8]);
	showMessage(lines[9]);
	showMessage(lines[10]);*/
	//Choose Left or Right:
	Dialog.create("Choose Folder to Save generated files... ");
	Dialog.addCheckbox("Translate Stacks Using Results Table from File", lines[8]);
	Dialog.addCheckbox("Do multiple positions", lines[9]);
	Dialog.addNumber("First Pos:", lines[10]);
	Dialog.addNumber("Last Pos:", lines[11]);
	Dialog.addString("Left Scale: ", lines[1]);
	Dialog.addString("Right Scale: ", lines[2]);
	Dialog.addCheckbox("Choose Left Scale", lines[3]);
	Dialog.addCheckbox("Choose Right Scale", lines[4]);
	Dialog.addMessage("Parent Folder To Save values:\n\n" + lines[0]); 
	Dialog.addString("Change parent folder?: ", lines[0]);
	//Dialog.addMessage("Subfolder Folder:\n\nTrack"+Pos+"\\");
	//Dialog.addString("Change Subfolder?: ", "Track"+Pos+"\\");
	Dialog.addMessage("Subfolder Folder:\n\n"+lines[5]);
	Dialog.addString("Change Subfolder?: (add dash at end)", lines[5]);
	Dialog.addCheckbox("Open dialog to chose a new Parent folder?", lines[12]);
	Dialog.addString("File Extension?: ", lines[6]);
	Dialog.addCheckbox("Do watershed?", lines[7]);
	Dialog.show();
	translateStackUsingResultsTable=Dialog.getCheckbox();
	domultiple=Dialog.getCheckbox();
	firstpos=Dialog.getNumber();
	lastpos=Dialog.getNumber();
	scaleleft=Dialog.getString();
	scaleright=Dialog.getString();
	chooseleft=Dialog.getCheckbox();
	chooseright=Dialog.getCheckbox();
	if (chooseleft==true) scale=scaleleft;
	if (chooseright==true) scale=scaleright;
	maindir=Dialog.getString();
	subdir=Dialog.getString();
	dir=maindir+subdir;
	newfolder=Dialog.getCheckbox();
	ext=Dialog.getString();	
	dowatershed=Dialog.getCheckbox();
	if (newfolder==true){
		maindir = getDirectory("Choose a Parent Folder"); //alternatively you can do dir = File.openDialog("Select a File"); and dir = File.getParent(File.getParent(dir))+"\\";
		//showMessage(dir);
		//maindir=File.getParent(dir2);
		dir=maindir+subdir;
	}	
	
	if (translateStackUsingResultsTable==true){
		translationValuesPath=File.openDialog("Choose the file that contains translation values:"); 
	}	

	
	showMessage("Data will be saved to "+dir);
	
	//SAVE VALUES TO FILE:
	f=File.open(path);
	print(f,maindir+" "+scaleleft+" "+scaleright+" "+chooseleft+" "+chooseright+" "+subdir+" "+ext+" "+dowatershed+" "+translateStackUsingResultsTable+" "+domultiple+" "+firstpos+" "+lastpos+" "+newfolder); 
	File.close(f);
	//File.makeDirectory(dir);
	//ALSO SAVE VALUES TO RESULTS FOLDER:
	f=File.open(dir+"Analysis_Setup-TrackAllObjects_Values.txt");
	print(f,maindir+" "+scaleleft+" "+scaleright+" "+chooseleft+" "+chooseright+" "+subdir+" "+ext+" "+dowatershed+" "+translateStackUsingResultsTable+" "+domultiple+" "+firstpos+" "+lastpos+" "+newfolder); 
	print(f,"maindir, scaleleft, scaleright, chooseleft, chooseright, subdir, ext, dowatershed, translateStackUsingResultsTable, domultiple, firstpos, lastpos, newfolder"); 
	File.close(f);
	//ALSO SAVE VALUES TO RESULTS FOLDER:
	f=File.open(dir+"Analysis_Setup-TrackAllObjects_Values_Setup.txt");
	print(f,particlesize+" "+autothreshold+" "+mythreshold+" "+mythresholdupper+" "+savetofolder+" "+previewThreshold+" "+N+" "+numberImages+" "+doCorrelation);  
	print(f,"particlesize, autothreshold, mythreshold, mythresholdupper, savetofolder, previewThreshold, N, numberImages, doCorrelation");  	
	File.close(f);
	
}


//create arrays of colors:


c1=newArray(500);
c2=newArray(500);
c3=newArray(500);
for (i=0; i<500;i++){
	c1[i]=floor(random*250);
	c2[i]=floor(random*250);
	c3[i]=floor(random*250);
	while(c1[i] + c2[i]+  c3[i]<500 ){//To make sure the colors have enough brightness
		c1[i]=floor(random*250);
		c2[i]=floor(random*250);
		c3[i]=floor(random*250);
	}
}
//set my favorite colors to the first ones
c1[1]=0;c2[1]=0;c3[1]=250;
c1[2]=0;c2[2]=250;c3[2]=0;
c1[3]=250;c2[3]=0;c3[3]=0;
c1[4]=250;c2[4]=250;c3[4]=0;
c1[5]=0;c2[5]=250;c3[5]=250;
c1[6]=250;c2[6]=250;c3[6]=250;
c1[7]=124;c2[7]=112;c3[7]=199;
c1[8]=4;c2[8]=90;c3[8]=160;
c1[9]=9;c2[9]=242;c3[9]=93;
c1[10]=177;c2[10]=36;c3[10]=235;
c1[11]=221;c2[11]=147;c3[11]=38;
c1[12]=105;c2[12]=110;c3[12]=136;
c1[13]=27;c2[13]=135;c3[13]=226;
//

//LOAD IMAGES
for (z=firstpos; z<=lastpos; z++){  //this for loop is the entire program.
	subdir="Track"+z+"\\";
	dir=maindir+subdir;
	File.makeDirectory(dir);
	//showMessage("open=[" +maindir+ "\Pos"+z+"fl\\");

if (numberImages==0){
	run("Image Sequence...", "open=[" +maindir+ "Pos"+z+"_"+ext+"\\] starting="+startfromimage+" increment=1 scale=100 file=[] or=[] ");
}
else{
	run("Image Sequence...", "open=[" +maindir+ "Pos"+z+"_"+ext+"\\] number="+numberImages+" starting="+startfromimage+" increment=1 scale=100 file=[] or=[] ");
}

mywindow=getTitle();
if (doCorrelation==true){
	runMacro("C:\\Fiji.app\\Batches_and_Macros\\Correlation.ijm");
	run("Duplicate...","title=CroppedCorrelation duplicate");
	selectWindow(mywindow);
	run("Close");
	selectWindow("CroppedCorrelation");
	mywindow=getTitle();
}




//showMessage("open=[" +maindir+ "\\Pos"+z+"_fl_Cam1\\]");
if (translateStackUsingResultsTable==true){
	//first transfer the translation values from file to results table
	if (isOpen("Results")){
		selectWindow("Results");
		print("[Results]","\\Clear") ;
		run("Clear Results");
	}
	filestring=File.openAsString(translationValuesPath); 
	rows=split(filestring, "\n"); 	
	rowslength=rows.length;
	//print(rowslength);	
	for(i=0; i<rowslength-1; i++){ 
		columns=split(rows[i+1],"\t"); 
		setResult("XM", i, columns[1]);
		setResult("YM", i, columns[2]);
	}	
	//now run the macro that does the translation
	runMacro("C:\\Program Files\\Fiji.app\\Batches_and_Macros\\TranslateXandYafterGraphAverageXandY.ijm");
}

//THIS CODE CHOPS UP THE ORIGINAL STACK INTO STACKS OF 100:///////////////////////

//mywindow=getTitle();//remove
selectWindow(mywindow);
numSlicesperStack=102;
if ((nSlices/numSlicesperStack)==(floor(nSlices/numSlicesperStack))){
	nSplitStacks=floor(nSlices/numSlicesperStack);
}
else{
	nSplitStacks=floor(nSlices/numSlicesperStack)+1;
}
if ((nSlices%102)<5){//Remove last stack if it is less than 5 slices long!:
	nSplitStacks=nSplitStacks-1;
}

//showMessage("Stack contains " + nSlices + " slices, that will be split into " +nSplitStacks+" stacks");

for (w=1; w<=nSplitStacks; w++){
	selectWindow(mywindow);
	//showMessage((1+numSlicesperStack*(w-1))+" to "+w*numSlicesperStack);
	run("Duplicate...", "title="+w+" duplicate range="+(1+numSlicesperStack*(w-1))+"-"+(w*numSlicesperStack));
}
///////////////////////////////////////////////////////////////////////////////////
diroriginal=dir;
for (u=1; u<=nSplitStacks; u++){
dir=diroriginal+u+"\\";
File.makeDirectory(dir);
selectWindow(u);
mywindow=getTitle();


//for this macro to work make sure that in analyze>>Set Measurements ONLY CENTER OF MASS, and select 0 decimal places!!!!!! 
run("Set Measurements...", "  center redirect=None decimal=0");
//Also make sure that you have not set a scale that converts pixels to micrometers!!!
//The coordinates of the tracked object are displayed in a window titled CoordinatesTable.

run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel"); //This just in case you have set up a scale which would mess up the tracking.
print("\\Clear");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
//doCommand("Command"); // Runs an ImageJ menu command in a separate thread and returns immediately. As an example, doCommand("Start Animation") starts animating the current stack in a separate thread and the macro continues to execute. Use run("Start Animation") and the macro hangs until the user stops the animation.



run("Remove Overlay");
setSlice(1);
setLocation(1980,5);
run("Duplicate...","duplicate");


if (isOpen("Results")){
	selectWindow("Results");
	print("[Results]","\\Clear") ;
	run("Clear Results");
}
setSlice(1);
myinitialsliceinfo=getInfo("slice.label");
setSlice(nSlices());
myfinalsliceinfo=getInfo("slice.label");
mynumberoflices=nSlices();

//setThreshold(59, 255);

//mythreshold=25;

if (autothreshold==true){run("Convert to Mask", "method=Triangle background=Dark calculate black");} // this calculates a different threshold for each image.
//setAutoThreshold("Triangle dark stack");} //"stack"  does stack histogram, which is a mean of all the slices
else{setThreshold(mythreshold, mythresholdupper);
run("Convert to Mask", "  black");
}

//setAutoThreshold("Default dark stack");    //setAutoThreshold("Default dark");
//showMessage("0");

//showMessage("1");
if (autothreshold==false){
run("Invert", "stack");  //Use this only if using Darkfield instead of Brightfield
}
//showMessage("2");

//run("Dilate", "stack");
//run("Dilate", "stack");

if (dowatershed==true){
	run("Invert", "stack");  //invert if watershed is happening in background of image.	
	run("Watershed", "stack");
	run("Invert", "stack");  //invert if watershed is happening in background of image.	
}

mywindowMask=getTitle();
setSlice(1);
//waitForUser;
//showMessage("3");

run("Analyze Particles...", "size="+particlesize+"-Infinity circularity=0.00-1.00 show=[Outlines] display exclude clear include slice"); //only does 1 image, not stack.
//run("Analyze Particles...", "size=150-Infinity circularity=0.00-1.00 show=[Outlines] display exclude clear include slice"); //only does 1 image, not stack.
//showMessage("4");
currentslice=getTitle();

//to show initial positions:
//run("Duplicate...", "title=Initial_Positions duplicate range=1-1");
//run("Invert");
//setLocation(1080,15);

selectWindow(mywindowMask);



selectWindow(currentslice);
selectWindow("Results");
for (n=1; n<=300; n++){ //Add empty values to result tables to have space for posible extra cells that come into the field of view:
	setResult("XM", nResults, -1);	
	setResult("YM", nResults-1, -1);	
}
updateResults(); //Updates the results table.
previousCoor = split(getInfo(), "\n");
sortedCoor=Array.copy(previousCoor); //This will temporarilly contain the new values assigned to each object.
previousCoorlength=previousCoor.length;
maxlength=previousCoorlength;
setLocation(1080,15);
if (isOpen("DistanceTable")){
	selectWindow("DistanceTable");
	print("[DistanceTable]","\\Clear") ;
}
else { run("Table...", "name=DistanceTable width=450 height=950");}
selectWindow("DistanceTable");
setLocation(1040,5);
//You must first create the heading of the table:
mystring="";
selectWindow(mywindowMask);//this is neccessary for the nSlices in the following line.
for (i=1; i<=nSlices; i++){ //runs through slices.	i<=nSlices
	mystring=mystring+"Slice"+i+"\t";
}
print("[DistanceTable]","\\Headings:Object\t"+mystring);
for (a=1; a<previousCoor.length; a++){ //Prints the number of objects to distance table.
	print("[DistanceTable]",a);	
}

//
if (isOpen("CoordinatesTable")){
	selectWindow("CoordinatesTable");
	print("[CoordinatesTable]","\\Clear") ;
}
else { run("Table...", "name=CoordinatesTable width=450 height=950");}
selectWindow("CoordinatesTable");
setLocation(1120,25);//moves window out of the way so that you can see the tracking.
//You must first create the heading of the table:
mystring="";
selectWindow(mywindowMask);//this is neccessary for the nSlices in the following line.
maskslices=nSlices;
for (i=1; i<=maskslices; i++){ //runs through slices.	i<=nSlices
	mystring=mystring+"Xslice"+i+"\t";
	mystring=mystring+"Yslice"+i+"\t";
}
print("[CoordinatesTable]","\\Headings:Object\t"+mystring);
//
for (a=1; a<previousCoor.length; a++){
	previousCoorValues1 = split(previousCoor[a], "\t"); 
	print("[CoordinatesTable]",a+"\t"+previousCoorValues1[1]+"\t"+previousCoorValues1[2]);	
}

selectWindow(currentslice);

close();
smallestdist=1000;
nearestpos=0;


/*
//draw circles only at the beginning"
selectWindow(mywindow);
setSlice(1);
setColor("red");
for (k=1; k<previousCoorlength; k++){ //for each line of previous slice.	
	previousCoorValues1 = split(previousCoor[k], "\t"); 	
	for (m=1; m<=nSlices; m++){ 
		setLineWidth(3);
		Overlay.drawEllipse(previousCoorValues1[1]-4, previousCoorValues1[2]-4, 8, 8);
		Overlay.show;	
		Overlay.setPosition(m);
	}
}
*/


for (i=2; i<=maskslices; i++){ //runs through slices.	i<=nSlices

	//setBatchMode(true);
	selectWindow(mywindowMask);
	setSlice(i);
	//print("before analyze, at slice "+ i+" added sleep");
	wait(200);
	run("Analyze Particles...", "size="+particlesize+"-Infinity circularity=0.00-1.00 show=[Outlines] display exclude clear include slice"); //only does 1 image, not stack.
	showStatus("Doing Pos "+z+" of "+lastpos+". Stack "+u+" of "+nSplitStacks+". Slice "+i+ " of " +maskslices+".");
	currentslice=getTitle();
	
	selectWindow("Results");
	unsortedCoor = split(getInfo(), "\n");
	resultslength=unsortedCoor.length;

	for (n=1; n<=300; n++){ //Add empty values to result tables to have space for posible extra cells that come into the field of view:
		setResult("XM", nResults, -1);
		setResult("YM", nResults-1, -1);	
	}
	updateResults(); //Updates the results table.
	selectWindow("Results");
	wait(100);// sometimes the next line seems to fail so I add this wait here.. we'll see if that fixes it.
	unsortedCoor = split(getInfo(), "\n");
	unsortedCoorcopy=Array.copy(unsortedCoor);
	//add a new column of zeros to unsortedCoorcopy that will carry the values of the positions that have used each value:
	for (n=0; n<unsortedCoorcopy.length; n++){ 
		unsortedCoorcopy[n]=unsortedCoorcopy[n]+"\t"+0;
	}


	
	//Save current table to array CoordinatesTablelines:
	selectWindow("CoordinatesTable");
	CoordinatesTablelines = split(getInfo(), "\n");
	selectWindow("DistanceTable");
	DistanceTableLines = split(getInfo(), "\n");
	//
	previousCoorlength=previousCoor.length;

	
	
	for (k=1; k<previousCoorlength; k++){ //for each line of previous slice.
		

		previousCoorValues1 = split(previousCoor[k], "\t");  //Obtains values of the position of the first object in the first list.
		if (previousCoorValues1[1]==-1 && previousCoorValues1[2]==-1) { //first skip zero values.
		}
		else{
			smallestdist=1000;
			
			for (m=1; m<resultslength; m++){  //for each line of the second list find the closest object in the second list to the object in the first list.
			
				unsortedCoorValues = split(unsortedCoor[m], "\t"); 
				//print(parseInt(unsortedCoorValues[1])+", "+parseInt(unsortedCoorValues[2])+";  "+parseInt(previousCoorValues1[1])+", "+parseInt(previousCoorValues1[2]));	
				dx=(parseInt(unsortedCoorValues[1])-parseInt(previousCoorValues1[1]));
				dy=(parseInt(unsortedCoorValues[2])-parseInt(previousCoorValues1[2]));
				dx2=dx*dx;
				dy2=dy*dy;
				d=round(sqrt(dx2+dy2));
							
				if (d<smallestdist) { 
					smallestdist=d;
				
					nearestpos=m;
					newpos=unsortedCoorValues[0];	
					newx=unsortedCoorValues[1];
					newy=unsortedCoorValues[2];
					
				}		
			}	
			//set zero the item of unsortedCoorcopy that corresponds to newpos, newx, newy, to keep track of which ones you have used.

			mergedvalue=split(unsortedCoorcopy[newpos], "\t");
			
			if (mergedvalue[1]==-1 && mergedvalue[2]==-1 ){//if this new position is -1,-1 i.e if this new position has already been used, then two cells are merging.
				usedby=mergedvalue[3];
				
				selectWindow("DistanceTable");
				distancelines=split(getInfo(), "\n");
	
				prevdistlines=split(distancelines[usedby],"\t");
				prevdist=prevdistlines[i-1];
				//showMessage("Coordinates of object "+k+" are from ("+previousCoorValues1[1]+","+previousCoorValues1[2]+") to ("+newx+","+newy+") with distance "+smallestdist+"   already used by object "+usedby+" with distance "+prevdist);
				
				
				if (smallestdist>prevdist){
					newx=-1;
					newy=-1;
					smallestdist=-1;
						
				}
				else{
					sortedCoorValues= split(sortedCoor[usedby], "\t"); 
					sortedCoor[usedby]=sortedCoorValues[0]+"\t"+-1+"\t"+-1;
					//sortedCoor[k]=d2s(k,0)+"\t"+d2s(newx,0)+"\t"+d2s(newy,0);
					//showMessage(newpos+"  "+usedby+"  "+(parseInt(usedby)-1)+"  "+CoordinatesTablelines[usedby]);
					print("[CoordinatesTable]","\\Update"+(parseInt(usedby)-1)+":"+CoordinatesTablelines[usedby]+"\t"+-1+"\t"+-1);


					print("[DistanceTable]","\\Update"+(parseInt(usedby)-1)+":"+DistanceTableLines[usedby]+"\t"+-1);
					//make a selection on the slice to remove selection from overlay:
				
				}
					
			}
			else unsortedCoorcopy[newpos]=d2s(newpos,0)+"\t"+-1+"\t"+-1+"\t"+k;
		
			/*commented on 3/13/13
			//This is neccessary if you want to see the values of unsortedCoorcopy:
			if (isOpen("unsortedCoorc")){
				selectWindow("unsortedCoorc");
				print("[unsortedCoorc]","\\Clear") ;
			}
			else { run("Table...", "name=unsortedCoorc width=500 height=950");}	
			//print("[unsortedCoorc]",unsortedCoorcopy);
			print("[unsortedCoorc]","\\Headings:Object\tX\tY\tUsedByObjectNo:\t-\t-\t-\t-\t");
			for (p=1; p<unsortedCoorcopy.length; p++){ 
				unsortedCoorValuescopy = split(unsortedCoorcopy[p], "\t"); 
				print("[unsortedCoorc]",unsortedCoorValuescopy[0]+"\t"+unsortedCoorValuescopy[1]+"\t"+unsortedCoorValuescopy[2]+"\t"+unsortedCoorValuescopy[3]);
			}
			*/
	
			if (smallestdist>40) {
	
				newx=-1;
				newy=-1;
				smallestdist=-1;
							
				}
			
			//print(smallestdist);
			print("[DistanceTable]","\\Update"+k-1+":"+DistanceTableLines[k]+"\t"+smallestdist);
			
			selectWindow("CoordinatesTable");
			
			
			print("[CoordinatesTable]","\\Update"+k-1+":"+CoordinatesTablelines[k]+"\t"+newx+"\t"+newy);
			
			/*
			//draw circle at end:
			setColor("blue");
			Overlay.drawEllipse(newx-4, newy-4, 8, 8);
			Overlay.show;	
			Overlay.setPosition(i);
			*/
			
			
			sortedCoor[k]=d2s(k,0)+"\t"+d2s(newx,0)+"\t"+d2s(newy,0); //new values for each object k. Later on you must transfer these to previousCoor for the next round.
			
		}
	}
	//now deal with zero values:
	for (k=1; k<previousCoorlength; k++){ 
		//print("[unsortedCoorc]","\\Clear") ; //This is neccessary to see the values of unsortedCoorcopy.
		previousCoorValues1 = split(previousCoor[k], "\t");  //Obtains values of the position of the first object in the first list.
		if (previousCoorValues1[1]==-1 && previousCoorValues1[2]==-1) {
			//print("[DistanceTable]","\\Update"+k-1+":"+DistanceTableLines[k]+"\t"+d2s(0,0));
			print("[DistanceTable]","\\Update"+k-1+":"+DistanceTableLines[k]+"\t"+-1);
			//print("[CoordinatesTable]","\\Update"+k-1+":"+CoordinatesTablelines[k]+"\t"+d2s(0,0)+"\t"+d2s(0,0));
			print("[CoordinatesTable]","\\Update"+k-1+":"+CoordinatesTablelines[k]+"\t"+-1+"\t"+-1);
			for (c=1; c<unsortedCoorcopy.length; c++){
				unsortedCoorValuescopy = split(unsortedCoorcopy[c], "\t");  
				if (unsortedCoorValuescopy[1]==-1 && unsortedCoorValuescopy[2]==-1) {
					
				}
				else{
					print("[CoordinatesTable]","\\Update"+k-1+":"+CoordinatesTablelines[k]+"\t"+unsortedCoorValuescopy[1]+"\t"+unsortedCoorValuescopy[2]);
					sortedCoor[k]=d2s(k,0)+"\t"+unsortedCoorValuescopy[1]+"\t"+unsortedCoorValuescopy[2]; //transfers values of the current slice to the previous slice.
					//unsortedCoorcopy[c]=d2s(c,0)+"\t"+d2s(0,0)+"\t"+d2s(0,0);
					unsortedCoorcopy[c]=d2s(c,0)+"\t"+d2s(-1,0)+"\t"+d2s(-1,0)+"\t"+k;
					/*
					for (p=1; p<unsortedCoorcopy.length; p++){ //this for loop can be removed
						unsortedCoorValuescopy = split(unsortedCoorcopy[p], "\t"); 
						print("[unsortedCoorc]",unsortedCoorValuescopy[0]+"\t"+unsortedCoorValuescopy[1]+"\t"+unsortedCoorValuescopy[2]);
					}
					*/
					//showMessage("unsortedCoorcopy["+c+"] has been set to zero");
					c=unsortedCoorcopy.length;
				}
				
					
				
				
				
			}
/*
		// This is usefull, just to show the values of the array unsortedCoorValuescopy, which keeps track of which values of unsortedCoorValues are being used:
		for (p=1; p<unsortedCoorcopy.length; p++){ 
			unsortedCoorValuescopy = split(unsortedCoorcopy[p], "\t"); 
			print("[unsortedCoorc]",unsortedCoorValuescopy[0]+"\t"+unsortedCoorValuescopy[1]+"\t"+unsortedCoorValuescopy[2]);
		}
		
		*/
			
		}		
	}
	
	//now draw lines:
	for (k=1; k<previousCoorlength; k++){ 
		previousCoorValues1 = split(previousCoor[k], "\t"); 
		sortedCoorValues= split(sortedCoor[k], "\t"); 
		selectWindow(mywindow);
		setSlice(i);
		setColor("green");
		//showMessage(previousCoorValues1[1]+","+ previousCoorValues1[2]+" to "+ sortedCoorValues[1]+","+sortedCoorValues[2]);
		for (m=i; m<=nSlices; m++){ 
			

			if ((previousCoorValues1[1]==-1 && previousCoorValues1[2]==-1)||(sortedCoorValues[1]==-1 && sortedCoorValues[2]==-1)) {
			}
			else{		
				/*setLineWidth(8);	
				Overlay.drawEllipse(oldx-4, oldy-4, 8, 8);
				Overlay.show;
				Overlay.setPosition(m);*/
				if (k>=300){nk=k-300;}
				else nk=k;
				setColor(c1[nk],c2[nk],c3[nk]);
				//setColor("green");
				setLineWidth(3);
				Overlay.drawLine(previousCoorValues1[1], previousCoorValues1[2], sortedCoorValues[1], sortedCoorValues[2]);
				Overlay.show;
				Overlay.setPosition(m);	
				//showMessage(previousCoorValues1[1]+","+ previousCoorValues1[2]+" to "+ sortedCoorValues[1]+","+sortedCoorValues[2]);
			}


			
			
		}
		
	}



		
	//Print a summary for this slice://////////////////////////////////////////////////////
	/*
	if (isOpen("SliceSummary")){
		selectWindow("SliceSummary");
		print("[SliceSummary]","\\Clear") ;
	}
	else { run("Table...", "name=SliceSummary width=500 height=950");}
	
	print("[SliceSummary]","\\Headings:Object\tpreviousCoorx\tpreviousCoory\tObject\tunsortedCoorx\tunsortedCoory\tObject\tsortedCoorx\tsortedCoory\tObject\tunsortedCoorcopyx\tunsortedCoorcopy");

	
	for (c=1; c<(previousCoor.length-180); c++){
		
		print("[SliceSummary]",previousCoor[c]+"\t"+unsortedCoor[c]+"\t"+sortedCoor[c]+"\t"+unsortedCoorcopy[c]);
	}
	*/
	
	/////////////////////////////////////////////////////////////////////////




	
	//transfer values from sortedCoor to previousCoor:
	previousCoor=Array.copy(sortedCoor);




	
/* This is just to show the values of previousCoor in table unsortedCoorx:
	print("[unsortedCoorc]","\\Clear") ;
	for (a=1; a<previousCoor.length; a++){
		previousCoorValues1 = split(previousCoor[a], "\t"); 
		print("[unsortedCoorc]",a+"\t"+previousCoorValues1[1]+"\t"+previousCoorValues1[2]);	
	}

	
*/

	
	//selectWindow("Results");
	//previousCoor = split(getInfo(), "\n");
	
	
	
	selectWindow(currentslice);
	
	close();
	
}



//selectWindow("CoordinatesTable");
selectWindow(mywindow);

getDateAndTime(year, month, dayOfWeek, dayOfMonth2, hour2, minute2, second2, msec2);
print("Calculation lasted for...");
print((msec2-msec)+" ms, "+(second2-second)+" secs, "+(minute2-minute)+" mins, "+(hour2-hour)+" hours, "+(dayOfMonth2-dayOfMonth)+" days.");



/*
//copy CoordinatesTable to finalresults, add ave values to finalresutls :
if (isOpen("FinalResults")){
	selectWindow("FinalResults");
	print("[FinalResults]","\\Clear") ;
}
else { run("FinalResults...", "name=FinalResults width=500 height=950");}


selectWindow("DistanceTable");
DistanceTable = split(getInfo(), "\n");
selectWindow("FinalResults");
print("[FinalResults]","\\Headings:"+DistanceTable[0]);
for (c=1; c<DistanceTable.length; c++){
	print("[FinalResults]",DistanceTable[c]) ;
}

lastline="ave"+"\t";
sampleline=split(DistanceTable[1], "\t");//this is just to know the number of slices by doing sampleline.length!
for (d=1; d<sampleline.length; d++){
	sum=0;
	count=0;
	for (c=1; c<DistanceTable.length; c++){
		value = split(DistanceTable[c], "\t"); 
		if (value[d]>=0){
			 sum=sum+value[d];
			 count=count+1;
		}
		
		//print("[FinalResults]",c+"\t"+value[d]) ;
	}
	ave=round(sum/(count));
	lastline=lastline+ave+"\t";

	//showMessage(sum+" "+count+" "+ave);
	
}
print("[FinalResults]",lastline) ;

*/






//just add to DistanceTable:

selectWindow("DistanceTable");
DistanceTable = split(getInfo(), "\n");


lastline="ave"+"\t";
sampleline=split(DistanceTable[1], "\t");//this is just to know the number of slices by doing sampleline.length!
sumoflastline=0;
averageoflastline=0;
for (d=1; d<sampleline.length; d++){
	sum=0;
	count=0;
	for (c=1; c<DistanceTable.length; c++){
		value = split(DistanceTable[c], "\t"); 
		if (value[d]>=0){
			 sum=sum+value[d];
			 count=count+1;
		}
		
		//print("[FinalResults]",c+"\t"+value[d]) ;
	}
	ave=round(sum/(count));
	lastline=lastline+ave+"\t";

	//showMessage(sum+" "+count+" "+ave);
	sumoflastline=sumoflastline+ave;
}
averageoflastline=sumoflastline/(sampleline.length-1);
print("[DistanceTable]",lastline) ;
print("[DistanceTable]","TotalAve\t"+averageoflastline) ;
//




//Makes new tables with a 4th of the coordinates and corresponding new distances:

if (isOpen("every4Vectors")){
	selectWindow("every4Vectors");
	print("[every4Vectors]","\\Clear") ;
}
else { run("Table...", "name=every4Vectors width=500 height=950");}


if (isOpen("every4Coord")){
	selectWindow("every4Coord");
	print("[every4Coord]","\\Clear") ;
}
else { run("Table...", "name=every4Coord width=500 height=950");}

if (isOpen("every4Dist")){
	selectWindow("every4Dist");
	print("[every4Dist]","\\Clear") ;
}
else { run("Table...", "name=every4Dist width=500 height=950");}
selectWindow("CoordinatesTable");
CoordinatesTable = split(getInfo(), "\n");
selectWindow("every4Coord");

for (c=0; c<CoordinatesTable.length; c++){
	values=split(CoordinatesTable[c], "\t");
	valuesdist=split(DistanceTable[c], "\t");
	newline="";
	newlineVector="";
	newlinedist="";
	newline=newline+values[0]+"\t";//this adds the object number.
	newlineVector=newlinedist+valuesdist[0]+"\t";//this adds the object number.
	newlinedist=newlinedist+valuesdist[0]+"\t";//this adds the object number.
	

	newline=newline+values[1]+"\t"+values[2]+"\t";
	oldxdist=values[1];
	oldydist=values[2];

	if (c==0) { //this will be the header.
		for (a=(9); a<values.length; a=a+8){		
			newline=newline+values[a]+"\t"+values[a+1]+"\t"; //this adds the x and y coordinates.
			newlineVector=newline+values[a]+"\t"+values[a+1]+"\t"; //this adds the x and y coordinates.	
			newlinedist=newlinedist+valuesdist[(a-7)/2]+"\t";
		}
		
		
		
	}
	else{
		for (a=(9); a<values.length; a=a+8){
			


				
			newline=newline+values[a]+"\t"+values[a+1]+"\t"; //this adds the x and y coordinates.
			newxdist=values[a];
			newydist=values[a+1];
	
			dx=(parseInt(newxdist)-parseInt(oldxdist));
			dy=(parseInt(newydist)-parseInt(oldydist));
			dx2=dx*dx;
			dy2=dy*dy;
			d=round(sqrt(dx2+dy2));
			for (b=a-8; b<=a; b++){//check the previous 4 coordinates (8 including x and y) to see if there was -1,-1  i.e. a jump.
				if (values[b]==-1 && values[b+1]==-1){
					d=NaN;
					dx=NaN;
					dy=NaN;
				}			
			}
				
			newlinedist=newlinedist+d+"\t";
			newlineVector=newlineVector+dx+"\t"+dy+"\t";
			oldxdist=newxdist;
			oldydist=newydist;
		}
	}
	
	
	
	if (c==0) {//print headings:
		print("[every4Coord]","\\Headings:"+newline);
		print("[every4Vectors]","\\Headings:"+newline);
		print("[every4Dist]","\\Headings:"+newlinedist);
	}
	else {
		print("[every4Coord]",newline); //print line.
		print("[every4Vectors]",newlineVector); //print line.
		print("[every4Dist]",newlinedist); //print line.
	}

}
//
//add average:


selectWindow("every4Dist");
DistanceTable = split(getInfo(), "\n");


lastline="ave"+"\t";
sampleline=split(DistanceTable[1], "\t");//this is just to know the number of slices by doing sampleline.length!
sumoflastline=0;
averageoflastline=0;
for (d=1; d<sampleline.length; d++){
	sum=0;
	count=0;
	for (c=1; c<DistanceTable.length; c++){
		value = split(DistanceTable[c], "\t"); 
		if (value[d]>=0){
			 sum=sum+value[d];
			 count=count+1;
		}
		
		//print("[FinalResults]",c+"\t"+value[d]) ;
	}
	ave=d2s(sum/(count),1);
	lastline=lastline+ave+"\t";

	//showMessage(sum+" "+count+" "+ave);
	sumoflastline=sumoflastline+ave;
}

averageoflastline=d2s(sumoflastline/(sampleline.length-1),1);
print("[every4Dist]",lastline) ;
print("[every4Dist]","TotalAve\t"+averageoflastline) ;


////////////////////




//now calculate vector averages from every4Vector and add them to both every4Vector and every4distance table////////

selectWindow("every4Vectors");
vectorTable = split(getInfo(), "\n");
lastline="av.vec"+"\t";

for (d=1; d<(((sampleline.length-1)*2)+1); d++){ //goes through slices i.e. columns.
	sum=0;
	count=0;	
	for (c=1; c<DistanceTable.length; c++){ //goes through each line.
		value = split(vectorTable[c], "\t"); 
		if (value[d]==NaN){
			
		}
		else{
		sum=sum+parseInt(value[d]);	
		count=count+1;
		}
		
	}
	//showMessage("sum "+sum+" count "+ count +" d "+d);
	ave=d2s(sum/(count),1);
	lastline=lastline+ave+"\t";


}
print("[every4Vectors]",lastline) ;
print("[every4Dist]",lastline) ;

//////////////////////////////////////////////////////////////


	
//make a new table with distances corrected by average translation vector:

if (isOpen("every4VectorsCorrected")){
	selectWindow("every4VectorsCorrected");
	print("[every4VectorsCorrected]","\\Clear") ;
}
else { run("Table...", "name=every4VectorsCorrected width=500 height=950");}
selectWindow("every4Vectors");
vectorTable = split(getInfo(), "\n");
lastline=split(vectorTable[vectorTable.length-1],"\t");
//showMessage(lastline[2]);
line="";
//print header:
print("[every4VectorsCorrected]","\\Headings:"+ vectorTable[0]) ;
//print objects:
for (c=1; c<vectorTable.length-1; c++){ //goes through each line.
		value = split(vectorTable[c], "\t"); 
		print("[every4VectorsCorrected]",value[0]) ;
}
for (d=1; d<lastline.length; d++){ //goes through slices i.e. columns.
	selectWindow("every4VectorsCorrected");
	vectorTableCorrected = split(getInfo(), "\n");
	for (c=1; c<vectorTable.length-1; c++){ //goes through each line.
		value = split(vectorTable[c], "\t"); 
		if (value[d]==NaN){	
			print("[every4VectorsCorrected]","\\Update"+c-1+":"+vectorTableCorrected[c]+"\t"+value[d]);	
		}
		else{
			newvalue=parseFloat(value[d])-parseFloat(lastline[d]);
			print("[every4VectorsCorrected]","\\Update"+c-1+":"+vectorTableCorrected[c]+"\t"+d2s(newvalue,1));		
		}
	}
}
/////////////////////

every4DistCorrected="every4DistCorrected"+u;



//Make table with distances calculated from corrected vectors:
if (isOpen(every4DistCorrected)){
	selectWindow(every4DistCorrected);
	print("["+every4DistCorrected+"]","\\Clear") ;
}
else { run("Table...", "name="+every4DistCorrected+" width=500 height=950");}
selectWindow("every4Dist");
distTable = split(getInfo(), "\n");
//print header:
print("["+every4DistCorrected+"]","\\Headings:"+ distTable[0]) ;
//print objects:
for (c=1; c<distTable.length-3; c++){ //goes through each line.
		value = split(distTable[c], "\t"); 
		print("["+every4DistCorrected+"]",value[0]) ;
}

selectWindow("every4VectorsCorrected");
vectorTable = split(getInfo(), "\n");
sampleline=split(distTable[1],"\t");
lastline="ave_dist_px\t";
cell_count="count\t";
for (d=1; d<(sampleline.length-1)*2; d=d+2){ //goes through slices i.e. columns.
	selectWindow(every4DistCorrected);
	distTableCorrected = split(getInfo(), "\n");
	sum=0;
	count=0;
	for (c=1; c<vectorTable.length-1; c++){ //goes through each line.
		values=split(vectorTable[c],"\t");
		dx=parseFloat(values[d]);
		dy=parseFloat(values[d+1]);
		dx2=dx*dx;
		dy2=dy*dy;
		dist=round(sqrt(dx2+dy2));
		print("["+every4DistCorrected+"]","\\Update"+c-1+":"+distTableCorrected[c]+"\t"+dist);	
		if (isNaN(dist)){				
		}
		else{	
		sum=sum+dist;	
		count=count+1;
		}	
	}
	//showMessage("sum "+sum+" count "+ count +" d "+d);
	ave=d2s(sum/(count),1);
	lastline=lastline+ave+"\t";
	cell_count=cell_count+d2s(count,0)+"\t";
}
print("["+every4DistCorrected+"]",lastline) ;
print("["+every4DistCorrected+"]",cell_count) ;
//Add slice date data line to every4DistCorrected:////////////////////////////////////////////////////////
selectWindow(mywindowMask);
datestring="date\t";
total_time_in_days="total_time_in_days\t";
dist_per_hr_in_um="speed um/hr\t";
hours_travelled="hours_travelled\t";

setSlice(1);
splitTitle=split(getInfo("slice.label"),"_");
time=split(splitTitle[1],"(");
time2=split(time[0],"-");
h0=time2[0];
m0=time2[1];
s0=time2[2];
//showMessage(h0+","+m0+","+s0);
sumhours=0;
array1="";
slicearray="";
avedist=split(lastline,"\t"); //lastline[] is the average distance in pixels for that slice.
//Array.print(avedist);
ave_dist_um="ave_dist_um\t";
for (c=5; c<nSlices; c=c+4){
	setSlice(c);
	splitTitle=split(getInfo("slice.label"),"_");
	date=splitTitle[0]+splitTitle[1];	
	datestring=datestring+date+"\t";

	time=split(splitTitle[1],"(");
	time2=split(time[0],"-");
	h=time2[0];
	m=time2[1];
	s=time2[2];
	dh=parseFloat(h)-h0;
	dm=parseFloat(m)-m0;
	ds=parseFloat(s)-s0;
	//showMessage(dh+"  "+dm+"  "+ds);
	
	if (dh<0){
		dh=dh+24;	
	}
	dhb=dh+dm/60+ds/3600;

	//array1=Array.concat(array1,dhb);
	slicearray=Array.concat(slicearray,c);
	
	sumhours=sumhours+dhb;
	array1=Array.concat(array1,sumhours);
	total_time_in_days=total_time_in_days+sumhours/24+"\t";
	//showMessage("avedist "+avedist[((c+3)/4)-1]+"dhb "+ dhb+ "scale "+scale); 
	hours_travelled=hours_travelled+dhb+"\t";
	dist_per_hr_in_um=dist_per_hr_in_um+(parseFloat((avedist[((c+3)/4)-1])/dhb))/(parseFloat(scale))+"\t"; 

	ave_dist_um=ave_dist_um+(parseFloat(avedist[((c+3)/4)-1]))/(parseFloat(scale)) +"\t";
	
	h0=h;
	m0=m;
	s0=s;
	
	
}


//Plot.create("Title", "X-axis Label", "Y-axis Label", slicearray, array1);
//Array.print(array1);

//Find initial date:
selectWindow(mywindow);
setSlice(1);
splitTitle=split(getInfo("slice.label"),"_");
initialdate=splitTitle[0]+splitTitle[1];	
//

print("["+every4DistCorrected+"]",ave_dist_um) ;
print("["+every4DistCorrected+"]",total_time_in_days) ;
print("["+every4DistCorrected+"]",hours_travelled) ;
print("["+every4DistCorrected+"]",dist_per_hr_in_um) ;
print("["+every4DistCorrected+"]",datestring) ;
print("["+every4DistCorrected+"]","initial_date\t"+initialdate) ;
print("["+every4DistCorrected+"]","directory\t"+dir) ;
print("["+every4DistCorrected+"]","mythreshold\t"+mythreshold) ;
print("["+every4DistCorrected+"]","particlesize\t"+particlesize);
print("["+every4DistCorrected+"]","scale px/um\t"+scale) ;
print("["+every4DistCorrected+"]","tracked_slices\t"+nSlices) ; 
print("["+every4DistCorrected+"]",total_time_in_days) ;
print("["+every4DistCorrected+"]",cell_count) ;
print("["+every4DistCorrected+"]",total_time_in_days) ;
print("["+every4DistCorrected+"]",dist_per_hr_in_um) ; 



//Save all windows:
//dir="D:\\Images\\Now\\Right\\10AT_Normoxia\\TrackPos10\\";  //This is chosen at the beginning.
if (savetofolder==true){
	File.makeDirectory(dir) 
	selectWindow("CoordinatesTable");
	saveAs("Text", dir+"CoordinatesTable.txt");
	run("Close");
	selectWindow("every4Dist");
	saveAs("Text", dir+"every4Dist.txt");
	run("Close");
	selectWindow("every4VectorsCorrected");
	saveAs("Text", dir+"every4VectorsCorrected.txt");
	run("Close");
	selectWindow("every4Vectors");
	saveAs("Text", dir+"every4Vectors.txt");
	run("Close");
	selectWindow("every4Coord");
	saveAs("Text", dir+"every4Coord.txt");
	run("Close");
	selectWindow("DistanceTable");
	saveAs("Text", dir+"DistanceTable.txt");
	run("Close");
	/*selectWindow("Initial_Positions");   //This wont work if batchmode is on!
	saveAs("Jpeg", dir+"Initial_Positions.jpg");
	waitForUser;
	run("Close");*/
	selectWindow(mywindow);
	setSlice(nSlices);
	saveAs("Jpeg", dir+"Last_Image.jpg");
	selectWindow("Results");
	run("Close");
	selectWindow(every4DistCorrected);
	saveAs("Text", dir+"FINAL_DATA_every4DistCorrected.txt");
	//run("Close");
	//setBatchMode(false);

	
	//Save a movie:
	run("AVI... ", "compression=JPEG frame=17 save="+dir+"Video.avi");
	//
	MyFunctionDoEveryN();
	
	
	selectWindow(mywindowMask);
	close();

	
}
else{
	selectWindow("CoordinatesTable");
	run("Close");
	selectWindow("every4Dist");
	run("Close");
	selectWindow("every4VectorsCorrected");
	run("Close");
	selectWindow("every4Vectors");
	run("Close");
	selectWindow("every4Coord");
	run("Close");
	selectWindow("DistanceTable");
	run("Close");
	/*selectWindow("Initial_Positions");   //This wont work if batchmode is on!
	saveAs("Jpeg", dir+"Initial_Positions.jpg");
	waitForUser;
	run("Close");*/
	selectWindow("Results");
	run("Close");
	selectWindow(mywindowMask);
	close();
	
}

selectWindow("Last_Image.jpg");
close();
//selectWindow(every4DistCorrected);
//close();
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

/////Merge all FINAL_DATA files into one and save it:
/*


nSplitStacks=12;
if (isOpen("every4DistCorrectedALL")){
	selectWindow("every4DistCorrectedALL");
	print("[every4DistCorrectedALL]","\\Clear") ;
}
else { run("Table...", "name=every4DistCorrectedALL width=450 height=950");}

//Print Headings on every4DistCorrectedALL" 
selectWindow("every4DistCorrected1");
copylines1 = split(getInfo(), "\n");
heading="1";
copylines0row=split(copylines1[0], "\t");
for (n=1; n<nSplitStacks*(copylines0row.length); n++){ 
	heading=heading+"\t"+(4*n+1);
}
print("[every4DistCorrectedALL]","\\Headings:"+heading) ;
//
//Copy lines to every4DistCorrectedALL
selectWindow("every4DistCorrected1");
copylines = split(getInfo(), "\n");
for (n=1; n<copylines.length; n++){ 
	string="";
	for (j=1; j<=nSplitStacks; j++){ 
		selectWindow("every4DistCorrected"+j);
		copylines = split(getInfo(), "\n");
		string=string+copylines[n]+"\t";
		
	}
	print("[every4DistCorrectedALL]",string);
}
*/
//////////////////////////////////////////////////////
//nSplitStacks=12;
if (isOpen("every4DistCorrectedALL")){
	selectWindow("every4DistCorrectedALL");
	print("[every4DistCorrectedALL]","\\Clear") ;
}
else { run("Table...", "name=every4DistCorrectedALL width=450 height=950");}

//Print Headings on every4DistCorrectedALL" 
selectWindow("every4DistCorrected1");
copylines1 = split(getInfo(), "\n");
heading="1";
copylines0row=split(copylines1[0], "\t");
for (n=1; n<nSplitStacks*(copylines0row.length); n++){ 
	heading=heading+"\t"+(4*n+1);
}
print("[every4DistCorrectedALL]","\\Headings:"+heading) ;
//
//Copy lines to every4DistCorrectedALL
selectWindow("every4DistCorrected1");
copylines = split(getInfo(), "\n");
for (n=1; n<18; n++){ 
	string="";
	totaltimeofprevwin=0;
	for (j=1; j<=nSplitStacks; j++){ 
		selectWindow("every4DistCorrected"+j);
		copylines = split(getInfo(), "\n");
		length=copylines.length;
		thisline=copylines[length-18+n];
		if (n==16){//for "Count" line i.e.n=16, add total time in days from previous window to each element of this window.				
			mysplit=split(thisline, "\t");
			num=mysplit[(mysplit.length)-1];
			//showMessage(parseFloat(num));
			totaltimeofCurrwin=totaltimeofprevwin+parseFloat(num);
			//showMessage("a");
			//showMessage(totaltimeofprevwin);
		}
		if (j!=1){ //remove the first column i.e the labels, if the window is not window1.
			thisline2=split(thisline, "\t");	
		
			thisline="";
			for (p=1; p<thisline2.length; p++){
				if (n==16){ //for "Count" line i.e.n=16, add total time in days from previous window to each element of this window.
					thisline=thisline+toString(parseFloat(thisline2[p])+totaltimeofprevwin)+"\t";
					//showMessage("b");
					//showMessage(thisline);
					//(totaltimeofprevwin);
				}
				else{
					thisline=thisline+thisline2[p]+"\t";
				}
				
				
			}
			
		}	
		
		string=string+thisline;  //copies only the last 17 rows from each window (because those are the final results)
		
		if (n==16){totaltimeofprevwin=totaltimeofCurrwin;}
		
	}
	print("[every4DistCorrectedALL]",string);
}
//////////////
selectWindow("every4DistCorrectedALL");
analysisDir=maindir+"Analysis\\";
File.makeDirectory(analysisDir);
saveAs("Text", analysisDir+"every4DistCorrectedALL_Pos"+z+".xls"); //saves a copy to the main folder
saveAs("Text", diroriginal+"every4DistCorrectedALL_Pos"+z+".xls"); //saves a copy to "Track" folder
//waitForUser;
//selectWindow("Pos"+z+"_"+ext);
//waitForUser;
close();
} //end of for z loop






if (savetofolder==true){
showMessage("Done. Data Saved to "+diroriginal);
}
else{
showMessage("Done");
}



function MyFunctionDoEveryN(){
		
	n=N; //we only look at 1 every n slices.
	mystring="";
	mywindow=getTitle();
	run("Remove Overlay");
	//selectWindow("CoordinatesTable");
	
	setSlice(1);
	//pathfile=File.openDialog("Choose the file to Open:"); 
	pathfile=dir+"CoordinatesTable.txt";
	//pathfile="C:\\Images\\101113-tesx-2wellsFridayCorrected15\\Track1\\1\\CoordinatesTable.txt";
	filestring=File.openAsString(pathfile); 
	CoordinatesTable=split(filestring, "\n"); 
	pathfile=dir+"DistanceTable.txt";
	//pathfile="C:\\Images\\101113-tesx-2wellsFridayCorrected15\\Track1\\1\\DistanceTable.txt";
	filestring=File.openAsString(pathfile); 
	DistTable=split(filestring, "\n"); 
	
	
	if (isOpen("NewDistanceTable")){
		selectWindow("NewDistanceTable");
		print("[NewDistanceTable]","\\Clear") ;
	}
	else { run("Table...", "name=NewDistanceTable width=450 height=950");
	}
	selectWindow(mywindow);//this is neccessary for the nSlices in the following line.
	for (i=1; i<=nSlices; i=i+n){ //runs through slices.	i<=nSlices
		mystring=mystring+"Slice"+i+"\t";
	}
	print("[NewDistanceTable]","\\Headings:Object\t"+mystring);
	
	for (c=1; c<CoordinatesTable.length; c++){
		print("[NewDistanceTable]",""+c);
	}
	//waitForUser; 
	
	cancel=false;
	
	selectWindow(mywindow);
	for (i=1; i<=(nSlices-n); i=i+n){
		selectWindow("NewDistanceTable");
		NewDistanceTableLines = split(getInfo(), "\n");
		selectWindow(mywindow);
		//waitForUser; 
		setSlice(i+n);	
		for (c=1; c<CoordinatesTable.length; c++){  //for (c=1; c<CoordinatesTable.length; c++){
	
			valuesDistTable=split(DistTable[c], "\t");	
			for (j=i; j<=i+n-1; j++){
				if (valuesDistTable[j]<0){
					cancel=true;	
				}
			}		
			if( cancel==true){
				dist="NaN";
				print("[NewDistanceTable]","\\Update"+c-1+":"+NewDistanceTableLines[c]+"\t"+dist);
				cancel=false;
			}
			else{
				//showMessage(c);
				values=split(CoordinatesTable[c], "\t");
				//showMessage("x1="+values[2*i-1]);
				//showMessage("x2="+values[(2*i-1)+2*n]);
				dx=(parseInt(values[(2*i-1)+2*n])-parseInt(values[2*i-1]));
				dy=(parseInt(values[2*i+2*n])-parseInt(values[2*i]));
				dx2=dx*dx;
				dy2=dy*dy;
				dist=round(sqrt(dx2+dy2));
						
				//showMessage(dist);
				print("[NewDistanceTable]","\\Update"+c-1+":"+NewDistanceTableLines[c]+"\t"+dist);
				//print("[NewDistanceTable]","\\Update"+c-1+":"+"\t"+dist);
				//print("[NewDistanceTable]",""+dist);
						
				if ((values[2*i-1]==-1 && values[2*i]==-1)||(values[(2*i-1)+2*n]==-1 && values[2*i+2*n]==-1)) {
					}
				else{	
					for (k=i; k<nSlices; k++){ 				
						//setColor("green");				
						setColor(c1[c],c2[c],c3[c]);
						setLineWidth(3);
						Overlay.drawLine(values[2*i-1], values[2*i], values[(2*i-1)+2*n], values[2*i+2*n]);
						Overlay.show;
						Overlay.setPosition(k+n);	
					}
				}				
			}
		}
		
	}
	run("AVI... ", "compression=JPEG frame=17 save="+dir+"VideoEvery"+n+".avi");	
	//setBatchMode(false);
	//waitForUser;
	selectWindow("NewDistanceTable");
	saveAs("Text", dir+"NewDistanceTableEvery"+n+".txt");
	run("Close");	

	/*
	analysisDir ="D:\\Images\\PC-3\\063014-10at_gfp5x3wellsof96plate0630\\Analysis";
	exec("C:\\Fiji.app\\Batches_and_Macros\\MergeFiles2\\MergeFiles2\\bin\\Release\\MergeFiles2.exe",analysisDir);
	wait(3000);
	path = analysisDir+"\\-Merge_063014-10at_gfp5x3wellsof96plate0630.xls";
	//showMessage(path);
	//exec("open", path);
	exec("open", path);
*/
	
	
}


