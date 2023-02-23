//
//  TaskItemExtension.swift
//  TodoListApp
//
//  Created by Peter G Hayes on 22/02/2023.
//

import SwiftUI

extension TaskItem
{
    func isCompleted() -> Bool {
        return completedDate != nil
    }
}
