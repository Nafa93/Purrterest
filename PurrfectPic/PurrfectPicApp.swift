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

    let coreDataManager: CoreDataManager
    let likedCatsRepository: LikedCatsRepository

    var homePath: NavigationPath
    var likesPath: NavigationPath

    init(
        homePath: NavigationPath = NavigationPath(),
        likesPath: NavigationPath = NavigationPath()
    ) {
        self.coreDataManager = CoreDataManager()
        self.likedCatsRepository = LikedCatsRepository(coreDataManager: coreDataManager)
        self.homePath = homePath
        self.likesPath = likesPath
    }

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
            case .imageDetail(let cat):
                ImageDetailView(
                    viewModel: ImageDetailViewModel(
                        likedCatsRepository: likedCatsRepository,
                        mainCat: cat
                    )
                )
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
                        HomeView(viewModel: HomeViewModel(likedCatsRepository: router.likedCatsRepository))
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
