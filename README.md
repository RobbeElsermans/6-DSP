
# How to Use

Welcome to our GUI application! If you want to use it in MATLAB, please ensure you have the following toolboxes installed:
- Signal Processing Toolbox
- Parallel Computing Toolbox

If you just want the app installer, you can find it here:
**GUI\PianoPlayerDataSynchronizer\for_redistribution**.

### System Requirements
- Executable compiled on a Windows 10 PC.

### Application Overview
Our application features two primary tabs:
1. **Input**: Where you input and sync your data.
2. **Plot**: Where you visualize the results.

#### Input Tab
The Input tab contains five buttons, each requesting a specific file type, as indicated on the button labels. Once a file is uploaded, its name will appear below the respective button.

On the right side, you will find fields for entering the Marker location and Tolerances. Any changes made here will be saved and loaded the next time you open the application.

Next, there's the "Sample Rates" box, containing variables that generally shouldn't need adjustment. However, if necessary, these can be modified, though changes to these fields will **not** be saved.

To process and sync all the data, click the "Synchronize" button. A loading screen will appear during processing. Upon completion, the output will be saved in a .csv file, and the location of this file will be displayed in an information box.

#### Plot Tab
In the Plot tab, you can visualize the output of the Blood Oxygenation and sEMG data. Checking the checkbox will display the graph. You can customize the color of the line by clicking the colorful square next to the checkbox and selecting a new color.

### Important Note
You can run the application without uploading a sEMG MVC file. If you choose to do this, a window will pop up asking for confirmation. This feature was implemented to maintain compatibility with some example datasets that do not include an MVC file.



# Who dit what
### Berkay
- GUI
### Tom
- Data extraction
- Filtering EMG
### Robbe
- Sync resampling
- Data aligning
