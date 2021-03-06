% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/GADAG_Run.R
\name{GADAG_Run}
\alias{GADAG_Run}
\title{Run GADAG}
\usage{
GADAG_Run(X, lambda, threshold = 0.1, GADAG.control = list(n.gen = 100,
  tol.Shannon = 1e-06, max.eval = 10000, pop.size = 10, p.xo = 0.25, p.mut =
  0.05), grad.control = list(tol.obj.inner = 1e-06, max.ite.inner = 50),
  ncores = 1, print.level = 0, return.level = 0)
}
\arguments{
\item{X}{Design matrix, with samples (n) in rows and variables (p) in columns.}

\item{lambda}{Parameter of penalization (>0).}

\item{threshold}{Thresholding value for the estimated edges.}

\item{GADAG.control}{A list containing parameters for controlling GADAG (termination conditions and inherent parameters of the Genetic Algortihm).
Some parameters (n.gen, max.eval and pop.size) are particularly critical for reducing the computational time.
\itemize{
\item{\code{n.gen}}{ maximal number of population generations (>0),}
\item{\code{pop.size}}{ initial population size for the genetic algorithm (>0),}
\item{\code{max.eval}}{ overall maximal number of calls of the evaluation function (>0, should be of the order of \code{n.gen}*\code{pop.size}),}
\item{\code{tol.Shannon}}{ threshold for the Shannon entropy (>0),}
\item{\code{p.xo}}{ crossover probability of the genetic algorithm (between 0 and 1),}
\item{\code{p.mut}}{ mutation probability of the genetic algorithm (between 0 and 1).}
}}

\item{grad.control}{A list containing the parameters for controlling the inner optimization, i.e. the gradient descent.
\itemize{
\item{\code{tol.obj.inner}}{ tolerance (>0),}
\item{\code{max.ite.inner}}{ maximum number of iterations (>0).}
}}

\item{ncores}{Number of cores (>0, depending on your computer).}

\item{print.level}{0 no print, 1 some info on the genetic algorithm behaviour are printed.}

\item{return.level}{0 only best solution is returned, 1 evolution of the current best solution and statistics on the population fitness values are also returned.}
}
\value{
A list with the following elements:
\itemize{
\item{\code{f.best}}{ Best fitness value.}
\item{\code{P.best}}{ Best node order (vector of length p).}
\item{\code{T.best}}{ Corresponding best edges values (vector of length p).}
\item{\code{G.best}}{ Best graph (matrix form).}
\item{\code{f.best.evol}}{ Evolution of the best fitness value across the iterations (if return.level=1).}
\item{\code{P.best.evol}}{ Evolution of the best node order across the iterations (if return.level=1).}
\item{\code{T.best.evol}}{ Evolution of the best edges values across the iterations (if return.level=1).}
\item{\code{fmin.evol}}{ Evolution of the minimal fitness value of the population across the iterations (if return.level=1).}
\item{\code{fmean.evol}}{ Evolution of the averaged fitness value of the population across the iterations (if return.level=1).}
\item{\code{fp10.evol}}{ Evolution of the quantiles of the fitness value across the iterations (if return.level=1).}
\item{\code{fp90.evol}}{ Evolution of the quantiles of the fitness value across the iterations (if return.level=1).}
\item{\code{Shannon.evol}}{ Evolution of the Shannon entropy of the population across the iterations (if return.level=1).}
}
}
\description{
Function to run GADAG, an algorithm that aims at inferring large sparse directed acyclic graphs
based on an observation sample X, by minimizing the penalized negative log-likelihood with a convex program embedded in a genetic algorithm.
}
\details{
This function returns as a primary output \code{G.best}, the adjacency matrix of the inferred graph. This matrix is computed thanks
to its decomposition (\code{P.best}, \code{T.best}).

The values of the inputs \code{n.gen}, \code{max.eval} and \code{pop.size} largely influence the algorithm inference capability,
but also its computational cost. As a rule-of-thumb, we recommend setting \code{pop.size} between 1 to 10 times the number of nodes,
and \code{n.gen} between 10 to 100 times \code{pop.size}. \code{tol.Shannon} may be decreased in case of premature stop. The other
parameters should only be modified with care.
}
\examples{
 #############################################################
 # Loading toy data
 #############################################################
 data(toy_data)
 # toy_data is a list of two matrices corresponding to a "star"
 # DAG (node 1 activates all other nodes):
 # - toy_data$X is a 100x10 design matrix
 # - toy_data$G is the 10x10 adjacency matrix (ground trough)

 #############################################################
 # Running GADAG
 #############################################################
 # Simple run, with only the penalty term specified
 GADAG_results <- GADAG_Run(X=toy_data$X, lambda=0.1)
 print(GADAG_results$G.best) # optimal adjacency matrix graph

 # Expensive run with many evaluations if we refine the
 # termination conditions
 \dontrun{
 n.gen <- 1e10 # we allow a very large number of iterations
 tol.Shannon <- 1e-10 # the entropy of Shannon of the population
                      # has to be very small
 pop.size <- 5*ncol(toy_data$G) # this is usually a good
                                # population size
 max.eval <- n.gen * pop.size # maximal number of nested
                              # evaluation
 GADAG_results <- GADAG_Run(X=toy_data$X, lambda=0.1,
      GADAG.control=list(n.gen=n.gen, tol.Shannon=tol.Shannon,
                         pop.size = pop.size, max.eval=max.eval))
 print(GADAG_results$G.best) # optimal adjacency matrix graph
 }

 # Expensive run if we also increase the population size
 \dontrun{
 pop.size <- 10*ncol(toy_data$G)
 GADAG_results <- GADAG_Run(X=toy_data$X, lambda=0.1,
      GADAG.control=list(pop.size=pop.size))
 print(GADAG_results$G.best) # optimal adjacency matrix graph
 }

 # You can have more information about the evolution of the
 # algorithm by turning return.level on
 \dontrun{
 return.level <- 1
 GADAG_results <- GADAG_Run(X=toy_data$X, lambda=0.1, return.level = return.level)
 print(GADAG_results$f.best.evol) # this shows the evolution of the fitness
                                  # across the iterations
 }
}
\seealso{
\code{\link{GADAG}}, \code{\link{GADAG_Run}}, \code{\link{GADAG_Analyze}}.
}
\author{
\packageAuthor{GADAG}
}
