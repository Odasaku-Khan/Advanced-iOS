import UIKit
import SwiftUI
class SceneDelegate: UIResponder,UIWindowSceneDelegate {
    
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let tapbarController = UITabBarController()
        let mybooks=UIHostingController(rootView:MyBooksView)
        mybooks.tabBarItem=UITabBarItem(title:"My Books",image:UIImage(systemName:"book"),tag:0)
        let addbooks=UIHostingController(rootView:AddBooksView())
        addbooks.tabBarItem=UITabBarItem(title:"Add Books",image:UIImage(systemName:"plus"),tag:1)
        let auth=UIHostingController(rootView:AuthView())
        auth.tabBarItem=UITabBarItem(title:"Auth",image:UIImage(systemName:"person.circle"),tag:2)
        tapbarController.viewControllers=[mybooks,addbooks,auth]
        window=UIWindow(windowScene:windowScene)
        self.window?.rootViewController=tapbarController
        self.window?.makeKeyAndVisible()
    }
}
