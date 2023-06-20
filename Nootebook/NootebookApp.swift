//
//  NootebookApp.swift
//  Nootebook
//
//  Created by asd on 19/06/2023.
//

import SwiftUI

@main
struct NootebookApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
