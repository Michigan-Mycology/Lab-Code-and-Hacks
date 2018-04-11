# Downloading and using Astral to create a species tree from multiple unrooted gene trees

  1. Use RAxML to produce the standard tree outputs. Create a new folder and copy the "RAxML_bipartitions.\*.nex" files to it. 
```
mkdir astral
cp RAxML_bipartitions.* ./astral/
```
  2. Navigate to the folder, and merge all nexus files into a single newick .tre file.
```
cd astral
cat *.nex > astral.tre
```
  3. The merged file will contain different loci for the same taxa across the different trees, which will cause Astral to read only the first tree. At this point, the unnecessary data should be between a "|" and ":". Therefore, to delete the loci and retain the branch length information, run the following command line.
```
cat astral.tre | sed 's/|[^:]*:/:/g' > astral_clean.tre
```
  4. Download the astral_clean.tre file onto your computer. Download the astral.5.6.1.jar file from this GitHub page, along with the "lib" folder and its contents. Place the .jar and the necessary "lib" folder into the same folder on your computer as your astral_clean.tre file.
  5. <b>On your own computer</b>, open the command prompt and navigate to the folder containing astral.5.6.1.jar, and enter the following line. Processing should take less than one minute.
```
java -jar astral.5.6.1.jar -i astral_clean.tre -o astral_clean_output.tre 2> astral_clean_output.log 
```
  6. Use FigTrees or a similar program to open the output consensus tree.
