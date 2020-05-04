#!/bin/bash

# these are all valid counter-clockwise jumps
M='124 456 631 259 987 742 36A A98 853 47B BCD D84 58C CDE E95 69D DEF FA6'

# we build an awk script that tries each jump
echo '#!/usr/bin/awk -f' > next.awk
# first the forward jump
echo $M | tr ' ' '\n' | \
	sed -E 's/^(.)(.)(.)$/$\1 \&\& $\2 \&\& !$\3 {o=$0; $\1=0; $\2=0; $\3=1; print $0, "\1-\3";$0=o}/' | \
	sed 's/$A/$10/g;s/$B/$11/g;s/$C/$12/g;s/$D/$13/g;s/$E/$14/g;s/$F/$15/g;' >> next.awk
# then the same jump backwards
echo $M | tr ' ' '\n' | \
	sed -E 's/^(.)(.)(.)$/$\3 \&\& $\2 \&\& !$\1 {o=$0; $\3=0; $\2=0; $\1=1; print $0, "\3-\1";$0=o}/' | \
	sed 's/$A/$10/g;s/$B/$11/g;s/$C/$12/g;s/$D/$13/g;s/$E/$14/g;s/$F/$15/g;' >> next.awk
# We replace $A for $10 to comply with awk syntax
chmod +x next.awk

# now we create all initial positions 
seq 15| awk '{for(i=1; i<=15; i++) $i=1; $NR=0; print}' | \
while read line
do
	# we start recording the initial state 
	echo $line `echo $line":" |tr ' ' '-'` | \
		./next.awk | \
		./next.awk | \
		./next.awk | \
		./next.awk | \
		./next.awk | \
		./next.awk | \
		./next.awk | \
		./next.awk | \
		./next.awk | \
		./next.awk | \
		./next.awk | \
		./next.awk
done | \
sed 's/1 1/1/g;s/2 2/2/g;s/3 3/3/g;s/4 4/4/g' | \
sed 's/5 5/5/g;s/6 6/6/g;s/7 7/7/g;s/8 8/8/g' | \
sed 's/9 9/9/g;s/A A/A/g;s/B B/B/g;s/C C/C/g;s/D D/D/g;s/E E/E/g;s/F F/F/g;' > all_solutions.txt
# Finally we contract all the simple jumps that can be compound

# We calculate the length of shortest paths
MIN=`awk '{print NF}' all_solutions.txt | sort -n | head -1`

# and we print the best solutions
awk -vMIN=$MIN 'NF==MIN {print}' all_solutions.txt
