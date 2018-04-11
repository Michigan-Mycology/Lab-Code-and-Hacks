for file in [your folder]/*.gz
do
gzip -d $file
done
echo "Done decompressing"
