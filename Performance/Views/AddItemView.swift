//
//  AddItemView.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import SwiftUI
import Combine

struct AddItemView: View {
    @EnvironmentObject var errorHandling: ErrorHandling
    @ObservedObject var model = AddItemViewModel()
    @FocusState private var focusedField: Field?

    @Binding var isPresented: Bool
    @Binding var needsReload: PersistanceMode?

    private enum Field {
        case name
        case location
        case hours
        case minutes
        case seconds
    }

    var body: some View {
        VStack {
            TextField("Performance name", text: $model.name)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .name)
            
            TextField("Location", text: $model.location)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .location)
            
            List {
                ForEach(model.locationResults, id: \.self) { location in
                    VStack(alignment: .leading) {
                        Text(location.title)
                        Text(location.subtitle)
                            .font(.system(.caption))
                    }
                    .onTapGesture {
                        self.model.location = location.title
                    }
                }
            }
            .disabled(model.state == .loading)
            
            HStack {
                TextField("0", text: $model.time.hoursString)
                    .frame(width: 50, height: 30, alignment: .center)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .hours)
                    .onReceive(Just(model.time.hoursString)) { _ in
                        model.validateHours()
                    }
                
                Text("h")
                
                TextField("00", text: $model.time.minutesString)
                    .frame(width: 40, height: 30, alignment: .center)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .minutes)
                    .onReceive(Just(model.time.minutesString)) { _ in
                        model.validateMinutes()
                    }
                
                Text("m")
                
                TextField("00.000", text: $model.time.secondsString)
                    .frame(width: 70, height: 30, alignment: .center)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .seconds)
                    .onReceive(Just(model.time.secondsString)) { _ in
                        model.validateSeconds()
                    }
                
                Text("s")
            }
            .padding()
            
            Toggle("Save online", isOn: $model.savingOnline)
                .toggleStyle(.switch)
                .padding(.horizontal)
            
            Button(action: {
                model.save { reloadType, error in
                    if let error = error {
                        errorHandling.handle(error: error)
                    } else {
                        if let needsReload = reloadType {
                            self.isPresented = false
                            self.needsReload = needsReload
                        }
                    }
                }
            }) {
                Spacer()
                if model.state == .loading {
                    ProgressView()
                } else {
                    Text("Button")
                }
                Spacer()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!model.isValid() || model.state == .loading)
        }
        .padding()
        .onSubmit {
            switch self.focusedField {
            case .name:
                self.focusedField = .location
                
            case .location:
                self.focusedField = .hours
                
            default: break
            }
        }
        .navigationBarItems(leading: Button(action: {
            isPresented = false
        }) {
            Text("Done")
        })
    }
    
}
