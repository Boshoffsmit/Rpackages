tableNominal2 <- function (vars, weights = NA, subset = NA, group = NA, miss.cat = NA,
    print.pval = c("none", "fisher", "chi2"), pval.bound = 10^-4,
    fisher.B = 2000, vertical = TRUE, cap = "", lab = "", col.tit.font = c("bf",
        "", "sf", "it", "rm"), font.size = "tiny", longtable = TRUE,
    nams = NA, cumsum = TRUE, ...)
{
    print.pval <- match.arg(print.pval)
    if (is.data.frame(vars) == TRUE) {
        tmp <- vars
        vars <- list()
        for (i in 1:ncol(tmp)) {
            vars[[i]] <- tmp[, i]
        }
        nams <- colnames(tmp)
    }
    n.var <- length(nams)
    if (identical(subset, NA) == FALSE) {
        if (identical(group, NA) == FALSE) {
            group <- group[subset]
        }
        if (identical(weights, NA) == FALSE) {
            weights <- weights[subset]
        }
        for (i in 1:n.var) {
            vars[[i]] <- vars[[i]][subset]
        }
    }
    vert.lin <- "|"
    if (vertical == FALSE) {
        vert.lin <- ""
    }
    for (i in 1:length(nams)) {
        nams[i] <- gsub("_", "\\\\_", as.character(nams[i]))
    }
    if (max(is.na(miss.cat)) == 0) {
        for (i in miss.cat) {
            vars[[i]] <- NAtoCategory(vars[[i]], label = "missing")
        }
    }
    if (identical(group, NA) == TRUE) {
        group <- rep(1, length(vars[[1]]))
    }
    if (identical(weights, NA) == TRUE) {
        weights2 <- 1
    }
    if (identical(weights, NA) == FALSE) {
        weights2 <- weights
    }
    for (i in 1:n.var) {
        vars[[i]][vars[[i]] == "NA"] <- NA
        vars[[i]] <- rep(vars[[i]], times = weights2)
    }
    group <- rep(group, times = weights2)
    vars <- lapply(vars, as.factor)
    group <- as.factor(group)
    ns.level <- unlist(lapply(lapply(vars, levels), length))
    n.group <- length(levels(group))
    cumsum <- as.logical(cumsum)
    stopifnot(identical(length(cumsum), 1L))
    nColPerGroup <- 2L + as.integer(cumsum)
    out <- matrix(NA, ncol = 2 + nColPerGroup * (n.group + 1),
        nrow = (sum(ns.level) + n.var))
    out <- data.frame(out)
    for (i in 1:n.var) {
        ind <- max(cumsum(ns.level[1:i])) - ns.level[i] + 1:(ns.level[i] +
            1) + (i - 1)
        splits <- split(vars[[i]], group)
        for (g in 1:n.group) {
            tmp <- splits[[g]]
            tmp <- tmp[is.na(tmp) == FALSE]
            if (sum(is.na(tmp)) > 0) {
                excl <- NULL
            }
            else {
                excl <- NA
            }
            tab <- table(tmp, exclude = excl)
            tab.s <- round(100 * tab/sum(tab), 2)
            out[ind, 2 + nColPerGroup * (g - 1) + 1] <- c(tab,
                sum(tab))
            out[ind, 2 + nColPerGroup * (g - 1) + 2] <- c(tab.s,
                sum(tab.s))
            if (cumsum) {
                out[ind, 2 + nColPerGroup * (g - 1) + 3] <- c(cumsum(tab.s),
                  NA)
            }
        }
        out[ind[1], 1] <- nams[[i]]
        out[ind, 2] <- c(levels(vars[[i]]), "all")
        tab2 <- table(vars[[i]])
        tab2.s <- round(100 * tab2/sum(tab2), 2)
        out[ind, 2 + nColPerGroup * n.group + 1] <- c(tab2, sum(tab2))
        out[ind, 2 + nColPerGroup * n.group + 2] <- c(tab2.s,
            sum(tab2.s))
        if (cumsum) {
            out[ind, 2 + nColPerGroup * n.group + 3] <- c(cumsum(tab2.s),
                NA)
        }
        v1 <- vars[[i]]
        g1 <- as.character(group)
        indNA <- (is.na(g1) == FALSE) & (g1 != "NA") & (is.na(v1) ==
            FALSE) & (v1 != "NA")
        v2 <- as.character(v1[indNA])
        g2 <- g1[indNA]
        ind1 <- length(unique(g2)) > 1
        ind2 <- print.pval %in% c("fisher", "chi2")
        ind3 <- length(unique(v2)) > 1
        splits2 <- split(v2, g2)
        ind4 <- 1 - max(unlist(lapply(lapply(splits2, is.na),
            sum)) == unlist(lapply(lapply(splits2, is.na), length)))
        if (ind1 * ind2 * ind3 * ind4 == 1) {
            if (print.pval == "fisher") {
                pval <- if (fisher.B == Inf)
                  fisher.test(v2, g2, simulate.p.value = FALSE)$p.value
                else fisher.test(v2, g2, simulate.p.value = TRUE,
                  B = fisher.B)$p.value
            }
            if (print.pval == "chi2") {
                pval <- chisq.test(v2, g2, correct = TRUE)$p.value
            }
            out[max(ind), 1] <- paste("$p", formatPval(pval,
                includeEquality = TRUE, eps = pval.bound), "$",
                sep = "")
        }
    }
    col.tit <- if (cumsum) {
        c("n", "\\%", "\\sum \\%")
    }
    else {
        c("n", "\\%")
    }
    col.tit.font <- match.arg(col.tit.font)
    fonts <- getFonts(col.tit.font)
    digits <- if (cumsum) {
        c(0, 1, 1)
    }
    else {
        c(0, 1)
    }
    groupAlign <- paste(rep("r", nColPerGroup), collapse = "")
    al <- paste("lll", vert.lin, groupAlign, sep = "")
    tmp <- cumsum(ns.level + 1)
    hlines <- sort(c(0, tmp - 1, rep(tmp, each = 2)))
    tab.env <- "longtable"
    float <- FALSE
    if (identical(longtable, FALSE)) {
        tab.env <- "tabular"
        float <- TRUE
    }
    if (n.group > 1) {
    	zz <- rep(c(levels(group), "all"), each = nColPerGroup)
    	zz[-match(unique(zz), zz)] <- ""
    	zz = toupper(sapply(zz, substr, start=1, stop=4))
        dimnames(out)[[2]] <- c(fonts$text("Variable"), fonts$text("Levels"),
            fonts$math(paste(col.tit, "_{\\mathrm{", zz, "}}", sep = "")))
        for (i in 1:n.group) {
            al <- paste(al, vert.lin, groupAlign, sep = "")
        }
        out[length(out[,1]),2] <- out[length(out[,1]),1]

        xtab1 <- xtable::xtable(out, digits = c(rep(0, 3), rep(digits,
            n.group + 1)), align = al, caption = cap, label = lab)
        xtab2 <- print(xtab1, include.rownames = FALSE, floating = float,
            type = "latex", hline.after = hlines, size = font.size,
            sanitize.text.function = function(x) {
                gsub("_", " ", x)
            }, tabular.environment = tab.env, ...)
    }
    if (n.group == 1) {
        out <- if (cumsum) {
            out[, 1:5]
        }
        else {
            out[, 1:4]
        }
        dimnames(out)[[2]] <- c(fonts$text("Variable"), fonts$text("Levels"),
            fonts$math(col.tit))
        out[length(out[,1]),2] <- out[length(out[,1]),1]
        xtab1 <- xtable::xtable(out[-1], digits = c(rep(0, 3), digits)[-1],
            align = substring(al, 2, nchar(al)), caption = cap, label = lab)
        xtab2 <- print(xtab1, include.rownames = FALSE, floating = float,
            type = "latex", hline.after = hlines, size = font.size,
            sanitize.text.function = function(x) {
                gsub("_", " ", x)
            }, tabular.environment = tab.env, ...)
    }
}