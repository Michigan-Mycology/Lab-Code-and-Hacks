for file in genbank/*.gz
do 
gzip -d $file
done
echo "Done decompressing"
