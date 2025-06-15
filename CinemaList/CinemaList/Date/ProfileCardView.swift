//
//  ProfileCardView.swift
//  CinemaList
//
//  Created by Андрей Сметанин on 15.06.2025.
//

import SwiftUI

struct ProfileCardView: View {
  
  let imageName: String
  let width: CGFloat
  let height: CGFloat
  
  var body: some View {
    Image(imageName)
      .resizable()
      .scaledToFill()
      .frame(width: width, height: height)
      .clipShape(RoundedRectangle(cornerRadius: 32))
  }
}

#Preview {
  ProfileCardView(imageName: "f1", width: 300, height: 533.33)
}
