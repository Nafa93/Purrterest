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
        case home(String)
    }

    let coreDataManager: CoreDataManager
    let likedCatsRepository: LikedCatsRepository

    var path = NavigationPath()

    init() {
        self.coreDataManager = CoreDataManager()
        self.likedCatsRepository = NetworkLikedCatsRepository(coreDataManager: coreDataManager)
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
            case .home(let tag):
                HomeView(
                    viewModel: HomeViewModel(likedCatsRepository: likedCatsRepository, tag: tag)
                )
        }
    }
}

@main
struct PurrfectPicApp: App {
    private let homeRouter = Router()
    private let likesRouter = Router()

    var body: some Scene {
        WindowGroup {
            @Bindable var homeRouter = homeRouter
            @Bindable var likesRouter = likesRouter

            TabView {
                Tab("Home", systemImage: "house") {
                    NavigationStack(path: $homeRouter.path) {
                        HomeView(viewModel: HomeViewModel(likedCatsRepository: homeRouter.likedCatsRepository))
                            .navigationDestination(for: Router.Route.self) { route in
                                homeRouter.destination(for: route)
                            }
                    }
                    .environment(homeRouter)
                }

                Tab("Likes", systemImage: "heart") {
                    NavigationStack(path: $likesRouter.path) {
                        LikesView(viewModel: LikesViewModel(likedCatsRepository: likesRouter.likedCatsRepository))
                            .navigationDestination(for: Router.Route.self) { route in
                                likesRouter.destination(for: route)
                            }
                    }
                    .environment(likesRouter)
                }
            }
        }
    }
}
