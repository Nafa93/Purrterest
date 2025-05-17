//
//  PurrfectPicApp.swift
//  PurrfectPic
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 14/05/2025.
//

import SwiftUI

@Observable final class Router {
    enum Route: Hashable {
        case imageDetail(Cat)
    }

    var homePath = NavigationPath()
    var likesPath = NavigationPath()
}

@main
struct PurrfectPicApp: App {
    private var router = Router()
    private var homeViewModel = HomeViewModel()

    var body: some Scene {
        WindowGroup {
            @Bindable var router = router

            TabView {
                Tab {
                    NavigationStack(path: $router.homePath) {
                        HomeView(viewModel: homeViewModel)
                            .navigationDestination(for: Router.Route.self) { route in
                                ImageDetail()
                            }
                    }
                } label: {
                    Image(systemName: "house")
                }

                Tab {
                    NavigationStack(path: $router.likesPath) {
                        LikesView()
                            .navigationDestination(for: Router.Route.self) { route in
                                ImageDetail()
                            }
                    }
                } label: {
                    Image(systemName: "heart")
                }
            }
            .environment(router)
        }
    }
}
