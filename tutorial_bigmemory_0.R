# Tutorial 0: High Performance Data Analytics with R (package: bigmemory) 

# Execute this code like so:
# $ qsub -l walltime=0:10:0,nodes=1:ppn=8 -X -I
# $ module load R
# $ cd $PBS_O_WORKDIR 
# $ R --vanilla < tutorial_bigmemory_0.R
# $ exit

# This example is the baseline for a series of HPC/R tutorials.
# It does not use cluster computing.
# It does demonstrated how to benchmark R code for performance.

# bigmemory provides only core functionality and depends on 
# the packages synchronicity, biganalytics, bigalgebra, bigtabulate
# to actually do stuff.

# ============================================================

# Measure how a calculation's duration scales with calculation complexity.
# The results are output to the R console.

# Setup:
# Within the R environment verify that the bigmemory package is installed.
# > installed.packages('bigmemory')
# If it is not install it like so:
# > install.packages('bigmemory')

library(bigmemory)

# ============================================================
 
# Benchmark start time.
start_time <- Sys.time()
 
# Trial size
iteration_count <- 10

#row_count <- 5
#column_count <- 2

row_count <- 5000
column_count <- 2000

data0 <- big.matrix(row_count, column_count, type="double", init = 0.0, dimnames=list(NULL, c("alpha", "beta")))

# Generate some random numbers, store them in the data matrix.
# The process id is reported as this will be helpful info when running on a cluster node.
for (iteration_index in 1:iteration_count) { 
    cat("PID: ", Sys.getpid(), " Iteration: ", iteration_index,'\n') 
	# Insert rows of uniform random numbers in the range 0 to 1
	for (row_index in 1:row_count) {
		data0[row_index,] <- runif(column_count, 0, 1)
	}
}

# Benchmark stop time and record duration as a function of iteration count.
cat("Insert rows duration/sec: ", Sys.time() - start_time)

# Show metadata for a big.matrix. The result can be used to reattach to a big.matrix.
describe(data0)

# Show some of the elements of a big.matrix.
# head(data0)
# tail(data0)

# Show all of the elements of a big.matrix.
# Don't do this if the matrix is very big.
# print(data0)
 
# Report results.
# Record first 6 rows.
sink("tutorial_bigmemory_0.result") # Redirect console output to the named file
head(data0)
sink() # Restore output to the console
