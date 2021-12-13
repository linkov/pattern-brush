//
//  UndoManager.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/26/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation


/** Handles undoing and redoing actions on the canvas, as well as user defined actions. */
public class UndoRedoManager {
    
    // MARK: Variables
    
    var undos: [[Int : () -> Any?]]
    
    var redos: [[Int : () -> Any?]]
    
    
    
    // MARK: Initialization
    
    init() {
        self.undos = []
        self.redos = []
    }
    
    
    // MARK: Functions
    
    /** Adds a new action to undos. */
    public func add(onUndo undo: @escaping () -> Any?, onRedo redo: @escaping () -> Any?) {
        // Add two entries to the dictionary, an undo and a redo with the respective indexes.
        undos.append([0: undo, 1: redo])
    }
    
    /** Undo the last event. */
    public func performUndo() -> Any? {
        if undos.isEmpty == true { return nil }
        
        // Get the last item in the stack.
        guard let last = undos.popLast() else { return nil }
        
        // That last item is a function that says how something should be undone. Run the function.
        let val = last[0]?()
        
        // Now take the redo of that function and add it to the redo stack.
        redos.insert(last, at: 0)
        
        return val
    }
    
    /** Redo the last event. */
    public func performRedo() -> Any? {
        if redos.isEmpty == true { return nil }
        
        // Get the last item in the redos.
        let last = redos.removeFirst()
        
        // Run that function to perform the redo.
        let val = last[1]?()
        
        // Make sure you add back the redo to the undo stack.
        undos.append(last)
        
        return val
    }
    
    /** Clears the undos. */
    public func clearUndos() {
        undos.removeAll()
    }
    
    /** Clears the redos. */
    public func clearRedos() {
        redos.removeAll()
    }
    
}
