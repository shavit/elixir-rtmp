package main

import (
  "log"
  "os"
  "os/exec"
)

func main(){
  var err error
  var counter int = 0
  var cmd *exec.Cmd

  // Stream multiple times
  for {
    cmd = exec.Command("./stream.sh")
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr

    err = cmd.Start()
    if err != nil{
      log.Fatal("Error running command: ", err)
    }
    log.Println("---> Starting to stream ", counter)
    err = cmd.Wait()

    // Limit the number of runs
    if counter > 10 {
      log.Printf("---> Finish running %v times\n", counter)
      break
    }
    counter += 1
  }
}
