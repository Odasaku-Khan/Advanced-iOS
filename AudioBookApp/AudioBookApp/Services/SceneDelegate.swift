import UIKit
import SwiftUI
import CoreData
class SceneDelegate: UIResponder,UIWindowSceneDelegate {
    
    var window: UIWindow?
    let persistenceController = PersistenceController.shared
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let tabBarController = UITabBarController()
        let session=UserSession()
        
        let myBooksView = MyBooksView()
            .environmentObject(session)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        let myBooksHostingController = UIHostingController(rootView: myBooksView)
        let myBooksNav = UINavigationController(rootViewController: myBooksHostingController)
        myBooksNav.tabBarItem = UITabBarItem(title: "My Books", image: UIImage(systemName: "book"), tag: 0)
        
        let authView=AuthView()
            .environmentObject(session)
            .environment(\.managedObjectContext,persistenceController.container.viewContext)
        let authHosting=UIHostingController(rootView: authView)
        let authNav=UINavigationController(rootViewController: authHosting)
        authNav.tabBarItem=UITabBarItem(title: "Auth", image: UIImage(systemName: "person.circle"), tag: 1)
        
        tabBarController.viewControllers = [myBooksNav,authNav]
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
}
