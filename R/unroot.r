#' @title get attributes from the dendrogram's root branches
#' @export
#' @param dend dendrogram object
#' @param the_attr the attribute to get from the branches (for example "height")
#' @param ... passed on to attr
#' @return The attributes of the branches of the dendrogram's root
#' @seealso \link{attr}
#' @examples
#' hc <- hclust(dist(USArrests[2:9,]), "com")
#' dend <- as.dendrogram(hc)
#' 
#' get_branches_attr(dend, "height") # 0.00000 71.96247
#' # plot(dend)
#' str(dend, 2)
get_branches_attr <- function(dend, the_attr,...) {
   if(class(dend) != "dendrogram")
   {
      warning("dend wasn't of class dendrogram (we assumed it did - but make sure everything is o.k.)")
      class(dend) <- "dendrogram"
   }
   sapply(dend, function(x) {attr(x, the_attr,...)})
}



#' @title unroot trees
#' @export
#' @aliases 
#' unroot.default
#' unroot.dendrogram
#' unroot.hclust
#' unroot.phylo
#' @usage
#' unroot(x, ...)
#' 
#' \method{unroot}{dendrogram}(x, branch_becoming_root = 1, new_root_height, ...)
#' 
#' \method{unroot}{hclust}(x, branch_becoming_root = 1, new_root_height, ...)
#' 
#' \method{unroot}{phylo}(x, ...)
#' @param x tree (dendrogram/hclust) object
#' @param branch_becoming_root a numeric choosing the branch of the root which will become the new root (from left to right)
#' @param new_root_height the new height of the branch which will become the new root.
#' @param ... passed on
#' @return An unrooted dendrogram
#' @seealso \link[ape]{unroot} {ape}
#' @examples
#' hc <- hclust(dist(USArrests[2:9,]), "com")
#' dend <- as.dendrogram(hc)
#' 
#' par(mfrow = c(1,3))
#' plot(dend, main = "original tree")
#' plot(unroot(dend , 1), main = "unrooted tree (left branch)")
#' plot(unroot(dend , 2), main = "tree without  (right branch)")
unroot <- function(x, ...) UseMethod("unroot")

#' @export
unroot.default <- function(x,...) stop("object x must be a dendrogram/hclust/phylo object")


#' @S3method unroot dendrogram
unroot.dendrogram <- function(x, branch_becoming_root = 1, new_root_height,...)
{
   if(missing(new_root_height)) new_root_height <- NULL
   
   dend <- x # (since this function is based on dendrograms)
   if(is.leaf(dend[[branch_becoming_root]])) {
      warning("unroot.dendrogram can't have the new root being a leaf.  Please choose another branch to be the root.")
      return(dend)
   }
   new_dend <- list()
   i_new_dend_branch <- 1
   
   # add branches from the new root branch to the new tree
   number_of_branches_in_root <- length(dend[[branch_becoming_root]])
   for(i in seq_len(number_of_branches_in_root))
   {
      new_dend[[i_new_dend_branch]] <- dend[[branch_becoming_root]][[i]]   # add the branches of the branc_becoming_root to the new tree
      i_new_dend_branch <- i_new_dend_branch + 1
   }
   
   # add all other branches of the old tree to the root of the new tree
   number_of_branches_in_dend <- length(dend)
   number_of_branches_in_dend_minus_root <-  number_of_branches_in_dend- 1
   branches_to_add_to_root <- seq_len(number_of_branches_in_dend)[-branch_becoming_root]   # id of branches to add to the root of the new tree
   for(i in seq_len(number_of_branches_in_dend_minus_root))
   {
      new_dend[[i_new_dend_branch]] <- dend[[branches_to_add_to_root]]	# add the branches of the branc_becoming_root to the new tree
      i_new_dend_branch <- i_new_dend_branch + 1
   }
   
   # set the proper attributes of the root of the new tree 
   if(!is.null(new_root_height)){			
      attr(new_dend, "height") <- new_root_height
   } else {
      attr(new_dend, "height") <- attr(dend, "height") + attr(dend[[branch_becoming_root]], "height") 
   }
   attr(new_dend, "members") <- sum(get_branches_attr(new_dend, "members")) # the new members of the root is the sum of the members in all of his branches
   attr(new_dend, "midpoint") <- mean(get_branches_attr(new_dend, "midpoint")) # the new members of the root is the sum of the members in all of his branches
   attr(new_dend, "label") <- "merged root" # might cause problems in the future?
   class(new_dend) <- 'dendrogram'
   new_dend <- stats:::midcache.dendrogram(new_dend) # might through warnings if we have 3 branches (but it will keep the "midpoints" in check 
   
   return(new_dend)
}



#' @S3method unroot hclust
unroot.hclust <- function(x, branch_becoming_root = 1, new_root_height, ...) {
   x_dend <- as.dendrogram(x)
   x_dend_unroot <- unroot(x_dend, branch_becoming_root , new_root_height, ...)
   x_unroot <- as_hclust_fixed(x_dend_unroot, x)  
   
   return(x_unroot)
}


#' @S3method unroot phylo
unroot.phylo <- function(x, ...) ape:::unroot(phy = x)














#' @title Flatten the branches of a dendrogram's root
#' @description
#' The function makes sure the two branches of the root of a dendrogram will have the same height.  The user can choose how to decide which height to use.
#' @export
#' @param dend dendrogram object
#' @param FUN how to choose the new height of both branches (defaults to taking the max between the two)
#' @param new_height overrides FUN, and sets the new height of the two branches manually
#' @param ... passed on (not used)
#' @return A dendrogram with both of the root's branches of the same height
#' @examples
#' hc <- hclust(dist(USArrests[2:9,]), "com")
#' dend <- as.dendrogram(hc)
#' attr(dend[[1]], "height") <- 150 # make the height un-equal
#' 
#' par(mfrow = c(1,2))
#' plot(dend, main = "original tree")
#' plot(flatten.dendrogram(dend), main = "Raised tree")
flatten.dendrogram <- function(dend, FUN = max, new_height,...)
{
   if(missing(new_height)) {
      dend_branches_height <- get_branches_attr(dend, "height")
      new_height <- FUN(dend_branches_height)      
   }
   for(i in seq_len(length(dend))) attr(dend[[i]], "height") <- new_height
   return(dend)
}



#' @title Raise the height of a dendrogram tree
#' @export
#' @param dend dendrogram object
#' @param heiget_to_add how much height to add to all the branches (not leaves) in the dendrogram
#' @param ... passed on (not used)
#' @return A raised dendrogram
#' @examples
#' hc <- hclust(dist(USArrests[2:9,]), "com")
#' dend <- as.dendrogram(hc)
#' 
#' par(mfrow = c(1,2))
#' plot(dend, main = "original tree")
#' plot(raise.dendrogram(dend , 100), main = "Raised tree")
raise.dendrogram <- function(dend, heiget_to_add,...)
{
   # Only if you are not a leaf - then do things
   if(!is.leaf(dend)) 
   {
      # first - move through all the branches and implement this function on them (they will return higher...
      num_of_branches <- length(dend)
      for(i in seq_len(num_of_branches))
      {
         dend[[i]] <- raise.dendrogram(dend[[i]], heiget_to_add)	# go into the tree with recursion...
      }
      # change the height of our current branch
      attr(dend, "height")	<- attr(dend, "height") + heiget_to_add
   }
   return(dend)
}


