# Solving Triangle Peg Puzzle with Unix command line tools

The board's state is represented by a strings of 1s and 0s. 

We will use an *awk* script to find all possible movements from a given state.

These are all the valid counter-clockwise jumps
```sh
M='124 456 631 259 987 742 36A A98 853'
```
We build an awk script that tries each jump
```sh
echo '#!/usr/bin/awk -f' > next.awk
# first the forward jump
echo $M | tr ' ' '\n' | \
	sed -E 's/^(.)(.)(.)$/$\1 \&\& $\2 \&\& !$\3 {o=$0; $\1=0; $\2=0; $\3=1; print $0, "\1-\3";$0=o}/' | \
	sed 's/$A/$10/g' >> next.awk
# then the same jump backwards
echo $M | tr ' ' '\n' | \
	sed -E 's/^(.)(.)(.)$/$\3 \&\& $\2 \&\& !$\1 {o=$0; $\3=0; $\2=0; $\1=1; print $0, "\3-\1";$0=o}/' | \
	sed 's/$A/$10/g' >> next.awk
# We replace $A for $10 to comply with awk syntax
chmod +x next.awk
```

Executing these commands results in the following *awk* script
```awk
#!/usr/bin/awk -f
$1 && $2 && !$4 {o=$0; $1=0; $2=0; $4=1; print $0, "1-4";$0=o}
$4 && $5 && !$6 {o=$0; $4=0; $5=0; $6=1; print $0, "4-6";$0=o}
$6 && $3 && !$1 {o=$0; $6=0; $3=0; $1=1; print $0, "6-1";$0=o}
$2 && $5 && !$9 {o=$0; $2=0; $5=0; $9=1; print $0, "2-9";$0=o}
$9 && $8 && !$7 {o=$0; $9=0; $8=0; $7=1; print $0, "9-7";$0=o}
$7 && $4 && !$2 {o=$0; $7=0; $4=0; $2=1; print $0, "7-2";$0=o}
$3 && $6 && !$10 {o=$0; $3=0; $6=0; $10=1; print $0, "3-A";$0=o}
$10 && $9 && !$8 {o=$0; $10=0; $9=0; $8=1; print $0, "A-8";$0=o}
$8 && $5 && !$3 {o=$0; $8=0; $5=0; $3=1; print $0, "8-3";$0=o}
$4 && $2 && !$1 {o=$0; $4=0; $2=0; $1=1; print $0, "4-1";$0=o}
$6 && $5 && !$4 {o=$0; $6=0; $5=0; $4=1; print $0, "6-4";$0=o}
$1 && $3 && !$6 {o=$0; $1=0; $3=0; $6=1; print $0, "1-6";$0=o}
$9 && $5 && !$2 {o=$0; $9=0; $5=0; $2=1; print $0, "9-2";$0=o}
$7 && $8 && !$9 {o=$0; $7=0; $8=0; $9=1; print $0, "7-9";$0=o}
$2 && $4 && !$7 {o=$0; $2=0; $4=0; $7=1; print $0, "2-7";$0=o}
$10 && $6 && !$3 {o=$0; $10=0; $6=0; $3=1; print $0, "A-3";$0=o}
$8 && $9 && !$10 {o=$0; $8=0; $9=0; $10=1; print $0, "8-A";$0=o}
$3 && $5 && !$8 {o=$0; $3=0; $5=0; $8=1; print $0, "3-8";$0=o}
```

We apply it 8 times over each valid initial condition
First we create all initial positions 
```sh
seq 10| awk '{for(i=1; i<=10; i++) $i=1; $NR=0; print}'
```
```
0 1 1 1 1 1 1 1 1 1
1 0 1 1 1 1 1 1 1 1
1 1 0 1 1 1 1 1 1 1
1 1 1 0 1 1 1 1 1 1
1 1 1 1 0 1 1 1 1 1
1 1 1 1 1 0 1 1 1 1
1 1 1 1 1 1 0 1 1 1
1 1 1 1 1 1 1 0 1 1
1 1 1 1 1 1 1 1 0 1
1 1 1 1 1 1 1 1 1 0
```
then we process each one with a pipeline of next-step evaluations
```sh
while read line
do
	# we start recording the initial state 
	echo $line `echo $line":" |tr ' ' '-'` | \
		./next.awk | \ # and we advance one jump
		./next.awk | \ # and again
		./next.awk | \ # and again
		./next.awk | \
		./next.awk | \
		./next.awk | \
		./next.awk | \
		./next.awk
done
```

Finally we contract all the simple jumps that can be compounded
```sh
sed 's/1 1/1/g;s/2 2/2/g;s/3 3/3/g;s/4 4/4/g' | \
sed 's/5 5/5/g;s/6 6/6/g;s/7 7/7/g;s/8 8/8/g' | \
sed 's/9 9/9/g;s/A A/A/g' > all_solutions.txt
```

The file `all_solutions.txt` contains 84 solutions. There are 12 solutions of lenght five. These are the ones we are looking for. There are also 24 solutions of lenght six, 30 ones of length sever and 18 ones of length eigth.

We calculate the length of shortest paths
```sh
MIN=`awk '{print NF}' all_solutions.txt | sort -n | head -1`
```
and we print the best solutions
```
awk -vMIN=$MIN 'NF==MIN {print}' all_solutions.txt
```
which happen to be 
```
0 0 1 0 0 0 0 0 0 0 1-0-1-1-1-1-1-1-1-1: 7-2 1-4 9-7-2 6-1-4-6 A-3
0 0 1 0 0 0 0 0 0 0 1-0-1-1-1-1-1-1-1-1: 7-2 1-4 9-7-2 6-4-1-6 A-3
0 1 0 0 0 0 0 0 0 0 1-1-0-1-1-1-1-1-1-1: A-3 1-6 8-A-3 4-6-1-4 7-2
0 1 0 0 0 0 0 0 0 0 1-1-0-1-1-1-1-1-1-1: A-3 1-6 8-A-3 4-1-6-4 7-2
0 0 0 0 0 0 0 1 0 0 1-1-1-0-1-1-1-1-1-1: 1-4 7-2 6-1-4 9-7-2-9 A-8
0 0 0 0 0 0 0 1 0 0 1-1-1-0-1-1-1-1-1-1: 1-4 7-2 6-1-4 9-2-7-9 A-8
0 0 0 0 0 0 0 0 1 0 1-1-1-1-1-0-1-1-1-1: 1-6 A-3 4-1-6 8-3-A-8 7-9
0 0 0 0 0 0 0 0 1 0 1-1-1-1-1-0-1-1-1-1: 1-6 A-3 4-1-6 8-A-3-8 7-9
0 0 0 1 0 0 0 0 0 0 1-1-1-1-1-1-1-0-1-1: A-8 7-9 3-A-8 2-9-7-2 1-4
0 0 0 1 0 0 0 0 0 0 1-1-1-1-1-1-1-0-1-1: A-8 7-9 3-A-8 2-7-9-2 1-4
0 0 0 0 0 1 0 0 0 0 1-1-1-1-1-1-1-1-0-1: 7-9 A-8 2-7-9 3-A-8-3 1-6
0 0 0 0 0 1 0 0 0 0 1-1-1-1-1-1-1-1-0-1: 7-9 A-8 2-7-9 3-8-A-3 1-6
```

In the final output the first 10 columns represent the final state, the next one represent the initial state, and the columns 12 to 16 represent the solution's jumps.

We can see that there are two solutions for each valid initial condition. These two solutions are specular symmetries, one going clockwise, the other going counter-clockwise. Discounting this effect, there is only one solution for each initial state. There are 6 initial states, with three rotational symmetries and two specular symmetries. In other words, there is essentially one solution, except symmetries.

