for file in your_dir/*.domtbl
do
stem=`basename $file .domtbl`
if [ ! -f your_dir/$stem.best ]; then
perl your_path/scripts/get_best_hmmtbl.pl $file > your_dir/$stem.best
fi
done
#get_best_hmmtbl.pl is available on the Spatafora et al. git hub page.
