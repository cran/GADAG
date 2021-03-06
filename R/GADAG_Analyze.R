##' @title Analyze GADAG results.
##' @description Function to Analyze GADAG results.
##' @param Results Outputs from \code{GADAG_Run()} function.
##' @param G (optional) Adjacency matrix corresponding to the true DAG (pxp matrix).
##' @param X (optional) Design matrix with samples (n) in rows and variables (p) in columns.
##' @param threshold Thresholding value for the edges.
##' @param plot.control A list containing parameters to control the produced graph outputs (\code{return.level} has to be turned to 1 in the main code beforehand):
##' \itemize{
##' \item \code{plot.graph} If TRUE, generates the figures with the actual and estimated graphs,
##' \item \code{plot.evol} If TRUE, generates the figures showing the evolution of the genetic algorithm (fitness value, Shannon entropy and best node ordering),
##' \item \code{plot.png} If TRUE, saves the figures in .png.
##' }
##' @rawNamespace export(GADAG_Analyze)
##' @return A vector containing the scores of precision, recall, number of false positives (FP), false negatives (FN), true positives (TP), true negatives (TN) and mean squared error (only if \code{G} and \code{X} are provided).
##' @author \packageAuthor{GADAG}
##' @details This function returns as primary outputs the performances of the estimation graph procedure
##' in terms of TP, FP, FN, TN, precision and recall, obtained by comparing the estimated
##' graph with the true one (if known and provided).
##' If specified (\code{plot.graph}, \code{plot.evol}), the user can plot both the estimated graph
##' and the true DAG (if known and provided) and the evolution of the algorithm. This generates three figures:
##' the first one represents the evolution of the fitness value (best fitness in red, averaged population fitness and quantiles across the iterations),
##' the second onen, the evolution of the Shannon entropy of each node across the iterations, the third one, the best node ordering (permutation that minimizes the fitness) across the iterations.
##'
##' @examples
##'  #############################################################
##'  # Loading toy data
##'  #############################################################
##'  data(toy_data)
##'  # toy_data is a list of two matrices corresponding to a "star"
##'  # DAG (node 1 activates all other nodes):
##'  # - toy_data$X is a 100x10 design matrix
##'  # - toy_data$G is the 10x10 adjacency matrix (ground trough)
##'
##'  ########################################################
##'  # Evaluating GADAG Results
##'  ########################################################
##'  # simple run, where you only get the precision, recall, number
##'  # of false positives, true positives, false negatives, true negatives
##'  # and mean squared error of the estimated graph
##'
##'  # run GADAG with the predefined parameters
##'  GADAG_results <- GADAG_Run(X=toy_data$X, lambda=0.1)
##'
##'  # analyze the results
##'  GADAG_analysis <- GADAG_Analyze(GADAG_results, G=toy_data$G, X=toy_data$X)
##'  print(GADAG_analysis) # here are the results
##'
##'  # more complex run, where you want to have some details about the procedure
##'  \dontrun{
##'  # run GADAG with return.level set to 1 beforehand
##'  GADAG_results <- GADAG_Run(X=toy_data$X, lambda=0.1,return.level=1)
##'
##'  # print the evolution of the algorithm
##'  plot.evol <- TRUE
##'  GADAG_analysis <- GADAG_Analyze(GADAG_results, G=toy_data$G, X=toy_data$X,
##'           plot.control = list(plot.evol=TRUE))
##'
##'  # in addition, print the estimated and the true graph
##'  plot.graph <- TRUE
##'  GADAG_analysis <- GADAG_Analyze(GADAG_results, G=toy_data$G, X=toy_data$X,
##'           plot.control = list(plot.evol=plot.evol, plot.graph= plot.graph))
##'
##'  # now save the results in .png, but only for the graphs
##'  plot.png <- TRUE
##'  GADAG_analysis <- GADAG_Analyze(GADAG_results, G=toy_data$G, X=toy_data$X,
##'           plot.control = list(plot.graph= plot.graph, plot.png = plot.png))
##'
##'  # in case you don't know the true DAG, you can't really know how good the
##'  # estimation is. You can't compute the precision, recall, MSE but you can
##'  # still plot the estimated graph and see the evolution of the algorithm
##'  plot.graph <- plot.evol <- TRUE
##'  plot.png <- FALSE
##'  GADAG_analysis <- GADAG_Analyze(GADAG_results, X=toy_data$X,
##'           plot.control = list(plot.graph= plot.graph, plot.evol = plot.evol))
##'  }

GADAG_Analyze <- function(Results,G=NULL,X=NULL,threshold=0.1,plot.control=list(plot.graph=FALSE,plot.evol=FALSE,plot.png=FALSE)){

  #############################################################
  # INPUTS:
  # Results: a list generated by GADAG_Run, containing:
  #      f.best: best fitness value
  #      P.best: best individual (node order)
  #      T.best: corresponding best triangular matrix (edges values)
  #      G.best: best graph
  # G: actual G matrix
  # X: matrix of observations (n*p)
  # threshold: thresholding value for the edges
  # plot.graph: if TRUE, generates the figures with the actual and estimated graphs
  # plot.evol: if TRUE, generates the figures showing the evolution of the algorithm (return.level of the main algo has to be = 1)
  # plot.png: if TRUE, saves the figures in .png
  # OUTPUTS
  # A vector containing the scores of precision, recall, FP, FN, TP, TN, MSE
  #############################################################

  p <- dim(Results$G.best)[1]

  if (is.null(plot.control$plot.graph)){
    plot.graph <- FALSE
  } else {
    plot.graph <- plot.control$plot.graph
  }
  if (is.null(plot.control$plot.evol)){
    plot.evol <- FALSE
  } else {
    plot.evol <- plot.control$plot.evol
  }
  if (is.null(plot.control$plot.png)){
    plot.png <- FALSE
  } else {
    plot.png <- plot.control$plot.png
  }

  if (plot.png==TRUE && plot.graph==FALSE && plot.evol==FALSE){
    cat("No graphs are produced. Please turn on plot.graph or plot.evol.")
  }

  if (is.null(G) && plot.graph==FALSE && plot.evol==FALSE){
    cat("Nothing can be computed since you don't know the true DAG.")
  }

   if (is.null(X) && !is.null(G)){
     cat("The mean squared error is not computed since the design matrix X is not provided.")
   }

  if (is.null(G) && plot.graph==TRUE && plot.png==FALSE && plot.evol==FALSE){
    cat("Nothing is computed and only the estimated graph is plotted.")
  }

  if (is.null(G) && plot.graph==TRUE && plot.png==TRUE && plot.evol==FALSE){
    cat("Nothing is computed and only the estimated graph is produced.")
  }

  if (is.null(G) && plot.evol==TRUE && plot.png==FALSE && plot.graph==FALSE){
    cat("Nothing is computed and only the evolution of the algorithm is plotted.")
  }

  if (is.null(G) && plot.evol==TRUE && plot.png==TRUE && plot.graph==FALSE){
    cat("Nothing is computed and only the evolution of the algorithm is produced.")
  }

  if (is.null(G) && plot.evol==TRUE && plot.png==TRUE && plot.graph==TRUE){
    cat("Nothing is computed and only the evolution of the algorithm and the estimated graph are produced.")
  }

   if (is.null(G) && plot.evol==TRUE && plot.png==FALSE && plot.graph==TRUE){
     cat("Nothing is computed and only the evolution of the algorithm and the estimated graph are plotted.")
   }

  G.best <- Results$G.best
  Gbest.bin <- matrix(0,p,p)
  Gbest.bin[(abs(G.best)>0)] <- 1
  if (!is.null(G)){
    # Compute values (FP, FN, TP, TN, MSE)
    G.bin <- G*0
    G.bin[(abs(G)>0)] <-1

    FP <- sum(Gbest.bin-G.bin==1)
    FN <- sum(Gbest.bin-G.bin==-1)
    TP <- sum(Gbest.bin!=0) - FP
    TN <- p*(p-1) - TP - FN - FP
    precision <- TP / ( TP + FP )
    recall    <- TP / ( TP + FN )

    if (!is.null(X)){
      n <- dim(X)[1]
      MSE <- (1/(n*p)) * sum((X-X%*%G.best)^2)
    }
  }

  if (plot.evol){
    if (length(Results)<12){
      cat("You don't have enough results to plot anything. Please turn return.level to 1 in the main algorithm. \n")
    } else {
      if (!is.null(G)){
        Node_highlight <- which(rbind(rowSums(abs(G)>0),colSums(abs(G)>0))==max(rbind(rowSums(abs(G)>0),colSums(abs(G)>0))),arr.ind=TRUE)[,1]
        col <- rep("black", p)
        col[Node_highlight] <- rainbow(length(Node_highlight))
        lwd <- rep(1, p)
        lwd[Node_highlight] <- 2
      } else {
        col <- rep("black",p)
        lwd <- rep(1, p)
        Node_highlight <- 1
      }
      # Fpop, min, mean and quantiles
      ylim=c(min(Results$fmin.evol),max(Results$fp90.evol))
      if (plot.png==TRUE){
        png("FitnessEvolution.png")
        plot(Results$f.best.evol, type="l", main="Cost function", xlab="Generation #", ylab="-logLikelihood", lwd=2, col="red",
          ylim=ylim)
        polygon(x=c(1:length(Results$fp10.evol),rev(1:length(Results$fp10.evol))), y=c(Results$fp10.evol, rev(Results$fp90.evol)), border=NA,col="lightgrey")
        lines(Results$fmean.evol)
        lines(Results$fp10.evol)
        lines(Results$fp90.evol)
        legend("topright", legend=c("Current best", "Population"), col=c("red","black"), lwd=c(2,1))
        dev.off()

        # Shannon
        png("ShannonEvolution.png")
        plot(Results$Shannon.evol[,Node_highlight], type="l", main="Shannon entropy", xlab="Generation #", ylab="Entropy", ylim=c(0, max(Results$Shannon.evol)),
          col=col[1], lwd=lwd[1])
        for (i in 2:p) lines(Results$Shannon.evol[,i], col=col[i], lwd=lwd[i])
        legend("topright",legend=paste0("Node ",Node_highlight),lwd=lwd[Node_highlight], col=col[Node_highlight])
        dev.off()

        # Nodes paths - bestever
        png("BestNodesEvolution.png")
        A <- which(Results$P.best.evol==Node_highlight, arr.ind=TRUE)
        a <- sort(A[,1], index.return=TRUE)$ix
        plot(A[a,1], A[a,2], ylim=c(0,p), type="l", main="Best permutation", xlab="Generation #", ylab="Node path", col=col[1], lwd=lwd[1])
        for (i in 2:p){
          A <- which(Results$P.best.evol==i, arr.ind=TRUE)
          a <- sort(A[,1], index.return=TRUE)$ix
          lines(A[a,1], A[a,2], col=col[i], lwd=lwd[i])
        }
        legend("topright", legend=paste0("Node ",Node_highlight), lwd=lwd[Node_highlight], col=col[Node_highlight])
        dev.off()
      } else {
        par(mfrow=c(1,1))
        plot(Results$f.best.evol, type="l", main="Cost function", xlab="Generation #", ylab="-logLikelihood", lwd=2, col="red",
             ylim=ylim)
        polygon(x=c(1:length(Results$fp10.evol),rev(1:length(Results$fp10.evol))), y=c(Results$fp10.evol, rev(Results$fp90.evol)), border=NA,col="lightgrey")
        lines(Results$fmean.evol)
        lines(Results$fp10.evol)
        lines(Results$fp90.evol)
        legend("topright", legend=c("Current best", "Population"), col=c("red","black"), lwd=c(2,1))

        # Shannon
        plot(Results$Shannon.evol[,Node_highlight], type="l", main="Shannon entropy", xlab="Generation #", ylab="Entropy", ylim=c(0, max(Results$Shannon.evol)),
             col=col[1], lwd=lwd[1])
        for (i in 2:p) lines(Results$Shannon.evol[,i], col=col[i], lwd=lwd[i])
        if (!is.null(G)){
           legend("topright",legend=paste0("Node ",Node_highlight),lwd=lwd[Node_highlight], col=col[Node_highlight])
        }
        # Nodes paths - bestever
        A <- which(Results$P.best.evol==Node_highlight, arr.ind=TRUE)
        a <- sort(A[,1], index.return=TRUE)$ix
        plot(A[a,1], A[a,2], ylim=c(0,p), type="l", main="Best permutation", xlab="Generation #", ylab="Node path", col=col[1], lwd=lwd[1])
        for (i in 2:p){
          A <- which(Results$P.best.evol==i, arr.ind=TRUE)
          a <- sort(A[,1], index.return=TRUE)$ix
          lines(A[a,1], A[a,2], col=col[i], lwd=lwd[i])
        }
        if (!is.null(G)){
          legend("topright", legend=paste0("Node ",Node_highlight), lwd=lwd[Node_highlight], col=col[Node_highlight])
        }
      }
    }
  }

  if (plot.graph) {
    if (!is.null(G)){
      net1 <- graph.adjacency(G.bin)
      lay1 <- layout.kamada.kawai(net1)
    }
    net2 <- graph.adjacency(Gbest.bin)
    if (is.null(G)){
      lay1 <- layout.kamada.kawai(net2)
    }
    if (plot.png==TRUE){
      if (!is.null(G)){
        png("TrueDAG.png")
        plot(net1,main="True DAG", layout=lay1)
        dev.off()
      }
      png("EstimatedDAG.png")
      plot(net2,main="Estimated DAG", layout=lay1)
      dev.off()
    } else {
      if (!is.null(G)){
        par(mfrow=c(1,2))
        plot(net1,main="True DAG", layout=lay1)
      }
      plot(net2,main="Estimated DAG", layout=lay1)
    }
  }

  if (!is.null(G)){
    options(scipen=50)
    if (!is.null(X)){
      val <- c(precision, recall, FP,FN,TP,TN,MSE)
      names(val)<-c("precision", "recall", "FP", "FN", "TP", "TN","MSE")
    } else {
      val <- c(precision, recall, FP,FN,TP,TN)
      names(val)<-c("precision", "recall", "FP", "FN", "TP", "TN")
    }
  } else {
    val=NULL
  }
  return(val)
}
