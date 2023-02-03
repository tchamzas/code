f<-function(s,n,sigma){2*((n-1)/2/sigma**2)**((n-1)/2)/gamma(0.5*(n-1))*s**(n-2)*exp(-(n-1)*s**2/2/sigma**2)}
nmin<-4
nmax<-25
nsub<-nmax-nmin+1
result<-rep(0,nsub)
sd<-0.2 #standard deviation of logX from adult data
for (i in 1:nsub) {
  n<-nmin+i-1
  tv<-qt(0.975, n-1)
  sup<-log(1.4)*sqrt(n)/tv
  g<-function(x){f(x,n,sd)}
  poweri<-integrate(g, 0, sup, subdivisions=100)
  result[i]<-poweri[[1]]
}
power<-data.frame(nsub=c(nmin:nmax), power=result)
power
