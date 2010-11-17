#!/bin/bash
#
# usage: ./commentator.sh '.*/.*\.(cpp|c|h)'
echo "Looking for opening comments (/* ...)..."

{
	for a in `find $(dirname "$1") -regextype awk -regex $(basename "$1")`; do 
		cd $(dirname "$a"); 
		git blame -f $(basename "$a") 
		cd - >/dev/null; 
		echo "NEW-FILE-HERE"
	done
} | gawk  '
	/NEW-FILE-HERE/ {
		nf=NR
	}
	!/Not Committed Yet/{
		if (/\) \/\*/ && NR-nf > 10) {
			total++
			user[$3]++
		}
		usertot[$3]++
	}
	END{
		print "Comments started: " total;
		print "tl: total lines. cs: lines starting a comment."
		print "cp: percentage of lines starting a comment by this user compared to all users."
		print "ratio: Comment starts/lines by user per mill"

		for (val in user) {
			mval=substr(val,2)
			printf ("%12s: ", mval)
			printf ("tl: %6d ", usertot[val])
			printf ("cs: %4d ", user[val])
			printf ("cp: %2d%% ", (user[val]*100)/(total))
			printf ("ratio: %3.2f‰\n", (user[val]*1000)/usertot[val])
		}
	}
	'

