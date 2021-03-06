scalingGrad1d <- function(x, knots, plot = FALSE) {
    
    n <- length(x)
    nKnots <- length(knots)
		
    if (nKnots == 1) return(matrix(0, nrow = n, ncol = nKnots))

    if ( any(x < knots[1]) | any(x > knots[nKnots]) )
      stop("'x' values must be inside the knots")
	
    ind <- order(x)
    xsorted <- x[ind]
	
## BUG fix for versions > 1.2. 'rightmost.closed'
## must be set to TRUE
    inter <- findInterval(x = xsorted, vec = knots,
                          rightmost.closed = TRUE)
    inter <- factor(inter, levels = 1:(nKnots-1))
    
## iCuts is of length nKnots
## the first and last element of 'iCuts' are 0 and  n
    iCuts <- as.numeric(tapply(xsorted, inter, length))
    iCuts[is.na(iCuts)] <- 0
    iCuts <- c(0, cumsum(iCuts))
    grad <- rep(0, n*nKnots)
    
## cat("Calling C\n")
    res <- .C(gradScale,
              n = as.integer(n),
              nKnots = as.integer(nKnots),
              iCuts = as.integer(iCuts),  
              x = as.double(xsorted), 
              knots = as.double(knots),
              grad = as.double(grad))
	
## CAUTION here: the gradients are for SORTED x values
## they must be put back in the original order.
    grad <- matrix(res$grad, nrow = n, ncol = nKnots)
    newgrad <- matrix(NA, nrow = n, ncol = nKnots)
    newgrad[ind, ] <- grad
    
    if (plot) {
## TODOto plot the hat functions??? 
		matplot(xsorted, grad, type ="l",
				main = "Gradients for affine scaling (quadratic splines)")
		abline(v = knots)
## eta[ell] <- 0
    }
	
	return(newgrad)    
    
}

scalingGrad <- function(X, knots, k) {
  scalingGrad1d(X[,k], knots[[k]])  
}

