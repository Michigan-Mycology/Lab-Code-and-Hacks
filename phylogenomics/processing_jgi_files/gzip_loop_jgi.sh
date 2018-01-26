for file in jgi/*.gz
do 
gzip -d $file
done
echo "Done decompressing"
