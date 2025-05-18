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

    let coreDataRepository = CoreDataRepository()

    var homePath = NavigationPath()
    var likesPath = NavigationPath()

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
            case .imageDetail(let cat):
                ImageDetailView(viewModel: ImageDetailViewModel(coreDataRepository: coreDataRepository, mainCat: cat))
        }
    }
}

@main
struct PurrfectPicApp: App {
    private let router = Router()

    var body: some Scene {
        WindowGroup {
            @Bindable var router = router

            TabView {
                Tab("Home", systemImage: "house") {
                    NavigationStack(path: $router.homePath) {
                        HomeView(viewModel: HomeViewModel(coreDataRepository: router.coreDataRepository))
                            .navigationDestination(for: Router.Route.self) { route in
                                router.destination(for: route)
                            }
                    }
                }

                Tab("Likes", systemImage: "heart") {
                    NavigationStack(path: $router.likesPath) {
                        LikesView()
                            .navigationDestination(for: Router.Route.self) { route in
                                router.destination(for: route)
                            }
                    }
                }
            }
            .environment(router)
        }
    }
}
