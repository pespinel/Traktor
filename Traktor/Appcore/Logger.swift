//
//  Logger.swift
//  Traktor
//
//  Created by Pablo on 19/06/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import SwiftyBeaver

// Emojis for logs
let authLog = "🔒"
let screenLog = "🔵"
let errorLog = "❌"

func configureLogger(){
    
    // Configure logger destinations
    let console = ConsoleDestination()
    let file = FileDestination()
    
    // Timestamp for console logs
    console.format = "$DHH:mm:ss$d $L $M"
    
    // Add destinations
    logger.addDestination(console)
    logger.addDestination(file)
    
}
