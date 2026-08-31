
Python file
daniebahry@danielbahry:~/ECEN_350_Labs/ECEN350_Labs/Lab01 $ perf stat python3 ./benchmark.py
Checksum: 41667916675000

 Performance counter stats for 'python3 ./benchmark.py':

   228,570,045,009      task-clock:u                     #    0.995 CPUs utilized             
                 0      context-switches:u               #    0.000 /sec                      
                 0      cpu-migrations:u                 #    0.000 /sec                      
             2,442      page-faults:u                    #   10.684 /sec                      
   787,875,862,393      instructions:u                   #    1.93  insn per cycle            
   408,678,762,427      cycles:u                         #    1.788 GHz                       
         2,994,348      branch-misses:u                                                       

     229.693566424 seconds time elapsed

     228.393008000 seconds user
       0.131857000 seconds sys





Daniels C file:
daniebahry@danielbahry:~/ECEN_350_Labs/ECEN350_Labs/Lab01 $ perf stat ./benchmark 
Checksum: 41667916675000

 Performance counter stats for './benchmark':

       525,210,869      task-clock:u                     #    0.997 CPUs utilized             
                 0      context-switches:u               #    0.000 /sec                      
                 0      cpu-migrations:u                 #    0.000 /sec                      
               192      page-faults:u                    #  365.567 /sec                      
     1,564,175,918      instructions:u                   #    1.66  insn per cycle            
       941,787,951      cycles:u                         #    1.793 GHz                       
           103,975      branch-misses:u                                                       

       0.526682015 seconds time elapsed

       0.526975000 seconds user
       0.000000000 seconds sys









Aharons C file:
daniebahry@danielbahry:~/ECEN_350_Labs/ECEN350_Labs/Lab01 $ perf stat ./benchmark 
Checksum: 41667916675000

 Performance counter stats for './benchmark':

         1,805,278      task-clock:u                     #    0.556 CPUs utilized             
                 0      context-switches:u               #    0.000 /sec                      
                 0      cpu-migrations:u                 #    0.000 /sec                      
               191      page-faults:u                    #  105.801 K/sec                     
           600,957      instructions:u                   #    0.62  insn per cycle            
           975,870      cycles:u                         #    0.541 GHz                       
             2,619      branch-misses:u                                                       

       0.003245153 seconds time elapsed

       0.003565000 seconds user
       0.000000000 seconds sys
