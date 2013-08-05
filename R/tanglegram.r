# Copyright (C) Tal Galili
#
# This file is part of dendextend.
#
# dendextend is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# dendextend is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  http://www.r-project.org/Licenses/
#


# tanglegram.r




# source for this code: http://stackoverflow.com/questions/12456768/duelling-dendrograms-in-r-placing-dendrograms-back-to-back-in-r

tanglegram <- function (...) UseMethod("tanglegram")


tanglegram.default <- function (object, ..., value) stop("no default function for tanglegram-")



# set.seed(23235)
# ss <- sample(1:150, 10 )
# hc1 <- hclust(dist(iris[ss,-5]), "com")
# hc2 <- hclust(dist(iris[ss,-5]), "single")
# dend1 <- as.dendrogram(hc1)
# dend2 <- as.dendrogram(hc2)
# dend1 <- color_branches(dend1, 4)
# dend2 <- color_branches(dend2, 4)
# tanglegram(sort(dend1) , sort(dend2))
# 
# tanglegram(rotate(dend1, labels(dend2) ), dend2, text_cex = 2, lwd = 5)

# abbreviate

# a good example of how massy this can be for THE SAME TREE!
# tanglegram(dend2, sort(dend2))

tanglegram.dendrogram <- function(dendo1,dendo2 , sort = F, 
                                  color_lines, 
                                  lwd = 2.5,
                                  columns_width = c(5,3,5),
                                  ylim_bottom = 1,
                                  margin_top = 3,
                                  margin_bottom = 2.5,
                                  margin_center = 1.8,
                                  margin_shell = 0.5,
                                  left_dendo_mar = c(margin_bottom,margin_shell,margin_top,margin_center),
                                  right_dendo_mar=c(margin_bottom,margin_center,margin_top,margin_shell),
                                  characters_to_trim = NULL,
                                  dLeaf = NULL, # -.3,
                                  dLeaf_left = 0.75 * strwidth("w"),
                                  dLeaf_right = -2.5 * strwidth("w"),
                                  axes = TRUE, 
                                  dendo_type = "r", # can also be "t"
                                  text_cex = 1,
                                  remove_nodePar =F,
                                  main_left = "",
                                  main_right = ""																	 
)
{
   # characters_to_trim = the number of characters to leave after trimming the labels.		
   # remove_nodePar = makes sure that we won't have any dots at the end of leaves
   # Future TODO:
   
   # remove colors from the tips of leaves
   if(remove_nodePar) {
      colLab_0 <- function(n) {
         if(is.leaf(n)) {
            a <- attributes(n)			
            attr(n, "nodePar") <- NULL
         }
         n
      }
      dendo1 <- dendrapply(dendo1, colLab_0)
      dendo2 <- dendrapply(dendo2, colLab_0)
   }
   # sort them for better graph
   if(sort == T) {	# based on the "rotate.dendrogram" function
      dendo1 <- sort(dendo1)
      dendo2 <- sort(dendo2)
   }
   
   
   l <- length(order.dendrogram(dendo1))
   
   # The matrix to draw the arrows:
   ord_arrow <- cbind((1:l)[order(order.dendrogram(dendo1))],(1:l)[order(order.dendrogram(dendo2))]) 
   
   # Set the layout of the plot elements
   layout(matrix(1:3,nrow=1),width=columns_width)
   
   # The first dendrogram:	
   par(mar=left_dendo_mar)
   plot(dendo1,horiz=TRUE, ylim=c(ylim_bottom,l),
        dLeaf = dLeaf_left, type = dendo_type, axes = axes,
        main = main_left
   )
   
   # The arrows:
   # arros colors:
   if(missing(color_lines)) color_lines <- rep("skyblue3", l)
   if(length(color_lines) < l) color_lines <- rep.int(color_lines, l)
   color_lines <- color_lines[ord_arrow[,1]]	
   
   par(mar=c(margin_bottom,0,margin_top,0))
   plot(NA, bty="n",axes=FALSE,xlim=c(0,1), ylim=c(ylim_bottom,l),ylab="",xlab="")
   col_indx <- 0
   apply(ord_arrow,1,
         function(x){
            col_indx <<- col_indx + 1
            arrows(0,x[1],1,x[2],code=3, length=0.05, col= color_lines[col_indx], lwd = lwd)
         }
   )
   
   # And the second dendrogram (to reverse it I reversed the xlim vector:
   par(mar=right_dendo_mar)
   plot(dendo2,horiz=TRUE, xlim=c(0,attr(dendo2,"height")), 
        ylim=c(ylim_bottom,l), 
        dLeaf = dLeaf_right ,
        type = dendo_type, axes = axes,
        main = main_right)
   
}

 tanglegram(dend2, dend1)

# tanglegram(rotate(dend1, labels(dend2) ), dend2, text_cex = 2, lwd = 5)


# tanglegram.hclust <- function(hc1,hc2)

dendobackback <- tanglegram.dendrogram # another name for the same function.
# hclustbackback <- tanglegram.hclust # another name for the same function.




