//
//  CatCardViewModel.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 17/05/2025.
//

import SwiftUI

struct CatCardView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var viewModel: CatCardViewModel
    private var onPictureTapped: (() -> Void)?
    private var onLikeTapped: (() -> Void)?

    init(
        viewModel: CatCardViewModel,
        onPictureTapped: (() -> Void)? = nil,
        onLikeTapped: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onPictureTapped = onPictureTapped
        self.onLikeTapped = onLikeTapped
    }

    var body: some View {
        Group {
            if let image = viewModel.cat.image {
                ZStack(alignment: .bottomTrailing) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .clipped()
                        .onTapGesture {
                            onPictureTapped?()
                        }

                    Button {
                        viewModel.upsertToCoreData()
                        onLikeTapped?()
                    } label: {
                        Image(systemName: viewModel.heartImageName)
                            .foregroundStyle(viewModel.heartImageColor)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white)
                            )
                    }
                    .padding([.trailing, .bottom], 8)
                }
            } else {
                PlaceholderView()
            }
        }
        .onAppear {
            viewModel.fetchFromCoreData()
        }
    }
}
