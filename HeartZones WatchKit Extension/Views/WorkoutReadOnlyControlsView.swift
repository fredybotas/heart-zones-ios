//
//  WorkoutReadOnlyControlsView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 01/02/2022.
//

import SwiftUI

struct WorkoutReadOnlyControlsView: View {
    weak var controller: HostingControllerReadOnlyWorkoutControlls?

    var body: some View {
        HStack {
            VStack {
                Button {
                    controller?.endReadOnlyMode()
                } label: {
                    Image(systemName: "xmark")
                }
                .padding(8)
                .font(Font.system(size: 25, weight: .regular, design: .default))
                Text("End")
            }
        }
    }
}

struct WorkoutReadOnlyControlsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutReadOnlyControlsView()
    }
}
