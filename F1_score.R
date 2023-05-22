# 20230522  
# [function] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
query_func <- function (query_m, badthre, pred_score, y) {
  # step1: 獲取依造門檻(badthre)，模型預測的結果
  pred_y <- sapply(pred_score > badthre, function(x) if (x){'bad'} else {'good'})
  tmp_df <- data.frame(pred_y=pred_y, y=y) # pred_y    y
  
  # step2: 計算 TP、FP、TN、FN
  if(query_m == "bad") {
    TP <- sum(apply(tmp_df, 1, function(row) all(row == "bad")), na.rm = TRUE)
    FP <- sum(apply(tmp_df, 1, function(row) all(row == list("bad", "good"))), na.rm = TRUE)
    TN <- sum(apply(tmp_df, 1, function(row) all(row == "good")), na.rm = TRUE)
    FN <- sum(apply(tmp_df, 1, function(row) all(row == list("good", "bad"))), na.rm = TRUE)
  }
  else if (query_m == "good") {
########
    TP <- sum(apply(tmp_df, 1, function(row) all(row == "good")), na.rm = TRUE)
    FP <- sum(apply(tmp_df, 1, function(row) all(row == list("good", "bad"))), na.rm = TRUE)
    TN <- sum(apply(tmp_df, 1, function(row) all(row == "bad")), na.rm = TRUE)
    FN <- sum(apply(tmp_df, 1, function(row) all(row == list("bad", "good"))), na.rm = TRUE)
  } else {
    stop(paste("ERROR: unknown query function", query_m))
  }
  
  # step3: 計算評估指標
  sensitivity <- TP/(TP+FN) # recall
  specificity <- TN/(TN+FP)#### 
  precision <- TP/(TP+FP)#### 
  
  ## F1 score
  #F1 <- (2*TP)/(2*TP+FP+FN)########
  F1 <- 2*precision*sensitivity/(precision+sensitivity) 
  ## log likelihood
  if (query_m == 'bad'){
    logLH <- sum(
      ifelse(y==query_m,
             log(pred_score),
             log(1-pred_score))
    )    
  } else {
    logLH <- sum(
		########
		ifelse(y==query_m,
		       log(1-pred_score),
		       log(pred_score)))
  }
  # LOG LIKELIHOOD
  # likeli_model <- sum(ifelse(spamTest$spam=='spam', log(spamTest$pred), log(1-spamTest$pred)))
  # likeli_model/dim(spamTest)[[1]]
  ## pseudo R-squared (直接看 query_m 的機率，機率不用反過來)
  pNull <- sum(ifelse(y==query_m,1,0))/length(y)
  logLH_Null <- sum(ifelse(y==query_m,log(pNull),log(1-pNull)))
  # Computing the null model’s log likelihood
  # pNull <- sum(ifelse(spamTest$spam=='spam',1,0))/dim(spamTest)[[1]]
  # likeli_nullModel <- sum(ifelse(spamTest$spam=='spam',1,0))*log(pNull) + sum(ifelse(spamTest$spam=='spam',0,1))*log(1-pNull)           
   ##  sum(ifelse(y==query_m,1,0))*log(pNull) +
   ## sum(ifelse(y==query_m,0,1))*log(1-pNull)
  deviance <- (-2)*logLH
  deviance_Null <- (-2)*logLH_Null #######
  pseudo_RS <- 1-(deviance/deviance_Null)########
###>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
  
  
  
  # calcualte pseudo R-squared
  # S <- 0
  # 1 - (-2*(likeli_model-S))/(-2*(likeli_nullModel-S))
  #0.56
  
###>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  
  
   
  return(list(
          sensitivity=sensitivity,
          specificity=specificity,
          precision=precision,
          F1score=F1,
          loglikelihood=logLH,
          pseudo_RS=pseudo_RS
              ))
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# read parameters >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("USAGE: Rscript hw2_yourID.R --target male|female --input file1 file2 ... filen --output out.csv", call.=FALSE)
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# parse parameters >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
query_m <- NA
files <- NA
out_f <- NA
badthre <- NA

i<-1
while (i < length(args)) {
  if (args[i] == "--target") {
    query_m<-args[i+1]
    i <- i+1
  } else if (args[i] == "--input") {
    j <- grep("-", c(args[(i+1):length(args)], "-"))[1]
    files <- args[(i+1):(i+j-1)]
    i <- i+j-1
  } else if (args[i] == "--output") {
    out_f <- args[i+1]
    i <- i+1
  } else if (args[i] == "--badthre") {
    badthre <- args[i+1]
    i <- i+1
  } else {
    stop(paste("Unknown flag", args[i]), call.=FALSE)
  }
  i<-i+1
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#stop("missing flag", call.=FALSE)

# check parameters >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if (is.na(query_m)) {
  stop("Missing required parameters '--target'", call.=FALSE)
}
if (any(is.na(files))) {
# stop("Missing required parameters '--input'", call.=FALSE)
  stop("missing flag", call.=FALSE)
}
if (is.na(badthre)) {
  stop("Missing required parameters '--badthre'", call.=FALSE)
}

for (f in files) {
  if (!file.exists(f)) {
    stop(paste("Input path does't exist!!", f), call.=FALSE)
  }
}

if (is.na(out_f)) {
  msg <- sprintf("Unable to identify '--output' -> '%s' ", out_f)
  new_out_path <- gsub(basename(files[[1]]), "", files[[1]])
  
  for (f in files) {
    new_out_path <- paste(new_out_path, 
                          "_", 
                          gsub(".csv", "", basename(f)), 
                          sep="")
  }
  
  out_f <- paste(new_out_path, "_output.csv", sep="")
  out_f <- gsub("/_", "/", out_f)
  msg2 <- sprintf("\n'--output' is automatically converted to -> '%s' ", out_f)
  message(msg, msg2)
}


dir.create(basename(dirname(out_f)), recursive = TRUE, showWarnings = FALSE)

message("\n[PROCESS]")
message(paste("query mode    :", query_m))
message(paste("bad threshold :", badthre))
message(paste("output file   :", out_f))

for (fid in seq_along(files)) {
  message(paste("files", fid, "      :", files[fid]))
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# read files & calculate the score >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
name_ls <- c()
sensitivity_ls <- c()
specificity_ls <- c()
F1score_ls <- c()
loglikelihood_ls <- c()
pseudo_RS_ls <- c()

for(file in files) {
  name <- gsub(".csv", "", basename(file))
  df <- read.table(file, header=T,sep=",",as.is=T)
  if (!any(match(names(df), "reference"))) {
    stop("Missing field 'reference'", call.=FALSE)
  } else if (!any(match(names(df), "pred.score"))) {
    stop("Missing field 'pred.score'", call.=FALSE)
  } else {
    message(sprintf("\n\nloading file -> '%s'", file))
    result <- query_func(
      query_m = query_m, 
      badthre = badthre, ########, 
      pred_score = df$pred.score, ########,
      y = df$reference ########
    )
    sensitivity_ls <- c(sensitivity_ls, round(result$sensitivity, 2))
    specificity_ls <- c(specificity_ls, round(result$specificity, 2))########
    F1score_ls <- c(F1score_ls, round(result$F1score, 2))########
    loglikelihood_ls <- c(loglikelihood_ls, round(result$loglikelihood, 2))########
    pseudo_RS_ls <- c(pseudo_RS_ls, round(result$pseudo_RS, 2))########
    name_ls <- c(name_ls, name)########
  }
}

#View(name_ls)
out_data <- data.frame(
                method = name_ls,
                sensitivity = sensitivity_ls,
                specificity = specificity_ls,
                F1 = F1score_ls,
                logLikelihood = loglikelihood_ls,########,
                pseudoRsquared = pseudo_RS_ls,########,
                stringsAsFactors = F)
#View(out_data )
index <- sapply(out_data[,c("sensitivity", "specificity", "F1", "logLikelihood", "pseudoRsquared")],
               which.max)

# output file >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
out_data<-rbind(out_data,c('BEST', name_ls[index]))
message("\n[Result]")
print(out_data)
write.csv(out_data, out_f, row.names = FALSE, quote = FALSE)
message("\nSuccessfully output result!!!")



