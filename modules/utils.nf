#!/usr/env/bin nextflow

COL_RESET   = "\u001B[0m"
COL_RED     = "\u001B[31m"
COL_GREEN   = "\u001B[32m"

def errLog(string){
  print(COL_RED + "*"*69 + COL_RESET + "\n")
  log.error(string)
  print(COL_RED + "*"*69 + COL_RESET)
  exit 1
}

def hlpLog(UsageInfo){
  print(COL_GREEN + "*"*69 + COL_RESET + "\n")
  print UsageInfo.join("\n") + "\n"
  print(COL_GREEN + "*"*69 + COL_RESET)
  exit 0
}

def checkFile(fn, type){
  if(fn != false && !new File(fn).exists()){
    errLog("${type}: ${fn} not Found !")
  }
}

