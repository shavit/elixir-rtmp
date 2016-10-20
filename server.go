package main

import (
  "log"
  "babylon/rtmp"
  "runtime"
)

func main(){
  var err error
  var port string = ":3001"

  runtime.GOMAXPROCS(runtime.NumCPU())

  err = rtmp.ListenAndServe(port)
  if err != nil {
    log.Fatal("Error: Cannot start server. ", err)
  }

  log.Println("---> Starting server")
  // Block
  select {}
}
