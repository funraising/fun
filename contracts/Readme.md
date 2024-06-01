Fun Contracts
================

```
                             Locked until end of the campain                                     
                             When campaing is succesfull -> unlocks                              
                             When campaing is unsuccesfull -> can be only returned               
           Created with     ┌─────────────┐                                                      
           max supply       │             │                                                      
        ┌──────────────────►│   FunToken  ├──────────────────────┐                               
        │                   │             │                      │                               
        │                   └─────────────┘                      ▼                               
┌───────┴──────┐                                           ┌───────────┐                         
│              │                                           │           │ Upon succesfull campaing
│  FunFactory  │                                           │  Uniswap  │ all the funds are moved 
│              │                                           │           │ to the pool            
└───────┬──────┘                                           └───────────┘                         
        │                                                        ▲                               
        │                   ┌────────────────┐                   │                               
        │                   │                │                   │                               
        └──────────────────►│   FunContract  ├───────────────────┘                               
                            │                │                                                   
                            └────────────────┘                                                   
                             Bonding curve                                                       
                             Point where funds are collected                                     
                             Point where funds can be withdraw back                              
                             upon failed campain                                                 
```
