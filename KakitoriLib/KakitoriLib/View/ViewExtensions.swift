//
//  ViewExtensions.swift
//  KakitoriLib
//
//  Created by Ansel Rognlie on 9/4/22.
//

import Foundation
import SwiftUI

extension View {
    public func bindHeight(to binding: Binding<CGFloat>) -> some View {
        func spacer(with geometry: GeometryProxy) -> some View {
            DispatchQueue.main.async { binding.wrappedValue = geometry.size.height }
            return Spacer()
        }
        return background(GeometryReader(content: spacer))
    }

    public func bindWidth(to binding: Binding<CGFloat>) -> some View {
        func spacer(with geometry: GeometryProxy) -> some View {
            DispatchQueue.main.async { binding.wrappedValue = geometry.size.width }
            return Spacer()
        }
        return background(GeometryReader(content: spacer))
    }
}
