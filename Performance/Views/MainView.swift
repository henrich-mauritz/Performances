//
//  MainView.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var errorHandling: ErrorHandling
    @ObservedObject var model = MainViewModel()
    
    @State var showingAddItem = false
    @State var needsReload: PersistanceMode?
    
    var body: some View {
        NavigationView {
            switch model.state {
            case .idle:
                Color.clear.onAppear(perform: {
                    model.load(.all, true) { error in
                        errorHandling.handle(error: error)
                    }
                })
            case .loading, .loaded:
                VStack {
                    Group {
                        Picker(selection: $model.persistanceMode, label: Text("Persistance mode")) {
                            ForEach(PersistanceMode.allCases, content: { mode in
                                Text(mode.rawValue.capitalized)
                            })
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                    ZStack {
                        Form {
                            ForEach(model.performances) { p in
                                PerformanceNavigationRow(performance: p)
                            }
                            .onDelete(perform: { offsets in
                                withAnimation {
                                    offsets.map { model.performances[$0] }.forEach { performance in
                                        model.delete(performance: performance) { error in
                                            if let error = error {
                                                errorHandling.handle(error: error)
                                            }
                                        }
                                    }
                                }
                            })
                        }
                        .refreshable(action: {
                            withAnimation {
                                model.load(model.persistanceMode, false) { error in
                                    errorHandling.handle(error: error)
                                }
                            }
                        })
                        if model.state == .loading {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Performances").font(.headline)
                    }
                    ToolbarItem {
                        Button(action: {
                            showingAddItem.toggle()
                        }, label: {
                            Label("Add Item", systemImage: "plus")
                        })
                            .sheet(isPresented: $showingAddItem, onDismiss: {
                                if let persistanceMode = needsReload {
                                    model.load(persistanceMode, true) { error in
                                        errorHandling.handle(error: error)
                                    }
                                }
                            }) {
                                NavigationView {
                                    AddItemView(isPresented: $showingAddItem,
                                                needsReload: $needsReload)
                                }
                            }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
