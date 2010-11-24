import sys

#if not invoked properly
if len(sys.argv) < 2:
	print ("Usage is: " + sys.argv[0] + " binaryDumpFile")
	sys.exit(0)
	
binFile = open(sys.argv[1], "rb") #open in binary mode
count  = ord(binFile.read(1))
print("Total Number of data points = " + str(count));

for r in range(count):
	#read each data point
	age = ord(binFile.read(1))
	earbuds = False
	if age >= 128:
		earbuds = True
		age = age - 128;
	freq = (ord(binFile.read(1)) << 8) + ord(binFile.read(1))
	print("age = " + str(age))
	if earbuds == True:
		print("Uses earbuds")
	print("Maximum Hearing Frequency = " + str(freq))

