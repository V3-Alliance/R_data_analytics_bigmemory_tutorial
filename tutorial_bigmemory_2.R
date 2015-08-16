# Tutorial 1: High Performance Data Analytics with R (package: bigmemory) 

# This example tests how column vs row population of big.matrix affects exection time.
# It does not use cluster computing.
# It does demonstrated how to benchmark R code for performance.

# This example shows:
# 1. how to refactor code into subroutines
# 2. how to calculate time differences in seconds.
# 3. how to plot 2 data sets on a common chart.
# 4. How to display progress information.
# 5. How to use basic iteration using explicit calls to seq()
# 6. How to manage very large data sets in the R environment.

# bigmemory provides only core functionality and depends on 
# the packages synchronicity, biganalytics, bigalgebra, bigtabulate
# to actually do stuff.

# ============================================================

# Measure how a calculation's duration scales with calculation complexity.
# The results are output to the R console.

# Setup:
# Within the R environment verify that the bigmemory and ggplot2 packages are installed.
# > installed.packages('bigmemory')
# > installed.packages('ggplot2')
# If it is not, install it like so:
# > install.packages('bigmemory')
# > install.packages('ggplot2')
# > install.packages('reshape')

library(bigmemory)
library(ggplot2)
library(reshape)

# ============================================================

iteration_count <- 1

populate_rows <- function(row_count, column_count) {

	data0 <- big.matrix(row_count, column_count, type="double", init = 0.0, dimnames=list(NULL, c("alpha", "beta")))

	cat("\nStart benchmark populate rows: ", "Rows=", row_count, "Cols=", column_count, '\n') 
	# Generate some random numbers, store them in the data matrix.
	# The process id is reported as this will be helpful info when running on a cluster node.
	for (iteration_index in 1:iteration_count) { 
		cat("PID (rows): ", Sys.getpid(), " Iteration: ", iteration_index,'\n') 
		# Insert rows of uniform random numbers in the range 0 to 1
		for (row_index in 1:row_count) {
			data0[row_index,] <- runif(column_count, 0, 1)
		}
	}
}

populate_columns <- function(row_count, column_count) {

	data1 <- big.matrix(row_count, column_count, type="double", init = 0.0, dimnames=list(NULL, c("alpha", "beta")))

	cat("\nStart benchmark populate columns: ", "Rows=", row_count, "Cols=", column_count, '\n') 
	# Generate some random numbers, store them in the data matrix.
	# The process id is reported as this will be helpful info when running on a cluster node.
	for (iteration_index in 1:iteration_count) { 
		cat("PID (columns): ", Sys.getpid(), " Iteration: ", iteration_index,'\n') 
		# Insert columns of uniform random numbers in the range 0 to 1
		for (column_index in 1:column_count) {
			data1[,column_index] <- runif(row_count, 0, 1)
		}
	}
}

# ============================================================
  
# Trial size, aka the number of data points to be plotted.
trial_count = 10

# Set the trial scale to something small so as not to run out of disk space.
# 10 will consume (10 x 10) ^ 2  x 2 x 5 x 8 = 0.8 MBytes.
# 1000 will consume 8GBytes.
# trial_scale = 1e3 Don't use this much on a node. Use the Lustre file system.
trial_scale = 10

# Data matrix size.
# About 8 GByte will be allocated.
row_count_0 <- 2
column_count_0 <- 5

# Allocate storage for results
# Count results.
matrix_sizes <- numeric(trial_count)
# Timing results.
durations0 <- numeric(trial_count)
durations1 <- numeric(trial_count)

# Iterate the trial while varying the trial parameters.
for(trial_index in seq(1, trial_count)) {
    
    # Exercise the function we are benchmarking.
    scale <- trial_index * trial_scale
	cat("\n\nTrialindex: ", trial_index, " Scale factor: ", scale, "\n")
    row_count = row_count_0 * scale
    column_count  =  column_count_0 * scale 
	matrix_sizes [trial_index] <-  row_count * column_count 
	cat("Bytes: ", row_count * column_count * 8, "\n")

    # ---------------------------- 
       
	# Benchmark 1 start time.
	start_time <- Sys.time()

 	populate_rows(row_count, column_count)
 	
    # Benchmark stop time and record duration as a function of iteration count.
    duration = difftime(Sys.time(), start_time, units="secs")
    durations0 [trial_index] <- duration

	# Benchmark 1 stop time and record duration as a function of iteration count.
	cat("Insert rows duration/sec: ", duration)
    
    # ----------------------------    

	# Benchmark 2 start time.
	start_time <- Sys.time()

 	populate_columns(row_count, column_count)
 	
    # Benchmark stop time and record duration as a function of iteration count.
    duration = difftime(Sys.time(), start_time, units="secs")
    durations1 [trial_index] <- duration

	# Benchmark 2 stop time and record duration as a function of iteration count.
	cat("Insert columns duration/sec: ", duration)
	
    # ----------------------------    
}

# ============================================================

# Organise the results into a form suitable for plotting 
duration_data <- data.frame(matrix_sizes, durations0, durations1)
plotable_data = melt(duration_data, , id.vars='matrix_sizes')

# Plot the results with each "addition" adding a layer to the plot.
# The result is a scatter plot with individual points 
# superimposed on a smoothed line and some axis labels.
#
ggplot(plotable_data, aes(x = matrix_sizes, y = value, colour = variable)) + 
    geom_point() +
    geom_smooth() + 
    theme_bw() + 
    scale_x_continuous('Matrix element count') + 
    scale_y_continuous ('Duration/sec') +
    ggtitle("Tutorial 2: R bigmemory")
    
# ============================================================

# Clear out the workspace.
#rm(list = ls())