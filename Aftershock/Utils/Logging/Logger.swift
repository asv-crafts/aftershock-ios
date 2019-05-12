//
//  Logger.swift
//  Aftershock
//
//  Created by Anatoly Vdovichev on 20/04/2019.
//  Copyright © 2019 ASVCorp. All rights reserved.
//

import Foundation

/// A singleton class for logging purposes
public class Logger {

    private static let CAPACITY = 100

    /// Log data storage
    private var data: Queue<LogMessage>

    /// Queue for making Logger thread-safe
    private let accessQueue = DispatchQueue(label: "SynchronizedLoggerAccess")
    
    /// Instance of the Logger
    static let instance = Logger()

    private init() {
        data = Queue()
    }

    /// count of messages in the log
    public var count: Int {
        return data.count
    }

    /// Put a message to the log
    public func log(message: String) {
        accessQueue.async {
            // put message to storage //
            self.data.enqueue(LogMessage(date: Date(),
                                    message: message))

            // drop old messages keeping amount of data within defined capacity
            while self.data.count > Logger.CAPACITY {
                _ = self.data.dequeue()
            }

            // send notification that log has been changed //
            NotificationHelper
                .sendNotification(keyword: NotificationHelper.Keyword.log)
        }
    }

    /// Get a message from the log using message index
    public func getMessage(index: Int) -> LogMessage? {
        var result: LogMessage?
        accessQueue.sync {
            result = data[index]
        }
        return result
    }
}
