args = commandArgs()
basename = sub(".R$", "", sub("^--file=(.*/)?", "", args[grep("^--file=", args)]))
if (length(basename) != 0)
    pdf(file=paste0(basename, "_tmp.pdf"), colormodel="gray", width=7, height=3)
par(family="Palatino")
par(mgp=c(2,0.8,0)) # title and axis margins. default: c(3,1,0)
par(mar=c(3,3,2,2)+0.1) # bottom, left, top, right margins. default: c(5,4,4,2)+0.1

# CI = sapply(0:10, function(x) binom.test(x,10)$conf.int)
binomCI = function(n, y) {
    a = y + 0.5
    b = n - y + 0.5
    if (y == 0) {
        qbeta(c(0,0.95), a, b)
    } else if (y == n) {
        qbeta(c(0.05,1), a, b)
    } else {
        qbeta(c(0.025,0.975), a, b)
    }
}
CCI = sapply(0:10, function(y) binomCI(10,y))
f = function(x) {
    p = dbinom(0:10, 10, x)
    sum(p * (CCI[1,] <= x & x <= CCI[2,]))
}
vf = Vectorize(f)
pb = function(x) (2/pi)*asin(sqrt(x))
qb = function(z) (sin(pi*z/2))^2
curve(pb(vf(qb(x))), n=10001, xlab="", ylab="", xaxt="n", yaxt="n", ylim=c(0.72,1))
abline(h=pb(0.95), lty=3)
axis(1, at=pb((0:10)/10), labels=(0:10)/10)
axis(2, at=pb(seq(0.85,1,0.05)), labels=seq(0.85,1,0.05), las=1)

dev.off()
embedFonts(paste0(basename, "_tmp.pdf"), outfile=paste0(basename, ".pdf"),
           options="-c \"<</NeverEmbed []>> setdistillerparams\" -f ")
