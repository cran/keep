\name{keep}

\alias{karray}
\alias{kOarray}
\alias{keep}
\alias{[.keep}
\alias{as.array.keep}
\alias{as.karray}
\alias{as.kOarray}


\title{Arrays with Better Control over Dimension Dropping}
\description{
Carrying out an array a subset operation in traditional \R will result in
dimensions being dropped when those dimensions have a size of 1. We can
circumvent this behaviour by setting \code{drop=FALSE} but this is an all or
nothing approach and often we require a more refined control over which
dimensions will be dropped. This extension provides the means to better
control dropping behaviour.
}

\usage{
karray(data = NA, dim = length(data), dimnames = NULL)
kOarray(data = NA, dim = length(data), dimnames = NULL, offset = rep(1, length(dim)),
        drop.negative = TRUE)
as.karray(x, ...)
as.kOarray(x, offset = rep(1, length(dim)), drop.negative = TRUE)
keep(index)
\method{as.array}{keep}(x, ...)
}

\arguments{
  \item{data, dim, dimnames, drop}{As in the function \code{array}}
  \item{offset}{Vector of first index values for each extent (defaults to 1s);
                a length-one argument will be silently recycled to the
                appropriate length}
  \item{drop.negative}{Should negative subscripts indicate exclusion?}
  \item{x}{an array or Oarray created with \code{karray} or \code{kOarray} respectively to be subsetted}
  \item{...}{arguments to specify how to subset \code{x}}
  \item{index}{an index or index range in a subsetting operation}
}

\details{
\code{karray} delegates to \code{array} to create an array of given size and
initialisation but adds the S3 class attribute \code{keep} to it. The \code{keep}
S3 class designation is used to direct the dispatch of array subsetting to
the overloaded \code{[} operator method, which in turn provides the added control
over dimension dropping. \code{[} method merely acts as a man in the middle, delegating
the actual subsetting to the handler for the \code{array} S3 class. It then re-attributes
the result with the appropriate dimension attributes. \code{kOarray} behaves
in the same manner except the base S3 class is now \code{Oarray} instead of array.
Note that \code{Oarray} is a package extension that must be installed and loaded
if you wish to make use of \code{kOarray}.

\code{as.karray} casts an \code{array} into a \code{karray} in a similar manner to
\code{as.array}. Likewise \code{as.kOarray} casts an \code{Oarray} into a \code{kOarray}.

Traditional \R will drop dimensions if the size of that dimension is 1. This can
cause major headaches if you wish to write programs in R that use array subsetting
with variable subsetting constraints. Consider for example,

\preformatted{
  M <- array(1:12, c(1,3,4))
  for (i in 1:4) print(dim(M[,,i:4]))
}

which produces the output,

\preformatted{
  [1] 3 4
  [1] 3 3
  [1] 3 2
  NULL
}

The first thing to notice is that the first dimension has been dropped even
though we wouldn't necessarily expect it to as we provided an empty argument
in the subsetting expression. As it has a size of 1 it has been dropped. The
second point to notice is that for the case of \code{i = 4} another dimension
was dropped as \code{4:4} results in a dimension of size 1. Now look at the
same case but with karray instead.

\preformatted{
  M <- karray(1:12, c(1,3,4))
  for (i in 1:4) print(dim(M[,,i:4]))
}

which produces the output,

\preformatted{
  [1] 1 3 4
  [1] 1 3 3
  [1] 1 3 2
  [1] 1 3
}

In this case the first dimension is preserved because for S3 class \code{keep}
an empty indexing argument implies we want to keep the dimension. However, we
still have the issue that if an indexing argument evaluates to 1 then it will
be dropped. However, we can stop this behaviour by making use of the \code{keep()}
function which flags the index dimension to be kept as a side effect of the function
call. In this case,

\preformatted{
  M <- karray(1:12, c(1,3,4))
  for (i in 1:4) print(dim(M[,,keep(i:4)]))
}

produces the output,

\preformatted{
  [1] 1 3 4
  [1] 1 3 3
  [1] 1 3 2
  [1] 1 3 1
}

}

\value{
\code{karray} and \code{as.karray} returns an \code{array} with additional S3 class designation of \code{keep}

\code{kOarray} and \code{as.kOarray} returns an \code{Oarray} with additional S3 class designation of \code{keep}

\code{as.array} returns an \code{array} with the additional S3 class designation removed

\code{keep} returns the index passed in. The function is used for its side effect of marking a dimension for preservation.
}

\note{
Whilst this package references the \code{Oarray} package internally it does not
make this dependency explicit. It does so to avoid having to have the package
installed in cases where you are not going to be using \code{Oarray}. If you
wish to use the \code{Oarray} related support you will need to ensure that the
package is installed and loaded yourself.

If you are going to be using \code{keep} arrays in S4 classes then you can make
reference to the appropriate array type through the package defined class unions
\code{karray} and \code{kOarray}. For example,

\preformatted{
  setClass("MyS4Class", representation(Array1="karray",Array2="karray", ...))
}

}

\author{
Paavo Jumppanen
}

\seealso{
\code{\link{array}},\code{\link[Oarray:Oarray]{Oarray}}
}

\examples{
# Normal R array
M <- array(1:12, c(4,3,1))

# First dimension dropped because it has size 1
print(M[,2,])

# Normal R array but with keep class
M2 <- karray(1:12, c(4,3,1))

# First dimension preserved
print(M2[,2,])

# middle dimension dropped for i=3 because 3:3 has length 1
for (i in 1:3) print(M2[,i:3,])

# use keep() to preserve middle dimension
for (i in 1:3) print(M2[,keep(i:3),])

# indexing through arrays works as normal
ind <- as.matrix(expand.grid(1:4,1:3,1:1))
M2[ind]
}

\keyword{array}
